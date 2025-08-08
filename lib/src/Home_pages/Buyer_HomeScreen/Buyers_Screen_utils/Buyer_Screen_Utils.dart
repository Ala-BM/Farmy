  String getCropProduct(Map<String, dynamic> cropData) {
    return cropData["product"]?.toString() ?? "Unknown Product";
  }

  String getCropCost(Map<String, dynamic> cropData) {
    final cost = cropData["costPerKg"];
    if (cost == null) return "N/A";
    return cost.toString();
  }

  String getCropRating(Map<String, dynamic> cropData) {
    print("EEEEEEEEEEEEEEEEEEEEEEEE $cropData");
    final rating = cropData["rating"];
    if (rating == null) return "N/A";
    return rating.toString();
  }