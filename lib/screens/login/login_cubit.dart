import 'package:boombox/backend/api.dart';
import 'package:boombox/modal/user_details.dart';
import 'package:boombox/screens/login/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordCubit extends Cubit<PasswordState>{
  bool _isVisible=false;

  PasswordCubit():super(PasswordInvisible());

  void toggle(){
    if(_isVisible){
      emit(PasswordInvisible());
      _isVisible=false;
    }
    else{
      emit(PasswordVisible());
      _isVisible=true;
    }
  }

}

class LoginCubit extends Cubit<LoginState>{

  LoginCubit():super(LoginInitial());

  Future<void> login(String email,String password) async {
    if(validateEmail(email).isNotEmpty){
      emit(LoginFailed(validateEmail(email)));
      return;
    }
    if(validatePass(password).isNotEmpty){
      emit(LoginFailed(validatePass(password)));
      return;
    }
    emit(LoginLoading());
    var json=await MyApi.getInstance.login(email, password);

    if(json['isSuccess']){
      final prefs= await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn',true);
      prefs.setString('email',email);
      prefs.setString('userId','${json['userId']}');
      UserDetails.id='${json['userId']}';
      emit(LoginSuccess());
    }
    else{
      emit(LoginFailed('Wrong email or password'));
    }
  }

  String validateEmail(String email){
    if(email.trim().isEmpty){
      return "Email can't be empty";
    }
    else if(!email.contains('@') || !email.contains('.')){
      return "Invalid email";
    }
    return '';
  }

  String validatePass(String pass){
    if(pass.trim().isEmpty){
      return "Password can't be empty";
    }
    else if(pass.length<=4){
      return "Password length should be more than 4";
    }
    return '';
  }
}