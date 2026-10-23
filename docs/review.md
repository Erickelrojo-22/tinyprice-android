# Revisión final

Se realizó una revisión independiente de solo lectura de la aplicación, el backend y los scripts. No se encontraron defectos críticos.

## Hallazgos verificados y acciones

- La sincronización de la copia de compilación omitía `app/build.gradle.kts`. Se reprodujo la ausencia del task Android al retirar únicamente ese archivo de la copia generada. El script ahora lo sincroniza; la misma comprobación terminó correctamente. Evidencias: `fresh-mirror-red.log` y `fresh-mirror-green.log`.
- Un test de interfaz esperaba dos ofertas, pero las tres ofertas de la referencia coinciden con la consulta de Nintendo. Se corrigió la expectativa del test, conservando el comportamiento del repositorio del curso.
- Se hizo condicional la copia de `local.properties`, para respetar también la configuración del SDK a través del entorno y no conservar una configuración local obsoleta en la copia de compilación.
- La preocupación por reutilizar un código de salida exitoso cuando falta un ejecutable no se reprodujo en este Windows PowerShell. El test real comprueba diagnóstico en stderr con salida cero, código de salida no cero y ejecutable inexistente; los tres casos se manejan correctamente. No se afirma haber corregido un fallo que no se reprodujo.

## Observaciones menores conservadas del codelab

- La tarjeta de inicio conserva la etiqueta DEMO incluso en una compilación remota. El listado de resultados sí indica correctamente si es demostración o búsqueda web.
- La apertura de enlaces presupone que hay un navegador instalado. Un dispositivo sin aplicación capaz de manejar ACTION_VIEW requiere un aviso adicional en una versión posterior.

## Límites de la revisión

La conectividad real, relevancia del proveedor y precios no pueden verificarse sin autenticación y API key. El contador de peticiones en memoria y `verify_jwt=false` son decisiones didácticas del codelab, no una arquitectura de servicio público para producción. Los repositorios actuales respetan cancelación; no se añade infraestructura para repositorios hipotéticos que la ignoren.
