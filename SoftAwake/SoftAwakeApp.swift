import SwiftUI
import UserNotifications
import AVFAudio

@main
struct SoftAwakeApp: App {
    @StateObject var alarmManager = AlarmManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ClockView()
                .environmentObject(alarmManager)
                .onAppear {
                    // Pass the alarmManager to the AppDelegate
                    appDelegate.alarmManager = alarmManager
                    
                    // Set the window from the active scene
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        appDelegate.window = window
                    }
                }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var alarmManager: AlarmManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        setupNotifications()
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: .duckOthers)
            print("Playback OK")
            try session.setActive(true)
            print("Playback active")
            return true
        } catch {
            print("Failed to set audio session \(error)")
            return false
        }
    }
    
    private func setupNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission denied: \(error.localizedDescription)")
            }
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
        presentAlarmView()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        presentAlarmView()
        completionHandler()
    }
    private func presentAlarmView() {
        DispatchQueue.main.async {
            guard let rootViewController = self.window?.rootViewController else { return }
            
            guard let alarmManager = self.alarmManager else {
                print("Error: alarmManager is nil in AppDelegate")
                return
            }
            
            let alarmVC = AlarmViewController(alarmManager: alarmManager)
            alarmVC.modalPresentationStyle = .fullScreen
            rootViewController.present(alarmVC, animated: true)
        }
    }
}
