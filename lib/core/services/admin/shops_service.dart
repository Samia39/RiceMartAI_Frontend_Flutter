class ShopsService {
  static List<Map<String, dynamic>> pendingShops = [
    {
      "id": 1,
      "shop": "Ali Traders",
      "owner": "Ali",
      "cnic": "35202-1234567-1",
      "city": "Lahore",
      "status": "Pending Review",
    },

    {
      "id": 2,
      "shop": "Punjab Rice Mill",
      "owner": "Ahmed",
      "cnic": "35202-7654321-9",
      "city": "Gujranwala",
      "status": "Pending Review",
    },
  ];

  static List<Map<String, dynamic>> approvedShops = [];

  static List<Map<String, dynamic>> getPendingShops() {
    return pendingShops;
  }

  static List<Map<String, dynamic>> getApprovedShops() {
    return approvedShops;
  }

  static void approveShop(int index) {
    var shop = pendingShops[index];

    shop["status"] = "Approved & Verified";

    approvedShops.add(shop);

    pendingShops.removeAt(index);
  }

  static void rejectShop(int index) {
    pendingShops.removeAt(index);
  }

  static void requestCorrection(int index, String reason) {
    pendingShops[index]["status"] = "Needs Correction";

    pendingShops[index]["correctionReason"] = reason;
  }

  static void suspendShop(int index) {
    approvedShops[index]["status"] = "Suspended";
  }

  static void deleteApprovedShop(int index) {
    approvedShops.removeAt(index);
  }
}
