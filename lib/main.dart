import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: DynamicListPage());
  }
}

class DynamicListPage extends StatefulWidget {
  const DynamicListPage({super.key});

  @override
  State<DynamicListPage> createState() => _DynamicListPageState();
}

class _DynamicListPageState extends State<DynamicListPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> passwordList = [];
  final List<bool> _obscureList = [];

  bool _obscureText = true;

  void saveNewPassword() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        passwordList.add(text);
        _obscureList.add(true);
        _controller.clear();
      });
    }
  }

  void removePassword(int index) {
    setState(() {
      passwordList.removeAt(index);
      _obscureList.removeAt(index);
    });
  }

  Future<bool> _verifyPin(BuildContext context) async {
    final TextEditingController _pinController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Enter PIN to view password'),
            content: TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'PIN',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (_pinController.text == '1234') {
                    Navigator.of(context).pop(true);
                  } else {
                    Navigator.of(context).pop(false);
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );

    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password Manager'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (int i = 0; i < passwordList.length; i++)
              ListTile(
                title: Text(
                  _obscureList[i]
                      ? '•' * passwordList[i].length
                      : passwordList[i],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _obscureList[i]
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () async {
                        if (!_obscureList[i]) {
                          // Already visible – just hide without asking
                          setState(() {
                            _obscureList[i] = true;
                          });
                        } else {
                          // Currently hidden – ask for PIN before showing
                          final pinCorrect = await _verifyPin(context);
                          if (pinCorrect) {
                            setState(() {
                              _obscureList[i] = false;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Incorrect PIN')),
                            );
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => removePassword(i),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: _controller,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'Enter new password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Save'),
                  onPressed: saveNewPassword,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
