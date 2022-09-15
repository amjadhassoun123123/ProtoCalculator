import UIKit
import Flutter
import Firebase


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
  override init() {
    super.init()
    FirebaseApp.configure()
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let methodChannelName = "co.spurry.calculator.fluttersignin/code"
      let codeChannel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: controller.binaryMessenger)
      
      codeChannel.setMethodCallHandler({
          (call : FlutterMethodCall, result : @escaping FlutterResult) -> Void in
          
          switch call.method {
          case "runPython":
              guard let args = call.arguments as? [String : String] else {return}
              let code = args["code"]!
              result(runPython(CommandLine.unsafeArgv,code))
            default:
              result(FlutterMethodNotImplemented)
          }
          
      })
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
//"def add(args):\n    try:\n        return sum([int(x) for x in args])\n    except Exception as e:\n        return 'error'\n"

//      let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "pythonCode.py"
//      if (FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)) {
//          print("File created successfully.")
//      } else {
//          print("File not created.")
//      }
//      let text = """
//                class Code:\n       @js\n      def function123(self):\n          x = 5\n          y = 10\n          return y - x
//                """
//
//
//      let file = "pythonCode.py" //this is the file. we will write to and read from it
//
//      if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//
//          let fileURL = dir.appendingPathComponent(file)
//
//          //writing
//          do {
//              try text.write(to: fileURL, atomically: false, encoding: .utf8)
//              print("we wrote some shit")
//              print(fileURL)
//          }
//          catch {/* error handling here */}
//
//          //reading
//          do {
//              let text2 = try String(contentsOf: fileURL, encoding: .utf8)
//          }
//          catch {/* error handling here */}
//      }
