import 'dart:convert';
import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {



     determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    locationValue = await Geolocator.getCurrentPosition();
    fetchWeatherData();
    fetchForecastData();
    print(" latitude value issssssss${locationValue.latitude}");
    print(" latitude value issssssss${locationValue.longitude}");
  }

  late Position locationValue;
  Map<String,dynamic> ?weather;
  Map<String,dynamic> ?forecast;

  fetchWeatherData()async{
       String weatherUrl="https://api.openweathermap.org/data/2.5/weather?lat=${locationValue.latitude}&lon=${locationValue.longitude}&appid=5d1baf9a236b13d26e491f69dcaa10cd";
       var responce = await http.get(Uri.parse(weatherUrl));
       print("Status code issssss${responce.statusCode}");
       weather=Map<String,dynamic>.from(jsonDecode(responce.body));
       setState(() {

       });
       print("weather valus isss$weather");
  }

  fetchForecastData()async{
       String weatherUrl="https://api.openweathermap.org/data/2.5/forecast?lat=${locationValue.latitude}&lon=${locationValue.longitude}&appid=5d1baf9a236b13d26e491f69dcaa10cd";
       var responce = await http.get(Uri.parse(weatherUrl));
       forecast=Map<String,dynamic>.from(jsonDecode(responce.body));
setState(() {

});
  }

  @override
  void initState() {
    // TODO: implement initState
    determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body:weather!=null && forecast  !=null? Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
            child: Column(
              children: [
                Text("${Jiffy.parse(DateTime.now().toString()).format(pattern: 'MMM do yy, h:mm')}"),
                Text("${weather!["name"]}"),
              ],
            ),
            ),

            Center(
              child: Column(
                children: [
                  Image.network("https://openweathermap.org/img/wn/${weather!["weather"][0]["icon"]}@2x.png"),
                  Text("${weather!["main"]['temp']} °"),
                ],
              ),
            )
,

            Column(
              children: [
                Text("${forecast!["list"][0]["main"]["feels_like"]} °"),
                Text("${forecast!["list"][0]["weather"][0]["description"]} °"),
                Text("${weather!["weather"][0]["description"]} °"),

                SizedBox(height: 50,),
                Text("Sunrise ${Jiffy.parse("${DateTime.fromMillisecondsSinceEpoch(weather!["sys"]["sunrise"] *1000)}").format(pattern: " h:mm a")}"),
              ],
            ),
            Spacer(),
            Container(
              height: 200,
              child: ListView.builder(
                  itemCount: 10,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context,index){
                return Container(
                  width:  250,
                  child: Column(
                    children: [
                      Text("${forecast!["list"][index]["dt_txt"]}"),
                      Image.network("https://openweathermap.org/img/wn/${forecast!["list"][index]["weather"][0]["icon"]}@2x.png"),
                      Text("${forecast!["list"][index]["weather"][0]["description"]}")
                    ],
                  ),
                );
              }),
            )

          ],
        ),
      ) :CircularProgressIndicator(),
    );
  }
}
