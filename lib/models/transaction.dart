class Payout{
  String id;
  double amount;
  DateTime createdAt;
  Object taskRef;
  bool payout;
  String status;
}

class StripeAcc{
  String stripeAcc;
}

class HistoryItem{
  String category;
  double amount;
  DateTime dateTime;
  String status;
}