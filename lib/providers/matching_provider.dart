import 'package:app/app/models/person_details_model.dart';
import 'package:app/app/models/mutual_transfer_match_model.dart';
import 'package:flutter/material.dart';

class MatchingProvider extends ChangeNotifier {
  List<MutualTransferMatch> _matches = [];
  bool _isLoading = false;

  List<MutualTransferMatch> get matches => _matches;
  bool get isLoading => _isLoading;

  void findMatches(PersonDetailsModel currentUser, List<PersonDetailsModel> allUsers) {
    _isLoading = true;
    notifyListeners();

    // Filter Pool based on core eligibility (Job, Scheme, Subject, Grade)
    List<PersonDetailsModel> pool =
        allUsers.where((u) {
          return u.uid != "UNKNOWN" && _isEligible(currentUser, u);
        }).toList();

    if (!pool.any((u) => u.uid == currentUser.uid)) {
      pool.add(currentUser);
    }

    // Build Directed Graph (Adjacency List based on desired districts)
    Map<String, List<PersonDetailsModel>> adjList = {};
    for (var u in pool) {
      adjList[u.uid] =
          pool.where((v) {
            if (u.uid == v.uid) return false;
            return _wantsLocation(u, v);
          }).toList();
    }

    List<List<PersonDetailsModel>> foundCycles = [];

    // Bounded Depth-First Search (Max Depth 4)
    void dfs(PersonDetailsModel current, List<PersonDetailsModel> path, Set<String> visited) {
      if (path.length > 4) return;

      for (var neighbor in (adjList[current.uid] ?? [])) {
        if (neighbor.uid == currentUser.uid && path.length >= 2) {
          foundCycles.add(List.from(path));
        } else if (!visited.contains(neighbor.uid)) {
          visited.add(neighbor.uid);
          path.add(neighbor);
          dfs(neighbor, path, visited);
          path.removeLast();
          visited.remove(neighbor.uid);
        }
      }
    }

    dfs(currentUser, [currentUser], {currentUser.uid});

    // Map to Model and Determine Choice Priority
    _matches =
        foundCycles.map((cycle) {
          MatchType type = MatchType.twoPerson;
          if (cycle.length == 3) type = MatchType.threePerson;
          if (cycle.length == 4) type = MatchType.fourPerson;

          // Determine which choice this match fulfills for the current user
          int matchedChoiceIndex = 0;
          if (cycle.length > 1) {
            PersonDetailsModel nextPerson = cycle[1];
            String targetDistrict = nextPerson.district?.toLowerCase() ?? '';

            if (currentUser.choice1 != null &&
                currentUser.choice1!.isNotEmpty &&
                targetDistrict == currentUser.choice1!.toLowerCase()) {
              matchedChoiceIndex = 1;
            } else if (currentUser.choice2 != null &&
                currentUser.choice2!.isNotEmpty &&
                targetDistrict == currentUser.choice2!.toLowerCase()) {
              matchedChoiceIndex = 2;
            } else if (currentUser.choice3 != null &&
                currentUser.choice3!.isNotEmpty &&
                targetDistrict == currentUser.choice3!.toLowerCase()) {
              matchedChoiceIndex = 3;
            }
          }

          return MutualTransferMatch(
            matchId: cycle.map((u) => u.uid).join('-'),
            matchType: type,
            cycle: cycle,
            matchedChoice: matchedChoiceIndex,
          );
        }).toList();

    _isLoading = false;
    notifyListeners();
  }

  // existing application business rules
  bool _isEligible(PersonDetailsModel a, PersonDetailsModel b) {
    if (a.job != b.job) return false;

    if (a.job == "Provincial School Teacher" || a.job == "National School Teacher") {
      if (a.scheme != b.scheme) return false;
      if (a.scheme != "PRIMARY" && a.subject != b.subject) return false;
      if (a.subjectMedium != b.subjectMedium) return false;
    }
    // else {
    //   if (a.grade != b.grade) return false;
    // }
    return true;
  }

  // Determines the directed edge A -> B
  bool _wantsLocation(PersonDetailsModel a, PersonDetailsModel b) {
    List<String> choices = [
      a.choice1?.toLowerCase() ?? '',
      a.choice2?.toLowerCase() ?? '',
      a.choice3?.toLowerCase() ?? '',
    ];
    return choices.contains(b.district?.toLowerCase() ?? '');
  }
}
