class Validators {
  static const int sysMin = 70;
  static const int sysMax = 250;
  static const int diaMin = 40;
  static const int diaMax = 150;
  static const int pulseMin = 30;
  static const int pulseMax = 220;
  static const int glucoseMin = 20;
  static const int glucoseMax = 600;

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Requerido';
    return null;
  }

  static String? integerInRange(
    String? value, {
    required int min,
    required int max,
    String label = 'Valor',
  }) {
    final base = required(value);
    if (base != null) return base;
    final n = int.tryParse(value!.trim());
    if (n == null) return '$label inválido';
    if (n < min || n > max) return '$label debe estar entre $min y $max';
    return null;
  }

  static String? sys(String? value) =>
      integerInRange(value, min: sysMin, max: sysMax, label: 'Sistólica');

  static String? dia(String? value) =>
      integerInRange(value, min: diaMin, max: diaMax, label: 'Diastólica');

  static String? pulse(String? value) =>
      integerInRange(value, min: pulseMin, max: pulseMax, label: 'Pulso');

  static String? glucose(String? value) => integerInRange(
    value,
    min: glucoseMin,
    max: glucoseMax,
    label: 'Glucosa',
  );

  static String? sysGreaterThanDia(int? sys, int? dia) {
    if (sys == null || dia == null) return null;
    if (sys <= dia) return 'La sistólica debe ser mayor que la diastólica';
    return null;
  }
}
