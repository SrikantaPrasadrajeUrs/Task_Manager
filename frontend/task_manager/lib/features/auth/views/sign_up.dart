import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nameController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal:16,),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Sign Up.",style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold
              ),),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: "Name"
                ),
              ),
              const SizedBox(height: 10,),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                    hintText: "Email"
                ),
              ),
              const SizedBox(height: 10,),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                    hintText: "Password"
                ),
              ),
              const SizedBox(height: 10,),
             ElevatedButton(onPressed: (){
               print(formKey.currentState?.validate());
             }, child: const Text("SIGN UP",style: TextStyle(color: Colors.white),)),
              const SizedBox(height: 10,),
              RichText(
                  text: TextSpan(
                style: Theme.of(context).textTheme.titleMedium,
                text: "Already have an account? ",
                children: [
                  TextSpan(
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    text: "Sign in"
                  )
                ]
              ))
            ],
          ),
        ),
      ),
    );
  }
}
