import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:renohouz_worker/manager.dart';
import 'package:renohouz_worker/providers/user_provider.dart';
import 'dart:async';
import '../utils/debugger.dart';
import 'package:provider/provider.dart';

class PhoneVerification extends StatefulWidget {
  final bool firstTime;
  const PhoneVerification({Key? key, this.firstTime = true}) : super(key: key);
  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  List<Widget> countryOptions = [];
  ValueNotifier<bool> loaded = ValueNotifier<bool>(true);

  List countryCodes = [
    ['+93', 'Afghanistan'],
    ['+355', 'Albania'],
    ['+213', 'Algeria'],
    ['+1-684', 'American Samoa'],
    ['+376', 'Andorra'],
    ['+54', 'Argentina'],
    ['+61', 'Australia'],
    ['+43', 'Austria'],
    ['+994', 'Azerbaijan'],
    ['+1-242', 'Bahamas'],
    ['+973', 'Bahrain'],
    ['+880', 'Bangladesh'],
    ['+1-246', 'Barbados'],
    ['+375', 'Belarus'],
    ['+32', 'Belgium'],
    ['+501', 'Belize'],
    ['+229', 'Benin'],
    ['+1-441', 'Bermuda'],
    ['+975', 'Bhutan'],
    ['+591', 'Bolivia'],
    ['+387', 'Bosnia And Herzegovina'],
    ['+267', 'Botswana'],
    ['+55', 'Brazil'],
    ['+246', 'British Indian Ocean Territory'],
    ['+1-284', 'British Virgin Islands'],
    ['+673', 'Brunei'],
    ['+359', 'Bulgaria'],
    ['+226', 'Burkina Faso'],
    ['+257', 'Burundi'],
    ['+855', 'Cambodia'],
    ['+237', 'Cameroon'],
    ['+1', 'Canada'],
    ['+238', 'Cape Verde'],
    ['+1-345', 'Cayman Islands'],
    ['+236', 'Central African Republic'],
    ['+235', 'Chad'],
    ['+56', 'Chile'],
    ['+86', 'China'],
    ['+61', 'Christmas Island'],
    ['+61', 'Cocos Islands'],
    ['+57', 'Colombia'],
    ['+269', 'Comoros'],
    ['+682', 'Cook Islands'],
    ['+506', 'Costa Rica'],
    ['+385', 'Croatia'],
    ['+53', 'Cuba'],
    ['+599', 'Curacao'],
    ['+357', 'Cyprus'],
    ['+420', 'Czech Republic'],
    ['+243', 'Democratic Republic Of The Congo'],
    ['+45', 'Denmark'],
    ['+253', 'Djibouti'],
    ['+1-767', 'Dominica'],
    ['+670', 'East Timor'],
    ['+593', 'Ecuador'],
    ['+20', 'Egypt'],
    ['+503', 'El Salvador'],
    ['+291', 'Eritrea'],
    ['+372', 'Estonia'],
    ['+251', 'Ethiopia'],
    ['+500', 'Falkland Islands'],
    ['+298', 'Faroe Islands'],
    ['+679', 'Fiji'],
    ['+358', 'Finland'],
    ['+33', 'France'],
    ['+689', 'French Polynesia'],
    ['+241', 'Gabon'],
    ['+220', 'Gambia'],
    ['+995', 'Georgia'],
    ['+49', 'Germany'],
    ['+233', 'Ghana'],
    ['+350', 'Gibraltar'],
    ['+30', 'Greece'],
    ['+299', 'Greenland'],
    ['+1-473', 'Grenada'],
    ['+1-671', 'Guam'],
    ['+502', 'Guatemala'],
    ['+44-1481', 'Guernsey'],
    ['+245', 'Guinea-bissau'],
    ['+224', 'Guinea'],
    ['+592', 'Guyana'],
    ['+509', 'Haiti'],
    ['+504', 'Honduras'],
    ['+852', 'Hong Kong'],
    ['+36', 'Hungary'],
    ['+354', 'Iceland'],
    ['+91', 'India'],
    ['+62', 'Indonesia'],
    ['+98', 'Iran'],
    ['+964', 'Iraq'],
    ['+44-1624', 'Isle Of Man'],
    ['+39', 'Italy'],
    ['+225', 'Ivory Coast'],
    ['+1-876', 'Jamaica'],
    ['+81', 'Japan'],
    ['+44-1534', 'Jersey'],
    ['+962', 'Jordan'],
    ['+7', 'Kazakhstan'],
    ['+254', 'Kenya'],
    ['+686', 'Kiribati'],
    ['+383', 'Kosovo'],
    ['+965', 'Kuwait'],
    ['+996', 'Kyrgyzstan'],
    ['+856', 'Laos'],
    ['+371', 'Latvia'],
    ['+961', 'Lebanon'],
    ['+266', 'Lesotho'],
    ['+231', 'Liberia'],
    ['+218', 'Libya'],
    ['+423', 'Liechtenstein'],
    ['+370', 'Lithuania'],
    ['+352', 'Luxembourg'],
    ['+853', 'Macau'],
    ['+261', 'Madagascar'],
    ['+265', 'Malawi'],
    ['+60', 'Malaysia'],
    ['+960', 'Maldives'],
    ['+223', 'Mali'],
    ['+356', 'Malta'],
    ['+692', 'Marshall Islands'],
    ['+222', 'Mauritania'],
    ['+230', 'Mauritius'],
    ['+262', 'Mayotte'],
    ['+52', 'Mexico'],
    ['+373', 'Moldova'],
    ['+377', 'Monaco'],
    ['+976', 'Mongolia'],
    ['+382', 'Montenegro'],
    ['+1-664', 'Montserrat'],
    ['+212', 'Morocco'],
    ['+258', 'Mozambique'],
    ['+95', 'Myanmar'],
    ['+264', 'Namibia'],
    ['+674', 'Nauru'],
    ['+977', 'Nepal'],
    ['+31', 'Netherlands'],
    ['+687', 'New Caledonia'],
    ['+64', 'New Zealand'],
    ['+505', 'Nicaragua'],
    ['+227', 'Niger'],
    ['+234', 'Nigeria'],
    ['+683', 'Niue'],
    ['+47', 'Norway'],
    ['+968', 'Oman'],
    ['+92', 'Pakistan'],
    ['+680', 'Palau'],
    ['+970', 'Palestine'],
    ['+507', 'Panama'],
    ['+675', 'Papua New Guinea'],
    ['+595', 'Paraguay'],
    ['+51', 'Peru'],
    ['+63', 'Philippines'],
    ['+48', 'Poland'],
    ['+351', 'Portugal'],
    ['+974', 'Qatar'],
    ['+40', 'Romania'],
    ['+7', 'Russia'],
    ['+250', 'Rwanda'],
    ['+590', 'Saint Barthelemy'],
    ['+290', 'Saint Helena'],
    ['+1-758', 'Saint Lucia'],
    ['+685', 'Samoa'],
    ['+378', 'San Marino'],
    ['+966', 'Saudi Arabia'],
    ['+221', 'Senegal'],
    ['+381', 'Serbia'],
    ['+248', 'Seychelles'],
    ['+232', 'Sierra Leone'],
    ['+65', 'Singapore'],
    ['+421', 'Slovakia'],
    ['+386', 'Slovenia'],
    ['+677', 'Solomon Islands'],
    ['+252', 'Somalia'],
    ['+27', 'South Africa'],
    ['+82', 'South Korea'],
    ['+211', 'South Sudan'],
    ['+34', 'Spain'],
    ['+94', 'Sri Lanka'],
    ['+249', 'Sudan'],
    ['+597', 'Suriname'],
    ['+46', 'Sweden'],
    ['+41', 'Switzerland'],
    ['+963', 'Syria'],
    ['+886', 'Taiwan'],
    ['+992', 'Tajikistan'],
    ['+255', 'Tanzania'],
    ['+66', 'Thailand'],
    ['+228', 'Togo'],
    ['+690', 'Tokelau'],
    ['+676', 'Tonga'],
    ['+1-868', 'Trinidad And Tobago'],
    ['+216', 'Tunisia'],
    ['+90', 'Turkey'],
    ['+993', 'Turkmenistan'],
    ['+1-649', 'Turks And Caicos Islands'],
    ['+688', 'Tuvalu'],
    ['+256', 'Uganda'],
    ['+380', 'Ukraine'],
    ['+971', 'United Arab Emirates'],
    ['+44', 'United Kingdom'],
    ['+1', 'United States'],
    ['+598', 'Uruguay'],
    ['+998', 'Uzbekistan'],
    ['+678', 'Vanuatu'],
    ['+58', 'Venezuela'],
    ['+84', 'Vietnam'],
    ['+681', 'Wallis And Futuna'],
    ['+967', 'Yemen'],
    ['+260', 'Zambia'],
    ['+263', 'Zimbabwe'],
  ];

