import 'package:dio/dio.dart';
import 'package:order_status/data/lds/auth/auth_lds.dart';
import 'package:order_status/data/models/remote/user/user_remote_model.dart';
import 'package:order_status/data/rds/user_rds/user_rds.dart';
import 'package:uuid/uuid.dart';

class AuthRepository {
  AuthRepository({
    required AuthLDS authLDS,
    required UserRDS userRDS,
  })  : _authLDS = authLDS,
        _userRDS = userRDS;

  final AuthLDS _authLDS;
  final UserRDS _userRDS;

  bool isAuth = false;

  // Возвращает то авторизован пользователь или нет
  Future<UserRemoteModel?> login(
      String authId, String adminId, bool isAdmin) async {
    try {
      final res = await _userRDS.getUserByAuthId(authId, adminId, isAdmin);

      if (res != null) {
        await _authLDS.writeUserId(authId);
        await _authLDS.writeAdminId(adminId);
        await _authLDS.writeIsAdmin(isAdmin);
      }
      return res;
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  Future<UserRemoteModel?> getIsAuth() async {
    final authId = _authLDS.readUserId();

    final adminid = _authLDS.readAdminId();

    final isAdmin = _authLDS.readIsAdmin();

    if (authId == null || adminid == null || isAdmin == null) {
      isAuth = false;
      return null;
    }

    final res = await login(authId, adminid, isAdmin);

    isAuth = res != null;

    return res;
  }
}
