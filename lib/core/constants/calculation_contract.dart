// THIS FILE IS THE SINGLE SOURCE OF TRUTH - mirror of CalculationContract.kt
// Do not change values without updating the mirror file in android/app/src/main/kotlin/com/qada/fard/prayer/CalculationContract.kt
abstract class CalculationContract {
  // Calculation Methods
  static const int methodMuslimWorldLeague = 0;
  static const int methodEgyptian = 1;
  static const int methodKarachi = 2;
  static const int methodUmmAlQura = 3;
  static const int methodDubai = 4;
  static const int methodMoonSightingCommittee = 5;
  static const int methodNorthAmerica = 6;
  static const int methodKuwait = 7;
  static const int methodQatar = 8;
  static const int methodSingapore = 9;
  static const int methodTehran = 10;
  static const int methodTurkey = 11;

  // Madhabs
  static const int madhabShafi = 0;
  static const int madhabHanafi = 1;

  // High Latitude Rules
  static const int highLatMiddleOfTheNight = 0;
  static const int highLatSeventhOfTheNight = 1;
  static const int highLatTwilightAngle = 2;

  // Channel & Pref Keys
  static const String channelName = 'com.qada.fard/instant_updates';
  static const String prefPrefix = 'flutter.';
}
