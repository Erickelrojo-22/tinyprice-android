# Registro de ejecución — docs/plan.md

2026-10-22: entorno inspeccionado; Java 17, Node 24 y SDKs Android 35/37.0 disponibles. Sin dispositivos ni AVD. Conectores de TinyFish y Supabase no conectados. CUA inicial agotó tiempo.

Decisión: nueva carpeta IATinyFish aísla el trabajo de campus-quest-app y Tarjetadepresentacion.
Decisión: la referencia del curso es una implementación existente; se integra con su atribución y se verifica. TDD se aplica a las correcciones propias.
Decisión: no detenerse por revisiones de diseño/plan, pues el usuario pidió ejecución autónoma explícitamente.

Backend: el chequeo TypeScript reprodujo dos parámetros implícitamente any. Una prueba adicional reprodujo HTTP 502 ante una entrada null entre resultados válidos. Se añadió filtrado tipado antes del mapeo: chequeo correcto y 11 tests correctos; evidencia RED en backend-red.log y GREEN en backend-tests.log.

Herramientas: instalados Deno 2.9.6, Supabase CLI 2.121.0, Gemini CLI 0.65.0 y Android CLI 1.0.16625370. Instalación de la skill oficial android-cli completada; Gemini skills list la descubre habilitada. La invocación moderna exige indicar el nombre de la skill. Se confió únicamente en la nueva carpeta IATinyFish para habilitar sus skills. Gemini interactivo sigue requiriendo seleccionar/autenticar la cuenta; no se simuló esa actividad.

Decisión: aislar la caché Gradle en AppData/Local/TinyPriceTools/gradle-home. El primer build encontró locks de transformaciones del PID 1992 y se observó otra compilación en IATinyFish-Autonomo. No se detienen ni se modifican procesos de ese otro proyecto. Se copió la caché de dependencias y se comparte únicamente la distribución inmutable del wrapper.

Emulador: imagen oficial Android 23 x86_64 descargada en segmentos y checksum SHA-1 comprobado contra metadatos de Google (7cbc291483ca07dc67b71268c5f08a5755f50f51). AVD propio TinyPrice_Codelab_API23, puerto 5580, ejecución sin ventana.

Nube: supabase projects list confirma ausencia de access token. No existe TINYFISH_API_KEY disponible. Se solicitó la autenticación al usuario de forma asíncrona mientras continúa el trabajo local. Script Complete-Cloud.ps1 preparado y sintaxis comprobada; no se afirma despliegue remoto.

Verificación final: 8 tests Android unitarios y 11 del backend correctos. Lint: 0 errores y 13 advertencias. APK de depuración generado y firma comprobada. Revisión independiente atendida; dos observaciones menores conservadas en review.md.

Emulador: el recolector UTP produjo rutas recursivas inválidas; se detuvieron únicamente los procesos identificados de nuestra ejecución. La suite real pasó sus 4 tests con AndroidJUnitRunner directo. Se comprobaron manualmente inicio, consulta vacía, tres resultados demo de Nintendo, detalle Pixel Store y regreso. Cuatro capturas inspeccionadas visualmente. No se abrió una fuente ficticia ni se afirmó búsqueda real.

Entrega: el exportador incluye app/build.gradle.kts explícitamente y excluye logs, credenciales, cachés y rutas de diagnóstico.

2026-10-23: Supabase conectado mediante integración; list_projects devuelve cero proyectos y list_organizations devuelve una organización. Se pidió su selección, requisito del proveedor antes de crear un proyecto. TinyFish abierto en la página de claves y redirige a inicio de sesión; no hay clave local. La autenticación CLI Supabase continúa ausente, pero la integración ofrece otra vía de despliegue.

Gemini CLI: se intentó usar las credenciales existentes con configuración temporal del proyecto. El servidor respondió IneligibleTierError / UNSUPPORTED_CLIENT para Code Assist individual. npm confirma 0.65.0 como versión publicada. No se declara activación de la skill ni se cambia de producto sin acuerdo. Se retiró la configuración temporal; no se leyeron ni imprimieron los secretos OAuth.

2026-10-23, cierre alojado: tras la elección expresa del usuario se creó TinyPrice, ref rnecwhzsgdinkjkbwhop, región us-east-1, plan cotizado $0/mes. Se desplegó search-products v1 con la integración Supabase. La sesión TinyFish quedó disponible; se leyó su clave existente sin mostrarla, se guardó en el archivo local excluido y se configuró en Supabase mediante su panel. El panel confirmó el secreto y se guardó captura con el valor oculto.

Prueba real: POST con Nintendo Switch OLED devolvió HTTP 200 y 9 ofertas con URLs HTTP. Android API 23 mostró los mismos 9 resultados, abrió el detalle y lanzó ACTION_VIEW al navegador con la fuente de Nintendo; se volvió al listado y se confirmó su estado mediante la jerarquía real. Capturas 07 a 09 y cloud-real-search.json.

Se cerraron los dos hallazgos menores de la revisión: indicador remoto de inicio y ausencia de navegador. Pruebas nuevas RED: 6 tests/2 fallos; GREEN: 6 tests/0 fallos. Verificación final: 8 unitarios, 11 backend, 6 instrumentados; lint 0 errores/13 advertencias. APKs demo y live actualizados. Activación Gemini por modelo permanece impedida por el rechazo del servicio; no afecta a la búsqueda real.

Adaptación posterior de skills: se verificó el anuncio oficial de Google que retiró el acceso personal de Gemini CLI el 18 de junio de 2026. Antigravity CLI 1.4.4 ya estaba instalado y respondió con la sesión existente. El registro real read_file confirmó la lectura de 753 líneas/36 433 bytes de android-cli/SKILL.md, y el agente identificó Google LLC y adb devices. La generación se cortó a 90 segundos; la consulta completa de la skill ya había finalizado. La comprobación adicional con prefijo slash llegó a 120 segundos sin respuesta final; no se declara completada. La adaptación se acredita por la lectura completa y la respuesta observadas, según la definición oficial de activación de skills. Sin cambios en la app ni nuevas credenciales.
