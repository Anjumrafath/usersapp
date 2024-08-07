import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:usersapp/map.dart';
import 'package:usersapp/model/predictedplaces.dart';
import 'package:usersapp/widget/placepredictiontile.dart';
import 'package:usersapp/widget/request.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({super.key});

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  List<PredictedPlaces> placesPredictedList = [];
  findPlaceAutoCompleteSearch(String inputText) async {
    if (inputText.length > 1) {
      String urlAutoCompleteSearch =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&componets=country:USA";
      var responseAutoCompleteSearch =
          await RequestAssistant.receiveRequest(urlAutoCompleteSearch);
      if (responseAutoCompleteSearch == "Error Occured, No Response") {
        return;
      }

      if (responseAutoCompleteSearch["Status"] == "OK") {
        var placePredictions = responseAutoCompleteSearch["Predictions"];
        var placePredictionsList = (placePredictions as List)
            .map((jsonData) => PredictedPlaces.fromJson(jsonData))
            .toList();
        setState(() {
          placesPredictedList = placePredictionsList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: darkTheme ? Colors.black : Colors.white,
          appBar: AppBar(
            backgroundColor: darkTheme ? Colors.amber.shade300 : Colors.blue,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back,
                  color: darkTheme ? Colors.black : Colors.white),
            ),
            title: Text(
              "Search  Location",
              style: TextStyle(
                color: darkTheme ? Colors.black : Colors.white,
              ),
            ),
            elevation: 0,
          ),
          body: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.amber.shade300 : Colors.blue,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white54,
                      blurRadius: 0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.adjust_sharp,
                              color: darkTheme ? Colors.black : Colors.white),
                          SizedBox(height: 18),
                          Expanded(
                            child: Padding(
                                padding: EdgeInsets.all(8),
                                child: TextField(
                                  onChanged: (value) {
                                    findPlaceAutoCompleteSearch(value);
                                  },
                                  decoration: InputDecoration(
                                      hintText: "Search Location here...",
                                      fillColor: darkTheme
                                          ? Colors.black
                                          : Colors.white,
                                      filled: true,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(
                                        left: 11,
                                        top: 8,
                                        bottom: 8,
                                      )),
                                )),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              //display place prediction result
              (placesPredictedList.length > 0)
                  ? Expanded(
                      child: ListView.separated(
                        itemCount: placesPredictedList.length,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return PlacePredictionTile(
                            predictedPlaces: placesPredictedList[index],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            height: 0,
                            color:
                                darkTheme ? Colors.amber.shade300 : Colors.blue,
                            thickness: 0,
                          );
                        },
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
