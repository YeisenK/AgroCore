class OrderValidator {
  static String? validateCustomer(String? value) {
    if (value == null || value.isEmpty) {
      return 'El cliente es requerido';
    }
    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  static String? validateCrop(String? value) {
    if (value == null || value.isEmpty) {
      return 'El cultivo es requerido';
    }
    return null;
  }

  static String? validateVariety(String? value) {
    if (value == null || value.isEmpty) {
      return 'La variedad es requerida';
    }
    return null;
  }

  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cantidad es requerida';
    }
    final quantity = double.tryParse(value);
    if (quantity == null || quantity <= 0) {
      return 'La cantidad debe ser mayor a 0';
    }
    return null;
  }

  // Eliminado: validateUnit

  static String? validateDeliveryDate(DateTime? date) {
    if (date == null) {
      return 'La fecha de entrega es requerida';
    }
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final deliveryDate = DateTime(date.year, date.month, date.day);

    if (deliveryDate.isBefore(todayDate)) {
      return 'La fecha no puede ser anterior a hoy';
    }
    return null;
  }
}
