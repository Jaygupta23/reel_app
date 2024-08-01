import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:reel_view/AddReelPage.dart';
import 'VideoPlayerWidget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> videoUrls = [];
  bool isLoading = true;
  int? selectedVideoId; // Use int? to handle nullable values

  @override
  void initState() {
    super.initState();
    _fetchVideoUrls();
  }

  Future<void> _fetchVideoUrls() async {
    try {
      print("API running ------");
      final response = await http.get(Uri.parse("http://192.168.0.113:8000/videos/getVideos/"));
      print("API response : $response");
      if (response.statusCode == 200) {
        final Map<String, dynamic> mapResponse = jsonDecode(response.body);
        print(mapResponse);
        setState(() {
          videoUrls = List<String>.from(mapResponse['data'].map(
                  (video) => "http://192.168.0.113:8000/media/" + video['path']));
          isLoading = false;
          print(videoUrls);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("Error: $e");
      // Handle error appropriately here
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleDeleteReel() async {
    if (selectedVideoId != null) {
      print("Deleting video with ID: $selectedVideoId");
      // Add your delete API call here
    } else {
      print("No video selected for deletion");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : PageView.builder(
              itemBuilder: (context, index) {
                print(index);
                selectedVideoId = index; // Update the selectedVideoId based on the current index
                return VideoPlayerWidget(url: videoUrls[index]);
              },
              itemCount: videoUrls.length,
              scrollDirection: Axis.vertical,
            ),
          ),
          Container(
            width: double.infinity,
            height: 50,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.squarePlus),
                  iconSize: 40,
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddReelPage(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.circlePlay),
                  iconSize: 40,
                  color: Colors.white,
                  onPressed: () {
                    // Handle button press
                  },
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.solidUser),
                  iconSize: 40,
                  color: Colors.blue.shade100,
                  onPressed: _handleDeleteReel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
