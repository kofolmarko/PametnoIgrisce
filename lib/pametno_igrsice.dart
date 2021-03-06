import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

const String deviceName = 'PametnoIgrisce';
const String serviceId = '0000aaaa-0000-1000-8000-00805f9b34fb';
const String charId = '0000bbbb-0000-1000-8000-00805f9b34fb';
BluetoothDevice? _device = null;

class PametnoIgrisceApp extends StatefulWidget {
  @override
  State<PametnoIgrisceApp> createState() => _PametnoIgrisceAppState();
}

class _PametnoIgrisceAppState extends State<PametnoIgrisceApp> {
  String currentActivity = 'Nalaganje...';
  String currentActivityImg = 'assets/night.png';

  void subscribeToService() async {
    FlutterBlue flutterBlue = FlutterBlue.instance;

    await flutterBlue.startScan(timeout: Duration(seconds: 4));

    await flutterBlue.scanResults.listen((resultsList) {
      setState(() {
        currentActivity = 'Iščem naprave...';  
      });
      
      resultsList.forEach((r) async {
        print(r.device.name);
        if (r.device.name == deviceName) {
          setState(() {
            currentActivity = 'Najdena naprava: ' + r.device.name;
          });

          _device = r.device;
        }
      });
    });

    flutterBlue.stopScan();

    if (_device != null) {
      setState(() {
        currentActivity = 'Povezujem se z napravo: ' + deviceName;
      });
      
      await _device?.connect();
      currentActivity = 'Iščem storitve...';
      List<BluetoothService>? services = await _device?.discoverServices();
      services?.forEach((service) async {
        String serviceUuid = service.uuid.toString();
          if (serviceUuid == serviceId) {
            var characteristics = service.characteristics;
            for(BluetoothCharacteristic c in characteristics) {
              setState(() {
                currentActivity = 'Iščem karakteristike...';
              });
              
              if (c.uuid.toString() == charId) {
                await c.setNotifyValue(true);
                c.value.listen((value) {
                  setState(() { 
                    currentActivity = getActivity(value.first);
                    currentActivityImg = getActivityImg(value.first);
                  });
                });
              }
            }
          }
      });
    }
  }

  @override
  void initState() {
    subscribeToService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.purple[400],
      home: Scaffold(
        appBar: AppBar(
          title: Text('Pametno Igrišče'),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 255, 166, 41),
        ),
        body:
          Column(
            children: [
              Center(
                child: Container(
                  child: Text(
                    'Trenutno stanje na igrišču:',
                      style: TextStyle(
                      fontSize: 20
                    ),
                  ),
                  margin: EdgeInsets.all(30),
                )
              ),
              Center(
                child: Container(
                  child: Image(
                    image: AssetImage(currentActivityImg)
                  ),
                  margin: EdgeInsets.all(20),
                )
              ),
              Center(
                child: Container(
                  child: Text(
                    currentActivity,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 35
                    ),
                  ),
                  margin: EdgeInsets.all(30),
                )
              ),
              // Center(
              //   child: Row(
              //     children: [
              //       Container(
              //         height: 100,
              //         width: 100,
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.all(Radius.circular(10)),
              //           color: Colors.amber
              //         ),
              //         margin: EdgeInsets.all(30),
              //         child: Text('Vreme'),
              //       ),
              //       Spacer(),
              //       Container(
              //         height: 100,
              //         width: 100,
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.all(Radius.circular(10)),
              //           color: Colors.blue,
              //         ),
              //         margin: EdgeInsets.all(30),
              //         child: Text('Lokacija'),
              //       )
              //     ],
              //   ),
              // )
            ],
          )
          
      )
    );
  }
  
  String getActivity(int state) {
    switch (state) {
      case 0: return 'Košarka';
      case 1: return 'Nogomet';
      case 2: return 'Možnost vandalizma';
      case 3: return 'Pogovor';
      case 4: return 'Brez aktivnosti';
      default: return 'Napaka v sistemu';
    }
  }
  
  String getActivityImg(int state) {
    switch (state) {
      case 0: return 'assets/basketball.png';
      case 1: return 'assets/football.png';
      case 2: return 'assets/vandalism.png';
      case 3: return 'assets/talking.png';
      case 4: return 'assets/night.png';
      default: return 'assets/cancel.png';
    }
  }
}