import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  late File _image;
  late List _output;
  final picker = ImagePicker();

  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  detectImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _output = output!;
      _loading = false;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  pickImage() async {
    var image = await picker.getImage(source: ImageSource.camera);

    if (image == null) {
      return null;
    }
    setState(() {
      _image = File(image.path);
    });

    detectImage(_image);
  }

  pickGalleryImage() async {
    var image = await picker.getImage(source: ImageSource.gallery);

    if (image == null) {
      return null;
    }
    setState(() {
      _image = File(image.path);
    });

    detectImage(_image);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0x004242),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
            ),
            Text(
              "Dog Cat Recognization",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Center(
              child: _loading
                  ? Container(
                      width: 400,
                      child: Column(
                        children: [
                          Image.network(
                              "https://cdn3.vectorstock.com/i/1000x1000/95/82/cute-cat-and-dog-icons-vector-13499582.jpg"),
                          SizedBox(
                            height: 50,
                          )
                        ],
                      ))
                  : Container(
                      child: Column(
                        children: [
                          Container(
                            height: 250,
                            child: Image.file(_image),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          _output != null
                              ? Text(
                                  '${_output[0]['label']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                )
                              : Container(),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => {pickImage()},
                    child: Container(
                      width: MediaQuery.of(context).size.width - 200,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.yellowAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Capture a Photo',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () => {pickGalleryImage()},
                    child: Container(
                      width: MediaQuery.of(context).size.width - 200,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.yellowAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Select a photo',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
