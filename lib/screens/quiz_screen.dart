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
    final msg = jsonEncode(
      {
        'service_id': 'service_7s40szl',
        'template_id': 'template_n98z524',
        'user_id': '7oxO0iKIjmZtqcydz',
        'template_params': {
          'user_name':'schad',
          'user_email': 'ngunzachadrack@aurtech.cd',
          'user_subject': 'Kanya Survey',
          'user_message': emailbody,
        }
      }
    );
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: msg
    );
    print(response.body);
  }

  Future _sendEmail(emailbody) async {
    String username = 'schadrackngunza@gmail.com';
    String password = 'snn1love';
    String recipient = 'ngunzachadrack@aurtech.cd';

    final token = '';
    //final smtpServer = gmail(username, password);
    final smtpServer = SmtpServer('smtp-relay.sendinblue.com', port: 587, username: username, password: password);
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<bool> userAnswers = List.generate(4, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(questions[index]),
            trailing: DropdownButton<bool>(
              value: userAnswers[index],
              onChanged: (bool? value) {
                setState(() {
                  userAnswers[index] = value!;
                });
              },
              items: <bool>[true, false].map<DropdownMenuItem<bool>>((bool value) {
                return DropdownMenuItem<bool>(
                  value: value,
                  child: Text(value ? 'Oui' : 'Non'),
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
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
              const SnackBar(content: Text('Veuillez répondre à toutes les questions.')),
            );
            return;
          }

          String emailBody = '';
          for (int i = 0; i < questions.length; i++) {
            emailBody += '${i + 1}. ${questions[i]}: ${userAnswers[i] ? 'Oui' : 'Non'}\n';
          }

          final Email email = Email(
            body: emailBody,
            subject: 'Résultats du quiz',
            recipients: ['schadrackngunza@gmail.com'],
          );

          //await FlutterEmailSender.send(email);
          //_sendEmail(emailBody);
          _sendNewEmail(emailBody);

          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Les réponses ont été envoyées par email.')),
          );
        },
        child: const Icon(Icons.send),
      ),
    );
  }
}