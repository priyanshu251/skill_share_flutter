import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skill_share/data/models/user.dart' as MyUser;
import 'package:dio/dio.dart';

import 'package:skill_share/constants/constants.dart';

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

class UserRepository {
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<MyUser.User> djangoSignIn() async {
    String? idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to get idToken');
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('idToken', idToken);
    printWrapped("idToken: $idToken");
    // await Future.delayed(Duration(seconds: 4));
    Response response = await Dio().post(
      UserApiConstants.authenticate,
      options: Options(
        headers: {
          'Authorization': 'Token $idToken',
        },
      ),
    );
    MyUser.User user = MyUser.User.fromMap(response.data);
    return user;
  }
}
