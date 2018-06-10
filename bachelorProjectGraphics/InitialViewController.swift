//
//  InitialViewController.swift
//  bachelorProjectGraphics
//
//  Created by Amandine Evard on 17.03.18.
//  Copyright © 2018 Amandine Evard. All rights reserved.
//

import Cocoa

class InitialViewController: NSViewController {

    //simulation
    var simulation: Simulation?
    var JSON_string : String?
    var startWithAnExample : Bool?
    var windowTitle : String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    //start with exemple
    @IBAction func startWithExempleButtonPressed(_ sender: NSButton) {
        JSON_string = nil
        startWithAnExample = true
        windowTitle = "Example"
        performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "start"), sender: self)
    }
    
    //open file
    @IBAction func openFileButtonPressed(_ sender: NSButton) {
        startWithAnExample = false
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["json"]
        
        if (openPanel.runModal() == NSApplication.ModalResponse.OK){
            guard let result = openPanel.url else {return}
            do {
                windowTitle = result.lastPathComponent
                let JSON_string = try String(contentsOf: result, encoding: .utf8)
                self.JSON_string = JSON_string
                performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "start"), sender: self)
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }

    @IBAction func newSimulationButtonPressed(_ sender: NSButton) {
        startWithAnExample = false
        JSON_string = nil
        windowTitle = nil
        performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "start"), sender: self)
    }
    
    
    //prepare for segue
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard segue.identifier!.rawValue == "start", let mainViewController = segue.destinationController as? MainViewController else { return}
        mainViewController.startWithAnExample = startWithAnExample
        mainViewController.JSON_string = JSON_string
        mainViewController.title = windowTitle
    }  
}
