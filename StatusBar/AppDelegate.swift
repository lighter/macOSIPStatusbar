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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // The application does not appear in the Dock and may not create
        // windows or be activated.
        NSApp.setActivationPolicy(.prohibited)

        self.start()
        
        let halfHour = 30 * 60
        Timer.scheduledTimer(withTimeInterval: TimeInterval(halfHour), repeats: true) { timer in
            self.start()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func start() {
        self.getMyIP() { (output) in
            DispatchQueue.main.async {
                self.statusBarItem.button?.title = "\(output.ip!), \(output.cc!)"
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
}

