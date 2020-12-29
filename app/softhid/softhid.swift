//
//  AppDelegate.swift
//  softhid
//
//  Created by Lawrence D'Anna on 12/27/20.
//

import Cocoa
import Carbon.HIToolbox.Events
import IOKit
import IOKit.serial


@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var connectButton: NSButton!
    @IBOutlet var disconnectButton: NSButton!
    @IBOutlet var window: NSWindow!
    @IBOutlet var serialPortSelector : NSPopUpButton!
    @IBOutlet var messages : NSTextView!

    var maybe_fd : Int32?

    @IBAction func connect(sender : NSButton) {
        guard let device = serialPortSelector.selectedItem?.title else {
            messages.string = "select a port to connect to"
            return
        }
        let fd = open(device, O_RDWR | O_NOCTTY | O_NONBLOCK)
        if (fd < 0) {
            messages.string = "error opening serial port: " + (String(utf8String: strerror(errno)) ?? "unkown error")
            return
        }
        if (ioctl(fd, TIOCEXCL) == -1) {
            messages.string = "serial port in use by another program"
            return
        }
        let speed_p = UnsafeMutablePointer<speed_t>.allocate(capacity: 1)
        defer { speed_p.deallocate() }
        speed_p.pointee = 115200
        if (ioctl(fd, kIOSSIOSPEED, speed_p) == -1 ) {
            messages.string = "unable to set the baud rate"
            return
        }
        maybe_fd = fd
        messages.string = "ok!"
        connectButton.isEnabled = false
        disconnectButton.isEnabled = true
    }

    @IBAction func disconnect(sender: NSButton) {
        if let fd = maybe_fd {
            close(fd);
        }
        messages.string = ""
        maybe_fd = nil
        connectButton.isEnabled = true
        disconnectButton.isEnabled = false
    }


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let matching : NSDictionary =  ["IOProviderClass": "IOSerialBSDClient"]
        let iterator_p = UnsafeMutablePointer<io_iterator_t>.allocate(capacity: 1)
        defer { iterator_p.deallocate() }
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

    func handleEvent(_ event: NSEvent) -> Bool {
        guard let fd = maybe_fd else { return false }
        switch(event.type) {
        case .keyUp:
            print("KU", event)
            guard let keycode = carbon_keycode_to_teensy[Int(event.keyCode)] else { return false }
            let seq = String.init(format: "\u{1b}{%du", keycode).data(using: String.Encoding.utf8)!
            let r = seq.withUnsafeBytes { p in
                write(fd, p.baseAddress, seq.count);
            }
            assert(r == seq.count)
            return true;
        case .keyDown:
            if event.isARepeat { return true }
            print("KD", event)
            guard let keycode = carbon_keycode_to_teensy[Int(event.keyCode)] else { return false }
            let seq = String.init(format: "\u{1b}{%dd", keycode).data(using: String.Encoding.utf8)!
            let r = seq.withUnsafeBytes { p in
                write(fd, p.baseAddress, seq.count);
            }
            assert(r == seq.count)
            return true;
        case .flagsChanged:
            print("FC", event)
            return false
        default:
            return false
        }
    }
}

class SofthidWindow: NSWindow {
    let x = kVK_ANSI_A
    override func sendEvent(_ event: NSEvent) {
        let del = NSApplication.shared.delegate as! AppDelegate
        let handleled = del.handleEvent(event)
        if  !handleled {
            super.sendEvent(event)
        }
    }
}
