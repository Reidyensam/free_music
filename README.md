# 🎶 SISPLAY — Sistema de Playlists Emocionales

## 🎯 Objetivo del Proyecto

Aplicar los conceptos y prácticas del módulo académico a una aplicación real. SISPLAY permite crear playlists según emociones, curar metadatos musicales y compartir colecciones culturalmente significativas.

## 🏢 Organización

**Emociones Sonoras S.A.**  
Proyecto basado en el sistema interno *Free_music*, con enfoque técnico y expresivo.

## ⚙️ Tecnologías utilizadas

- **Lenguaje principal**: Dart (Flutter)
- **CI/CD**: GitHub Actions + scripts YAML
- **Contenerización (futuro)**: Docker
- **Editor de metadata musical**: Mp3tag + archivos `.txt`

## 🔗 Estructura de branches

- `main`: versión estable
- `develop`: cambios en curso
- `feature/*`: nuevas funcionalidades
- `hotfix/*`: correcciones urgentes

## 🧪 Pruebas

- Carpeta `test/` con pruebas widget básicas
- Validación de UI: búsqueda de texto
- Resultado actual: ✅ All tests passed

## 🛠️ Pipeline CI/CD

- Activación automática en `push`
- Etapas: checkout → analyze → test → build `.apk` → subir artefacto
- Artefacto nombrado dinámicamente: `SISPLAY-42-main.apk`
- Evidencia: logs, artefacto compilado, análisis técnico

## 🚀 Estrategia de Release

**Canary Release**: se distribuye inicialmente a usuarios internos para verificar experiencia emocional antes del despliegue general.

## 📦 Entregables esperados

- Evidencias de builds por fecha y versión
- Capturas de logs, `.apk` generado, pruebas ejecutadas
- Presentación técnica con todos los puntos del proyecto


### Eliminación de dependencia innecesaria

Se eliminó `sign_in_with_apple` por no ser requerida en plataforma Android.  
El proyecto no contempla autenticación por Apple ID.  
Se limpió el `pubspec.yaml` y se verificó ausencia de imports o referencias en el código fuente.


### Resolución de incompatibilidad: go_router

El paquete `go_router ^16.0.0` requería Dart SDK `>=3.1.0`, no compatible con entorno actual (3.0.0).  
🔧 Se optó por bajar la versión a `^12.1.3`, confirmada estable y funcional.  
📎 Evidencia técnica: `pubspec.lock`, log de ejecución exitoso y captura funcional de navegación.



---

Este README puede crecer contigo: podés agregar flujos de usuario, curadurías musicales destacadas o capturas del sistema.

---

¿Querés que prepare ahora el script YAML que registre fecha y número de versión como log interno? O preferís generar una tabla de evidencias con fechas y ejecuciones, lista para exportar como parte de la entrega.

Vamos moldeando cada parte como una restauración de software con valor propio. Decime qué tallamos a continuación 🔧📖.