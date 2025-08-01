/// An exception thrown during the login process.
class LoginWithEmailAndPasswordFailure implements Exception {
  final String message;

  const LoginWithEmailAndPasswordFailure([
    this.message = 'Incorrect email or password. Please try again.',
  ]);
}

/// An exception thrown during the sign-up process.
class SignUpWithEmailAndPasswordFailure implements Exception {
  final String message;

  const SignUpWithEmailAndPasswordFailure([
    this.message = 'An unknown error occurred. Please try again later.',
  ]);
}