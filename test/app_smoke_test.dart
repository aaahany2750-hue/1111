import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashtransfer/main.dart';
void main(){ testWidgets('FlashTransfer home renders', (tester) async { await tester.pumpWidget(const ProviderScope(child: FlashTransferApp())); expect(find.text('Discover'), findsOneWidget); }); }
