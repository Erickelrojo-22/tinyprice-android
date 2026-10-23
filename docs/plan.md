# TinyPrice Implementation Plan

**Goal:** entregar la práctica Android + TinyFish + Supabase reproducible y verificada.
**Architecture:** interfaz Compose con estado unidireccional y repositorios demo/remoto; Edge Function para proteger TinyFish.
**Tech Stack:** Kotlin, Compose, Retrofit/Gson, Gradle, TypeScript/Deno y Supabase CLI.
**Spec:** docs/design.md
**Execution:** autónoma en esta sesión, según instrucción expresa del usuario.

## Global Constraints

- Paquete com.apps.iatinyfish; minSdk 23; versiones compatibles con el entorno.
- No modificar proyectos vecinos ni revelar claves.
- Mantener la procedencia del material del docente.
- No presentar pruebas con proveedor simulado como integración real.

## Review Focus

Consulta vacía mientras existe una búsqueda en curso; respuestas remotas fuera de orden; URLs no HTTP; errores y falta de credenciales; diferencia entre builds demo y remotos.

## Task 1: Proyecto compilable y pruebas del curso

Files: archivos Gradle, app/src, gradle/wrapper, docs/provenance.md.
Interfaces: DealsRepository.search(query): List<ProductOffer>; DealsUiState consumido por Compose.
- [x] Integrar instantánea oficial del curso y wrapper.
- [x] Ejecutar pruebas unitarias y assembleDebug, resolver incompatibilidades de entorno.

## Task 2: Comportamiento y verificación Android

Files: DealsViewModel.kt, tests unitarios e instrumentados.
Interfaces: eventos de búsqueda y selección, estado observado con ciclo de vida.
- [x] Añadir y observar fallar regresiones de cancelación/validación si el código del curso las necesita.
- [x] Corregir únicamente fallos reproducidos y ejecutar el conjunto de pruebas.
- [x] Crear dispositivo de prueba, instalar y comprobar búsqueda, detalle, navegación y errores.

## Task 3: Función y servicios

Files: supabase/config.toml, supabase/functions/search-products, package.json, scripts.
Interfaces: POST {query:string} -> {offers:ProductOffer[]} o error HTTP controlado.
- [x] Instalar CLI local y probar función con Deno sin claves reales.
- [x] Comprobar sesión Supabase y TinyFish disponible sin extraer datos de autenticación del navegador.
- [x] Si hay acceso, enlazar, configurar secreto y desplegar; si no, preparar script validado e informar el bloqueo concreto.

## Task 4: Entrega

Files: README.md, docs/estado-practica.md, docs/evidence, dist.
- [x] Compilar APK final y verificar pruebas, lint y ausencia de secretos.
- [x] Revisar archivos y registrar comandos/resultados verificables.
- [x] Entregar ubicación del APK y estado real de las dependencias externas.

## Cierre

Trabajo local completo y verificado. El despliegue real sigue pendiente de credenciales. Task 3 acredita comprobar el acceso y preparar el script alternativo, no un despliegue.
