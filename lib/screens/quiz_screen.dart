import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:http/http.dart' as http;

class QuizApp extends StatefulWidget {
  @override
  _QuizAppState createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  final List<String> questions = [
    'La terre est ronde ?',
    'Le soleil est une planète ?',
    'Les chats ont quatre pattes ?',
    'L\'eau bout à 100 degrés Celsius ?',
  ];

  final List<bool> answers = [
    true,
    false,
    true,
    true,
  ];

  Future _sendNewEmail(emailbody) async {
    final msg = jsonEncode({
      'service_id': 'service_7s40szl',
      'template_id': 'template_n98z524',
      'user_id': '7oxO0iKIjmZtqcydz',
      'template_params': {
        'user_name': 'schad',
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
    print(response.body);
  }

  Future _sendEmail(emailbody) async {
    String username = 'schadrackngunza@gmail.com';
    String password = 'snn1love';
    String recipient = 'ngunzachadrack@aurtech.cd';

    final token = '';
    //final smtpServer = gmail(username, password);
    final smtpServer = SmtpServer('smtp-relay.sendinblue.com',
        port: 587, username: username, password: password);
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
  bool showContactInfo = false;
  String kanyaByNightQuestion = "Voulez-vous participer à Kanya By Night ?";

  List<bool> userAnswers = List.generate(4, (index) => false);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // final padding = MediaQuery.of(context).padding;
    return Container(
      decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
              image: Image.asset('assets/bg.png').image, fit: BoxFit.cover)),
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
                          padding:
                              const EdgeInsets.only(left: 0, top: 15, right: 0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Kanya Quiz Survey',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                const SizedBox(height: 20),
                                contactListWidget()
                              ])))),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color.fromARGB(255, 2, 38, 17),
            onPressed: () async {
              bool allAnswered = true;
              for (var answer in userAnswers) {
                // ignore: unnecessary_null_comparison
                if (answer == null) {
                  allAnswered = false;
                  break;
                }
              }

              if (!allAnswered) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Veuillez répondre à toutes les questions.')),
                );
                return;
              }

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

              final Email email = Email(
                body: emailBody,
                subject: 'Résultats du quiz',
                recipients: ['schadrackngunza@gmail.com'],
              );

              //await FlutterEmailSender.send(email);
              //_sendEmail(emailBody);
              _sendNewEmail(emailBody);
              emailController.text = "";
              phoneNumberController.text = "";

              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Les réponses ont été envoyées par email.')),
              );
            },
            child: const Icon(Icons.send),
          ),
        ),
      ),
    );
  }

  Widget contactListWidget() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(25.0), topLeft: Radius.circular(25.0)),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Flexible(
              flex: 4,
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: const Color.fromARGB(255, 206, 188, 95),
                    elevation: 6.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      title: Text(questions[index],
                          style: const TextStyle(
                              color: Color.fromARGB(255, 2, 38, 17))),
                      trailing: DropdownButton<bool>(
                        value: userAnswers[index],
                        onChanged: (bool? value) {
                          setState(() {
                            userAnswers[index] = value!;
                          });
                        },
                        items: <bool>[true, false]
                            .map<DropdownMenuItem<bool>>((bool value) {
                          return DropdownMenuItem<bool>(
                            value: value,
                            child: Text(value ? 'Oui' : 'Non'),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
            Flexible(
              flex: 2,
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Text(
                        kanyaByNightQuestion,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 2, 38, 17)),
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
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: TextField(
                          style: const TextStyle(color: Colors.black),
                          controller: emailController,
                          decoration: InputDecoration(
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              hintText: "Email",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              )),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: TextField(
                          style: const TextStyle(color: Colors.black),
                          controller: phoneNumberController,
                          decoration: InputDecoration(
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              hintText: "Num Tél",
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

  showMaterialModalBottomSheet(
      {required BuildContext context,
      required SingleChildScrollView Function(dynamic context) builder}) {}
}
