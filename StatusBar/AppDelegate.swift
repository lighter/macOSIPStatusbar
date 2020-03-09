//
//  AppDelegate.swift
//  StatusBar
//
//  Created by lighter on 2020/3/7.
//  Copyright © 2020 lighter. All rights reserved.
//

import Cocoa
import SwiftUI
import NetworkExtension
import Network

struct myIPResponse: Codable {
    let ip: String?
    let country: String?
    let cc: String?
    
    init(ip: String? = nil, country: String? = nil, cc: String? = nil) {
        self.ip = ip
        self.country = country
        self.cc = cc
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let monitor = NWPathMonitor()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // The application does not appear in the Dock and may not create
        // windows or be activated.
        NSApp.setActivationPolicy(.prohibited)

        self.startMonitor()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func startMonitor() {
        self.monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.startGetMyIP()
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    func startGetMyIP() {
        self.getMyIP() { (output) in
            DispatchQueue.main.async {
                self.statusBarItem.button?.title = "\(output.ip!), \(output.cc!)"
                self.showNotification(title: output.ip!, subtitle: output.country!)
            }
        }
    }
    
    func getMyIP(completionBlock: @escaping (myIPResponse) -> Void) {
        let urlString = "https://api.myip.com/"
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, res, err in
                if let data = data {
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(myIPResponse.self, from: data) {
                        completionBlock(json)
                    }
                }
            }.resume()
        }
    }
    
    func showNotification(title: String, subtitle: String) -> Void {
                let notification = NSUserNotification()
                notification.title = title
                notification.subtitle = subtitle
                notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.delegate = self as? NSUserNotificationCenterDelegate
                NSUserNotificationCenter.default.deliver(notification)
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter,
                                             shouldPresent notification: NSUserNotification) -> Bool {
            return true
    }
}

