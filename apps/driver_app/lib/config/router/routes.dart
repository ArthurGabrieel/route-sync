abstract final class Routes {
  static const login = "/login";
  static const deliveries = "/deliveries";
  static String deliveryDetail(String id) => "/deliveries/$id";
  static const route = "/route";
}
