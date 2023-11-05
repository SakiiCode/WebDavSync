import 'package:webdavsync/file_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Valid state: ', () {
    test('Created on remote', () {
      final state = FileState.unitTest(existsRemote: true, lastModifiedRemote: DateTime.now());
      state.setActions();
      expect(state.fileAction, FileAction.download);
      expect(state.indexAction, IndexAction.remote);
    });
    test('Created on local', () {
      final state = FileState.unitTest(existsLocal: true, lastModifiedLocal: DateTime.now());
      state.setActions();
      expect(state.fileAction, FileAction.upload);
      expect(state.indexAction, IndexAction.local);
    });
    test('Created on both ends', () {
      final state = FileState.unitTest(
          existsRemote: true,
          lastModifiedRemote: DateTime.now(),
          existsLocal: true,
          lastModifiedLocal: DateTime.now());
      state.setActions();
      expect(state.fileAction, FileAction.ask);
      expect(state.indexAction, IndexAction.ask);
    });
    test('Deleted on remote', () {
      final state = FileState.unitTest(
          existsIndex: true,
          lastModifiedIndex: DateTime.now(),
          existsLocal: true,
          lastModifiedLocal: DateTime.now());
      state.setActions();
      expect(state.fileAction, FileAction.deleteLocal);
      expect(state.indexAction, IndexAction.delete);
    });
    test('Deleted on local', () {
      final state = FileState.unitTest(
          existsRemote: true,
          lastModifiedRemote: DateTime.now(),
          existsIndex: true,
          lastModifiedIndex: DateTime.now());
      state.setActions();
      expect(state.fileAction, FileAction.deleteRemote);
      expect(state.indexAction, IndexAction.delete);
    });
    test('Deleted on both ends', () {
      final state = FileState.unitTest(existsIndex: true, lastModifiedIndex: DateTime.now());
      state.setActions();
      expect(state.fileAction, FileAction.none);
      expect(state.indexAction, IndexAction.delete);
    });
    test('New version on local', () {
      DateTime older = DateTime.now().subtract(const Duration(days: 1));
      DateTime newer = DateTime.now();
      final state = FileState.unitTest(
          existsRemote: true,
          lastModifiedRemote: older,
          existsIndex: true,
          lastModifiedIndex: older.copyWith(),
          existsLocal: true,
          lastModifiedLocal: newer);
      state.setActions();
      expect(state.fileAction, FileAction.upload);
      expect(state.indexAction, IndexAction.local);
    });
    test('New version on remote', () {
      DateTime older = DateTime.now().subtract(const Duration(days: 1));
      DateTime newer = DateTime.now();
      final state = FileState.unitTest(
          existsRemote: true,
          lastModifiedRemote: newer,
          existsIndex: true,
          lastModifiedIndex: older,
          existsLocal: true,
          lastModifiedLocal: older.copyWith());
      state.setActions();
      expect(state.fileAction, FileAction.download);
      expect(state.indexAction, IndexAction.remote);
    });
    test('Remote has been rolled back', () {
      DateTime older = DateTime.now().subtract(const Duration(days: 1));
      DateTime newer = DateTime.now();
      final state = FileState.unitTest(
          existsRemote: true,
          lastModifiedRemote: older,
          existsIndex: true,
          lastModifiedIndex: newer,
          existsLocal: true,
          lastModifiedLocal: newer.copyWith());
      state.setActions();
      expect(state.fileAction, FileAction.upload);
      expect(state.indexAction, IndexAction.local);
    });
    test('Local has been rolled back', () {
      DateTime older = DateTime.now().subtract(const Duration(days: 1));
      DateTime newer = DateTime.now();
      final state = FileState.unitTest(
          existsRemote: true,
          lastModifiedRemote: newer,
          existsIndex: true,
          lastModifiedIndex: newer.copyWith(),
          existsLocal: true,
          lastModifiedLocal: older);
      state.setActions();
      expect(state.fileAction, FileAction.download);
      expect(state.indexAction, IndexAction.remote);
    });
    test('The file has been rolled back on both ends', () {
      DateTime older = DateTime.now().subtract(const Duration(days: 1));
      DateTime newer = DateTime.now();
      final state = FileState.unitTest(
          existsRemote: true,
          lastModifiedRemote: older,
          existsIndex: true,
          lastModifiedIndex: newer,
          existsLocal: true,
          lastModifiedLocal: older.copyWith());
      state.setActions();
      expect(state.fileAction, FileAction.none);
      expect(state.indexAction, IndexAction.remote);
    });
    test('The file has been modified on both ends', () {
      DateTime older = DateTime.now().subtract(const Duration(days: 3));
      DateTime newer = DateTime.now().subtract(const Duration(days: 2));
      DateTime newest = DateTime.now().subtract(const Duration(days: 1));
      final state = FileState.unitTest(
          existsRemote: true,
          lastModifiedRemote: newer,
          existsIndex: true,
          lastModifiedIndex: older,
          existsLocal: true,
          lastModifiedLocal: newest);
      state.setActions();
      expect(state.fileAction, FileAction.ask);
      expect(state.indexAction, IndexAction.ask);
    });
    test('No changes', () {
      DateTime newer = DateTime.now().subtract(const Duration(days: 1));
      final state = FileState.unitTest(
          existsRemote: true,
          lastModifiedRemote: newer,
          existsIndex: true,
          lastModifiedIndex: newer.copyWith(),
          existsLocal: true,
          lastModifiedLocal: newer.copyWith());
      state.setActions();
      expect(state.fileAction, FileAction.none);
      expect(state.indexAction, IndexAction.none);
    });
  });
  group("Invalid state: ", () {
    test("Not exist anywhere", () {
      expect(() => FileState.unitTest().setActions(), throwsAssertionError);
    });
    test("lastModified null", () {
      expect(() => FileState.unitTest(existsRemote: true).setActions(), throwsAssertionError);
      expect(() => FileState.unitTest(existsIndex: true).setActions(), throwsAssertionError);
      expect(() => FileState.unitTest(existsLocal: true).setActions(), throwsAssertionError);
    });
  });
}
