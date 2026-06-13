sealed class Failure { const Failure(this.message); final String message; }
class WifiFailure extends Failure { const WifiFailure(super.message); }
class TransferFailure extends Failure { const TransferFailure(super.message); }
class StorageFailure extends Failure { const StorageFailure(super.message); }
class PermissionFailure extends Failure { const PermissionFailure(super.message); }
class NetworkFailure extends Failure { const NetworkFailure(super.message); }
class VerificationFailure extends Failure { const VerificationFailure(super.message); }
class UnknownFailure extends Failure { const UnknownFailure(super.message); }
class Result<T> { const Result._({this.value, this.failure}); final T? value; final Failure? failure; bool get isSuccess => failure == null; factory Result.ok(T value)=>Result._(value:value); factory Result.err(Failure failure)=>Result._(failure:failure); }
