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
  String currentActivity = 'Invalid information';
  String currentActivityImg = 'assets/night.png';

  void subscribeToService() async {
    FlutterBlue flutterBlue = FlutterBlue.instance;

    await flutterBlue.startScan(timeout: Duration(seconds: 4));

    await flutterBlue.scanResults.listen((resultsList) {
      setState(() {
        currentActivity = 'Scanning for devices...';  
      });
      
      resultsList.forEach((r) async {
        print(r.device.name);
        if (r.device.name == deviceName) {
          setState(() {
            currentActivity = 'Device found: ' + r.device.name;
          });

          _device = r.device;
        }
      });
    });

    flutterBlue.stopScan();

    if (_device != null) {
      setState(() {
        currentActivity = 'Connecting to device: ' + deviceName;
      });
      
      await _device?.connect();
      currentActivity = 'Searching for services...';
      List<BluetoothService>? services = await _device?.discoverServices();
      services?.forEach((service) async {
        String serviceUuid = service.uuid.toString();
          if (serviceUuid == serviceId) {
            var characteristics = service.characteristics;
            for(BluetoothCharacteristic c in characteristics) {
              setState(() {
                currentActivity = 'Searching for characteristics...';
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
          title: Text('PametnoIgrisce'),
          backgroundColor: Colors.orange,
        ),
        body:
          Column(
            children: [
              Center(
                child: Text(
                  currentActivity
                ),
              ),
              Center(
                child: Image(
                  image: AssetImage(currentActivityImg)
                ),
              )
            ],
          )
          
      )
    );
  }
  
  String getActivity(int state) {
    switch (state) {
      case 0: return 'Basketball';
      case 1: return 'Football';
      case 2: return 'Breaking bottles';
      case 3: return 'Talking';
      case 4: return 'No activity';
      default: return 'Invalid data';
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