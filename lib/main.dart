import 'package:flutter/material.dart';
import 'package:reel_view/SplashScreen.dart';
import 'VideoPlayerWidget.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {

  final List<String> videoUrls = [
    'https://videos.pexels.com/video-files/27384916/12131948_360_640_30fps.mp4',
    'https://videos.pexels.com/video-files/6869468/6869468-uhd_1440_2560_30fps.mp4',
    'https://videos.pexels.com/video-files/20609537/20609537-sd_360_640_30fps.mp4',
    'https://videos.pexels.com/video-files/18446385/18446385-sd_360_640_30fps.mp4',
    'https://videos.pexels.com/video-files/16567442/16567442-uhd_1440_2560_60fps.mp4',
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: AppBar(backgroundColor: Theme.of(context).colorScheme.inverseSurface,),


      ),
      body: PageView.builder(
        itemBuilder: (context, index){
        return VideoPlayerWidget(url: videoUrls[index]);
      },
        itemCount: videoUrls.length,
        scrollDirection: Axis.vertical
      ),
    );
  }
}
