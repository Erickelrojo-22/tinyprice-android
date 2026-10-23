# TinyPrice — práctica Android, TinyFish y Supabase

Proyecto de la práctica de Aplicaciones Móviles Nativas, preparado en la carpeta `IATinyFish`. Basado en el [codelab del docente](https://epanchanaf.github.io/tinyprice-codelab/) y su referencia completa; consultar [procedencia](docs/provenance.md).

## Abrir y ejecutar

En Android Studio, abre **esta carpeta**, espera la sincronización de Gradle y selecciona un emulador o teléfono autorizado. Pulsa **Run**. Por defecto la app utiliza **datos ficticios identificados como demostración**.

Desde PowerShell, situado en esta carpeta:

```powershell
.\gradlew.bat :app:assembleDebug -PuseRemoteDeals=false
```

Para compilar, comprobar los tests y guardar el APK en `dist`:

```powershell
.\scripts\Build-Demo.ps1
# Si tienes un dispositivo conectado:
.\scripts\Build-Demo.ps1 -Install
```

## Herramientas

- JDK 17, Gradle 9.6.0 y Android Gradle Plugin 9.4.1.
- Android SDK 37.0 para compilar; Android 6.0 / API 23 como mínimo para ejecutar.
- Kotlin, Compose, Retrofit/Gson y corrutinas.
- Node.js 20 o posterior para las herramientas locales de Supabase, Gemini CLI y Deno.
- `local.properties` contiene únicamente la ruta al SDK de esta computadora y se excluye de Git.
- `android.overridePathCheck=true` permite trabajar en la carpeta solicitada, cuyo nombre contiene tildes.
- Los scripts usan una caché Gradle propia en `%LOCALAPPDATA%\TinyPriceTools\gradle-home` para evitar conflictos con compilaciones simultáneas de otros proyectos.
- En este Windows, el ejecutor de tests no cargaba clases desde la ruta con tildes. Los scripts compilan una copia sincronizada en `%LOCALAPPDATA%\TinyPriceTools\workspace` y devuelven APK y reportes a esta carpeta. El código que debes editar sigue siendo el de `IATinyFish`.

Reinstalación de las herramientas Node en otra computadora:

```powershell
npm.cmd ci
npx supabase --version
npx deno --version
npx gemini --version
```

## Qué hace la aplicación

`Compose → DealsViewModel / StateFlow → DealsRepository`.

La implementación local permite recorrer búsqueda, resultados, detalle, regreso y estados de validación. La implementación remota usa Retrofit para enviar `{ "query": "producto" }` a la función `search-products`. Supabase consulta TinyFish y devuelve `offers` con título, resumen y enlace de origen.

**Los resultados web no garantizan un precio normalizado.** La aplicación muestra “Ver en fuente” y conserva el enlace, tal como indica el curso.

## Activar la integración real

Este código no incluye credenciales, cuentas creadas ni una URL remota verificada. El estado exacto se registra en [estado de la práctica](docs/estado-practica.md). Para completar los pasos alojados necesitas una cuenta propia de Supabase, un proyecto y la API key de TinyFish obtenida siguiendo el enlace del codelab.

1. Crea el proyecto en Supabase y copia su **Reference ID**.
2. Inicia sesión con `npx supabase login`.
3. Ejecuta el script siguiente, reemplazando la referencia. La clave se solicita mediante entrada oculta:

```powershell
.\scripts\Complete-Cloud.ps1 -ProjectRef 'REFERENCIA_REAL_DE_20_CARACTERES'
```

El script enlaza el proyecto, guarda el secreto en Supabase, despliega la función, comprueba una búsqueda real y solamente entonces activa las propiedades remotas y genera `dist/TinyPrice-live.apk`. Su sintaxis se comprueba localmente; su ejecución remota requiere las credenciales indicadas.

Como alternativa, puedes guardar `TINYFISH_API_KEY` en **Supabase Dashboard → Edge Functions → Secrets** y desplegar con:

```powershell
npx supabase functions deploy search-products --project-ref TU_REFERENCE_ID
```

La URL base del cliente será `https://TU_REFERENCE_ID.supabase.co/functions/v1`. No agregues `search-products` a esa propiedad: Retrofit añade el nombre de la función.

La configuración `verify_jwt=false` corresponde al endpoint público didáctico del laboratorio. No equivale a una configuración de distribución abierta en producción. La clave de TinyFish permanece en Supabase y nunca se agrega al APK.

## Verificar

```powershell
.\scripts\Verify-Local.ps1
# Tests de interfaz, con un teléfono o emulador (usa su serial de adb devices):
.\scripts\Test-UI.ps1 -Device emulator-5580
```

Los tests del backend ejecutan el manejador real con el transporte de TinyFish simulado explícitamente. No consumen créditos ni prueban una cuenta real. Cubren validación, CORS, errores, ausencia de configuración, límite de resultados y peticiones, URLs y respuestas mal formadas.

Las pruebas Android verifican estado, repositorios, cancelación y navegación de interfaz. Los resultados de cada ejecución se guardan en `docs/evidence/`; los reportes completos de Gradle se generan bajo `app/build/reports/`.

La verificación final pasó 8 tests unitarios, 11 del backend y 4 de interfaz en API 23. `Test-UI.ps1` usa AndroidJUnitRunner directamente por ADB: el recolector UTP de Gradle produjo rutas recursivas inválidas en este AVD antiguo y se detuvo. Las capturas reales de inicio, validación, resultados y detalle están en `docs/evidence/`.

## Actividad de skills

Android CLI se instala en `%USERPROFILE%\AppData\AndroidCLI\android.exe`. Desde PowerShell puedes invocarlo con:

```powershell
$androidCli = "$env:USERPROFILE\AppData\AndroidCLI\android.exe"
& $androidCli --version
& $androidCli skills add android-cli --project=.
npx gemini skills list
```

En la versión instalada, el identificador `android-cli` debe especificarse; el comando sin nombre mostrado en el codelab responde “Must specify at least one skill”. En una sesión autenticada de Gemini, revisa el proyecto y usa `/trust`, `/skills reload` y `/skills list` para completar la actividad interactiva del curso.

## Archivos de interés

- `app/src/main/`: aplicación Android.
- `app/src/test/`: pruebas unitarias y regresiones.
- `app/src/androidTest/`: pruebas Compose.
- `supabase/functions/search-products/`: función y pruebas TypeScript.
- `scripts/`: compilación, verificación, preparación de imagen y conexión a la nube.
- `docs/`: diseño, plan, procedencia, progreso, evidencias y estado de los 16 pasos.
- `dist/`: APK y archivo de entrega generados localmente.
