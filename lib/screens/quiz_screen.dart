import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

import '../helper/google_signin_api.dart';

class QuizApp extends StatefulWidget {
  @override
  _QuizAppState createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  final List<String> questions = [
    'Seriez-vous prêt à revenir dans ce restaurant à l\'avenir ?',
    'Avez-vous apprécié votre repas ?',
    'Êtes-vous satisfait du service qui vous a été offert ?',
    'Était-ce votre première visite dans ce restaurant ?',
    'Recommanderiez-vous ce restaurant à un ami ?'
  ];

  final List<bool> answers = [true, false, true, true, true];

  OverlayState? overlayState;
  OverlayEntry? overlayEntry;
  String modePaiement = '';
  showOverlay(BuildContext context) {
    overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(0, 0, 0, 0).withOpacity(0.8),
                ),
                child: Center(
                  child: Image.asset(
                    "assets/kanya.gif",
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
            ));
    overlayState!.insert(overlayEntry!);
  }

  bool showLoading = true;
  bool showAlert = false;

  Future _sendNewEmail(emailbody) async {
    final msg = jsonEncode({
      'service_id': 'service_7s40szl',
      'template_id': 'template_n98z524',
      'user_id': '7oxO0iKIjmZtqcydz',
      'template_params': {
        'user_name': 'a Kanya customer',
        'user_email': 'ngunzachadrack@aurtech.cd',
        'user_subject': 'Kanya Survey',
        'user_message': emailbody,
      }
    });
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: msg);

    if (response.statusCode == 200) {
      setState(() {
        showAlert = true;
        showLoading = false;
        overlayEntry!.remove();
        print(response.body);
        print('${showAlert}');
      });
    }
  }

  Future _sendEmail(emailbody) async {
    String username = 'schadrackngunza@gmail.com';
    String password = 'snn1love';
    String recipient = 'ngunzachadrack@aurtech.cd';

    final token = '';
    final smtpServer = gmailRelaySaslXoauth2(username, password);
    // final smtpServer = SmtpServer('smtp-relay.sendinblue.com',
    //     port: 587, username: username, password: password);
    final message = Message()
      ..from = Address(username, 'Flutter Quiz App')
      ..recipients.add(recipient)
      ..subject = 'Quiz Results'
      ..text = emailbody;

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. \n' + e.toString());
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return const Color.fromARGB(144, 2, 38, 17);
    }
    return const Color.fromARGB(255, 206, 188, 95);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  FocusNode myFocusNode = FocusNode();
  FocusNode myFocusNode1 = FocusNode();
  FocusNode myFocusNode2 = FocusNode();
  bool showContactInfo = false;
  String kanyaByNightQuestion =
      " Souhaitez-vous être notifié \n lors du lancement du programme Kanya By Night ?";

  List<bool> userAnswers = List.generate(5, (index) => false);

  @override
  void dispose() {
    myFocusNode.dispose();
    myFocusNode1.dispose();
    myFocusNode2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double h = 8.5;
    // final padding = MediaQuery.of(context).padding;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (tapDown) {
        myFocusNode.unfocus();
        myFocusNode1.unfocus();
        myFocusNode2.unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
                image: Image.asset('assets/bgSurvey.png').image,
                fit: BoxFit.cover)),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            key: _scaffoldKey,
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: Colors.transparent,
            ),
            body: Stack(
              children: [
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        width: size.width,
                        height: size.height * .8,
                        child: Padding(
                            padding: const EdgeInsets.only(
                                left: 0, top: 0, right: 0, bottom: 0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    '',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 36),
                                  ),
                                  const SizedBox(height: 0),
                                  contactListWidget()
                                ])))),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 2, 38, 17),
              onPressed: () async {
                if (showLoading) {
                  showOverlay(context);
                }
                var alertStyle = const AlertStyle(
                  isCloseButton: false,
                  isOverlayTapDismiss: false,
                );

                String emailBody = '';
                for (int i = 0; i < questions.length; i++) {
                  emailBody +=
                      '${i + 1}. ${questions[i]}: ${userAnswers[i] ? 'Oui' : 'Non'}\n';
                }

                if (emailController.text.isNotEmpty &&
                    phoneNumberController.text.isNotEmpty) {
                  emailBody +=
                      '6. Email: ${emailController.text} \n Tél: ${phoneNumberController.text}';
                }

                if (noteController.text.isNotEmpty) {
                  emailBody += '\n Observations: ${noteController.text}';
                }

                await _sendNewEmail(emailBody);

                if (showAlert) {
                  // ignore: use_build_context_synchronously
                  Alert(
                      context: context,
                      style: alertStyle,
                      title: '',
                      desc: "Merci de nous faire part de votre avis !",
                      image: Image.asset(
                        "assets/successCircle.gif",
                        width: 100,
                        height: 100,
                      ),
                      alertAnimation: fadeAlertAnimation,
                      buttons: [
                        DialogButton(
                          color: const Color(0xff1e8d72),
                          onPressed: () async {
                            setState(() {
                              emailController.text = "";
                              phoneNumberController.text = "";
                              noteController.text = "";
                              emailBody = '';
                              userAnswers = List.generate(5, (index) => false);
                              showAlert = false;
                              myFocusNode.unfocus();
                              myFocusNode1.unfocus();
                              myFocusNode2.unfocus();
                              if (showContactInfo) {
                                showContactInfo = false;
                              }
                            });
                            Navigator.pop(context);
                          },
                          width: 120,
                          child: const Text(
                            "Ok",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ]).show();
                }
              },
              child: const Icon(Icons.send),
            ),
          ),
        ),
      ),
    );
  }

  Widget contactListWidget() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(25.0), topLeft: Radius.circular(25.0)),
          color: Colors.grey.shade200,
        ),
        child: Column(
          children: [
            Flexible(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.only(top: 2),
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Card(
                        color: Colors
                            .white, //const Color.fromARGB(255, 206, 188, 95),
                        elevation: 6.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                      title: Text(questions[index],
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 2, 38, 17)))),
                                ),
                                Column(
                                  children: [
                                    Radio(
                                      value: true,
                                      groupValue: userAnswers[index],
                                      activeColor: Colors.green,
                                      onChanged: (val) {
                                        setState(() {
                                          userAnswers[index] = val!;
                                        });
                                      },
                                    ),
                                    const Text("Oui",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 2, 38, 17))),
                                    const SizedBox(
                                      height: 10,
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  children: [
                                    Radio(
                                      value: false,
                                      groupValue: userAnswers[index],
                                      activeColor: Colors.red,
                                      onChanged: (val) {
                                        setState(() {
                                          userAnswers[index] = val!;
                                        });
                                      },
                                    ),
                                    const Text("Non",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 2, 38, 17))),
                                    const SizedBox(
                                      height: 10,
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Flexible(
              flex: 5,
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    controller: noteController,
                    focusNode: myFocusNode,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hoverColor: const Color.fromARGB(255, 206, 188, 95),
                        icon: const Icon(Icons.note),
                        labelText: 'Observations',
                        hintText: 'Laissez-nous une note !',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: myFocusNode.hasFocus
                                  ? const Color.fromARGB(255, 206, 188, 95)
                                  : Colors.grey,
                              width: 1),
                        )),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Text(
                        kanyaByNightQuestion,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 2, 38, 17),
                            fontSize: 18),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Checkbox(
                        checkColor: Colors.white,
                        fillColor: MaterialStateProperty.resolveWith(getColor),
                        value: showContactInfo,
                        onChanged: (bool? value) {
                          setState(() {
                            showContactInfo = value!;
                          });
                        },
                      )
                    ],
                  ),
                ),
                Visibility(
                  visible: showContactInfo,
                  child: Column(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.only(left: 10, right: 10, top: 10),
                        child: TextField(
                          style: const TextStyle(color: Colors.black),
                          controller: emailController,
                          focusNode: myFocusNode1,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              focusColor:
                                  const Color.fromARGB(255, 206, 188, 95),
                              hoverColor:
                                  const Color.fromARGB(255, 206, 188, 95),
                              icon: const Icon(Icons.mail),
                              labelText: 'Entrer Email',
                              hintText: 'ex: exemple@exemple.com',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              )),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 5),
                        child: TextField(
                          style: const TextStyle(color: Colors.black),
                          controller: phoneNumberController,
                          focusNode: myFocusNode2,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              focusColor:
                                  const Color.fromARGB(255, 206, 188, 95),
                              hoverColor:
                                  const Color.fromARGB(255, 206, 188, 95),
                              icon: const Icon(Icons.phone),
                              labelText: 'Numéro de téléphone',
                              hintText: '+2438500008765',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget fadeAlertAnimation(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Align(
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  showMaterialModalBottomSheet(
      {required BuildContext context,
      required SingleChildScrollView Function(dynamic context) builder}) {}
}
