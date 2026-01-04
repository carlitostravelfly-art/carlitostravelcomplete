import UIKit
import Flutter

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {

  // Canal nativo hacia Flutter
  private var deepLinkChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {

    // Solo registrar plugins. Nada de tocar rootViewController aquí.
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Crear/obtener el canal de forma segura
  private func getDeepLinkChannel() -> FlutterMethodChannel? {
    if let channel = deepLinkChannel {
      return channel
    }

    guard let controller = window?.rootViewController as? FlutterViewController else {
      print("⚠️ No se pudo obtener FlutterViewController aún")
      return nil
    }

    let channel = FlutterMethodChannel(
      name: "carlitostravel/deeplink",
      binaryMessenger: controller.binaryMessenger
    )
    deepLinkChannel = channel
    return channel
  }

  // 🔥 Manejo de URL Schemes (carlitostravel://pago?status=APPROVED)
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {

    print("📲 iOS Deep Link recibido:", url.absoluteString)

    if let channel = getDeepLinkChannel() {
      channel.invokeMethod("onDeepLink", arguments: url.absoluteString)
    }

    return true
  }

  // 🔥 Universal links (https://.../redirect.html → si lo usas)
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {

    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
       let url = userActivity.webpageURL {

      print("🌐 Universal Link recibido:", url.absoluteString)

      if let channel = getDeepLinkChannel() {
        channel.invokeMethod("onDeepLink", arguments: url.absoluteString)
      }
    }

    return true
  }
}
