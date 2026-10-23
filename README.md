# TinyPrice — práctica Android, TinyFish y Supabase

Proyecto de la práctica de Aplicaciones Móviles Nativas, preparado en la carpeta `IATinyFish`. Basado en el [codelab del docente](https://epanchanaf.github.io/tinyprice-codelab/) y su referencia completa; consultar [procedencia](docs/provenance.md).

## Abrir y ejecutar

En Android Studio, abre **esta carpeta**, espera la sincronización de Gradle y selecciona un emulador o teléfono autorizado. Pulsa **Run**. Por defecto la app usa la función remota ya desplegada en el proyecto TinyPrice. `dist/TinyPrice-live.apk` es la versión conectada y `dist/TinyPrice-demo.apk` conserva datos ficticios para practicar sin Internet.

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

La integración ya está desplegada en `https://rnecwhzsgdinkjkbwhop.supabase.co/functions/v1/search-products`. Se comprobó una búsqueda real de Nintendo Switch OLED: HTTP 200 y 9 resultados con enlaces de origen. La clave se almacena como secreto de Supabase y queda fuera del código, APK y ZIP. El estado exacto se registra en [estado de la práctica](docs/estado-practica.md).

Los siguientes pasos son una alternativa para repetir el despliegue por CLI en otro proyecto; el despliegue actual se realizó mediante la integración y el panel oficial:

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

La verificación final pasó 8 tests unitarios, 11 del backend y 6 de interfaz en API 23. `Test-UI.ps1` usa AndroidJUnitRunner directamente por ADB: el recolector UTP de Gradle produjo rutas recursivas inválidas en este AVD antiguo y se detuvo. Las capturas de demostración y de la integración real están en `docs/evidence/`.

## Actividad de skills

Android CLI se instala en `%USERPROFILE%\AppData\AndroidCLI\android.exe`. Desde PowerShell puedes invocarlo con:

```powershell
$androidCli = "$env:USERPROFILE\AppData\AndroidCLI\android.exe"
& $androidCli --version
& $androidCli skills add android-cli --project=.
npx gemini skills list
```

En la versión instalada, el identificador `android-cli` debe especificarse; el comando sin nombre mostrado en el codelab responde “Must specify at least one skill”. La skill se descubre correctamente. La invocación con la sesión existente de Google devolvió `UNSUPPORTED_CLIENT` / `IneligibleTierError` del servicio para Gemini CLI 0.65.0, que también era la versión publicada en npm al comprobarla. La activación mediante modelo no se declara completada; este impedimento no afecta al APK ni a TinyFish/Supabase.

## Archivos de interés

- `app/src/main/`: aplicación Android.
- `app/src/test/`: pruebas unitarias y regresiones.
- `app/src/androidTest/`: pruebas Compose.
- `supabase/functions/search-products/`: función y pruebas TypeScript.
- `scripts/`: compilación, verificación, preparación de imagen y conexión a la nube.
- `docs/`: diseño, plan, procedencia, progreso, evidencias y estado de los 16 pasos.
- `dist/`: APK y archivo de entrega generados localmente.
