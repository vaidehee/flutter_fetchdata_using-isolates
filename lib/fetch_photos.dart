import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'photo_model.dart';

class FatchPhotoScreen extends StatefulWidget {
  @override
  _FatchPhotoScreenState createState() => _FatchPhotoScreenState();
}

class _FatchPhotoScreenState extends State<FatchPhotoScreen>
    with TickerProviderStateMixin {
  AnimationController animationController;
  Animation<BorderRadius> borderWithAnimation;

  @override
  void initState() {
    super.initState();

    //animation is used to check the performance of the app while fetching data with and without isolates
    animationController = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
           animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
           animationController.forward();
        }
      });

    borderWithAnimation = BorderRadiusTween(
      begin: BorderRadius.circular(100.0),
      end: BorderRadius.circular(0.0),
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.linear,
    ));
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 30.0,
            ),
            AnimatedBuilder(
              animation: borderWithAnimation,
              builder: (context, child) {
                return Center(
                  child: Container(
                    alignment: Alignment.center,
                    width: 300,
                    height: 50,
                    child: Text("Button",style: TextStyle(color: Colors.white,fontSize: 15.0),),
                    decoration: BoxDecoration(
                      color: Colors.cyan,
                      borderRadius: borderWithAnimation.value,
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: FutureBuilder<List<Photo>>(
                  future: fetchPhotos(http.Client()),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) print(snapshot.error);

                    return snapshot.hasData
                        ? PhotosList(
                            photos: snapshot.data,
                          )
                        : Center(child: CircularProgressIndicator());
                  }),
            ),
          ],
        ),
      )),
    );
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }
}

List<Photo> parsePhotos(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
}

Future<List<Photo>> fetchPhotos(http.Client client) async {
  final response =
      await client.get('https://jsonplaceholder.typicode.com/photos');


  // return parsePhotos(response.body);  //fetch data without using isolates

  return compute(parsePhotos, response.body);  //compute is used to fetch data with using isolates
}

class PhotosList extends StatelessWidget {
  final List<Photo> photos;

  PhotosList({Key key, this.photos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return Image.network(photos[index].thumbnailUrl);
      },
    );
  }
}
