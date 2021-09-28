class Endpoints {
  Endpoints._();

  // base url
  static const String baseUrl = "http://jsonplaceholder.typicode.com";
  //static const String baseUrl = "https://demo.moqui.org/rest/s1/pop";

  // receiveTimeout
  static const int receiveTimeout = 15000;

  // connectTimeout
  static const int connectionTimeout = 30000;

  // booking endpoints
  static const String getPosts = baseUrl + "/posts";
  static const String doLogin = baseUrl + "/login"; // ?username&password
  static const String getProducts = baseUrl + "/products/CategoryProducts"; // ?productCategoryId=PopcAllProducts
}