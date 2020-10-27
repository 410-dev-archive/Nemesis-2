//
//  ViewController.swift
//  Nemesis 2
//
//  Created by Hoyoun Song on 2020/07/05.
//  Copyright © 2020 410. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    static let patchDataUpdateURL = "https://github.com/410-dev/Nemesis-2/raw/master/patchd.zip"
    static let compatible = "package_compatibility=nemesis2-2"
    let patchData = Bundle.main.resourcePath! + "/patchd/"
    let flagData = NSSwiftUtils.getHomeDirectory() + "Library/Application Support/Nemesis2/"
    
    let PROGRAM_NAME = "Relay Classroom"
    
    let Graphics: GraphicComponents = GraphicComponents()
    
    @IBOutlet weak var StatusLabel: NSTextField!
    @IBOutlet weak var PatchUpdatedDateLabel: NSTextField!
    
    @IBOutlet weak var LSStartButtonOutlet: NSButton!
    @IBOutlet weak var LSStopButtonOutlet: NSButton!
    @IBOutlet weak var LSSuspendButtonOutlet: NSButton!
    @IBOutlet weak var PatchUpdateButtonOutlet: NSButton!
    @IBOutlet weak var AdminPasswordField: NSSecureTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create Library Directory
        NSSwiftUtils.createDirectoryWithParentsDirectories(to: flagData)
        
        // Splash updated date of patch data
        if NSSwiftUtils.doesTheFileExist(at: patchData + "updatedDate") {
            PatchUpdatedDateLabel.stringValue = "Patch Updated Date: " + NSSwiftUtils.readContents(of: patchData + "updatedDate").replacingOccurrences(of: "\n", with: "")
        }else{
            Graphics.messageBox_errorMessage(title: "Error", contents: "Patch data library not found. Please download again from official repository. The app will quit now.")
            exit(0)
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
            Graphics.messageBox_errorMessage(title: "Error", contents: PROGRAM_NAME + " not found. The app will quit now.")
            exit(0)
        }
    }
    
    func endOfProcess() {
        LSStartButtonOutlet.isEnabled = true
        LSStopButtonOutlet.isEnabled = true
        LSSuspendButtonOutlet.isEnabled = true
        PatchUpdateButtonOutlet.isEnabled = true
        AdminPasswordField.isEnabled = true
        StatusLabel.stringValue = "Done"
    }
    
    func startProcess() {
        
        // Comment this code if testing is done
//        if !Graphics.messageBox_warning(title: "Beta", contents: "This version is a test version, therefore it may not be stable. This will (probably) not harm the system. Would you continue?") {
//           exit(0)
//        }
        
        
        Graphics.messageBox_dialogue(title: "Do Not Quit", contents: "Please do not quit the application. Quitting app while on-going process may break the system.")
        LSStartButtonOutlet.isEnabled = false
        LSStopButtonOutlet.isEnabled = false
        LSSuspendButtonOutlet.isEnabled = false
        PatchUpdateButtonOutlet.isEnabled = false
        AdminPasswordField.isEnabled = false
    }
    
    @IBAction func OnStartPressed(_ sender: Any) {
        isKISImg()
        
        var isRootPasswordCorrect = false
        
        // Check user password is correct
        if AdminPasswordField.stringValue.count >= 1{
            NSSwiftUtils.executeShellScriptWithRootPrivilages(pass: AdminPasswordField.stringValue, "touch#/var/nemesis-sudotest")
            if NSSwiftUtils.doesTheFileExist(at: "/var/nemesis-sudotest") {
                NSSwiftUtils.executeShellScriptWithRootPrivilages(pass: AdminPasswordField.stringValue, "rm#-f#/var/nemesis-sudotest")
                isRootPasswordCorrect = true
            }
        }
        
        
        // Check if stopped by this tool && Password field is filled
        if NSSwiftUtils.doesTheFileExist(at: flagData + "stopped") && AdminPasswordField.stringValue.count >= 1 && isRootPasswordCorrect{
            
            // Disable all interactions
            startProcess()
            
            // Start Pre-Process
            NSSwiftUtils.executeShellScriptWithRootPrivilages(pass: AdminPasswordField.stringValue, patchData + "start_preproc#" + patchData)
            
            // Manage Launch Agents
            StatusLabel.stringValue = "Updating Launch Agents (ROOT)"
            if !NSSwiftUtils.readContents(of: patchData + "rlaunchagentlist").replacingOccurrences(of: "\n", with: "").elementsEqual("") {
                let listOfLaunchAgents = NSSwiftUtils.readContents(of: patchData + "rlaunchagentlist").components(separatedBy: "\n")
                for i in 0..<listOfLaunchAgents.count {
                    NSSwiftUtils.executeShellScriptWithRootPrivilages(pass: AdminPasswordField.stringValue, "launchctl#load#-w#" + listOfLaunchAgents[i])
                }
            }
            
            // Manage Launch Agents in Userlevel
            StatusLabel.stringValue = "Updating Launch Agents (USER)"
            if !NSSwiftUtils.readContents(of: patchData + "launchagentlist").replacingOccurrences(of: "\n", with: "").elementsEqual("") {
                let listOfULaunchAgents = NSSwiftUtils.readContents(of: patchData + "launchagentlist").components(separatedBy: "\n")
                for i in 0..<listOfULaunchAgents.count {
                    NSSwiftUtils.executeShellScript("launchctl", "load", "-w", listOfULaunchAgents[i])
                }
            }
            
            // Rename files based on rename-orig and rename-to file in patch data
            StatusLabel.stringValue = "Reparing FS"
            let listOfRenamedFiles = NSSwiftUtils.readContents(of: patchData + "rename-to").components(separatedBy: "\n")
            let listOfOriginalFiles = NSSwiftUtils.readContents(of: patchData + "rename-orig").components(separatedBy: "\n")
            for i in 0..<listOfRenamedFiles.count {
                if listOfRenamedFiles[i].elementsEqual("") {
                    break
                }
                NSSwiftUtils.executeShellScriptWithRootPrivilages(pass: AdminPasswordField.stringValue, "mv#" + listOfRenamedFiles[i] + "#" + listOfOriginalFiles[i])
            }
            
            // Start Post-Process
            NSSwiftUtils.executeShellScriptWithRootPrivilages(pass: AdminPasswordField.stringValue, patchData + "start_postproc#" + patchData + "#/tmp/nemesis_exitd")
            
            // Check exit from post process
            if NSSwiftUtils.readContents(of: "/tmp/nemesis_exitd").replacingOccurrences(of: "\n", with: "").elementsEqual("success") {
                // Write flag
                NSSwiftUtils.executeShellScript("touch", flagData + "started")
                NSSwiftUtils.executeShellScript("rm", "-f", flagData + "stopped")
            }else{
                Graphics.messageBox_errorMessage(title: "Error", contents: PROGRAM_NAME + " Kickstart process failed. Subprocess returned: " + NSSwiftUtils.readContents(of: "/tmp/nemesis_exitd") + "\nPlease try again after updating patch data.")
            }
            // Re-Enable interaction
            endOfProcess()
        }else if NSSwiftUtils.doesTheFileExist(at: flagData + "suspended") {
            isKISImg()
            StatusLabel.stringValue = "Resuming " + PROGRAM_NAME
            let listOfSuspendProc = NSSwiftUtils.readContents(of: patchData + "suspendList").components(separatedBy: "\n")
            for i in 0..<listOfSuspendProc.count {
                if listOfSuspendProc[i].elementsEqual("") {
                    break
                }
                NSSwiftUtils.executeShellScript("killall", "-CONT", listOfSuspendProc[i])
            }
            NSSwiftUtils.executeShellScript("rm", "-f", flagData + "suspended")
            endOfProcess()
        }else if AdminPasswordField.stringValue.count == 0 {
            isKISImg()
            Graphics.messageBox_errorMessage(title: "Error", contents: "Administrator password field is empty. If you do not have password, please set one. Then try again.")
        }else if !isRootPasswordCorrect {
            isKISImg()
            Graphics.messageBox_errorMessage(title: "Error", contents: "Administrator password is incorrect. Try again.")
        }else{
            isKISImg()
            Graphics.messageBox_errorMessage(title: "Error", contents: "It seems \(PROGRAM_NAME) is already up and running.")
        }
    }
    
    @IBAction func OnStopPressed(_ sender: Any) {
        isKISImg()
        
        var isRootPasswordCorrect = false
        
        // Check user password is correct
        if AdminPasswordField.stringValue.count >= 1{
            NSSwiftUtils.executeShellScriptWithRootPrivilages(pass: AdminPasswordField.stringValue, "touch#/var/nemesis-sudotest")
            if NSSwiftUtils.doesTheFileExist(at: "/var/nemesis-sudotest") {
                NSSwiftUtils.executeShellScriptWithRootPrivilages(pass: AdminPasswordField.stringValue, "rm#-f#/var/nemesis-sudotest")
                isRootPasswordCorrect = true
            }
        }
        // Check if password field is filled
        if AdminPasswordField.stringValue.count >= 1 && isRootPasswordCorrect{
               
            // Disable all interactions
            startProcess()
               
            // Start Pre-Process
            NSSwiftUtils.executeShellScriptWithRootPrivilages(pass: AdminPasswordField.stringValue, patchData + "stop_preproc#" + patchData)
            
            // Manage Launch Agents
            StatusLabel.stringValue = "Updating Launch Agents (ROOT)"
            if !NSSwiftUtils.readContents(of: patchData + "rlaunchagentlist").replacingOccurrences(of: "\n", with: "").elementsEqual("") {
                let listOfLaunchAgents = NSSwiftUtils.readContents(of: patchData + "rlaunchagentlist").components(separatedBy: "\n")
                for i in 0..<listOfLaunchAgents.count {
                    NSSwiftUtils.executeShellScriptWithRootPrivilages(pass: AdminPasswordField.stringValue, "launchctl#unload#-w#" + listOfLaunchAgents[i])
                }
            }
            
            // Manage Launch Agents in Userlevel
            StatusLabel.stringValue = "Updating Launch Agents (USER)"
            if !NSSwiftUtils.readContents(of: patchData + "launchagentlist").replacingOccurrences(of: "\n", with: "").elementsEqual("") {
                let listOfULaunchAgents = NSSwiftUtils.readContents(of: patchData + "launchagentlist").components(separatedBy: "\n")
                for i in 0..<listOfULaunchAgents.count {
                    NSSwiftUtils.executeShellScript("launchctl", "unload", "-w", listOfULaunchAgents[i])
                }
            }
            
            // Rename files based on rename-orig and rename-to file in patch data
            StatusLabel.stringValue = "Reparing FS"
            let listOfRenamedFiles = NSSwiftUtils.readContents(of: patchData + "rename-to").components(separatedBy: "\n")
            let listOfOriginalFiles = NSSwiftUtils.readContents(of: patchData + "rename-orig").components(separatedBy: "\n")
            for i in 0..<listOfRenamedFiles.count {
                if listOfRenamedFiles[i].elementsEqual("") {
                    break
                }
                NSSwiftUtils.executeShellScriptWithRootPrivilages(pass: AdminPasswordField.stringValue, "mv#" + listOfOriginalFiles[i] + "#" + listOfRenamedFiles[i])
            }
            
            // Start Post-Process
            NSSwiftUtils.executeShellScriptWithRootPrivilages(pass: AdminPasswordField.stringValue, patchData + "stop_postproc#" + patchData + "#/tmp/nemesis_exitd")
            
            // Check exit from post process
            if NSSwiftUtils.readContents(of: "/tmp/nemesis_exitd").replacingOccurrences(of: "\n", with: "").elementsEqual("success") {
                // Write flag
                NSSwiftUtils.executeShellScript("touch", flagData + "stopped")
                NSSwiftUtils.executeShellScript("rm", "-f", flagData + "started")
            }else{
                Graphics.messageBox_errorMessage(title: "Error", contents: PROGRAM_NAME + " terminate process failed. Subprocess returned: " + NSSwiftUtils.readContents(of: "/tmp/nemesis_exitd") + "\nPlease try again after updating patch data.")
            }
            // Re-Enable interaction
            endOfProcess()
        }else if AdminPasswordField.stringValue.count == 0 {
            isKISImg()
            Graphics.messageBox_errorMessage(title: "Error", contents: "Administrator password field is empty. If you do not have password, please set one. Then try again.")
        }else if !isRootPasswordCorrect {
            isKISImg()
            Graphics.messageBox_errorMessage(title: "Error", contents: "Administrator password is incorrect. Try again.")
        }else{
            isKISImg()
            Graphics.messageBox_errorMessage(title: "Error", contents: "It seems \(PROGRAM_NAME) is already stopped.")
        }
    }
    
    @IBAction func OnSuspendPressed(_ sender: Any) {
        isKISImg()
        if NSSwiftUtils.doesTheFileExist(at: flagData + "suspended") {
            Graphics.messageBox_errorMessage(title: "Error", contents: PROGRAM_NAME + " is already suspended. Please press start button to resume.")
        }else{
            StatusLabel.stringValue = "Suspending " + PROGRAM_NAME
            let listOfSuspendProc = NSSwiftUtils.readContents(of: patchData + "suspendList").components(separatedBy: "\n")
            for i in 0..<listOfSuspendProc.count {
                if listOfSuspendProc[i].elementsEqual("") {
                    break
                }
                NSSwiftUtils.executeShellScript("killall", "-STOP", listOfSuspendProc[i])
            }
            StatusLabel.stringValue = "Writing Flag"
            NSSwiftUtils.executeShellScript("touch", flagData + "suspended")
            NSSwiftUtils.executeShellScript("rm", "-f", flagData + "stopped")
            endOfProcess()
        }
    }
    
    @IBAction func OnUpdatePatchDataPressed(_ sender: Any) {
        ViewController.updatePatchData()
        PatchUpdatedDateLabel.stringValue = "Patch Updated Date: " + NSSwiftUtils.readContents(of: patchData + "updatedDate").replacingOccurrences(of: "\n", with: "")
    }
    
    public static func updatePatchData() {
        let Graphics: GraphicComponents = GraphicComponents()
        NSSwiftUtils.executeShellScript(Bundle.main.resourcePath! + "/patchd/updatedl", patchDataUpdateURL, "/tmp/mempatch.zip")
        NSSwiftUtils.executeShellScript(Bundle.main.resourcePath! + "/validator", "/tmp/mempatch.zip", compatible, "/tmp/val")
        if NSSwiftUtils.readContents(of: "/tmp/val").contains("Binary file (standard input) matches") {
            NSSwiftUtils.executeShellScript("mkdir", "-p", "/tmp/patchd")
            NSSwiftUtils.executeShellScript("unzip", "-q", "/tmp/mempatch.zip", "-d", "/tmp/patchd")
            if NSSwiftUtils.readContents(of: "/tmp/patchd/updatedDate").elementsEqual(NSSwiftUtils.readContents(of: Bundle.main.resourcePath! + "/patchd/updatedDate")) {
                Graphics.messageBox_dialogue(title: "Nothing to Update", contents: "You are using the latest version.")
                NSSwiftUtils.removeDirectory(at: "/tmp/patchd", ignoreSubContents: true)
                NSSwiftUtils.executeShellScript("rm", "-f", "/tmp/mempatch.zip")
            }else{
                if Graphics.messageBox_ask(title: "Found Update", contents: "You have a patch update.\nCurrent Patch: " + NSSwiftUtils.readContents(of: Bundle.main.resourcePath! + "/patchd/updatedDate") + "\nLatest Patch: " + NSSwiftUtils.readContents(of: "/tmp/patchd/updatedDate") + "\n\nWould you update?", firstButton: "Yes", secondButton: "No") {
                    NSSwiftUtils.executeShellScript("rm", "-rf", Bundle.main.resourcePath! + "/patchd")
                    NSSwiftUtils.executeShellScript("cp", "-r", "/tmp/patchd", Bundle.main.resourcePath!)
                    Graphics.messageBox_dialogue(title: "Update Done", contents: "Patch is now up-to-date.")
                }else{
                    Graphics.messageBox_dialogue(title: "Aborted", contents: "Patch update aborted.")
                }
            }
        }else{
            NSSwiftUtils.executeShellScript("rm", "-f", "/tmp/mempatch.zip")
            Graphics.messageBox_errorMessage(title: "Error", contents: "Failed downloading latest compatible patch data from repository.")
        }
    }
}

