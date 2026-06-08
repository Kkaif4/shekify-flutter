import 'package:drift/drift.dart';

QueryExecutor openConnection() {
  return WebMockExecutor();
}

class WebMockExecutor extends QueryExecutor {
  @override
  SqlDialect get dialect => SqlDialect.sqlite;

  @override
  TransactionExecutor beginTransaction() {
    return _MockTransactionExecutor();
  }

  @override
  QueryExecutor beginExclusive() {
    return this;
  }

  @override
  Future<void> runBatched(BatchedStatements statements) async {}

  @override
  Future<bool> ensureOpen(QueryExecutorUser user) async {
    return true;
  }

  @override
  Future<void> runCustom(String statement, [List<Object?>? args]) async {}

  @override
  Future<int> runDelete(String statement, List<Object?> args) async {
    return 0;
  }

  @override
  Future<int> runInsert(String statement, List<Object?> args) async {
    return 0;
  }

  @override
  Future<List<Map<String, Object?>>> runSelect(String statement, List<Object?> args) async {
    return [];
  }

  @override
  Future<int> runUpdate(String statement, List<Object?> args) async {
    return 0;
  }
}

class _MockTransactionExecutor extends TransactionExecutor {
  @override
  SqlDialect get dialect => SqlDialect.sqlite;

  @override
  bool get supportsNestedTransactions => false;

  @override
  TransactionExecutor beginTransaction() {
    return this;
  }

  @override
  QueryExecutor beginExclusive() {
    return this;
  }

  @override
  Future<void> runBatched(BatchedStatements statements) async {}

  @override
  Future<void> rollback() async {}

  @override
  Future<void> send() async {}

  @override
  Future<bool> ensureOpen(QueryExecutorUser user) async => true;

  @override
  Future<void> runCustom(String statement, [List<Object?>? args]) async {}

  @override
  Future<int> runDelete(String statement, List<Object?> args) async => 0;

  @override
  Future<int> runInsert(String statement, List<Object?> args) async => 0;

  @override
  Future<List<Map<String, Object?>>> runSelect(String statement, List<Object?> args) async => [];

  @override
  Future<int> runUpdate(String statement, List<Object?> args) async => 0;
}
