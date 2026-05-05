class AdminService {
  static List<Map<String, dynamic>> pendingShops = [];

  static List<Map<String, dynamic>> approvedShops = [];

  static void approveShop(int index) {
    approvedShops.add(pendingShops[index]);

    pendingShops.removeAt(index);
  }

  static void rejectShop(int index) {
    pendingShops.removeAt(index);
  }
}
