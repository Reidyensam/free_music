# 🎶 SISPLAY — Sistema de Playlists Emocionales

## 🎯 Objetivo del Proyecto

Aplicar los conceptos y prácticas del módulo académico a una aplicación real.  
**SISPLAY** permite:

- Crear playlists según emociones  
- Curar metadatos musicales  
- Compartir colecciones culturalmente significativas  
- Documentar evidencia técnica como parte del patrimonio del software  

---

## 🏢 Organización

**Emociones Sonoras S.A.**  
Proyecto basado en el sistema interno **Free_music**, con enfoque técnico, expresivo y patrimonial.

---

## ⚙️ Tecnologías utilizadas

- 🐦 **Lenguaje principal:** Dart (Flutter)  
- ⚙️ **Framework UI:** Flutter estable  
- 🚀 **CI/CD:** GitHub Actions con scripts YAML curados  
- 📦 **Editor de metadata:** Mp3tag + archivos `.txt` estructurados  
- 🧪 **Tests:** Flutter test + reporter expanded  
- 🐳 **Contenerización (futuro):** Docker para despliegue escalable  

---

## 🔗 Estructura de branches

| Branch       | Propósito                          |
|--------------|------------------------------------|
| `main`       | Versión estable                    |
| `develop`    | Cambios en curso                   |
| `feature/*`  | Nuevas funcionalidades             |
| `hotfix/*`   | Correcciones urgentes              |

---

## 🧪 Pruebas

- Carpeta `test/` con pruebas widget básicas  
- Validación visual: búsqueda de texto y navegación emocional  
- Reporter expandido activado en CI/CD  
- Resultado actual: ✅ Todos los tests pasan  

---

## 🛠️ Pipeline CI/CD patrimonial

Activado automáticamente en `push` a `main` o `develop`, con las siguientes etapas:

1. ⬇️ Checkout  
2. 🛠️ Setup Flutter (`3.32.8` con Dart `3.8.1`)  
3. 📊 Análisis estático (`flutter analyze`)  
4. 🧪 Validación existencia carpeta `test/`  
5. 🧪 Pruebas unitarias (`flutter test`)  
6. 🏗️ Compilación de APK (modo debug)  
7. 📦 Subida de artefacto `.apk` nombrado dinámicamente  

Artefacto generado:


---

## 🧰 Resoluciones técnicas patrimoniales

### 🔥 Eliminación de dependencia innecesaria

Se eliminó `sign_in_with_apple` por no ser requerida en plataforma Android.  
Se limpió el `pubspec.yaml` y se verificó ausencia de imports o referencias en el código fuente.

### 🔁 go_router

- ❌ `^16.0.0` requería Dart `>=3.1.0`  
- ✅ Se bajó a `^12.1.3`, compatible con Dart 3.0.0  
- 📎 Evidencia: `pubspec.lock`, log de ejecución, captura funcional  

### 🔁 flutter_hooks

- ❌ `^0.21.2` requería SDK pre-release `>=3.21.0-13.0.pre.4`  
- ✅ Se bajó a `^0.20.4`, estable y funcional  
- 📎 Evidencia: hooks activos, resolución y captura técnica  

### 🔁 supabase_flutter

- ❌ `^2.9.1` requería Dart `>=3.3.0`  
- ✅ Se bajó a `^1.10.15`, estable y funcional  
- 📎 Evidencia: logs de conexión y captura técnica  

---

## 🚀 Estrategia de Release

**Canary Release**  
Distribución anticipada a usuarios internos para verificar respuesta emocional y estabilidad funcional antes del despliegue general.

---

## 📦 Evidencia técnica esperada

| Elemento                      | Ubicación / Formato                          |
|------------------------------|----------------------------------------------|
| Log CI/CD                    | `ci_log_YYYY_MM_DD.txt`                      |
| Captura visual del pipeline  | `ci_success_YYYY_MM_DD.png`                  |
| Artefacto generado           | `build/app/outputs/flutter-apk/app-debug.apk`|
| Registro patrimonial         | Sección `README`, `CHANGELOG.md`             |
| Pruebas ejecutadas           | Log expandido `flutter test`                 |

---

## 🛠️ CI/CD actualizado · Agosto 2025

Se actualizó el entorno CI/CD a Flutter `3.32.8` y Dart `3.8.1` para compatibilidad con:


🔧 Esto permitió eliminar parches defensivos (`sed`) y blindar el pipeline sin comprometer modernidad ni compatibilidad.  
📎 La versión del flujo queda documentada como parte del legado técnico del proyecto.

---

## 🧾 Changelog técnico patrimonial

```md
## [CI/CD Update] - 2025-08-05

✅ Flutter actualizado en CI/CD a 3.32.8 (Dart 3.8.1)  
📦 Compatibilidad asegurada con dependencias clave sin parches temporales  
🛠️ Ajustes verificados: `flutter_lints`, `characters`, `webview_flutter`  
📂 Artefactos generados y nombrados dinámicamente  
📜 Evidencia capturada en logs, capturas y registros técnicos