import 'package:webdavsync/client.dart';
import 'package:flutter/material.dart';

class Credentials extends StatefulWidget {
  const Credentials({super.key});

  @override
  State<Credentials> createState() => _CredentialsState();
}

class _CredentialsState extends State<Credentials> {
  final urlController = TextEditingController(text: webDavHelper.url);
  final usernameController = TextEditingController(text: webDavHelper.user);
  final passwordController = TextEditingController();
  final intervalController = TextEditingController(text: webDavHelper.interval.toString());

  TimeUnit intervalUnits = webDavHelper.intervalUnits;

  @override
  void dispose() {
    super.dispose();
    urlController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    intervalController.dispose();
  }

  void save() {
    webDavHelper.update(
        url: urlController.text,
        user: usernameController.text,
        pwd: passwordController.text.isEmpty ? null : passwordController.text,
        interval: int.tryParse(intervalController.text) ?? 0,
        intervalUnits: intervalUnits);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(30),
        child: Column(children: [
          TextField(
            controller: urlController,
            decoration: const InputDecoration(hintText: "WebDAV address"),
          ),
          TextField(
            controller: usernameController,
            decoration: const InputDecoration(hintText: "Username"),
          ),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(hintText: "Password"),
            obscureText: true,
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                'Auto sync every',
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: intervalController,
                  keyboardType: TextInputType.number,
                ),
              ),
              DropdownButton<TimeUnit>(
                value: intervalUnits,
                /*icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),*/
                onChanged: (TimeUnit? newValue) {
                  if (newValue != null) {
                    setState(() {
                      intervalUnits = newValue;
                    });
                  }
                },
                items: TimeUnit.values
                    .map((timeUnit) => DropdownMenuItem(value: timeUnit, child: Text(timeUnit.name)))
                    .toList(),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Text("Set this to 0 to disable auto sync"),
          const SizedBox(
            height: 30,
          ),
          SizedBox(
              //width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: save,
                style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
                child: const Text('Save'),
              )),
        ]));
  }
}
