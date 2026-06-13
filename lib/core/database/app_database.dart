import 'package:drift/drift.dart';

class TransferHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sender => text()();
  TextColumn get receiver => text()();
  TextColumn get fileName => text()();
  IntColumn get fileSize => integer()();
  DateTimeColumn get transferDate => dateTime()();
  IntColumn get durationMillis => integer()();
  TextColumn get status => text()();
  TextColumn get direction => text()();
  TextColumn get sha256 => text().nullable()();
}
