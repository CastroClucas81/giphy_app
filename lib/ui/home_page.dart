import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:giphy_app/ui/gif_page.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _baseApiRoute = 'https://api.giphy.com/v1/gifs';
  String? _search;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null || _search!.isEmpty)
      response = await http.get(Uri.parse(
          '$_baseApiRoute/trending?api_key=494QLsBc8idAuLS21EeurYLtbbfUaUpY&limit=20&rating=g'));
    else
      response = await http.get(Uri.parse(
          '$_baseApiRoute/search?api_key=494QLsBc8idAuLS21EeurYLtbbfUaUpY&q=$_search&limit=20&offset=$_offset&rating=g&lang=en'));

    return jsonDecode(response.body);
  }

  int _getCount(List data) {
    if (_search == null || _search!.isEmpty) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
          'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif',
          fit: BoxFit.cover,
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                onSubmitted: (text) {
                  setState(() {
                    _search = text;
                    _offset = 0;
                  });
                },
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  labelText: "Pesquise aqui!",
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      if (snapshot.hasError)
                        return Container();
                      else
                        return _createGifTable(context, snapshot);
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _createGifTable(
    BuildContext context,
    AsyncSnapshot snapshot,
  ) {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: (context, index) {
        String image =
            snapshot.data["data"][index]["images"]["fixed_height"]["url"];

        if (_search == null || index < snapshot.data["data"].length) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GifPage(
                    gifData: snapshot.data["data"][index],
                  ),
                ),
              );
            },
            onLongPress: () {
              Share.share(image);
            },
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: image,
              height: 300.0,
              fit: BoxFit.cover,
            ),
          );
        } else {
          return Container(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _offset += 19;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70.0,
                  ),
                  Text(
                    "Carregar mais",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                    ),
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
