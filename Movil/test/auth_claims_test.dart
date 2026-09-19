import 'package:flutter_test/flutter_test.dart';

import 'package:eco_reto/ui/auth/cubit/auth_cubit.dart';

void main() {
  group('AuthCubit.claimDelToken', () {

    final token = <String, dynamic>{
      'sub': '28',
      'jti': 'abc',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier':
          '28',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name':
          'qa_usuarios',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress':
          'qa@test.local',
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role':
          'ESTUDIANTE',
    };

    test('encuentra el id con claims de .NET', () {
      expect(
        AuthCubit.claimDelToken(token, const ['nameidentifier', 'nameid', 'sub']),
        '28',
      );
    });

    test('encuentra el nombre sin confundirlo con el id', () {
      expect(
        AuthCubit.claimDelToken(token, const ['unique_name', '/name']),
        'qa_usuarios',
      );
    });

    test('encuentra el correo', () {
      expect(
        AuthCubit.claimDelToken(token, const ['emailaddress', 'email']),
        'qa@test.local',
      );
    });

    test('los roles se leen del claim largo', () {
      expect(AuthCubit.rolesDelToken(token), ['ESTUDIANTE']);
    });
  });
}