  int countryIndex = 115;
  String phoneNumber = '';
  bool waitingForSMS = false;
  bool codeWasSent = false;
  bool verifyingCode = false;
  String? errorMessage;
  String? errorCodeMessage;
  int timeLeft = 45;
  Timer? timer;
  late String verificationId;

  Future loadCountryOptions() async {
    for (int i = 0; i < countryCodes.length; i++) {
      countryOptions.add(Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                countryIndex = i;
              });
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Image(
                    image: AssetImage('assets/country_flags/${f(countryCodes[i][1])}.png'),
                    height: 18,
                    isAntiAlias: true,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(child: Text(countryCodes[i][1], overflow: TextOverflow.ellipsis))
                ],
              ),
            ),
          ),
          Container(width: double.infinity, height: 0.7, color: Colors.grey[300])
        ],
      ));
    }
    loaded.value = true;
  }

  void verificationCompleted(PhoneAuthCredential credential) async {
    Debugger.log("call verification completed");
    // UserCredential user = await FirebaseAuth.instance.signInWithCredential(credential);
    // if (user != null) {
    //   // user.user.getIdToken().then((value) {
    //   //   Debugger.log('\nid token\n********$value\n*******\n');
    //   // });
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
    // }
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.updatePhoneNumber(credential);
      //await FirebaseAuth.instance.currentUser.linkWithCredential(credential);
      await context.read<UserProvider>().updatePhoneNumber(widget.firstTime);
      if (!widget.firstTime) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      Debugger.log(e);
      if (e.code == "invalid-verification-code") {
        Debugger.log("wrong otp code");
        setState(() {
          errorCodeMessage = 'Code is invalid';
        });
      } else {
        setState(() {
          errorMessage = 'Something went wrong. Please try again.';
        });
      }
      setState(() {
        verifyingCode = false;
      });
    } catch (e) {
      Debugger.log(e);
      setState(() {
        errorMessage = 'Something went wrong. Please try again.';
        verifyingCode = false;
      });
    }
  }

  void verificationFailed(FirebaseAuthException e) {
    Debugger.log("failed otp");
    Debugger.log(e);
    setState(() {
      timeLeft = 45;
    });
    stopTimer();
    if (e.code == "invalid-phone-number") {
      Debugger.log("phone number was invalid");
      setState(() {
        waitingForSMS = false;
        errorMessage = 'Invalid phone number';
      });
    } else {
      setState(() {
        waitingForSMS = false;
        errorMessage = 'Something went wrong. Please try again';
      });
    }
  }

  void codeSent(String id, int? resendToken) async {
    Debugger.log("otp code was sent\n id: $id");
    setState(() {
      verificationId = id;
      codeWasSent = true;
    });
  }

  Future<void> verifyCode(String code) async {
    setState(() {
      verifyingCode = true;
      errorCodeMessage = null;
    });
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code);
      //UserCredential user = await FirebaseAuth.instance.signInWithCredential(credential);
      //await FirebaseAuth.instance.currentUser.linkWithCredential(credential);
      User? user = FirebaseAuth.instance.currentUser;
      Debugger.log("updating phone number");
      await user?.updatePhoneNumber(credential);
      Debugger.log("updated on firebase");
      await context.read<UserProvider>().updatePhoneNumber(widget.firstTime);
      if (!widget.firstTime) {
        Navigator.pop(context);
      }
      // if (user != null) {
      //   FirebaseAuth.instance.signOut();
      //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
      // }
    } on FirebaseAuthException catch (e) {
      Debugger.log(e);
      if (e.code == "invalid-verification-code") {
        Debugger.log("wrong otp code");
        setState(() {
          errorCodeMessage = 'Code is invalid';
        });
      } else {
        setState(() {
          errorMessage = 'Please try again.';
        });
      }
      setState(() {
        verifyingCode = false;
      });
    } catch (e) {
      Debugger.log(e);
      setState(() {
        errorMessage = 'Something wrong. Please try again.';
        verifyingCode = false;
      });
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft < 1) {
        timer.cancel();
        setState(() {
          waitingForSMS = false;
          timeLeft = 45;
        });
      } else {
        setState(() => timeLeft--);
      }
    });
  }

  void stopTimer() {
    if (timer != null) {
      timeLeft = 45;
      timer?.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    //loadCountryOptions();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  String f(String n) {
    return n.toLowerCase().replaceAll(' ', '_');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 64.0, bottom: 12),
            child: Text('Phone Verification', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                SizedBox(height: 16.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Select country'),
                              content: Container(
                                height: MediaQuery.of(context).size.height - 200,
                                width: MediaQuery.of(context).size.height - 200,
                                //width: double.infinity,
                                child: ValueListenableBuilder(
                                  valueListenable: loaded,
                                  builder: (context, bool isLoaded, _) {
                                    if (isLoaded) {
                                      return Scrollbar(
                                        // child: SingleChildScrollView(
                                        //   child: Column(children: countryOptions),
                                        // ),
                                        child: ListView.builder(
                                          itemCount: countryCodes.length,
                                          itemBuilder: (context, i) {
                                            return Column(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      countryIndex = i;
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                    child: Row(
                                                      children: [
                                                        Image(
                                                          image: AssetImage(
                                                              'assets/country_flags/${f(countryCodes[i][1])}.png'),
                                                          height: 18,
                                                          isAntiAlias: true,
                                                        ),
                                                        SizedBox(width: 8.0),
                                                        Expanded(
                                                            child: Text(countryCodes[i][1], overflow: TextOverflow.ellipsis))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Container(width: double.infinity, height: 0.7, color: Colors.grey[300])
                                              ],
                                            );
                                          },
                                        ),
                                      );
                                    } else {
                                      return Center(child: CircularProgressIndicator());
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.lightGreen, width: 2.0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                        child: Row(
                          children: [
                            Card(
                              shadowColor: Colors.black,
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                              child: Image(
                                image: AssetImage(
                                    'assets/country_flags/${(countryCodes[countryIndex][1] as String).toLowerCase().replaceAll(RegExp(r' +'), "_")}.png'),
                                width: 28,
                                isAntiAlias: true,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(countryCodes[countryIndex][0], style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          labelText: 'Phone Number',
                          //hintText: 'E.g.: 124456679',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                          errorText: errorMessage,
                        ),
                        onChanged: (val) => setState(() => phoneNumber = '${countryCodes[countryIndex][0]}$val'),
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 20, letterSpacing: 1.5),
                      ),
                    ),
                  ],
                ),
                waitingForSMS
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('If you did not received the SMS,\nplease try again in $timeLeft seconds.'),
                      )
                    : SizedBox(height: 0),
                SizedBox(height: 16.0),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  ElevatedButton(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text('Verify'),
                    ),
                    onPressed: waitingForSMS
                        ? null
                        : () {
                            setState(() {
                              errorMessage = null;
                            });
                            Debugger.log(phoneNumber);
                            FirebaseAuth.instance.verifyPhoneNumber(
                              phoneNumber: phoneNumber,
                              verificationCompleted: verificationCompleted,
                              verificationFailed: verificationFailed,
                              codeSent: codeSent,
                              timeout: Duration(minutes: 2),
                              codeAutoRetrievalTimeout: (t) => Debugger.log(t),
                            );
                            setState(() => waitingForSMS = true);
                            startTimer();
                          },
                  )
                ]),
                codeWasSent ? GetCode(verifyCode, errorCodeMessage, verifyingCode) : SizedBox(height: 0),
              ],
            ),
          ),
          widget.firstTime
              ? TextButton(
                  onPressed: () {
                    User? user = FirebaseAuth.instance.currentUser;
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes, logout')),
                            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
                          ],
                        );
                      },
                    ).then((confirm) async {
                      if (confirm && user != null) {
                        Manager.signOut().catchError((err) {
                          Debugger.log(err);
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text('Something went wrong. Please try again later.'),
                                actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Ok'))],
                              );
                            },
                          );
                        });
                      }
                    });
                  },
                  child: Text('Log out'),
                )
              : SizedBox(height: 0),
        ],
      ),
    );
  }
}

