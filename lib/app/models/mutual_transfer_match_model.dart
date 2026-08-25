import 'package:app/app/models/person_details_model.dart';

enum MatchType { twoPerson, threePerson, fourPerson }

class MutualTransferMatch {
  final String matchId;
  final MatchType matchType;
  final List<PersonDetailsModel> cycle;
  final int matchedChoice;

  MutualTransferMatch({
    required this.matchId,
    required this.matchType,
    required this.cycle,
    required this.matchedChoice,
  });
}
