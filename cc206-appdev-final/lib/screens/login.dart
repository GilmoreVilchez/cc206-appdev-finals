import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mike_login/modules/CallbackAnimation.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:flutter_mike_login/modules/button.dart';

String _email, _password; //save email, password input
bool _autovalidate = false; //initialize autovalidator
bool _isHidden = true; //show/hide password

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

//initialize animation states
class CustomAnimator extends SimpleAnimation {
  CustomAnimator(String animationName) : super(animationName);

  start() {
    isActive = true;
  }

  stop() {
    isActive = false;
  }
}

class _LoginState extends State<Login> {
  TextEditingController email;
  TextEditingController password;

  final riveFileName = 'assets/mike.riv';
  Artboard _artboard;
  SimpleAnimation _idle, _lookDown, _closeEyes, _openEyes;
  // Mike animations: idle, lookdown, close eyes, open eyes/lookdown again
  final _formKey = GlobalKey<FormState>();

  bool _closingEyes = false;
  bool _lookingDown = false;
  bool _isIdle = true;

  @override
  void initState() {
    _loadRiveFile();
    super.initState();
    password = TextEditingController();
    email = TextEditingController();
  }

  void _replay(CallbackAnimation animation) {
    animation.resetAndStart(_artboard);
  }

  void _reset(SimpleAnimation animation) {
    animation.instance.time = (animation.instance.animation.enableWorkArea
                ? animation.instance.animation.workStart
                : 0)
            .toDouble() /
        animation.instance.animation.fps;
  }

  void _togglelookDown(bool value) =>
      setState(() => _lookDown.isActive = _lookingDown = value);

  void _toggleCloseEyes(bool value) =>
      setState(() => _closeEyes.isActive = _closingEyes = value);

  void _toggleIdle(bool value) =>
      setState(() => _idle.isActive = _isIdle = value);

  // loads a Rive file
  void _loadRiveFile() async {
    final bytes = await rootBundle.load(riveFileName);
    final file = RiveFile();

    if (file.import(bytes)) {
      Artboard baseArtboard = file.mainArtboard;
      //Intialize animations
      baseArtboard.addController(_idle = SimpleAnimation('full'));
      baseArtboard.addController(_lookDown = SimpleAnimation('lookdown'));
      baseArtboard.addController(_closeEyes = SimpleAnimation('eyes closed'));

      _idle.isActive = _isIdle;
      _lookDown.isActive = _lookingDown;
      _closeEyes.isActive = _closingEyes;

      setState(() => _artboard = baseArtboard);
    } else {
      print("Error loading file.");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double maxWidth = 400;

    void _togglePasswordView() {
      setState(() {
        _isHidden = !_isHidden;
      });
    }

    return Scaffold(
        body: new GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
              _toggleCloseEyes(false);
              _toggleIdle(true);
              _togglelookDown(false);
              _reset(_closeEyes);
              _reset(_lookDown);
            },
            child: Stack(
              children: [
                Container(
                  color: Colors.white,
                  width: screenWidth,
                  height: screenHeight,
                ), //Container & Color Design
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        const Color(0xff00796b),
                        const Color(0xff26a69a),
                        const Color(0xff26a69a),
                        const Color(0xffc6ff00)
                      ],
                      tileMode: TileMode
                          .clamp, // repeats the gradient over the canvas
                    ),
                  ),
                  width: screenWidth,
                  height: screenHeight,
                ),
                Column(
                  children: [
                    Center(
                      child: Container(
                        padding: EdgeInsets.only(bottom: 170),
                        width: maxWidth,
                        height: maxWidth,
                        child: _artboard != null
                            ? Rive(
                                artboard: _artboard,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: CircularProgressIndicator(),
                              ),
                      ),
                    ),
                  ],
                ),

