# Health Tracker

Aplicación Flutter de código abierto para registrar y consultar mediciones de
presión arterial y glucosa de forma local. Está pensada como una bitácora
personal sencilla, privada y portable para dar seguimiento a indicadores de
salud en el día a día.

> Nota: esta app no sustituye el diagnóstico, tratamiento ni seguimiento de un
> profesional de la salud. Los datos registrados son informativos.

## Características

- Registro de presión arterial por sesión con lectura de brazo derecho e
  izquierdo.
- Registro de glucosa en mg/dL con tipo de medición: ayunas, postprandial u
  otro.
- Dashboard con últimas mediciones y resumen de registros recientes.
- Bitácora con filtros por hoy, semana, mes o rango personalizado.
- Gráficas de tendencia para presión arterial y glucosa.
- Perfil local con datos básicos, notas e IMC.
- Recordatorios configurables para presión o glucosa.
- Notificaciones inteligentes: aviso previo, aviso en el momento y seguimiento
  cada 5 minutos si no se registra la medición.
- Generación y vista previa de reportes PDF con tablas y gráficas.
- Datos almacenados 100% en el dispositivo, sin envío a la nube.

## Tecnologías

- Flutter y Dart
- Material 3
- Riverpod para manejo de estado
- Isar como base de datos local
- flutter_local_notifications y android_alarm_manager_plus para recordatorios
- fl_chart para gráficas
- pdf y printing para reportes

## Estructura principal

```text
lib/
  models/          Modelos de datos e integraciones con Isar
  repositories/    Interfaces y repositorios locales
  screens/         Pantallas principales de la app
  services/        Notificaciones, reportes y servicios de apoyo
  utils/           Validadores
  widgets/         Componentes reutilizables
```

## Requisitos

- Flutter instalado
- Dart compatible con el SDK definido en `pubspec.yaml`
- Android Studio o Xcode si se compila para dispositivos móviles

Este proyecto usa Flutter con SDK Dart `>=3.11.0 <4.0.0`.

## Instalación

Clona el repositorio:

```bash
git clone https://github.com/ArtuEG/health_app.git
cd health_app
```

Instala dependencias:

```bash
flutter pub get
```

Genera los archivos necesarios de Isar si hace falta:

```bash
dart run build_runner build
```

Ejecuta la app:

```bash
flutter run
```

## Builds

Para generar un APK de Android:

```bash
flutter build apk --release
```

Para generar un App Bundle:

```bash
flutter build appbundle
```

## Privacidad

Health Tracker guarda la información únicamente en la base de datos local del
dispositivo. La app no cuenta con backend propio, no sincroniza información y no
envía datos personales a servicios externos.

Si compartes un reporte PDF, el manejo de ese archivo queda bajo tu control y el
de la aplicación por la que decidas enviarlo.

## Estado del proyecto

El proyecto está en desarrollo activo. La base funcional ya incluye registro de
presión arterial, glucosa, perfil, recordatorios, bitácora, gráficas y reportes
PDF.

Algunas mejoras posibles:

- Exportación o respaldo de la base de datos.
- Pruebas automatizadas para repositorios, validadores y servicios.
- Mejoras de accesibilidad.
- Internacionalización.
- Cifrado local opcional.

## Contribuir

Las contribuciones son bienvenidas. Puedes abrir un issue para reportar errores,
proponer mejoras o discutir nuevas funciones.

Para enviar cambios:

1. Haz fork del repositorio.
2. Crea una rama descriptiva.
3. Ejecuta formato y análisis antes de abrir el pull request.

```bash
dart format .
flutter analyze
```

## Autor

Creada por Arturo Elizalde.

- GitHub: [@ArtuEG](https://github.com/ArtuEG)
- Contacto: <artudev365@gmail.com>