# Revisión final

Se realizó una revisión independiente de solo lectura de la aplicación, el backend y los scripts. No se encontraron defectos críticos.

## Hallazgos verificados y acciones

- La sincronización de la copia de compilación omitía `app/build.gradle.kts`. Se reprodujo la ausencia del task Android al retirar únicamente ese archivo de la copia generada. El script ahora lo sincroniza; la misma comprobación terminó correctamente. Evidencias: `fresh-mirror-red.log` y `fresh-mirror-green.log`.
- Un test de interfaz esperaba dos ofertas, pero las tres ofertas de la referencia coinciden con la consulta de Nintendo. Se corrigió la expectativa del test, conservando el comportamiento del repositorio del curso.
- Se hizo condicional la copia de `local.properties`, para respetar también la configuración del SDK a través del entorno y no conservar una configuración local obsoleta en la copia de compilación.
- La preocupación por reutilizar un código de salida exitoso cuando falta un ejecutable no se reprodujo en este Windows PowerShell. El test real comprueba diagnóstico en stderr con salida cero, código de salida no cero y ejecutable inexistente; los tres casos se manejan correctamente. No se afirma haber corregido un fallo que no se reprodujo.

## Observaciones menores resueltas el 23 de octubre

- La tarjeta de inicio ahora recibe el modo del estado: muestra DEMO en la variante de demostración y BÚSQUEDA WEB en la remota.
- La apertura de enlaces captura ActivityNotFoundException y muestra una explicación si falta navegador.
- Dos pruebas nuevas reprodujeron ambos fallos (6 tests, 2 fallos) antes de modificar la aplicación; después pasaron las 6 pruebas. Evidencias: ui-final-red.log, ui-final-green.log e instrumentation-results.txt.

## Límites de la revisión

La conectividad real ya se verificó: HTTP 200 y 9 resultados de TinyFish con URLs de origen. No se verifican precios normalizados, stock ni relevancia exhaustiva de cada página. El contador de peticiones en memoria y `verify_jwt=false` son decisiones didácticas del codelab, no una arquitectura de servicio público para producción. Los repositorios actuales respetan cancelación; no se añade infraestructura para repositorios hipotéticos que la ignoren.
