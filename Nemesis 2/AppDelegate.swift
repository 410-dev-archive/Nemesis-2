//
//  AppDelegate.swift
//  Nemesis 2
//
//  Created by Hoyoun Song on 2020/07/05.
//  Copyright © 2020 410. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBAction func OnPatchUpdate(_ sender: Any) {
        ViewController.updatePatchData(doShowDialog: true)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        exit(0)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

