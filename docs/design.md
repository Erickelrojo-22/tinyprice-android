# TinyPrice: alcance de la práctica

Fecha: 2026-10-22. Solicitud: reproducir autónomamente el codelab del docente.

## Resultado

Proyecto Android IATinyFish, paquete com.apps.iatinyfish, Kotlin y Jetpack Compose, Android mínimo API 23. Pantalla de búsqueda, carga, resultados, validación, errores y detalle con apertura de la fuente. Se conservan datos de demostración claramente identificados y un repositorio remoto alternativo.

## Arquitectura

Compose -> DealsViewModel/StateFlow -> DealsRepository -> Retrofit -> Supabase search-products -> TinyFish Search. La API key vive exclusivamente en secretos de Supabase. No se crean tablas ni se inventan precios a partir de fragmentos web.

## Referencia y adaptación

Se utiliza la instantánea completa que acompaña la práctica del docente, con atribución, wrapper de Gradle reproducible y ajustes necesarios para Windows. Las modificaciones de comportamiento reciben pruebas de regresión antes de implementarse. La configuración no altera otros proyectos ni las propiedades globales de Gradle.

## Criterios de aceptación

- Compilación APK y pruebas unitarias correctas.
- Pruebas instrumentadas en un dispositivo/emulador si el entorno lo permite.
- Función comprobada con validaciones y respuestas del proveedor simuladas de manera explícita en tests.
- Integración real solamente con cuentas y credenciales disponibles; una simulación no cuenta como búsqueda real.
- APK, instrucciones Windows, evidencia verificable y estado exacto de los 16 pasos.
- Ningún secreto en Git, APK, capturas o informe.

## Decisiones autorizadas

El usuario pidió ejecutar solo y sin nuevas pausas de aprobación. Se sigue el diseño del curso y se documentan las decisiones y cualquier dependencia externa pendiente. La ejecución local y los artefactos continúan aunque falte el acceso a servicios.
