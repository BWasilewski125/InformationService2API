// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:showcaseview/showcaseview.dart';
// import '../models/Styles.dart';
// import '../viewModels/LoginViewModel.dart';
// import 'EventWebPage.dart';  // <–– web’owa strona wydarzeń
//
// class LoginWebView extends StatefulWidget {
//   const LoginWebView({super.key});
//
//   @override
//   State<LoginWebView> createState() => _LoginWebViewState();
// }
//
// class _LoginWebViewState extends State<LoginWebView> {
//   final _formKey = GlobalKey<FormState>();
//   final _loginController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//   bool _obscureText = true;
//
//   @override
//   void dispose() {
//     _loginController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   void _togglePasswordVisibility() {
//     setState(() {
//       _obscureText = !_obscureText;
//     });
//   }
//
//   Future<void> _handleLogin() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//     final login = _loginController.text.trim();
//     final password = _passwordController.text.trim();
//
//     // Timeout na wypadek, gdyby backend przestał odpowiadać
//     Future.delayed(const Duration(seconds: 7), () {
//       if (_isLoading && mounted) {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Brak odpowiedzi z serwera')),
//         );
//       }
//     });
//
//     try {
//       final ok = await context.read<LoginViewModel>().login(login, password);
//       if (ok) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const EventWebPage()),
//         );
//       } else {
//         final msg = context.read<LoginViewModel>().errorMessage;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(msg)),
//         );
//         setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content:
//           Text('Nie udało się połączyć z serwerem. Spróbuj ponownie później.'),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Jeśli planujesz użyć showcaseview, odkomentuj niżej:
//     // return ShowCaseWidget(builder: Builder(builder: (_) => _buildBody()));
//     return _buildBody();
//   }
//
//   Widget _buildBody() {
//     return Scaffold(
//       backgroundColor: AppColors.theDarkest,
//       body: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 500),
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                     'Zaloguj się',
//                     style: TextStyle(
//                       fontFamily: AppTextStyles.Andada,
//                       fontSize: 32,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   TextFormField(
//                     controller: _loginController,
//                     enabled: !_isLoading,
//                     keyboardType: TextInputType.emailAddress,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontFamily: AppTextStyles.Andada,
//                     ),
//                     decoration: const InputDecoration(
//                       labelText: 'Login/Email',
//                       labelStyle: TextStyle(color: Colors.white70),
//                       filled: true,
//                       fillColor: AppColors.darkest,
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (v) {
//                       if (v == null || v.trim().isEmpty) {
//                         return 'Wprowadź swój login';
//                       }
//                       if (v.trim().length < 3) {
//                         return 'Za krótki login';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _passwordController,
//                     enabled: !_isLoading,
//                     obscureText: _obscureText,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontFamily: AppTextStyles.Andada,
//                     ),
//                     decoration: InputDecoration(
//                       labelText: 'Hasło',
//                       labelStyle: const TextStyle(color: Colors.white70),
//                       filled: true,
//                       fillColor: AppColors.darkest,
//                       border: const OutlineInputBorder(),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscureText
//                               ? Icons.visibility_off
//                               : Icons.visibility,
//                           color: Colors.white70,
//                         ),
//                         onPressed: _togglePasswordVisibility,
//                       ),
//                     ),
//                     validator: (v) {
//                       if (v == null || v.isEmpty) {
//                         return 'Wprowadź swoje hasło';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: TextButton(
//                       onPressed: () {
//                         // TODO: obsługa "Zapomniałeś hasła?"
//                       },
//                       child: const Text(
//                         'Zapomniałeś hasła?',
//                         style: TextStyle(color: Colors.white70),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _handleLogin,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.purple,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                       ),
//                       child: _isLoading
//                           ? const SizedBox(
//                         height: 24,
//                         width: 24,
//                         child: CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 2.5,
//                         ),
//                       )
//                           : const Text(
//                         'Zaloguj się',
//                         style: TextStyle(
//                           fontFamily: AppTextStyles.Andada,
//                           fontSize: 20,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
