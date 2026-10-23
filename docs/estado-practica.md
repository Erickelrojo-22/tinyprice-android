# Estado de la práctica TinyPrice

Fecha de trabajo: 22 de octubre de 2026, America/Guayaquil.

Actualización del 23 de octubre: Supabase quedó conectado mediante la integración y se comprobó una organización sin proyectos. Se solicitó elegir esa organización antes de crear TinyPrice. TinyFish sigue mostrando inicio de sesión y no se ha proporcionado su clave. La sesión existente de Google se intentó con Gemini CLI 0.65.0 (también la versión publicada en npm), pero el servicio respondió `UNSUPPORTED_CLIENT` / `IneligibleTierError`; la activación mediante modelo sigue sin verificarse.

## Resultado local comprobado

- APK de demostración generado en `dist/TinyPrice-demo.apk`.
- 8 pruebas unitarias Android correctas: ViewModel, repositorio remoto y cancelación.
- 11 pruebas del backend correctas y comprobación TypeScript correcta. El transporte de TinyFish se simula explícitamente en los tests.
- Lint Android: 0 errores y 13 advertencias, principalmente versiones más recientes de dependencias del curso, icono de aplicación, etiqueta redundante y recomendación KTX.
- Firma de depuración APK verificada con esquemas v1 y v2. Paquete `com.apps.iatinyfish`, versión 1.0, minSdk 23, targetSdk 37.
- Imagen oficial Android API 23 x86_64 verificada y AVD propio `TinyPrice_Codelab_API23` creado. Las 4 pruebas de interfaz pasaron con AndroidJUnitRunner por ADB. Se inspeccionaron visualmente 4 capturas reales de inicio, validación, resultados y detalle; también se comprobó el regreso a resultados.
- Android CLI, Gemini CLI, Supabase CLI y Deno instalados. La skill oficial android-cli está instalada y Gemini la descubre habilitada; no se ha simulado una activación mediante modelo sin autenticar Gemini.

## Los 16 pasos del curso

| Paso | Tema | Estado y evidencia |
|---|---|---|
| 1 | Antes de comenzar | Entorno y requisitos comprobados. |
| 2 | Arquitectura | Implementada y descrita en design.md y README.md. |
| 3 | TinyFish: cuenta y clave | Pendiente de acceso a la cuenta y API key del usuario. No se verificaron créditos promocionales. |
| 4 | TinyFish Search | Contrato y mapeo implementados y probados sin consumir créditos; llamada real pendiente. |
| 5 | Entorno Android y skill | Herramientas y skill instaladas; descubrimiento en Gemini verificado. Activación interactiva mediante modelo pendiente de autenticar Gemini. |
| 6 | Configurar proyecto | Proyecto Gradle completo, API 23 mínima y SDK 37 de compilación. |
| 7 | Modelo y repositorios | Demo y remoto implementados, con fuentes web conservadas. |
| 8 | Estado y ViewModel | Implementados; regresiones de cancelación reproducidas y corregidas. |
| 9 | Interfaz Compose | Implementada; APK ejecutado, 4 tests instrumentados y recorrido manual correctos. |
| 10 | Cuenta Supabase por correo | Acceso a la cuenta verificado mediante la integración conectada; no se acredita el método de registro. |
| 11 | Proyecto Supabase Cloud | Organización detectada, sin proyectos. Pendiente de selección de organización solicitada al usuario. |
| 12 | Edge Function | Código local, tipos y 11 tests correctos. |
| 13 | Secreto y despliegue | Supabase conectado; pendientes organización para crear el proyecto y API key de TinyFish. |
| 14 | Conectar Android | Cliente remoto preparado. La URL real se activa solamente después de verificar el backend. |
| 15 | Probar y diagnosticar | 8 pruebas unitarias, 11 del backend y 4 de interfaz correctas; resultados en verification.json y capturas en evidence. |
| 16 | Publicar y continuar | Entrega local preparada. Publicar en Google Play es opcional y no se realizó. |

## Qué falta para terminar la parte alojada

Confirmar la organización Supabase para crear el proyecto y disponer de una API key de TinyFish. La integración Supabase ya está conectada y permite desplegar la función; para usar el script CLI también se necesita `npx supabase login`. Los permisos de archivos no proporcionan la clave de TinyFish.

El script `scripts/Complete-Cloud.ps1` está preparado para enlazar, guardar el secreto mediante un archivo temporal, desplegar, comprobar una búsqueda real y generar el APK remoto. Su sintaxis se verificó, pero **no se ha ejecutado ni validado contra un proyecto real**.

No deben presentarse las ofertas de demostración ni los tests con proveedor simulado como evidencia de una búsqueda real.

## Adaptaciones de Windows

La caché privada evita colisiones con otra compilación activa ajena a esta carpeta. La copia de compilación con ruta ASCII resuelve la carga de clases del ejecutor de tests en la ruta original con tildes; los scripts sincronizan fuentes y devuelven reportes y APK. No se modificaron los proyectos vecinos.

Consultar `review.md` para las observaciones menores y `provenance.md` para la referencia utilizada.

El recolector UTP de `connectedDebugAndroidTest` produjo rutas recursivas inválidas en el almacenamiento de API 23 y se detuvo esa ejecución. La misma suite compilada pasó con AndroidJUnitRunner directamente mediante ADB; `scripts/Test-UI.ps1` permite repetirla. El servidor de layout de Android CLI no respondió en este AVD, por lo que se inspeccionaron jerarquías reales mediante `uiautomator dump`.
