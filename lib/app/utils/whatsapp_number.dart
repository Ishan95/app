String normalizeWhatsAppNumber(String input) {
  final number = input.trim();
  final compact = number.replaceAll(RegExp(r'[\s()-]'), '');

  if (RegExp(r'^07\d{8}$').hasMatch(compact)) {
    return '+94${compact.substring(1)}';
  }
  if (RegExp(r'^947\d{8}$').hasMatch(compact)) {
    return '+$compact';
  }
  if (RegExp(r'^\+947\d{8}$').hasMatch(compact)) {
    return compact;
  }

  return number;
}

String whatsappLinkNumber(String input) {
  return normalizeWhatsAppNumber(input).replaceAll(RegExp(r'\D'), '');
}
