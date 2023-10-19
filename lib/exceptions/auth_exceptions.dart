class AuthExceptions implements Exception {
  static const Map<String, String> errors = {
    "EMAIL_EXISTS": "E-mail já existe.",
    "OPERATION_NOT_ALLOWED": "Operação não permitida.",
    "TOO_MANY_ATTEMPTS_TRY_LATER": "Acesso bloqueado. Tente mais tarde.",
    "EMAIL_NOT_FOUND": "E-mail não encontrado.",
    "INVALID_PASSWORD": "Senha inválida.",
    "USER_DISABLED": "Usuário desativado.",
    "INVALID_LOGIN_CREDENTIALS": "Credenciais inválidas.",
  };
  final String message;

  AuthExceptions(this.message);

  @override
  String toString() {
    return errors[message] ??
        'Ocorreu um erro na autenticação. Verifique suas credenciais.';
  }
}