                Positioned(
                  top: screenHeight * 0.32,
                  child: Container(
                    width: screenWidth,
                    child: Center(
                      child: Container(
                        width: 300,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12
                                  .withOpacity(0.1), //color of shadow
                              spreadRadius: 5, //spread radius
                              blurRadius: 7, // blur radius
                              offset: Offset(0, 2),
                            ), //Login Box Shadow Effect
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: Colors.white,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Form(
                                  key: _formKey,
                                  autovalidate:
                                      _autovalidate, //form autovalidator

                                  child: Column(children: <Widget>[
                                    FocusScope(
                                      onFocusChange: (value) {
                                        if (!value) {
                                        } else {
                                          _toggleIdle(false);
                                          _togglelookDown(true);
                                          _toggleCloseEyes(false);
                                          _reset(_closeEyes);
                                        } //textbox focus logic

                                        if (_formKey.currentState.validate() ==
                                                !null &&
                                            _autovalidate == true) {
                                          _formKey.currentState.reset();
                                        } //clear form error
                                      },
                                      child: TextFormField(
                                        controller: email,
                                        keyboardType: TextInputType.text,
                                        validator: (val) {
                                          if (val.length != 20 &&
                                              _autovalidate == true)
                                            return "Incorrect/Empty Email. Please Try Again.";
                                          else if (!val.contains(
                                                  "cictapps@wvsu.edu.ph") &&
                                              _autovalidate == true)
                                            return "Incorrect/Empty Email. Please Try Again.";
                                          else
                                            return null;
                                        }, //form autovalidator logic
                                        //form inputs
                                        onSaved: (val) => _email = val,
                                        onChanged: (val) => setState(
                                            () => _autovalidate = false),

                                        decoration: InputDecoration(
                                          labelText: 'Email',
                                          labelStyle: TextStyle(
                                              color: Colors.teal.shade600,
                                              fontSize: 17.5),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.teal.shade600,
                                                width: 1.0),
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.teal.shade600,
                                                width: 1.85),
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    FocusScope(
                                      onFocusChange: (value) {
                                        if (!value) {
                                        } else {
                                          _toggleIdle(false);
                                          _toggleCloseEyes(true);
                                          _reset(_lookDown);
                                        }
                                        if (_formKey.currentState.validate() ==
                                                !null &&
                                            _autovalidate == true) {
                                          _formKey.currentState.reset();
                                        } //clear form error
                                      },
                                      child: TextFormField(
                                        controller: password,
                                        keyboardType: TextInputType.text,
                                        validator: (val) {
                                          if (val.length != 4 &&
                                              _autovalidate == true)
                                            return "Password Invalid. Try Again.";
                                          else if (!val.contains("toor") &&
                                              _autovalidate == true)
                                            return "Password Invalid. Try Again.";
                                          else
                                            return null;
                                        }, //form autovalidator logic

                                        onSaved: (val) => _password = val,
                                        onChanged: (val) => setState(
                                            () => _autovalidate = false),
                                        obscureText: _isHidden,
                                        decoration: InputDecoration(
                                          suffix: InkWell(
                                            onTap: _togglePasswordView,
                                            child: Icon(
                                              _isHidden
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                            ), //show/hide password
                                          ),
                                          labelText: 'Password',
                                          labelStyle: TextStyle(
                                              color: Colors.teal.shade600,
                                              fontSize: 17.5),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.teal.shade600,
                                                width: 1.0),
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.teal.shade600,
                                                width: 1.86),
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ])),
                              SizedBox(
                                height: 30,
                              ),
                              //Login Button
                              Bouncing(
                                  onPress: () {
                                    if (email.text == "cictapps@wvsu.edu.ph" &&
                                        password.text == "toor") {
                                      _formKey.currentState.save();
                                      Navigator.pushNamed(context, '/home');
                                    } else {
                                      setState(() => _autovalidate = true);
                                    }
                                  }, //button form autovalidator logic

                                  child: GradientButton(
                                    //button design
                                    increaseHeightBy: 11,
                                    gradient: Gradients.cosmicFusion,
                                    shadowColor: Gradients
                                        .cosmicFusion.colors.last
                                        .withOpacity(0.25),
                                    child: Text("Log In"),
                                    increaseWidthBy: double.infinity,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                //bottom banner
                Container(
                  alignment: Alignment.bottomCenter,
                  margin: const EdgeInsets.only(bottom: 40.0),
                  child: Text(
                    "To Begin,"
                    "enter your Email & Password. Click Outside the TextField to Idle Animation.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black45),
                  ),
                ),
              ],
            )));
  }
}
