abstract class Result<T>{}
class Success<T> extends Result<T>{}

class Error<T> extends Result<T>
 {
  final Exception exception;
Error(this.exception);
 }