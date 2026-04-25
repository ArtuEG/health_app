# Plan de Implementación por Etapas — App de Seguimiento de Salud

Este documento describe, paso a paso y por etapas, el plan para implementar la app Flutter de seguimiento de presión arterial y glucosa (100% local).

---

## Resumen rápido
- Objetivo: app Android (Flutter) que registre presión (ambos brazos) y glucosa; notificaciones inteligentes; historial; exportar PDF con gráficas.
- DB local recomendada: `Isar` (alternativa: `Hive`, `sqflite`).
- Notificaciones: `flutter_local_notifications` + `android_alarm_manager_plus` (opcional).

---

## Etapa 0 — Preparación (0.5 - 1 día)
Objetivo: preparar repo, dependencias y estructura mínima.

Tareas:
- Crear rama/feature: `feature/health-tracker-plan`.
- Actualizar `pubspec.yaml` con dependencias base: `isar`, `isar_flutter`, `flutter_local_notifications`, `android_alarm_manager_plus`, `pdf`, `printing`, `fl_chart`, `riverpod` (o `provider`), `intl`.
- Crear carpetas: `lib/models/`, `lib/services/`, `lib/screens/`, `lib/repositories/`, `lib/widgets/`, `assets/`.

Entregables:
- `pubspec.yaml` con dependencias.
- Estructura de carpetas en `lib/`.

Aceptación:
- `flutter pub get` corre sin errores.

---

## Etapa 1 — Modelado y esquema DB (1 - 2 días)
Objetivo: definir modelos Dart y esquema para `Isar` (o `Hive`).

Modelos principales:
- `UserProfile` — `id`, `fullName`, `age`, `heightCm`, `weightKg`, `notes?`.
- `ArmReading` — `sys`, `dia`, `pulse`.
- `BPSession` — `id`, `dateTime`, `rightArm: ArmReading`, `leftArm: ArmReading`, `note?`.
- `GlucoseMeasurement` — `id`, `dateTime`, `mgPerDl`, `notes?`, `type` (enum: `fasting|postprandial|other`).
- `ReminderConfig` — `id`, `type` (`pressure|glucose`), `times` (lista), `enabled`, `repeatPolicy`.

Tareas:
- Implementar clases en `lib/models/` con anotaciones de `Isar` o adaptadores para `Hive`.
- Crear índices por `dateTime` y por `type` donde aplique.
- Escribir migraciones mínimas o documentación de esquema.

Entregables:
- Archivos: `lib/models/user_profile.dart`, `lib/models/bp_session.dart`, `lib/models/glucose.dart`, `lib/models/reminder_config.dart`.

Aceptación:
- Esquema compilable y tests unitarios simples para creación/lectura de objetos.

---

## Etapa 2 — Repositorios y capa de datos local (2 - 3 días)
Objetivo: abstraer acceso a DB y operaciones CRUD.

Tareas:
- Implementar `IBPRepository`, `IGlucoseRepository`, `IUserRepository` (interfaces).
- Implementaciones concretas en `lib/repositories/isar_*` que usen `Isar`.
- Servicios: `DataService` para inicializar DB y exponer repositorios.
- Utilities: serialización, validaciones de rangos.

Entregables:
- `lib/repositories/` con implementaciones y tests de integración locales.

Aceptación:
- Guardar/leer/filtrar mediciones por rango de fecha funciona y tiene tests automatizados.

---

## Etapa 3 — Diseño UI y wireframes (1 - 2 días)
Objetivo: definir pantallas, flujos y validaciones UX.

Pantallas clave:
- `DashboardScreen` — resumen, acceso rápido.
- `RecordBPScreen` — formulario por sesión que obliga ambos brazos.
- `RecordGlucoseScreen` — formulario simple.
- `ProfileScreen` — expediente editable.
- `RemindersScreen` — configurar alarmas/horarios.
- `LogScreen` — historial con filtros y botón `Exportar PDF`.

Tareas:
- Crear wireframes (puede ser simple en Markdown o imágenes en `assets/wireframes/`).
- Definir validaciones: ranges y campos obligatorios.

Entregables:
- `design/wireframes.md` o PNGs en `assets/wireframes/`.

Aceptación:
- Flujos prototipados y aprobados por el equipo/product owner.

---

## Etapa 4 — Formularios y validaciones (2 - 3 días)
Objetivo: implementar la entrada de datos y validaciones estrictas.

Reglas clave:
- `RecordBPScreen` obliga ambos brazos; validar `sys > dia` y rangos razonables.
- `RecordGlucoseScreen` valida `mg/dL` y tipo (ayunas/postprandial).

