// The HTTP listener and TinyFish transport are external boundaries. Keep the
// real request handler, validation and result mapping in every test.
const originalServe = Deno.serve;
Deno.serve = (() => undefined) as unknown as typeof Deno.serve;
const { searchProducts } = await import("./index.ts");
Deno.serve = originalServe;

function assert(condition: unknown, message = "Assertion failed"): asserts condition {
  if (!condition) throw new Error(message);
}

function equal(actual: unknown, expected: unknown) {
  assert(JSON.stringify(actual) === JSON.stringify(expected),
    `Expected ${JSON.stringify(expected)}, received ${JSON.stringify(actual)}`);
}

function request(body: unknown, ip = crypto.randomUUID()): Request {
  return new Request("https://project.example/functions/v1/search-products", {
    method: "POST",
    headers: { "Content-Type": "application/json", "x-forwarded-for": ip },
    body: JSON.stringify(body),
  });
}

async function withProvider(
  provider: typeof fetch,
  run: () => Promise<void>,
) {
  const previousKey = Deno.env.get("TINYFISH_API_KEY");
  const previousFetch = globalThis.fetch;
  Deno.env.set("TINYFISH_API_KEY", "unit-test-placeholder");
  globalThis.fetch = provider;
  try { await run(); } finally {
    globalThis.fetch = previousFetch;
    if (previousKey === undefined) Deno.env.delete("TINYFISH_API_KEY");
    else Deno.env.set("TINYFISH_API_KEY", previousKey);
  }
}

Deno.test("CORS preflight succeeds without reading a provider key", async () => {
  const response = await searchProducts(new Request("https://project.example", { method: "OPTIONS" }));
  equal(response.status, 200);
  equal(response.headers.get("Access-Control-Allow-Methods"), "POST, OPTIONS");
  await response.text();
});

Deno.test("GET is rejected with a method error", async () => {
  const response = await searchProducts(new Request("https://project.example"));
  equal(response.status, 405);
  assert((await response.json()).error);
});

Deno.test("malformed JSON is a client error", async () => {
  const response = await searchProducts(new Request("https://project.example", { method: "POST", body: "{" }));
  equal(response.status, 400);
  assert((await response.json()).error);
});

Deno.test("query type and length are validated before transport", async () => {
  for (const query of [undefined, null, 42, "", " ", "a", "x".repeat(201)]) {
    const response = await searchProducts(request({ query }));
    equal(response.status, 400);
    await response.json();
  }
});

Deno.test("missing hosted secret returns an explicit configuration error", async () => {
  const previousKey = Deno.env.get("TINYFISH_API_KEY");
  Deno.env.delete("TINYFISH_API_KEY");
  try {
    const response = await searchProducts(request({ query: "Nintendo Switch" }));
    equal(response.status, 503);
    equal((await response.json()).code, "TINYFISH_NOT_CONFIGURED");
  } finally {
    if (previousKey !== undefined) Deno.env.set("TINYFISH_API_KEY", previousKey);
  }
});

Deno.test("results retain real sources, omit invented prices and are limited to ten", async () => {
  await withProvider(async (input) => {
    const url = new URL(String(input));
    equal(url.origin, "https://api.search.tinyfish.ai");
    equal(url.searchParams.get("query"), "Switch OLED");
    return Response.json({ results: Array.from({ length: 12 }, (_, index) => ({
      title: `Switch ${index}`, url: `https://www.store.example/product/${index}`,
      snippet: "Oferta con enlace de origen",
    })) });
  }, async () => {
    const response = await searchProducts(request({ query: "  Switch OLED  " }));
    equal(response.status, 200);
    const payload = await response.json();
    equal(payload.query, "Switch OLED");
    equal(payload.offers.length, 10);
    equal(payload.offers[0].store, "store.example");
    equal(payload.offers[0].sourceUrl, "https://www.store.example/product/0");
    equal(payload.offers[0].price, "Ver en fuente");
    equal(payload.offers[0].isBestValue, false);
    assert(Number.isFinite(Date.parse(payload.searchedAt)));
  });
});

Deno.test("non HTTP links never become an actionable source", async () => {
  await withProvider(async () => Response.json({ results: [
    { title: "Unsafe source", url: "javascript:alert(1)" },
  ] }), async () => {
    const response = await searchProducts(request({ query: "Switch" }));
    equal(response.status, 200);
    equal((await response.json()).offers[0].sourceUrl, "");
  });
});

Deno.test("malformed result entries do not hide valid product sources", async () => {
  await withProvider(async () => Response.json({ results: [
    null, 42, "invalid", [], { title: "Switch OLED", url: "https://store.example/switch" },
  ] }), async () => {
    const response = await searchProducts(request({ query: "Switch" }));
    equal(response.status, 200);
    const offers = (await response.json()).offers;
    equal(offers.length, 1);
    equal(offers[0].productName, "Switch OLED");
  });
});

Deno.test("upstream failures do not expose provider credentials or body", async () => {
  await withProvider(async () => new Response("Private provider detail", { status: 401 }), async () => {
    const response = await searchProducts(request({ query: "Switch" }));
    equal(response.status, 502);
    const body = await response.text();
    assert(!body.includes("unit-test-placeholder"));
    assert(!body.includes("Private provider detail"));
  });
});

Deno.test("network failure becomes a controlled gateway error", async () => {
  await withProvider(async () => { throw new TypeError("Connection refused in test"); }, async () => {
    const response = await searchProducts(request({ query: "Switch" }));
    equal(response.status, 502);
    assert((await response.json()).error);
  });
});

Deno.test("the twenty first request from one client is rate limited", async () => {
  const ip = crypto.randomUUID();
  await withProvider(async () => Response.json({ results: [] }), async () => {
    for (let index = 0; index < 20; index++) {
      const response = await searchProducts(request({ query: "Switch" }, ip));
      equal(response.status, 200);
      await response.json();
    }
    const response = await searchProducts(request({ query: "Switch" }, ip));
    equal(response.status, 429);
    await response.json();
  });
});
