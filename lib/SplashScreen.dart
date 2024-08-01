// import 'dart:async';
// import 'package:flutter/material.dart';
// // import 'package:reel_view/main.dart';
//
// class SplashScreen extends StatefulWidget{
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//
//     super.initState();
//     Timer(Duration(seconds: 3), (){
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(),
//       ));
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         color: Colors.black87,
//         child: Center(
//             child: Image.asset(
//               'assets/images/logo1.png',
//               width: 100.0,
//               height: 100.0,
//             )
//         ),
//       ),
//     );
//   }
// }