
import 'package:app1/weather.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app1/Home_page.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MaterialApp(home: CalculateConsumptionPage()));
}

class CalculateConsumptionPage extends StatefulWidget {
  @override
  _EnergyConsumptionPageState createState() => _EnergyConsumptionPageState();
}

class _EnergyConsumptionPageState extends State<CalculateConsumptionPage> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _getTemperatureFromWeatherPage() async {
    final cityName = buildingAreaController.text.trim();

    if (cityName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter Building Area first',style: TextStyle(color: Colors.black) , textAlign: TextAlign.center,),
          backgroundColor: Colors.redAccent.shade100,),
      );
      return;
    }

    final temperature = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => WeatherPage(cityName: cityName),  // Pass the city name
      ),
    );

    if (temperature != null) {
      setState(() {
        temperatureController.text = temperature.toString();
      });
    }
  }

  Map<String,double>  estimerConsommationMensuelle({
    required double gazTrimestre, // en m³
    required double elecTrimestre, // en kWh
    required double surface,
    required int nbOccupants,
    required int temperature,
  }) {
    // === Electricity ===
    double elecMensuelleBase = elecTrimestre / 3;

    // Correction pour électricité (été surtout)
    double correctionElec = 0.0;
    if (temperature > 25) {
      correctionElec += 0.08; // climatisation
    }

    // === Gaz ===
    double gazMensuelleBase = gazTrimestre / 3;

    // Correction for gaz (winter surtout)
    double correctionGaz = 0.0;
    if (temperature < 15) {
      correctionGaz += 0.10; // heater in gaz
    }

    // === Communes === (surface & nb occupants)
    double correctionOccupants = (nbOccupants - 1) * 0.05;
    double correctionSurface = (surface - 80) * 0.005;

    // Applique the corrections in two types of energies
    double totalCorrectionGaz = (correctionGaz + correctionOccupants + correctionSurface).clamp(-0.25, 0.25);
    double totalCorrectionElec = (correctionElec + correctionOccupants + correctionSurface).clamp(-0.25, 0.25);

    double estimationGaz = gazMensuelleBase * (1 + totalCorrectionGaz);
    double estimationElec = elecMensuelleBase * (1 + totalCorrectionElec);


    return {
      'gaz_m3': estimationGaz,
      'electricite_kwh': estimationElec,
    };

  }



  double calculerCoutElectricite(double consommationKWh) {
    // calculate estimation cost for electricity
    double cout = 0.0;

    if (consommationKWh <= 125) {
      cout = consommationKWh * 0.416;
    } else if (consommationKWh <= 250) {
      cout = (125 * 0.416) + ((consommationKWh - 125) * 0.621);
    } else if (consommationKWh <= 1000) {
      cout = (125 * 0.416) + (125 * 0.621) + ((consommationKWh - 250) * 3.967);
    } else {
      cout = (125 * 0.416) + (125 * 0.621) + (750 * 3.967) +
          ((consommationKWh - 1000) * 4.175);
    }
    return cout ;
  }

    // Ajout de la taxe fixe trimestrielle

  double coutconsomationtrimesterielle(consommationKWh){

     double cout = 0 ;

      if (consommationKWh >= 70 && consommationKWh <= 190) {
        cout += 25;
      } else if (consommationKWh >= 191 && consommationKWh <= 390) {
        cout += 100;
      } else if (consommationKWh > 390) {
        cout += 200;
      }

      return cout;

  }



  double calculerCoutGaz(double consommationM3) { // calculate cost estimation for gaz
    double cout = 0.0;

    if (consommationM3 <= 25) {
      cout = consommationM3 * 0.326;
    } else if (consommationM3 <= 60) {
      cout = (25 * 0.326) + ((consommationM3 - 25) * 1.348);
    } else {
      cout = (25 * 0.326) + (35 * 1.348) + ((consommationM3 - 60) * 2.025);
    }

    return cout;
  }

  double convertionM3toKwh(double gazunit ){ // convert m3 of gaz to kwh
    return gazunit * 11.0 ;
  }

  double convertirThermEnM3(double consommationTh) {
    return consommationTh * 2.7624; // 1 th ≈ 2.7624 m³
  }

  double convertirM3enTherm(double consommationM3) {
    return consommationM3 * 0.362; // 1 m³ ≈ 0.362 th
  }

  double calculerCoutTotal(double consommationElectricite, double consommationGaz) { // calculate sum of estimation cost (gaz + electricity)
    // Calculate individual costs
    double coutElec = calculerCoutElectricite(consommationElectricite);
    double coutGaz = calculerCoutGaz(consommationGaz);

    // Calculate total cost
    double coutTotal = coutElec + coutGaz;

    return coutTotal;
  }


  final TextEditingController electricityUsageController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController gazController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController buildingAreaController = TextEditingController();
  final TextEditingController occupantsController = TextEditingController();
  final TextEditingController surfaceController = TextEditingController();
  final TextEditingController temperatureController = TextEditingController();
  final TextEditingController heatingSystemController = TextEditingController();
  final TextEditingController airConditioningController = TextEditingController();
  final TextEditingController freezerController = TextEditingController();
  final TextEditingController otherEquipmentController = TextEditingController();

  bool heatingSystem = false;
  bool airConditioning = false;
  bool freezer = false;
  bool otherEquipment = false;






  Future<void> _saveDataToFirebase() async {



    if (_formKey.currentState!.validate()) {
      try {

        final elec = double.tryParse(electricityUsageController.text) ?? 0.0;
        final gaz = double.tryParse(gazController.text) ?? 0.0;

        // Get current date
        final dateStr = dateController.text;
        final date = DateFormat('d/M/yyyy').parse(dateStr);
        final trimester = 'T${((date.month - 1) ~/ 3) + 1}'; // Calculate trimester
        final year = date.year.toString();

        double convertM3toth = convertirM3enTherm(gaz);


        final estimationEnergy = estimerConsommationMensuelle(
          gazTrimestre: convertM3toth ,
          elecTrimestre: elec,
          surface: double.tryParse(surfaceController.text) ?? 80.0,
          nbOccupants: int.tryParse(occupantsController.text) ?? 1,
          temperature: int.tryParse(temperatureController.text) ?? 20,
        ) ;


        double elect = estimationEnergy['electricite_kwh'] ?? 0.0 ;
        double gas = estimationEnergy['gaz_m3'] ?? 0.0 ;

        double convertThtoM3 = convertirThermEnM3(gas) ;

        double convertm3toKwh = convertionM3toKwh(convertThtoM3);


        double coutGaz = calculerCoutGaz(convertThtoM3);
        double coutElec = calculerCoutElectricite(estimationEnergy['electricite_kwh'] ?? 0.0 );
        double totalcostestimated = coutGaz + coutElec;



        double estiamtiontotal = convertm3toKwh + elect ;

        double consototal = elec + convertm3toKwh ;

        final uid = FirebaseAuth.instance.currentUser!.uid;



          final docRef =  await FirebaseFirestore.instance.collection('users').doc(uid).collection('energyconsumption').add({


          "date": dateStr,
          'trimester': trimester, // Explicitly store trimester
          'year': year,
          'electricityusage': elec,
          'gazusage': convertM3toth,
          'cost': double.tryParse(costController.text) ?? 0.0,

          'apartementarea': buildingAreaController.text,
          'numberofoccupants': int.tryParse(occupantsController.text) ?? 0 ,
          'surface': double.tryParse(surfaceController.text) ?? 0.0,
          "temperature": double.tryParse(temperatureController.text) ?? 0,

          'totalconsumption': consototal ,// total consumption of energy (gaz , electricity)
          'estimaitedconsumption': estimationEnergy , // estimation energy concern gaz and electricity

          'estimationmtotal': estiamtiontotal , //total estimation for one month
          'estimatedElect': elect ,
           'estimatedgas': gas ,
          'estimatedGazConverted': convertm3toKwh ,
          'totalestimatedCost' : totalcostestimated , // total estimated cost for one month



          'timestemp': FieldValue.serverTimestamp(),

        });

        if (heatingSystem) {
          await docRef.collection('equipmentused').add({
            'name': 'Heating System',
            'value': double.tryParse(heatingSystemController.text) ?? 0.0,
          });
        }
        if (airConditioning) {
          await docRef.collection('equipmentused').add({
            'name': 'Air Conditioning',
            'value': double.tryParse(airConditioningController.text) ?? 0.0,
          });
        }
        if (freezer) {
          await docRef.collection('equipmentused').add({
            'name': 'Freezer',
            'value': double.tryParse(freezerController.text) ?? 0.0,
          });
        }
        if (otherEquipment) {
          await docRef.collection('equipmentused').add({
            'name': otherEquipmentController.text,
            'value': 0.0 ,
          });
        }


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data saved successfully!', style: TextStyle(color: Colors.green.shade900), textAlign: TextAlign.center),
          backgroundColor: Colors.green.shade400,),
        );

        _formKey.currentState!.reset();
        [
          electricityUsageController,
          dateController,
          gazController,
          costController,
          buildingAreaController,
          occupantsController,
          surfaceController,
          heatingSystemController,
          airConditioningController,
          freezerController,
          otherEquipmentController
        ].forEach((controller) => controller.clear());

        setState(() {
          heatingSystem = false;
          airConditioning = false;
          freezer = false;
          otherEquipment = false;
        });

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      }


    }

  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Energy Consumption', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white,size: 30 ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _buildSectionTitle('Monthly Energy Consumption:'),
                _buildTextField("Electricity (kWh)", electricityUsageController),
                _buildTextField("Gas (Th)", gazController),

                Container(
                  margin: EdgeInsets.all(6),
                  alignment: Alignment.centerRight,
                //  padding: EdgeInsets.symmetric(vertical: 4,),
                  child: TextButton(
                    onPressed: (){
                      _showBottomSheet(context);
                    },

                    child: Text("Where i find the information ?",style: TextStyle(
                      fontSize: 18,color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationThickness: 2,
                        decorationColor: Colors.blue
                    ),textAlign: TextAlign.right,),
                   // icon: Icon(Icons.emoji_objects_rounded,color: Colors.amber,),

                  ),
                ),

                _buildTextField("Cost (DA)", costController),


                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: "Date",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        dateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the date';
                      }
                      return null;
                    },
                  ),
                ),


                _buildSectionTitle('Apartment Information:'),

              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  controller: buildingAreaController,
                  decoration: InputDecoration(
                    labelText: ' Apartment Area ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the Area';
                    }
                    return null;
                  },
                ),
              ),

                _buildTextField("Number of Occupants", occupantsController),
                _buildTextField("Surface (m²)", surfaceController),

                _buildSectionTitle("required check weather :"),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(400, 60),
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)
                      )
                  ),
                  onPressed: _getTemperatureFromWeatherPage,
                  child: Text('Get Current Temperature',style: TextStyle(
                      color: Colors.white,fontSize: 16
                  ),),
                ),


                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(170, 60),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _saveDataToFirebase,
                      child: Text('Save Data', style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      )),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(170, 60),
                        backgroundColor: Colors.red.shade300,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                      },
                      child: Text("Go Home", style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      )),
                    ),

                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white70,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView(
          padding: EdgeInsets.all(6) ,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(
                      color: Colors.lightBlueAccent.shade400,
                      width: 1
                  )
              ),
              margin: EdgeInsets.all(15),
              child: ListTile(
              leading: Icon(Icons.contact_support_rounded,color: Colors.amber,size: 30,),

                minTileHeight: 60,
                title: Text("Add the value of electricity and gas in registration energy ",
                    style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w600),
                    textAlign: TextAlign.left,

                ),

              ),
            ),
            
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
                  side: BorderSide(
                    width: 2,
                    color: Colors.lightBlueAccent.shade400
                  )
              ),
              margin: EdgeInsets.only(left: 15,right: 15),
              child: Image.asset("images/facture1.png",
                height: 250,width:400 ,alignment: Alignment.center,),
            ),
            
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(
                      color: Colors.lightBlueAccent.shade400,
                      width: 1
                  )
              ),
              margin: EdgeInsets.all(15),
              child: ListTile(
                leading: Icon(Icons.contact_support_rounded,color: Colors.amber,size: 30,),
                minTileHeight: 60,
                title: Text("Add the sum value of cost in registration Energy",
                    style: TextStyle(
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w600,
                    ),textAlign: TextAlign.left,),
              ),

            ),

            Container(
              margin: EdgeInsets.only(left: 15,right: 15,bottom: 15),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  child: Text(
                    ' Understood !',
                    style: TextStyle(fontSize: 18,color: Colors.white),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  minimumSize: Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),


          ],
        );
      },
    );
  }



  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

}





