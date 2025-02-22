import UIKit

class AlarmViewController: UIViewController {
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startBackgroundTask()
        (UIApplication.shared.delegate as? AppDelegate)?.alarmManager?.playAlarm()
    }
    
    private func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    @objc func dismissAlarm() {
        (UIApplication.shared.delegate as? AppDelegate)?.alarmManager?.stopAlarm()
        endBackgroundTask()
        dismiss(animated: true)
    }
    
    deinit {
        endBackgroundTask()
    }
}
