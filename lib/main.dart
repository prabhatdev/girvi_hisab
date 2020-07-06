import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:girvihisab/appTheme.dart';
import 'package:girvihisab/screens/Home/HomeScreen.dart';
import 'package:girvihisab/screens/Login/LoginScreen.dart';
import 'package:girvihisab/screens/OrderScreen/OrderScreen.dart';
import 'package:girvihisab/screens/SearchResultScreen/SearchResultScreen.dart';
import 'package:girvihisab/screens/SignUp/SignUpScreen.dart';
import 'package:girvihisab/screens/Splash/SplashScreen.dart';
import 'package:responsive_framework/responsive_wrapper.dart';
import 'package:responsive_framework/utils/scroll_behavior.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
   initializeApp(
    apiKey: "AIzaSyBA4IyPenGdIeUtGFOVSFUCnSeVMl-qsTM",
    authDomain: "girvihisab.firebaseapp.com",
    databaseURL: "https://girvihisab.firebaseio.com",
    projectId: "girvihisab",
    storageBucket: "girvihisab.appspot.com",
    messagingSenderId: "334794123203",
    appId: "1:334794123203:web:6f1080be5d5e89d397ff76",
    measurementId: "G-VPS51F8CF4"
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(new MyApp()));
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatefulWidget {



  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = new UniqueKey();

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: AppTheme.isLightTheme ? Brightness.dark : Brightness.light,
      statusBarBrightness: AppTheme.isLightTheme ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: AppTheme.isLightTheme ? Colors.white : Colors.black,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness: AppTheme.isLightTheme ? Brightness.dark : Brightness.light,
    ));
    return MaterialApp(
      key: key,
      title: 'Girvi Hisab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(),
      builder: (context, widget) => ResponsiveWrapper.builder(
        BouncingScrollWrapper.builder(context, widget),
        maxWidth: 1000,
        minWidth: 450,
        defaultScale: false,
//        breakpoints: [
//          ResponsiveBreakpoint.resize(450, name: MOBILE),
//          ResponsiveBreakpoint.autoScale(800, name: TABLET),
//          ResponsiveBreakpoint.autoScale(1000, name: TABLET),
//          ResponsiveBreakpoint.resize(1200, name: DESKTOP),
//          ResponsiveBreakpoint.autoScale(2460, name: "4K"),
//        ],

      ),
      routes: routes,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      navigatorObservers: [routeObserver],
      supportedLocales: [
        const Locale('en', 'US'), // English
      ],
    );
  }

  var routes = <String, WidgetBuilder>{
    Routes.SPLASH: (BuildContext context) => SplashScreen(),
    Routes.LOGIN: (BuildContext context) => LoginScreen(),
    Routes.HOME: (BuildContext context) => HomeScreen(),
    Routes.SIGN_UP: (BuildContext context) => SignUpScreen(),
    Routes.SEARCH_RESULT: (BuildContext context) => SearchResultScreen(),
    Routes.ORDER: (BuildContext context) => OrderScreen(),
    // Routes.SearchScreen: (BuildContext context) => ReservationsDetailsWrapper(),
//    Routes.SearchScreen: (BuildContext context) => HomeScreen(),
  };
}

class Routes {
  static const String HOME = "/home";
  static const String ORDER = "/order";
  static const String SEARCH_RESULT = "/search_result";
  static const String LOGIN = "/login";
  static const String SIGN_UP = "/sign_up";
  static const String SPLASH = "/";
}
