# Actividad de skills: adaptación oficial a Antigravity CLI

Fecha de comprobación: 23 de octubre de 2026.

## Causa del error de Gemini

El mensaje `UNSUPPORTED_CLIENT` no se corrige reinstalando la misma versión. El equipo oficial de Gemini CLI anunció que el acceso con cuentas personales, incluidas las modalidades gratuitas y Google AI Pro/Ultra, dejó de atender solicitudes el 18 de junio de 2026. La vía recomendada para esas cuentas es Antigravity CLI. El anuncio distingue el acceso empresarial y mediante API key, que requiere disponer del acceso correspondiente.

Fuente: [anuncio del equipo de Gemini CLI](https://github.com/google-gemini/gemini-cli/discussions/28017).

## Adaptación de la actividad

Antigravity CLI 1.4.4 ya estaba instalado en esta computadora y respondió con la sesión existente. Se utilizó en modo de planificación para consultar la skill oficial `android-cli`, sin cambiar la aplicación ni leer credenciales.

La documentación oficial indica que la activación de una skill consiste en leer sus instrucciones y utilizarlas. Antigravity leyó por completo `.agents/skills/android-cli/SKILL.md`: el registro de la herramienta confirma 753 líneas y 36 433 bytes. Identificó el nombre `android-cli`, el autor `Google LLC` y `adb devices` para listar los dispositivos conectados. No se necesita una herramienta denominada `activate_skill` para este mecanismo.

Fuentes: [funcionamiento de las skills](https://www.antigravity.google/docs/skills/), [migración y rutas compatibles](https://www.antigravity.google/docs/cli/gcli-migration).

Evidencia compacta: `evidence/antigravity-skill-verification.json`. La primera llamada leyó completamente la skill y respondió con el nombre, autor y comando correctos, aunque la generación de texto fue cortada al llegar a 90 segundos. Una comprobación adicional con el prefijo `/android-cli` alcanzó 120 segundos sin respuesta final; no se presenta esa segunda comprobación como completada. La lectura íntegra confirmada por la herramienta es la evidencia de consulta/activación utilizada.

## Repetir la actividad

Desde la raíz de `IATinyFish`, iniciar `agy` y pedir explícitamente:

```text
/android-cli Explica cómo listar los dispositivos Android conectados.
```

La ruta `.agents/skills/android-cli/SKILL.md` ya coincide con la ruta de skills del proyecto que admite Antigravity; no se duplica ni se altera la skill del docente.

## Alcance académico

Esta es una adaptación al reemplazo oficial de Google. No se presenta como una reparación del acceso personal retirado de Gemini CLI. Si la rúbrica exige ejecutar literalmente el cliente `gemini` contra un modelo, se debe acordar la adaptación con el docente o utilizar una modalidad de acceso a Gemini CLI que Google siga admitiendo.
