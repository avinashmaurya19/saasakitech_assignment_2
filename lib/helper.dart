import 'package:firebase_auth/firebase_auth.dart';

class FireBaseLogout{
  void logOut() async {
    await FirebaseAuth.instance.signOut();
  }

}

