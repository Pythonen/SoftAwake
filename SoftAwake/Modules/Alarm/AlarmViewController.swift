import UIKit
import SwiftUICore

class AlarmViewController: UIViewController {
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private let alarmManager: AlarmManager
    
    init(alarmManager: AlarmManager) {
            self.alarmManager = alarmManager
            super.init(nibName: nil, bundle: nil)
        }
    required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startBackgroundTask()
    }
    private func setupUI() {
            view.backgroundColor = .systemBackground
            
            let stopButton = UIButton(configuration: .filled())
            stopButton.setTitle("Stop Alarm", for: .normal)
        stopButton.addTarget(self, action: #selector(dismissAlarm), for: .touchUpInside)
            
            view.addSubview(stopButton)
            stopButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                stopButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                stopButton.widthAnchor.constraint(equalToConstant: 200),
                stopButton.heightAnchor.constraint(equalToConstant: 50)
            ])
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
        alarmManager.stopAlarm()
        dismiss(animated: true)
    }
    
    deinit {
        endBackgroundTask()
    }
}
