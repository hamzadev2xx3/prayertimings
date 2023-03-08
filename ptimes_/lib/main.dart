import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import 'package:geocoding/geocoding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Fetching Co-ordinates of the user
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  double latitude = position.latitude;
  double longitude = position.longitude;
  print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
  print('------------My Prayer Times------------');

  final myCoordinates = Coordinates(latitude, longitude);
  //Fetching Country name by passing the long,lat.
  final List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);
  final Placemark placemark = placemarks.first;
  final String country = placemark.country!;

  print('country:$country');

  //Dictionary Containing Countries with their respective Calculation Method
  final methods = {
    'Pakistan,Afghanistan,Malaysia,India,Indonesia,Bangladesh':
        CalculationMethod.karachi,
    'Saudi Arabia,Qatar,Bahrain,Jordan,United Arab Emirates,Kuwait,Yemen,Syria,Oman':
        CalculationMethod.umm_al_qura,
    'United States,United Kingdom,Canada': CalculationMethod.north_america,
    'Algeria,Germany,Italy,Japan,Azerbaijan,Philippines,Solomon Islands,Mexico,Argentina,Timor-Leste,Cyprus,South Africa,Bhutan,Maldives,Brunei,Brazil,Taiwan,Hong Kong,Australia,Papua New Guinea,New Zealand,Fiji,Tajikistan,Georgia,Mongolia,Armenia,Palestine,Israel,Laos,Lebanon,Kyrgyzstan,Turkmenistan,Iraq,Iran,Nepal,North Korea,Sri Lanka,Kazakhstan,Cambodia,Thailand,Uzbekistan,South Korea,Myanmar (Burma),Vietnam,Spain,Ukraine,Poland,Romania,Netherlands,Belgium,Czechia,Greece,Portugal,Sweden,Hungary,Belarus,Austria,Serbia,Switzerland,Bulgaria,Denmark,Finland,Slovakia,Norway,Ireland,Croatia,Moldova,Bosnia and Herzegovina,Albania,Lithuania,North Macedonia,Slovenia,Latvia,Estonia,Montenegro,Luxembourg,Malta,Iceland,Andorra,Monaco,Liechtenstein,San Marino,Vatican City,China,':
        CalculationMethod.muslim_world_league,
    'Indonesia,Singapore': CalculationMethod.singapore,
    'Turkey': CalculationMethod.turkey,
  };

  // Select the appropriate CalculationMethod based on the user's country
  CalculationMethod method =
      CalculationMethod.karachi; //Default method if country name not found
  for (var entry in methods.entries) {
    var countries = entry.key.split(',');
    if (countries.contains(country)) {
      method = entry.value;
      break;
    }
  }

  //TimeZone Just For Testing
  //final kushtiaUtcOffset = Duration(hours: 6);
  final KuwaitUTC = Duration(hours: 3);
  // then pass your offset to PrayerTimes like this:
  //final prayerTimes = PrayerTimes(coordinates, date, params, utcOffset: newYorkUtcOffset);

  // Calculate prayer times using the selected CalculationMethod and the user's location
  //final params = CalculationParameters(fajrAngle: 16, ishaAngle: 15);
  final params = method.getParameters();
  //print('Selected CalculationMethod: ${method.name}');
  params.madhab = Madhab.hanafi; // Usage for Asr Time
  final prayerTimes = PrayerTimes.today(myCoordinates, params,
      utcOffset: KuwaitUTC); // 3rd parameter->> utcOffset: KuwaitUTC

  print(
      "---Today's Prayer Times in Your Local Timezone(${prayerTimes.fajr.timeZoneName})---");
  print('Fajr: ${DateFormat.jm().format(prayerTimes.fajr)}');
  print('Sunrise: ${DateFormat.jm().format(prayerTimes.sunrise)}');
  print('Dhuhr: ${DateFormat.jm().format(prayerTimes.dhuhr)}');
  print('Asr: ${DateFormat.jm().format(prayerTimes.asr)}');
  print('Maghrib: ${DateFormat.jm().format(prayerTimes.maghrib)}');
  print('Sunset: ${DateFormat.jm().format(prayerTimes.maghrib)}');
  print('Isha: ${DateFormat.jm().format(prayerTimes.isha)}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