Tareas:
- Widgets reutilizables: `ArmReadingWidget`, `TimePicker`, `NumberField` con validación.
- Guardar en repositorio y cancelar notificaciones relacionadas (si existen).

Entregables:
- `lib/screens/record_bp_screen.dart`, `lib/widgets/arm_reading_widget.dart`.

Aceptación:
- No se permite guardar si faltan campos o valores fuera de rango.

---

## Etapa 5 — Notificaciones inteligentes (2 - 3 días)
Objetivo: implementar recordatorios prep (T-30m), momento (T) y repetición cada 5 minutos hasta completar.

Arquitectura:
- Programar notificaciones individuales por evento: `prep`, `moment`, y `followUp` (cada 5 min, hasta N repeticiones).
- Al grabar medición, cancelar notificaciones pendientes por `sessionId`.

Tareas:
- Servicio `NotificationService` en `lib/services/notification_service.dart` usando `flutter_local_notifications`.
- Integración con `android_alarm_manager_plus` para confiabilidad en background (Android).
- Guardar IDs de notificaciones en `ReminderConfig` o en tabla auxiliar.

Entregables:
- `lib/services/notification_service.dart`, tests manuales en dispositivo Android.

Aceptación:
- Notifs `prep` y `moment` aparecen correctamente; follow-ups se repiten cada 5 min hasta que se registra entrada y luego se cancelan.

---

## Etapa 6 — Reportes PDF y exportación (2 días)
Objetivo: generar PDF con encabezado (expediente), tabla y gráficas, y compartir.

Estrategia:
- Usar `pdf` + `printing`.
- Generar gráficas: 1) dibujar con primitivas del `pdf` (portable), o 2) renderizar `fl_chart` a `png` y embeder en PDF.

Tareas:
- Implementar `ReportService` que recupere datos, genere tablas y gráficas y devuelva un `Uint8List` para compartir.
- Pantalla `ReportPreviewScreen` para previsualizar y compartir.

Entregables:
- `lib/services/report_service.dart`, `lib/screens/report_preview_screen.dart`.

Aceptación:
- PDF generado con encabezado y gráficas; se puede compartir por WhatsApp/Email.

---

## Etapa 7 — Bitácora, filtros y gráficas interactivas (1.5 - 2 días)
Objetivo: mostrar historial, filtrar por rango y ver gráficas de tendencia.

Tareas:
- Implementar `LogScreen` con filtros rápidos (`Diario`, `Mensual`, `Rango personalizado`).
- Gráficas con `fl_chart`: comparativa SYS/DIA (derecho vs izquierdo) y curva de glucosa.

Entregables:
- `lib/screens/log_screen.dart`, `lib/widgets/trend_chart.dart`.

Aceptación:
- Filtros funcionan y las gráficas muestran series por fecha.

---

## Etapa 8 — Pruebas, local QA y build Android (1 - 2 días)
Objetivo: verificar flujos, corregir bugs y generar APK / AAB.

Tareas:
- Tests unitarios para validaciones y repositorios.
- Tests manuales en dispositivo Android (notifs, background behavior, PDF share).
- Preparar build: `flutter build apk --release` o `flutter build appbundle`.

Entregables:
- APK/AAB de prueba y checklist de QA.

Aceptación:
- QA checklist completado sin fallos críticos.

---

## Etapa 9 — Publicación y privacidad (0.5 - 1 día)
Objetivo: checklist final y preparación de release.

Tareas:
- Revisar permisos: solo los necesarios (notificaciones, almacenamiento si aplica).
- Documentar que los datos son 100% locales; añadir pantalla/consentimiento de privacidad.
- Crear assets y capturas para Play Store.

Entregables:
- Checklist de publicación y texto de privacidad en la app.

Aceptación:
- App lista para subir y documentación de privacidad incluida.

---

## Recomendaciones adicionales
- Logs y backups: permitir exportar base de datos (opcional cifrado) para migración entre dispositivos.
- Modularidad: escribir repositorios e interfaces para facilitar cambiar DB (`Isar` ↔ `sqflite`).
- Rendimiento: indexar por `dateTime` y paginar bitácora para renders rápidos.

---

## Próximos pasos inmediatos
1. Confirmas si prefieres `Isar` o `Hive` para que genere los modelos Dart.
2. Indicar el flujo de trabajo preferido (state management: `riverpod` o `provider`).

---

Archivo: `IMPLEMENTATION_PLAN.md`
