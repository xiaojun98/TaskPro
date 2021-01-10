import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class AnalyticsServices {
  final FirebaseAnalytics _analytics = FirebaseAnalytics();
  FirebaseAnalyticsObserver getAnalyticsObserver() => FirebaseAnalyticsObserver(analytics: _analytics);

  Future logLogin() async {
    await _analytics.logLogin(loginMethod: 'phone');
  }
  
  Future logSignUp() async {
    await _analytics.logSignUp(signUpMethod: 'phone');
  }

  Future logTaskCreated() async {
    await _analytics.logEvent(name: "create_task");
  }

  Future logDraftSaved() async {
    await _analytics.logEvent(name: "save_draft");
  }

  Future logTaskEdited() async {
    await _analytics.logEvent(name: "edit_task");
  }

  Future logTaskCancelled() async {
    await _analytics.logEvent(name: "cancel_task");
  }

  Future logTaskViewed() async {
    await _analytics.logEvent(name: "view_task");
  }

  Future logTaskCompleted() async {
    await _analytics.logEvent(name: "complete_task");
  }

  Future logBookmarkAdded() async {
    await _analytics.logEvent(name: "add_bookmark");
  }

  Future logOfferSent() async {
    await _analytics.logEvent(name: "sent_offer");
  }

  Future logOfferCancelled() async {
    await _analytics.logEvent(name: "cancel_offer");
  }

  Future logOfferAccepted() async {
    await _analytics.logEvent(name: "accept_offer");
  }

  Future logSearch() async {
    await _analytics.logEvent(name: "search");
  }

  Future logProfileViewed() async {
    await _analytics.logEvent(name: "view_profile");
  }

  Future logProfileEdited() async {
    await _analytics.logEvent(name: "edit_profile");
  }

  Future logReportSubmitted() async {
    await _analytics.logEvent(name: "submit_report");
  }

  Future logMsgSent() async {
    await _analytics.logEvent(name: "sent_msg");
  }

  Future logPayout() async {
    await _analytics.logEvent(name: "payout");
  }

  Future logStripeCreated() async {
    await _analytics.logEvent(name: "create_stripe");
  }

  Future logStripeLinked() async {
    await _analytics.logEvent(name: "link_stripe");
  }

}