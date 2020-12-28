//
//  AppDelegate.swift
//  softhid
//
//  Created by Lawrence D'Anna on 12/27/20.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

class SofthidWindow: NSWindow {
    override func sendEvent(_ event: NSEvent) {
        switch(event.type) {
        case .keyUp:
            print("KU", event)
        case .keyDown:
            print("KD", event)
        case .flagsChanged:
            print("FC", event)
        default:
            break;
        }
    }
}
