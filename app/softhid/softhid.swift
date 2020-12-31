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
    @IBOutlet var tapButton: NSButton!
    @IBOutlet var releaseKeyboardMenuItem: NSMenuItem!
    @IBOutlet var releaseKeyboardTouchbarItem: NSButton!


    var maybe_fd : Int32?
    var maybe_tap : CFMachPort?
    var keyboard_flags : UInt64 = 0
    
    let kSHIFT = NSEvent.ModifierFlags.shift.rawValue
    let kCONTROL = NSEvent.ModifierFlags.control.rawValue
    let kOPTION = NSEvent.ModifierFlags.option.rawValue
    let kCOMMAND = NSEvent.ModifierFlags.command.rawValue

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

    func handleTapEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> CGEvent? {
        print("TAPxx", event)
        switch (type) {
        case .tapDisabledByTimeout:
            messages.string = "Tap disabled by timeout."
            tapIsDisabled()
        case.tapDisabledByUserInput:
            if messages.string != "Tap disabled." {
                messages.string = "Tap disabled by user input."
            }
            tapIsDisabled()
        case .keyUp:
            break
        case .keyDown:
            let keycode = event.getIntegerValueField(.keyboardEventKeycode)
            let mask = UInt64(kCONTROL | kOPTION | kCOMMAND)
            if keyboard_flags & mask == mask && keycode == kVK_Delete {
                disableTap(sender: nil)
            }
        case .flagsChanged:
            keyboard_flags = event.flags.rawValue
        default:
            assert(false)
        }
        return nil
    }

    @IBAction func disableTap(sender: Any?) {
        CGEvent.tapEnable(tap: maybe_tap!, enable: false)
        messages.string = "Tap disabled."
        tapIsDisabled()
    }
    
    func tapIsDisabled() {
        tapButton.isEnabled = true
        releaseKeyboardMenuItem.isEnabled = false
        releaseKeyboardTouchbarItem.isEnabled = false
    }
    
    func tapIsEnabled() {
        tapButton.isEnabled = false
        releaseKeyboardMenuItem.isEnabled = true
        releaseKeyboardTouchbarItem.isEnabled = true
    }

    @IBAction func tap(sender: NSButton) {

        func callback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
            let del = Unmanaged<AppDelegate>.fromOpaque(refcon!).takeUnretainedValue()
            if let e = del.handleTapEvent(proxy: proxy, type: type, event: event) {
                return Unmanaged.passRetained(e)
            } else  {
                return nil
            }
        }
        
        let first_time = maybe_tap == nil
        
        if maybe_tap == nil {
            let mask : UInt64 = 1 << CGEventType.keyUp.rawValue | 1 << CGEventType.keyDown.rawValue  | 1 << CGEventType.flagsChanged.rawValue
            maybe_tap = CGEvent.tapCreate(tap:.cgSessionEventTap, place:.headInsertEventTap, options:.defaultTap, eventsOfInterest: mask, callback:callback, userInfo: Unmanaged.passUnretained(self).toOpaque())
        }

        guard let tap = maybe_tap else
        {
            messages.string = "Couldn't create tap.\nCheck that permission is granted in Preferences > Security > Privacy > Accessibility"
            return
        }

        if (first_time) {
            let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
        
        CGEvent.tapEnable(tap: tap, enable: true)
        
        if (!CGEvent.tapIsEnabled(tap: tap)) {
            messages.string = "Couldn't enale tap."
            return
        }
        
        messages.string = "Tap enabled!\n" + "Press ⌃⌥⌘⌫ to release."
        tapIsEnabled()
    }


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let matching : NSDictionary =  ["IOProviderClass": "IOSerialBSDClient"]
        let iterator_p = UnsafeMutablePointer<io_iterator_t>.allocate(capacity: 1)
        defer { iterator_p.deallocate() }
        let kr = IOServiceGetMatchingServices(kIOMasterPortDefault, matching, iterator_p)
        if kr == KERN_SUCCESS {
            var devices : [String] = []
            while true {
                let service = IOIteratorNext(iterator_p.pointee)
                if service == 0 { break }
                let k : NSString = "IOCalloutDevice"
                let dev = IORegistryEntryCreateCFProperty(service, k, kCFAllocatorDefault, 0).takeRetainedValue()
                devices.append(String(dev as! CFString))
            }
            devices.sort { (a, b) -> Bool in
                if a.starts(with: "/dev/cu.usbserial") && !b.starts(with: "/dev/cu.usbserial") {
                    return true
                } else {
                    return a < b
                }
            }
            for dev in devices {
                serialPortSelector.addItem(withTitle: dev)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func handleEvent(_ event: NSEvent) -> Bool {
        print(event)
        guard let fd = maybe_fd else { return false }
        switch(event.type) {
        case .keyUp:
            guard let keycode = carbon_keycode_to_teensy[Int(event.keyCode)] else { return false }
            let seq = String.init(format: "\u{1b}{%du", keycode).data(using: String.Encoding.utf8)!
            let r = seq.withUnsafeBytes { p in
                write(fd, p.baseAddress, seq.count);
            }
            assert(r == seq.count)
            return true;
        case .keyDown:
            if event.isARepeat { return true }
            guard let keycode = carbon_keycode_to_teensy[Int(event.keyCode)] else { return false }
            let seq = String.init(format: "\u{1b}{%dd", keycode).data(using: String.Encoding.utf8)!
            let r = seq.withUnsafeBytes { p in
                write(fd, p.baseAddress, seq.count);
            }
            assert(r == seq.count)
            return true;
        case .flagsChanged:
            var flags = 0
            let ef = event.modifierFlags.rawValue;
            if ef & NSEvent.ModifierFlags.shift.rawValue != 0 {
                flags |= teensy_SHIFT;
            }
            if ef & kLEFT_SHIFT != 0 {
                flags |= teensy_LEFT_SHIFT;
            }
            if ef & kRIGHT_SHIFT != 0 {
                flags |= teensy_RIGHT_SHIFT;
            }
            if ef & NSEvent.ModifierFlags.control.rawValue != 0 {
                flags |= teensy_CTRL;
            }
            if ef & kLEFT_CONTROL != 0 {
                flags |= teensy_LEFT_CTRL;
            }
            if ef & kRIGHT_SHIFT != 0 {
                flags |= teensy_RIGHT_CTRL;
            }
            if ef & NSEvent.ModifierFlags.option.rawValue != 0 {
                flags |= teensy_ALT;
            }
            if ef & kLEFT_OPTION != 0 {
                flags |= teensy_LEFT_ALT;
            }
            if ef & kRIGHT_OPTION != 0 {
                flags |= teensy_RIGHT_ALT;
            }
            if ef & NSEvent.ModifierFlags.command.rawValue != 0 {
                flags |= teensy_GUI;
            }
            if ef & kLEFT_COMMAND != 0 {
                flags |= teensy_LEFT_GUI;
            }
            if ef & kRIGHT_OPTION != 0 {
                flags |= teensy_RIGHT_GUI;
            }
            let seq = String.init(format: "\u{1b}{%df", flags).data(using: String.Encoding.utf8)!
            let r = seq.withUnsafeBytes { p in
                write(fd, p.baseAddress, seq.count);
            }
            assert(r == seq.count)
            return true
        default:
            return false
        }
    }
}

class SofthidWindow: NSWindow {
    let x = kVK_ANSI_A

    @IBOutlet var touchbar : NSTouchBar!

    override func makeTouchBar() -> NSTouchBar? {
        return touchbar
    }

    override func sendEvent(_ event: NSEvent) {
        let del = NSApplication.shared.delegate as! AppDelegate
        let handleled = del.handleEvent(event)
        if  !handleled {
            super.sendEvent(event)
        }
    }
}
