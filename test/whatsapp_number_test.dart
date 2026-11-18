import 'package:app/app/utils/whatsapp_number.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stores a Sri Lankan 07 mobile number with +94', () {
    expect(normalizeWhatsAppNumber('0713895782'), '+94713895782');
    expect(normalizeWhatsAppNumber('071 389 5782'), '+94713895782');
  });

  test('keeps international numbers stable', () {
    expect(normalizeWhatsAppNumber('94713895782'), '+94713895782');
    expect(normalizeWhatsAppNumber('+94713895782'), '+94713895782');
    expect(normalizeWhatsAppNumber('+447123456789'), '+447123456789');
    expect(normalizeWhatsAppNumber('07138'), '07138');
  });

  test('links work with old local and newly saved values', () {
    expect(whatsappLinkNumber('0713895782'), '94713895782');
    expect(whatsappLinkNumber('+94713895782'), '94713895782');
  });
}
