import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:usersapp/global.dart';
import 'package:usersapp/info/app_info.dart';
import 'package:usersapp/map.dart';
import 'package:usersapp/model/predictedplaces.dart';
import 'package:usersapp/widget/directions.dart';
import 'package:usersapp/widget/progressdialog.dart';
import 'package:usersapp/widget/request.dart';

class PlacePredictionTile extends StatefulWidget {
  const PlacePredictionTile({super.key, this.predictedPlaces});
  final PredictedPlaces? predictedPlaces;

  @override
  State<PlacePredictionTile> createState() => _PlacePredictionTileState();
}

class _PlacePredictionTileState extends State<PlacePredictionTile> {
  getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Setting up Drop-off,Please wait....",
            ));
    String placeDirectionDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";
    var responseApi =
        await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);
    Navigator.pop(context);
    if (responseApi == "Error Occured, No Response") {
      return;
    }
    if (responseApi["status"] == "Ok") {
      Directions directions = Directions();
      directions.locationName = responseApi["result"]["name"];
      directions.locationId = placeId;
      directions.locationLatitude = responseApi["result"]["location"]["lat"];
      directions.locationLongitude = responseApi["result"]["location"]["lng"];
      Provider.of<AppInfo>(context, listen: false)
          .updateDropOffLocationAddress(directions);
      setState(() {
        userDropOffAddress = directions.locationName!;
      });
      Navigator.pop(context, "obtainedDropOff");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return ElevatedButton(
        onPressed: () {
          getPlaceDirectionDetails(widget.predictedPlaces!.place_id, context);
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: darkTheme ? Colors.black : Colors.white,
          backgroundColor: darkTheme ? Colors.amber.shade200 : Colors.blue,
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(
                Icons.add_location,
                color: darkTheme ? Colors.amber.shade300 : Colors.blue,
              ),
              SizedBox(width: 10),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.predictedPlaces!.main_text!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: darkTheme ? Colors.amber.shade300 : Colors.blue,
                      )),
                  Text(widget.predictedPlaces!.secondary_text!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: darkTheme ? Colors.amber.shade300 : Colors.blue,
                      )),
                ],
              ))
            ],
          ),
        ));
  }
}
