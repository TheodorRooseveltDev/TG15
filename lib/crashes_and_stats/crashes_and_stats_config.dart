import 'package:flutter/material.dart';
import 'package:kingmaker_casino_trial_games/services/legal_service.dart';


String crashesAndStatsOneSignalString = "9a49242b-db0a-4bea-ae4f-f88561247241";

String crashesAndStatsDevKeypndAppId = "6756220949";

String crashesAndStatsAfDevKey1 = "CbvxHMq47NDpz"; 
String crashesAndStatsAfDevKey2 = "38RmTTgpQ";


String crashesAndStatsUrl = 'https://kingmakercasinotrialgames.com/crashesandstats/';

String crashesAndStatsStandartWord = "crashesandstats";


void crashesAndStatsOpenStandartAppLogic(BuildContext context) async {
  final legalAccepted = legalService.isAccepted;
  
  if (!legalAccepted) {
    Navigator.of(context).pushReplacementNamed('/legal');
  } else {
    Navigator.of(context).pushReplacementNamed('/home');
  }
}
