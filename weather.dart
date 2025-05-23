import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

class WeatherPage extends StatefulWidget{

  final String cityName;  // Add this line

  const WeatherPage({super.key,   required this.cityName});

  State<WeatherPage> createState()=> _WeatherPageState();

}

class _WeatherPageState extends State<WeatherPage>{

  static const _apikey = "e95eafdd9be89044599c41afc0b6633f";
  final WeatherFactory _wf = WeatherFactory(_apikey);
  Weather ? _weather ;
  @override
  void initState() {
    super.initState();
    _wf.currentWeatherByCityName(widget.cityName).then((W){  // Use widget.cityName
      setState(() {
        _weather = W ;
      });
    }).catchError((error) {
      // Show error message if city not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not fetch weather for ${widget.cityName}')),
      );
      Navigator.pop(context); // Go back if error occurs
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text("Check the weather",style: TextStyle(
          fontWeight: FontWeight.bold,color: Colors.white
      ),),backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white,size: 30 ),
      ),
      body: ListView(
        children: [_buildUI()],
      )

    );
  }

  Widget _buildUI() {
    if (_weather == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SizedBox(
      width: MediaQuery
          .sizeOf(context)
          .width,
      height: MediaQuery
          .sizeOf(context)
          .height,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _locationHeader(),
          SizedBox(
            height: MediaQuery
                .sizeOf(context)
                .height * 0.05,
          ),
          _dateTimeinfo(),
          SizedBox(
            height: MediaQuery
                .sizeOf(context)
                .height * 0.02,
          ),
          _weathericon(),
          SizedBox(
            height: MediaQuery
                .sizeOf(context)
                .height * 0.02,
          ),
          _currentTemp(),
          SizedBox(
            height: MediaQuery
                .sizeOf(context)
                .height * 0.02,
          ),
          _extrainfo()
        ],
      ),
    );
  }



  Widget _locationHeader() {
    return Text(_weather?.areaName ?? "", style: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w500
    ),);
  }

  Widget _dateTimeinfo() {
    DateTime now = _weather!.date!;
    return Column(
      children: [
        Text(DateFormat("h:mm a").format(now), style: TextStyle(
            fontSize: 35
        ),),
        SizedBox(height: 10,),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(DateFormat("EEEE").format(now), style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16
            ),),
            Text(" ${DateFormat("d.M.y").format(now)} ", style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16
            ),),

          ],
        )
      ],
    );
  }

  Widget _weathericon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery
              .sizeOf(context)
              .height * 0.23,
          decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage("https://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"))
          ),),
        Text(_weather?.weatherDescription ?? " ", style: TextStyle(
            color: Colors.black,
            fontSize: 20
        ),)
      ],
    );
  }

  Widget _currentTemp() {
    return Text("${_weather?.temperature?.celsius?.toStringAsFixed(0)}° C ",
      style: TextStyle(
          fontSize: 90, fontWeight: FontWeight.w500, color: Colors.black
      ),);
  }Widget _extrainfo() {
    return Column(
      children: [

        Container(
          height: MediaQuery
              .sizeOf(context)
              .height * 0.15,
          width: MediaQuery
              .sizeOf(context)
              .width * 0.80,
          decoration: BoxDecoration(
              color: Colors.blueGrey.shade400,
              borderRadius: BorderRadius.circular(10)
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(" Max : ${_weather?.tempMax?.celsius?.toStringAsFixed(0)} °C",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 15
                    ),),
                  Text(" Min : ${_weather?.tempMin?.celsius?.toStringAsFixed(0)} °C",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 15
                    ),),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(" Wind : ${_weather?.windSpeed?.toStringAsFixed(0)} m/s ",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 15
                    ),),
                  Text(" Humidity : ${_weather?.humidity?.toStringAsFixed(0)} % ",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 15
                    ),),
                ],
              )
            ],

          ),
        ),
        SizedBox(height: 20,),
        Container(
          margin: EdgeInsets.only(bottom: 10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: Size(330, 60),
                backgroundColor: Colors.blue.shade800,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)
                )
            ),
            onPressed: (){
              Navigator.pop(context, _weather?.temperature?.celsius?.round() ?? 20);
            },
            child: Text('Use This Temperature',style: TextStyle(
                color: Colors.white,fontSize: 16
            ),),
          ),
        ),

      ],
    );

  }
}