class GetCode extends StatefulWidget {
  final Future<void> Function(String) onComplete;
  final String? errorCodeText;
  final bool verifyingCode;
  GetCode(this.onComplete, this.errorCodeText, this.verifyingCode);
  @override
  _GetCodeState createState() => _GetCodeState();
}

class _GetCodeState extends State<GetCode> {
  String code = '';
  List<FocusNode> focusNodes = [FocusNode(), FocusNode(), FocusNode(), FocusNode(), FocusNode(), FocusNode()];
  int index = 0;

  Widget field(FocusNode focusNode) {
    return Container(
      width: 45,
      child: TextField(
        focusNode: focusNode,
        onChanged: (val) {
          setState(() {
            index++;
            code += val;
          });
          if (index < 6) {
            focusNodes[index].requestFocus();
          } else {
            widget.onComplete(code);
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Text(widget.verifyingCode ? 'Verifying...' : 'Enter the code', style: TextStyle(fontSize: 18)),
        SizedBox(height: 8.0),
        Container(
          width: 200,
          //padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: TextField(
            onChanged: (String val) {
              if (val.length > 5) {
                widget.onComplete(val);
              }
            },
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 8),
            textAlign: TextAlign.center,
            maxLength: 6,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              errorText: widget.errorCodeText,
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}
