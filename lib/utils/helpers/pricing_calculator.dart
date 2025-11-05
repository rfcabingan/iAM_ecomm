class IAMPricingCalculator {
  /// --- Calculate Price based on tax and shipping ---

  /// Calculates the total price (₱) including 12% VAT and location-based shipping cost.
  static double calculateTotalPrice(double productPrice, String location) {
    if (productPrice < 0)
      throw ArgumentError('Product price cannot be negative.');
    if (location.isEmpty) throw ArgumentError('Location cannot be empty.');

    final taxRate = getTaxRateForLocation(location);
    final taxAmount = productPrice * taxRate;
    final shippingCost = getShippingCost(location);

    final totalPrice = productPrice + taxAmount + shippingCost;
    return totalPrice;
  }

  /// --- Calculate shipping cost ---

  /// Returns the shipping cost (₱) formatted as a string.
  static String calculateShippingCost(double productPrice, String location) {
    final shippingCost = getShippingCost(location);
    return formatPeso(shippingCost);
  }

  /// --- Calculate tax ---

  /// Returns the VAT (₱) for the given product price and location.
  static String calculateTax(double productPrice, String location) {
    final taxRate = getTaxRateForLocation(location);
    final taxAmount = productPrice * taxRate;
    return formatPeso(taxAmount);
  }

  /// --- Get Tax Rate and Shipping Cost (Helper Methods) ---

  /// VAT rate for the Philippines (currently 12%).
  static double getTaxRateForLocation(String location) {
    // You can expand this for special economic zones or tax-free areas.
    return 0.12;
  }

  /// Determines the shipping cost (₱) based on region.
  /// These are sample values for demo purposes.
  static double getShippingCost(String location) {
    final normalized = location.toLowerCase();

    if (normalized.contains('luzon')) return 50.00;
    if (normalized.contains('visayas')) return 150.00;
    if (normalized.contains('mindanao')) return 250.00;

    // Default flat rate within the Philippines.
    return 180.00;
  }

  /// --- Peso Formatting Utility ---

  /// Converts a numeric amount to a Peso string with two decimal places.
  /// Example: ₱1,234.56
  static String formatPeso(double amount) {
    final formatted = amount.toStringAsFixed(2);
    return '₱$formatted';
  }

  /// Example structure once `CartModel` is defined.
  /// Each item should contain a `price` field.
  // static double calculateCartTotal(CartModel cart) {
  //   return cart.items.map((e) => e.price).fold(0.0, (prev, curr) => prev + (curr ?? 0.0));
  // }
}

// ------------------------------OLD CODE ------------------------------------

// /// Utility class for calculating prices, tax, and shipping.
// class IAMPricing {

//   /// --- Calculate Price based on tax and shipping ---

//   /// Calculates the total price by adding tax and shipping cost to the product price.
//   static double calculateTotalPrice(double productPrice, String location) {
//     double taxRate = getTaxRateForLocation(location);
//     double taxAmount = productPrice * taxRate;

//     double shippingCost = getShippingCost(location);

//     double totalPrice = productPrice + taxAmount + shippingCost;
//     return totalPrice;
//   }

//   /// --- Calculate shipping cost ---

//   /// Calculates the shipping cost and returns it as a formatted string.
//   static String calculateShippingCost(double productPrice, String location) {
//     double shippingCost = getShippingCost(location);
//     return shippingCost.toStringAsFixed(2);
//   }

//   /// --- Calculate tax ---

//   /// Calculates the tax amount and returns it as a formatted string.
//   static String calculateTax(double productPrice, String location) {
//     double taxRate = getTaxRateForLocation(location);
//     double taxAmount = productPrice * taxRate;
//     return taxAmount.toStringAsFixed(2);
//   }

//   /// --- Get Tax Rate and Shipping Cost (Helper Methods) ---

//   /// Lookup the tax rate for the given location from a tax rate database or API.
//   /// Return the appropriate tax rate.
//   static double getTaxRateForLocation(String location) {
//     // Example tax rate of 10%
//     return 0.10;
//   }

//   /// Lookup the shipping cost for the given location using a shipping rate API.
//   /// Calculate the shipping cost based on various factors like distance, weight, etc.
//   static double getShippingCost(String location) {
//     // Example shipping cost of $5
//     return 5.00;
//   }

//   /// --- Sum all cart values and return total amount ---

//   /// NOTE: This function is incomplete as the 'CartModel' class is not defined.
//   /// It is included exactly as provided in the snippet.
//   // static double calculateCartTotal(CartModel cart) {
//   //   return cart.items.map((e) => e.price).fold(0, (previousPrice, currentPrice) => previousPrice + (currentPrice ?? 0));
//   // }
// }
