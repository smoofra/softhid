//
//  AppDelegate.swift
//  softhid
//
//  Created by Lawrence D'Anna on 12/27/20.
//

import Cocoa
import Carbon.HIToolbox.Events
import IOKit


@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!

    @IBOutlet var serialPortSelector : NSPopUpButton!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let matching : NSDictionary =  ["IOProviderClass": "IOSerialBSDClient"]
        let iterator_p = UnsafeMutablePointer<io_iterator_t>.allocate(capacity: 1)
        let kr = IOServiceGetMatchingServices(kIOMasterPortDefault, matching, iterator_p)
        if kr == KERN_SUCCESS {
            while true {
                let service = IOIteratorNext(iterator_p.pointee)
                if service == 0 { break }
                let k : NSString = "IOCalloutDevice"
                let dev = IORegistryEntryCreateCFProperty(service, k, kCFAllocatorDefault, 0).takeRetainedValue()
                serialPortSelector.addItem(withTitle: String(dev as! CFString))
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

class SofthidWindow: NSWindow {
    let x = kVK_ANSI_A
    override func sendEvent(_ event: NSEvent) {
        switch(event.type) {
        case .keyUp:
            print("KU", event)
            if let keycode = carbon_keycode_to_teensy[Int(event.keyCode)] {

            }
        case .keyDown:
            print("KD", event)
        case .flagsChanged:
            print("FC", event)
        default:
            break;
        }
        super.sendEvent(event)
    }
}
