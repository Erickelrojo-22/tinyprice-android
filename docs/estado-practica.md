# Estado de la práctica TinyPrice

Fecha de trabajo: 22 de octubre de 2026, America/Guayaquil.

Actualización final del 23 de octubre: el usuario eligió su organización y se creó TinyPrice en el plan cotizado de $0/mes. La función está desplegada, la clave de TinyFish está guardada como secreto y la búsqueda real devolvió 9 resultados tanto por HTTP como desde Android. La actividad de skills se adaptó a Antigravity CLI, reemplazo oficial recomendado por Google: el agente leyó completamente la skill y confirmó autor y comando. Gemini CLI antiguo conserva su rechazo de acceso personal. Los detalles y los límites de tiempo de las comprobaciones están en actividad-skills.md.

## Resultado local comprobado

- APK conectado generado en `dist/TinyPrice-live.apk` y variante sin Internet en `dist/TinyPrice-demo.apk`.
- 8 pruebas unitarias Android correctas: ViewModel, repositorio remoto y cancelación.
- 11 pruebas del backend correctas y comprobación TypeScript correcta. El transporte de TinyFish se simula explícitamente en los tests.
- Lint Android: 0 errores y 13 advertencias, principalmente versiones más recientes de dependencias del curso, icono de aplicación, etiqueta redundante y recomendación KTX.
- Firma de depuración APK verificada con esquemas v1 y v2. Paquete `com.apps.iatinyfish`, versión 1.0, minSdk 23, targetSdk 37.
- Imagen oficial Android API 23 x86_64 verificada y AVD propio `TinyPrice_Codelab_API23` creado. Las 6 pruebas de interfaz pasaron con AndroidJUnitRunner por ADB. Se inspeccionaron capturas de demostración y de la búsqueda real; se comprobaron detalle, apertura del enlace en el navegador y regreso a los 9 resultados reales.
- Android CLI, Gemini CLI, Supabase CLI y Deno instalados. La skill oficial android-cli está instalada y Gemini la descubre habilitada; no se ha simulado una activación mediante modelo sin autenticar Gemini.

## Los 16 pasos del curso

| Paso | Tema | Estado y evidencia |
|---|---|---|
| 1 | Antes de comenzar | Entorno y requisitos comprobados. |
| 2 | Arquitectura | Implementada y descrita en design.md y README.md. |
| 3 | TinyFish: cuenta y clave | Sesión disponible y clave existente configurada en Supabase sin exponerla. No se acreditan promociones ni saldo. |
| 4 | TinyFish Search | Búsqueda real HTTP 200 y 9 resultados con fuentes; cloud-real-search.json. |
| 5 | Entorno Android y skill | Adaptado a Antigravity CLI 1.4.4: consulta completa de la skill confirmada por el registro de read_file; autor y comando correctos. Gemini CLI literal sigue rechazado por Google. |
| 6 | Configurar proyecto | Proyecto Gradle completo, API 23 mínima y SDK 37 de compilación. |
| 7 | Modelo y repositorios | Demo y remoto implementados, con fuentes web conservadas. |
| 8 | Estado y ViewModel | Implementados; regresiones de cancelación reproducidas y corregidas. |
| 9 | Interfaz Compose | Implementada; APK conectado ejecutado, 6 tests instrumentados y recorrido manual correctos. |
| 10 | Cuenta Supabase por correo | Acceso a la cuenta verificado mediante la integración conectada; no se acredita el método de registro. |
| 11 | Proyecto Supabase Cloud | TinyPrice creado en us-east-1; referencia rnecwhzsgdinkjkbwhop; ACTIVE_HEALTHY; cotización $0/mes. |
| 12 | Edge Function | Código desplegado como search-products, versión 1 activa; tipos y 11 tests correctos. |
| 13 | Secreto y despliegue | TINYFISH_API_KEY guardado en el panel oficial; función remota comprobada. |
| 14 | Conectar Android | Modo remoto activado por defecto; búsqueda de Nintendo devuelve 9 resultados en API 23. |
| 15 | Probar y diagnosticar | 8 pruebas unitarias, 11 del backend y 6 de interfaz correctas; HTTP y recorrido real también comprobados. |
| 16 | Publicar y continuar | Entrega local preparada. Publicar en Google Play es opcional y no se realizó. |

## Integración alojada

La parte alojada está operativa en `https://rnecwhzsgdinkjkbwhop.supabase.co/functions/v1/search-products`. Se desplegó mediante la integración Supabase y se configuró el secreto mediante el panel oficial. El APK, código y archivo de entrega no incluyen la clave. Los precios y la disponibilidad deben comprobarse en la fuente; el cliente no inventa precios a partir de los resultados de búsqueda.

El script `scripts/Complete-Cloud.ps1` se conserva como alternativa por CLI. Su sintaxis se verificó, pero no se ejecutó contra el proyecto: la ejecución comprobada utilizó la integración y el panel. Para utilizar esa alternativa se necesita iniciar sesión en la CLI.

No deben presentarse las ofertas de demostración ni los tests con proveedor simulado como evidencia de una búsqueda real.

## Adaptaciones de Windows

La caché privada evita colisiones con otra compilación activa ajena a esta carpeta. La copia de compilación con ruta ASCII resuelve la carga de clases del ejecutor de tests en la ruta original con tildes; los scripts sincronizan fuentes y devuelven reportes y APK. No se modificaron los proyectos vecinos.

Consultar `review.md` para las observaciones menores y `provenance.md` para la referencia utilizada.

El recolector UTP de `connectedDebugAndroidTest` produjo rutas recursivas inválidas en el almacenamiento de API 23 y se detuvo esa ejecución. La misma suite compilada pasó con AndroidJUnitRunner directamente mediante ADB; `scripts/Test-UI.ps1` permite repetirla. El servidor de layout de Android CLI no respondió en este AVD, por lo que se inspeccionaron jerarquías reales mediante `uiautomator dump`.
