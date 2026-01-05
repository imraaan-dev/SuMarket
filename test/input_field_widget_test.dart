import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';


void main() {


  testWidgets('email labeled InputField widget test', (tester) async {
    await tester.pumpWidget(MyWidget());

    final labelFinder = find.text('Email');
    final hintFinder = find.text('abc@sabanciuniv.edu');

    expect(labelFinder, findsOneWidget);
    expect(hintFinder, findsOneWidget);
  });
}



//we copy _InputField widget from the login screen, this is what we will test
class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

//We wrap the widget in a placeholder widget (MyWidget) to create an environment for the widget to be tested in.
class MyWidget extends StatelessWidget {
  MyWidget({super.key});
  final _emailController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(title: Text("test")),
        body: _InputField(
          controller: _emailController,
          label: 'Email',
          hint: 'abc@sabanciuniv.edu',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            final v = value?.trim() ?? '';
            if (v.isEmpty) return 'Please enter your email';
            if (!v.contains('@')) return 'Enter a valid email address';
            return null;
          },
        )
      ),
    );
  }
}