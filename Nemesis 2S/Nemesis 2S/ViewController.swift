//
//  ViewController.swift
//  Nemesis 2S
//
//  Created by Hoyoun Song on 2020/07/13.
//  Copyright © 2020 410. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    let patchData = Bundle.main.resourcePath! + "/patchd/"
    let flagData = NSSwiftUtils.getHomeDirectory() + "Library/Application Support/Nemesis2/"
    let Graphics: GraphicComponents = GraphicComponents()
    let PROGRAM_NAME = "Relay Classroom";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isKISImg()
        if NSSwiftUtils.doesTheFileExist(at: flagData + "suspended") {
            resume()
        }else{
            suspend()
        }
    }
    
    func isKISImg() {
        // Check if KIS image
        var LSExistInAnyform = false
        if !NSSwiftUtils.readContents(of: patchData + "checkifpth").replacingOccurrences(of: "\n", with: "").elementsEqual("") {
            let checkPath = NSSwiftUtils.readContents(of: patchData + "checkifpth").components(separatedBy: "\n")
            for i in 0..<checkPath.count {
                if NSSwiftUtils.doesTheFileExist(at: checkPath[i]) {
                    LSExistInAnyform = true
                    break
                }
            }
        }
        if !LSExistInAnyform {
            Graphics.messageBox_errorMessage(title: "Error", contents: "\(PROGRAM_NAME) not found. The app will quit now.")
            exit(0)
        }
    }
    
    func suspend() {
        let listOfSuspendProc = NSSwiftUtils.readContents(of: patchData + "suspendList").components(separatedBy: "\n")
        for i in 0..<listOfSuspendProc.count {
            if listOfSuspendProc[i].elementsEqual("") {
                Graphics.messageBox_dialogue(title: "BREAK", contents: "i=\(i)")
                break
            }
            NSSwiftUtils.executeShellScript("killall", "-STOP", listOfSuspendProc[i])
        }
        NSSwiftUtils.executeShellScript("touch", flagData + "suspended")
        NSSwiftUtils.executeShellScript("rm", "-f", flagData + "stopped")
        Graphics.messageBox_dialogue(title: "Task Done", contents: "\(PROGRAM_NAME) is now suspended.")
        exit(0)
    }
    
    func resume() {
        let listOfSuspendProc = NSSwiftUtils.readContents(of: patchData + "suspendList").components(separatedBy: "\n")
        for i in 0..<listOfSuspendProc.count {
            if listOfSuspendProc[i].elementsEqual("") {
                break
            }
            NSSwiftUtils.executeShellScript("killall", "-CONT", listOfSuspendProc[i])
        }
        NSSwiftUtils.executeShellScript("rm", "-f", flagData + "suspended")
        Graphics.messageBox_dialogue(title: "Task Done", contents: "\(PROGRAM_NAME) is now on.")
        exit(0)
    }
    
}

