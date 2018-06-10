//
//  ViewController.swift
//  bachelorProjectGraphics
//
//  Created by Amandine Evard on 02.03.18.
//  Copyright © 2018 Amandine Evard. All rights reserved.
//

import Cocoa
import Charts

class MainViewController: NSViewController, NSTextFieldDelegate {
    
    //energyGraphics
    @IBOutlet weak var energyGraphicView: LineChartView!
    @IBOutlet weak var simulationView: SimulationView!
    //flowrate graphics
    @IBOutlet weak var flowRateView: LineChartView!
    
    //progress indicator
    @IBOutlet weak var progressIndicator: PieChartView!
    
    //data for the energy graphs
    let dataEp: [Double] = []
    let dataEk: [Double] = []
    let lineChartEp = LineChartDataSet()
    let lineChartEk = LineChartDataSet()
    let data = LineChartData()
    
    //data for the flowrate graph
    let dataFlow: [Double] = []
    let lineChartFlow = LineChartDataSet()
    let dataf = LineChartData()
    
    //flag
    var flagStop : Bool = false
    
    //startWithExample
    var startWithAnExample : Bool?
    //openfile
    var JSON_string : String?
    
    //itérateurs:
    var i : Int = 0 // iteration simulation
    var j : Int = 0 //iteration initial falling
    
    //data for progress pie:
    var progressIndicatorDataSet = PieChartDataSet()
    let data2 = PieChartData()
    
    //simulation parameters:
    @IBOutlet weak var springConstantSphereTextfield: NSTextField!
    @IBOutlet weak var springConstantWallTextfield: NSTextField!
    @IBOutlet weak var numberOfIterationsTextfield: NSTextField!
    @IBOutlet weak var deltaTTextfield: NSTextField!
    @IBOutlet weak var radiusSphereTextfield: NSTextField!
    @IBOutlet weak var massSphereTextfield: NSTextField!
    @IBOutlet weak var funnelSmallDiameterTextfield: NSTextField!
    @IBOutlet weak var funnelBigDiameterTextfield: NSTextField!
    @IBOutlet weak var funnelSmallHeigthTextfield: NSTextField!
    @IBOutlet weak var funnelBigHeigthTextfield: NSTextField!
    @IBOutlet weak var funnelAngleTextfield: NSTextField!
    @IBOutlet weak var nbOfIterationsFirstPartTextField: NSTextField!
    @IBOutlet weak var rhoTextField: NSTextField!
    @IBOutlet weak var muStaticTextField: NSTextField!
    @IBOutlet weak var dissipationFactorTextField: NSTextField!
    
    
    //simulation:
    var simulation : Simulation?
    
    //buttons:
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var showResultButton: NSButton!
    @IBOutlet weak var generateParametersButton: NSButton!
    @IBOutlet weak var exportFlowRateButton: NSButton!
    
    //label
    @IBOutlet weak var labelText: NSTextField!
    @IBOutlet weak var flowRateChartLabel: NSTextField!
    @IBOutlet weak var energyChartLabel: NSTextField!
    @IBOutlet weak var muStaticLabel: NSTextField!
    @IBOutlet weak var dissipationFactorLabel: NSTextField!
    
    
    //checks
    @IBOutlet weak var showGridCheck: NSButton!
    @IBOutlet weak var frictionCheck: NSButton!
    
    
    //-----------------------------------------------------------------------------
    //------did load--------------------
    //-----------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        //background color
        self.view.layer?.backgroundColor = CGColor.init(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
        
        //Energy graph:
        lineChartEp.label = "potential Energy"
        lineChartEk.label = "kinetic Energy"
        
        lineChartEp.colors = [NSUIColor(red: 128/255, green: 0/255, blue: 42/255, alpha: 1.0)]
        lineChartEp.drawCircleHoleEnabled = false
        lineChartEp.drawCirclesEnabled = false
        lineChartEp.drawValuesEnabled = false
        lineChartEp.lineWidth = 2
        
        lineChartEk.colors = [NSUIColor(red: 230/255, green: 54/255, blue: 0/255, alpha: 1.0)]
        lineChartEk.drawCircleHoleEnabled = false
        lineChartEk.drawCirclesEnabled = false
        lineChartEk.drawValuesEnabled = false
        lineChartEk.lineWidth = 2
        
        data.addDataSet(lineChartEp)
        data.addDataSet(lineChartEk)
        
        self.energyGraphicView.data = data
        self.energyGraphicView.chartDescription?.text = "total Energy"
        
        energyGraphicView.backgroundColor = NSColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)

        
        
        //progress indicator:
        let percentLoad = PieChartDataEntry(value: 0)
        let percentNotLoad = PieChartDataEntry(value : 100 - percentLoad.value)
        let tab = [percentLoad, percentNotLoad]
        progressIndicatorDataSet = PieChartDataSet(values: tab, label: "")
        progressIndicatorDataSet.colors = [NSColor(red: 128/255, green: 0/255, blue: 42/255, alpha: 1.0), NSColor.clear]
        data2.addDataSet(progressIndicatorDataSet)
        progressIndicator.legend.enabled = false
        let centerText: NSMutableAttributedString = NSMutableAttributedString(string: "Progress")
        progressIndicatorDataSet.drawValuesEnabled = false
        self.progressIndicator.centerAttributedText = centerText
        self.progressIndicator.data = data2
        progressIndicator.chartDescription?.text = ""
        
        //design
        labelText.stringValue = "Sand Funnel Simulation"
        showResultButton.isHidden = true
        flowRateChartLabel.frameCenterRotation = CGFloat(-90)
        energyChartLabel.frameCenterRotation = CGFloat(-90)

        
        //flowrate Graph
        lineChartFlow.label = "Flow Rate"
        lineChartFlow.colors = [NSUIColor(red: 128/255, green: 0/255, blue: 42/255, alpha: 1.0)]
        lineChartFlow.drawCircleHoleEnabled = false
        lineChartFlow.drawCirclesEnabled = false
        lineChartFlow.drawValuesEnabled = false
        dataf.addDataSet(lineChartFlow)
        self.flowRateView.data = dataf
        self.flowRateView.gridBackgroundColor = NSUIColor.white
        self.flowRateView.chartDescription?.text = "flow rate sphere"
        flowRateView.backgroundColor = NSColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        lineChartFlow.lineWidth = 2
    }
    //-----------------------------------------------------------------------------
    //------did appear--------------------
    //-----------------------------------------------------------------------------
    override func viewDidAppear() {
        //if start with an example
        if (startWithAnExample == true){
            self.startButton.isEnabled = false
            self.stopButton.isEnabled = false
            self.saveButton.isEnabled = false
            self.exportFlowRateButton.isEnabled = false
            DispatchQueue.global(qos: .utility).async {
                //example:
                self.simulation = Simulation(mainInformations: SimulationData(deltaT: 0.000178, nbOfSteps: 14000, results: nil, springConstantSphere: 131.5, springConstantWall: 263.0, massSphere: 0.000067, radiusSphere: 0.002, funnelDiameter: 0.016, inclinaisonDegreFunnel: 45, funnelBigDiameter: 0.064, funnelSmallHeigth : 0.005, funnelBigHeigth : 0.05, nbIterationsInitialRepartition: 2000, muStatic: 0.1,dissipationFactor: 0.06575 ))
                DispatchQueue.main.async {
                    guard let simulation = self.simulation else {return}
                    self.frictionCheck.state = self.getStateCheckfromBool(check: simulation.frictionCheck)
                    self.frictionCheck.isEnabled = false
                    self.simulationView.simulation = simulation
                    self.simulationView.needsDisplay = true
                    self.writeSimulationParametersToTextField()
                    self.startButton.isEnabled = true
                    self.saveButton.isEnabled = true
                }
            }
        //if loading simulation
        } else if ( JSON_string != nil) {
            guard let JSON_string = JSON_string else {return}
            self.startButton.isEnabled = false
            self.stopButton.isEnabled = false
            self.saveButton.isEnabled = false
            self.exportFlowRateButton.isEnabled = false
            DispatchQueue.global(qos: .utility).async {
                do {
                    let savingInfos_JSON : SimulationData = try JSONDecoder().decode(SimulationData.self, from: Data(JSON_string.utf8))
                    self.simulation = Simulation(mainInformations: savingInfos_JSON)
                    self.simulationView.simulation = self.simulation
                    DispatchQueue.main.async {
                        guard let simulation = self.simulation else{return}
                        self.frictionCheck.state = self.getStateCheckfromBool(check: simulation.frictionCheck)
                        self.saveButton.isEnabled = true
                        if (simulation.results != nil){
                            self.startButton.isEnabled = false
                            self.exportFlowRateButton.isEnabled = true
                            self.showResultButton.isHidden = false
                            let positionsInitials = simulation.results!.positionsResultsTab[0]!
                            self.reloadUIforResults(positions: positionsInitials)
                            self.allTextFieldAreEditable(false)
                        } else {
                            self.startButton.isEnabled = true
                        }
                        self.writeSimulationParametersToTextField()
                    }
                } catch {
                    //alert file cannot be open
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.messageText = "Error"
                        alert.informativeText = "File seems not working"
                        alert.alertStyle = .warning
                        alert.addButton(withTitle: "OK")
                        self.stopButton.isEnabled = false
                        self.startButton.isEnabled = true
                        if (alert.runModal() == .alertFirstButtonReturn){
                            self.view.window?.close()
                        }
                    }
                }
            }
            
        // new simulation
        } else{
            self.stopButton.isEnabled = false
            self.saveButton.isEnabled = false
            self.startButton.title = "Create Simulation"
        }
    }
    
    
    //-----------------------------------------------------------------------------
    //------start pressed--------------------
    //-----------------------------------------------------------------------------
    @IBAction func startPressed(_ sender: NSButton) {
        flagStop = false
        saveButton.isEnabled = false
        stopButton.isEnabled = true
        startButton.isEnabled = false
        exportFlowRateButton.isEnabled = false

        frictionCheck.isEnabled = false
        allTextFieldAreEditable(false)
        //if new simulation
        if (simulation == nil) {
            let springConstantSphere : Double? = Double(springConstantSphereTextfield.stringValue)
            let springConstantWall : Double? = Double(springConstantWallTextfield.stringValue)
            let numberOfIterations : Int? = Int(numberOfIterationsTextfield.stringValue)
            let deltaTEntry : Double? = Double(deltaTTextfield.stringValue)
            let radiusSphere : Double? = Double(radiusSphereTextfield.stringValue)
            let massSphere : Double?  = Double(massSphereTextfield.stringValue)
            let funnelSmallDiameter : Double? = Double(funnelSmallDiameterTextfield.stringValue)
            let funnelBigDiameter : Double? = Double(funnelBigDiameterTextfield.stringValue)
            let funnelSmallHeigth : Double? = Double(funnelSmallHeigthTextfield.stringValue)
            let funnelBigHeigth : Double? = Double(funnelBigHeigthTextfield.stringValue)
            let funnelAngle : Double? = Double(funnelAngleTextfield.stringValue)
            let nbIterationsInitialRepartition: Int? = Int(nbOfIterationsFirstPartTextField.stringValue)
            var muStatic: Double? = Double(muStaticTextField.stringValue)
            var dissipationFactor: Double? = Double(dissipationFactorTextField.stringValue)
            let tab: [Double?] = [muStatic,dissipationFactor]
            if frictionCheck.state == .off{
                muStatic = nil
                dissipationFactor = nil
            }
            if let springConstantSphere = springConstantSphere, let springConstantWall = springConstantWall, let numberOfIterations = numberOfIterations,let deltaTEntry = deltaTEntry, let radiusSphere = radiusSphere, let massSphere = massSphere, let funnelSmallDiameter = funnelSmallDiameter, let funnelBigDiameter = funnelBigDiameter, let funnelSmallHeigth = funnelSmallHeigth, let funnelBigHeigth = funnelBigHeigth, let funnelAngle2 = funnelAngle,let nbIterationsInitialRepartition = nbIterationsInitialRepartition,muStatic ?? 1 > 0 && dissipationFactor ?? 1>0 && funnelAngle2>=0 && funnelAngle2<90 && funnelBigHeigth>=radiusSphere*2 && funnelBigDiameter>=funnelSmallDiameter && springConstantSphere>0 && springConstantWall>0 && numberOfIterations>0 && deltaTEntry>0 && radiusSphere>0 && massSphere>0 && funnelSmallDiameter>0 && funnelBigDiameter>0 && funnelSmallHeigth>0 && funnelBigHeigth>0 && (tab.map{$0 == nil}.reduce(true, {$0 && $1}) || tab.map{$0 ?? -1 > 0}.reduce(true, {$0 && $1})){
                let infos = SimulationData(deltaT: deltaTEntry, nbOfSteps: numberOfIterations, results: nil, springConstantSphere: springConstantSphere, springConstantWall: springConstantWall, massSphere: massSphere, radiusSphere: radiusSphere, funnelDiameter: funnelSmallDiameter, inclinaisonDegreFunnel : funnelAngle2, funnelBigDiameter : funnelBigDiameter,funnelSmallHeigth : funnelSmallHeigth, funnelBigHeigth : funnelBigHeigth, nbIterationsInitialRepartition: nbIterationsInitialRepartition, muStatic : muStatic, dissipationFactor : dissipationFactor)
                simulation = Simulation(mainInformations: infos)
                simulationView.simulation = simulation
                simulationView.needsDisplay = true
                self.startButton.title = "Start Simulation"
                saveButton.isEnabled = true
                startButton.isEnabled = true
                stopButton.isEnabled = false
                allTextFieldAreEditable(true)
            } else {
                //alert not valide parameters
                let alert = NSAlert()
                alert.messageText = "Error"
                alert.informativeText = "Please enter valide numbers"
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
                stopButton.isEnabled = false
                startButton.isEnabled = true
                allTextFieldAreEditable(true)
            }
        }
        //play simulation:
        else {
            guard let simulation = simulation else{return}
            if( j == 0) {
                simulation.listOfWalls.append(Wall(Xa: simulation.funnelBase/2 - simulation.funnelBottleneck/2, Ya: simulation.funnelBottleneckLength, Xb: simulation.funnelBase/2 - simulation.funnelBottleneck/2 + simulation.funnelBottleneck, Yb: simulation.funnelBottleneckLength, k: simulation.springConstantWall))
                simulationView.needsDisplay = true
                let centerText: NSMutableAttributedString = NSMutableAttributedString(string: "Initial Progress")
                self.progressIndicator.centerAttributedText = centerText
                progressIndicatorDataSet.colors = [NSColor(red: 163/255, green: 220/255, blue: 236/255, alpha: 1.0), NSColor.clear]
            }
            DispatchQueue.global(qos: .utility).async {
                if( self.i == 0){
                    self.spheresFallingForInitialRepartition()
                }
                if (self.j == simulation.nbIterationsInitialRepartition && self.i == 0 && !self.flagStop){
                    if (simulation.listOfWalls.endIndex==7) {simulation.listOfWalls.remove(at: 6)}
                    for t in 1...3 {
                        DispatchQueue.main.async {
                            self.lineChartEp.clear()
                            self.lineChartEk.clear()
                            self.reloadUI()
                            if(!self.flagStop){
                                self.labelText.stringValue = "Simulation start in ... \(4-t)"
                            }
                        }
                        sleep(1)
                    }
                    self.progressIndicatorDataSet.values[0].y = 0
                    self.progressIndicatorDataSet.values[1].y = 100
                    self.reloadUI()
                }
                DispatchQueue.main.async {
                    if(!self.flagStop){
                        self.labelText.stringValue = "Simulating..."
                        let centerText: NSMutableAttributedString = NSMutableAttributedString(string: "Simulation Progress")
                        self.progressIndicator.centerAttributedText = centerText
                        self.progressIndicatorDataSet.colors = [NSColor(red: 128/255, green: 0/255, blue: 42/255, alpha: 1.0), NSColor.clear]
                    }
                }
                if(!self.flagStop){
                    self.simulationPlay()
                }
            }
        }
    }

    //-----------------------------------------------------------------------------
    //------alert--------------------
    //-----------------------------------------------------------------------------
    func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    //-----------------------------------------------------------------------------
    //------button stop pressed--------------------
    //-----------------------------------------------------------------------------
    @IBAction func stopPressed(_ sender: NSButton) {
        flagStop = true
        startButton.title = "Continue"
        saveButton.isEnabled = true
        startButton.isEnabled = true
        stopButton.isEnabled = false
        labelText.stringValue = ""
        allTextFieldAreEditable(true)
        if simulation?.results != nil{
            exportFlowRateButton.isEnabled = true
        }
    }
    
    //-----------------------------------------------------------------------------
    //------function simulation--------------------
    //-----------------------------------------------------------------------------
    func spheresFallingForInitialRepartition(){
        guard let simulation = simulation else {return}
        let reloadFactor : Int = Int(ceil(1800/Double(simulation.listOfSpheres.count)))
        while( j < simulation.nbIterationsInitialRepartition &&  self.flagStop == false) {
            //calcul new positions and test reload grid
            let displacementI = VerletAlgorithm(simulation: simulation)
            if (gridNeedReload(displacementMaxOneIteration: displacementI, simulation: simulation)){
                simulation.grid.updateSpheresInGrid(listOfSphere: simulation.listOfSpheres)
            }
            //simulation
            if(self.j % reloadFactor == 0){
                _ = self.lineChartEp.addEntry(ChartDataEntry(x: Double(j) * simulation.deltaT, y: simulation.totalPotentialEnergy()))
                _ = self.lineChartEk.addEntry(ChartDataEntry(x: Double(j) * simulation.deltaT, y: simulation.totalKineticEnergy()))
                let progress = Double(j)/Double(simulation.nbIterationsInitialRepartition) * 100
                self.progressIndicatorDataSet.values[0].y = progress
                self.progressIndicatorDataSet.values[1].y = 100 - progress
                self.reloadUI()
            }
            j+=1
        }
        DispatchQueue.main.async {
            if( self.j == simulation.nbIterationsInitialRepartition){
                self.progressIndicatorDataSet.values[0].y = 100
                self.progressIndicatorDataSet.values[1].y = 0
            }
            self.reloadUI()
        }
    }
    
    func simulationPlay(){
        guard let simulation = simulation else{return}
        let reloadFactor : Int = Int(ceil(1800/Double(simulation.listOfSpheres.count)))
        while( self.i < simulation.nbOfSteps &&  self.flagStop == false) {
            //calcul new positions and test reload grid
            let displacementI = VerletAlgorithm(simulation: simulation)
            if (gridNeedReload(displacementMaxOneIteration: displacementI, simulation: simulation)){
                simulation.removeSpheres()
                simulation.grid.updateSpheresInGrid(listOfSphere: simulation.listOfSpheres)
            }
            //simulation
            if(self.i % reloadFactor == 0){ //reload factor decision here
                simulation.updateSimulationResult(currentN: self.i, reloadfactor: reloadFactor)
                _ = self.lineChartEp.addEntry(ChartDataEntry(x: Double(self.i) * simulation.deltaT, y: simulation.results!.energyResultsTab[Double(self.i)*simulation.deltaT]![0]))
                _ = self.lineChartEk.addEntry(ChartDataEntry(x: Double(self.i) * simulation.deltaT, y: simulation.results!.energyResultsTab[Double(i)*simulation.deltaT]![1]))
                if let flowrate = simulation.results?.flowRateTab[Double(self.i) * simulation.deltaT]{
                    _ = self.lineChartFlow.addEntry(ChartDataEntry(x:Double(self.i) * simulation.deltaT , y: flowrate))
                }
                let progress = Double(self.i) / Double(simulation.nbOfSteps) * 100
                self.progressIndicatorDataSet.values[0].y = progress
                self.progressIndicatorDataSet.values[1].y = 100 - progress
                self.reloadUI()
            }
            self.i+=1
        }
        DispatchQueue.main.async {
            self.saveButton.isEnabled = true
            if( self.i == simulation.nbOfSteps){
                self.startButton.title = "Simulation Finished"
                self.labelText.stringValue = "Simulation Finished"
                self.startButton.isEnabled = false
                self.stopButton.isEnabled = false
                self.showResultButton.isHidden = false
                self.exportFlowRateButton.isEnabled = true
                self.progressIndicatorDataSet.values[0].y = 100
                self.progressIndicatorDataSet.values[1].y = 0
            }
            self.reloadUI()
        }
    }

    //-----------------------------------------------------------------------------
    //------showResults--------------------
    //-----------------------------------------------------------------------------

    @IBAction func showResultsButtonPressed(_ sender: NSButton) {
        showResultButton.isEnabled = false
        lineChartEp.clear()
        lineChartEk.clear()
        lineChartFlow.clear()
        guard let results = simulation?.results?.positionsResultsTab else {return}
        guard let energy = simulation?.results?.energyResultsTab else {return}
        guard let flowrate = simulation?.results?.flowRateTab else {return}
        let numberOfIterations = energy.keys.count
        let resultsSorted = results.sorted(by: { $0.0 < $1.0 })
        var ii :Int = 0
        DispatchQueue.global(qos: .utility).async {
            for (key , positions) in resultsSorted {
                guard let energyPair = energy[key] else {return}
                if let flowratekey = flowrate[key]{
                    _ = self.lineChartFlow.addEntry(ChartDataEntry(x: key, y: flowratekey))
                    _ = self.lineChartEp.addEntry(ChartDataEntry(x: key, y: energyPair[0]))
                    _ = self.lineChartEk.addEntry(ChartDataEntry(x: key, y: energyPair[1]))
                }
                usleep(UInt32(4000))//decision here
                let progress = Double(ii) / Double(numberOfIterations) * 100
                self.progressIndicatorDataSet.values[0].y = progress
                self.progressIndicatorDataSet.values[1].y = 100 - progress
                self.reloadUIforResults(positions: positions)
                ii += 1
            }
            DispatchQueue.main.async {
                self.progressIndicatorDataSet.values[0].y = 100
                self.progressIndicatorDataSet.values[1].y = 0
                self.updateProgressIndicator()
                self.showResultButton.isEnabled = true
            }
        }
    }
    //-----------------------------------------------------------------------------
    //------textfield fonction--------------------
    //-----------------------------------------------------------------------------
    
    func allTextFieldAreEditable(_ bool : Bool){
        springConstantSphereTextfield.isEditable = bool
        springConstantWallTextfield.isEditable = bool
        numberOfIterationsTextfield.isEditable = bool
        deltaTTextfield.isEditable = bool
        radiusSphereTextfield.isEditable = bool
        massSphereTextfield.isEditable = bool
        funnelSmallDiameterTextfield.isEditable = bool
        funnelBigDiameterTextfield.isEditable = bool
        funnelSmallHeigthTextfield.isEditable = bool
        funnelBigHeigthTextfield.isEditable = bool
        funnelAngleTextfield.isEditable = bool
        rhoTextField.isEditable = bool
        nbOfIterationsFirstPartTextField.isEditable = bool
        muStaticTextField.isEditable = bool
        dissipationFactorTextField.isEditable = bool
        //button
        generateParametersButton.isEnabled = bool
        
    }
    
    func writeSimulationParametersToTextField(){
        guard let simulation = simulation else {return}
        self.springConstantSphereTextfield.stringValue = String(simulation.springConstantSphere)
        self.springConstantWallTextfield.stringValue = String(simulation.springConstantWall)
        self.numberOfIterationsTextfield.stringValue = String(simulation.nbOfSteps)
        self.deltaTTextfield.stringValue = String(simulation.deltaT)
        self.radiusSphereTextfield.stringValue = String(simulation.radiusSphere)
        self.massSphereTextfield.stringValue = String(simulation.massSphere)
        self.funnelSmallDiameterTextfield.stringValue = String(simulation.funnelBottleneck)
        self.funnelBigDiameterTextfield.stringValue = String(simulation.funnelBase)
        self.funnelSmallHeigthTextfield.stringValue = String(simulation.funnelBottleneckLength)
        self.funnelBigHeigthTextfield.stringValue = String(simulation.funnelBaseHeigth)
        self.funnelAngleTextfield.stringValue = String(simulation.inclinaisonDegreFunnel)
        self.nbOfIterationsFirstPartTextField.stringValue = String(simulation.nbIterationsInitialRepartition)
        self.muStaticTextField.stringValue = simulation.muStatic == nil ? "" : String(simulation.muStatic!)
        self.dissipationFactorTextField.stringValue = simulation.dissipationFactor==nil ? "" : String(simulation.dissipationFactor!)
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        guard let _ = simulation else {return}
        guard let txtFld = obj.object as? NSTextField else {return}
        if (txtFld.isEditable){
            //alert delete current simulation
            let answer = dialogOKCancel(question: "You're about to delete the current simulation.", text: "Continue?")
            if answer  { //ok button tape
                self.simulation = nil
                simulationView.simulation = self.simulation
                i = 0
                j = 0
                lineChartEp.clear()
                lineChartEk.clear()
                lineChartFlow.clear()
                self.progressIndicatorDataSet.values[0].y = 0
                self.progressIndicatorDataSet.values[1].y = 100
                self.startButton.title = "Create Simulation"
                frictionCheck.isEnabled = true
                reloadUI()
            } else {
                writeSimulationParametersToTextField()
            }
        }
    }
    //-----------------------------------------------------------------------------
    //------update function--------------------
    //-----------------------------------------------------------------------------
    
    func updateProgressIndicator(){
        self.progressIndicatorDataSet.notifyDataSetChanged()
        self.data2.notifyDataChanged()
        self.progressIndicator.notifyDataSetChanged()
        self.progressIndicator.needsDisplay = true
    }
    
    func updateEnergyChart(){
        self.lineChartEp.notifyDataSetChanged()
        self.lineChartEk.notifyDataSetChanged()
        self.data.notifyDataChanged()
        self.energyGraphicView.notifyDataSetChanged()
        self.energyGraphicView.needsDisplay = true
    }
    func updateFlowRateChart(){
        self.lineChartFlow.notifyDataSetChanged()
        self.dataf.notifyDataChanged()
        self.flowRateView.notifyDataSetChanged()
        self.flowRateView.needsDisplay = true
    }
    
    func reloadUI(){
        DispatchQueue.main.async {
            //update chart
            self.updateEnergyChart()
            //simulation view
            self.simulationView.needsDisplay = true
            //update pie
            self.updateProgressIndicator()
            //chart flowrate
            self.updateFlowRateChart()
        }
    }
    
    func reloadUIforResults(positions: [[Double]]){
        DispatchQueue.main.async {
            //play simulation with positions
            self.simulationView.positions = positions
            self.simulationView.needsDisplay = true
            //update chart
            self.updateEnergyChart()
            self.updateFlowRateChart()
            //progress indicator
            self.updateProgressIndicator()
        }
    }
    
    //-----------------------------------------------------------------------------
    //------saving the result--------------------
    //-----------------------------------------------------------------------------
     //save the simulation's datas:
    @IBAction func saveButtonPressed(_ sender: NSButton) {
        guard let simulation = simulation else {return}
        let saving = SimulationData(deltaT: simulation.deltaT, nbOfSteps: simulation.nbOfSteps, results: simulation.results, springConstantSphere: simulation.springConstantSphere, springConstantWall: simulation.springConstantWall, massSphere: simulation.massSphere, radiusSphere: simulation.radiusSphere, funnelDiameter: simulation.funnelBottleneck, inclinaisonDegreFunnel: simulation.inclinaisonDegreFunnel, funnelBigDiameter: simulation.funnelBase, funnelSmallHeigth: simulation.funnelBottleneckLength, funnelBigHeigth: simulation.funnelBaseHeigth, nbIterationsInitialRepartition: simulation.nbIterationsInitialRepartition, muStatic: simulation.muStatic, dissipationFactor: simulation.dissipationFactor)
        if let json_data = try? JSONEncoder().encode(saving){
            guard let json_string = String(data: json_data, encoding : .utf8) else{return}
            let savePanel = NSSavePanel()
            savePanel.canCreateDirectories = true
            savePanel.allowedFileTypes = ["json"]
            savePanel.begin { result in
                if result == NSApplication.ModalResponse.OK {
                    guard let url = savePanel.url else {return}
                    do {
                        try json_string.write(to: url, atomically: false, encoding: String.Encoding.utf8)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    //export flowrate
    @IBAction func exportFlowRatePressed(_ sender: NSButton) {
        guard let simulation = simulation else {return}
        guard let  results = simulation.results?.flowRateTab else{return}
        let saving = FlowRateData(radius: simulation.radiusSphere, bottleneck: simulation.funnelBottleneck,mass: simulation.massSphere, flowrateDictionnary: results)
        if let json_data = try? JSONEncoder().encode(saving){
            guard let json_string = String(data: json_data, encoding : .utf8) else{return}
            let savePanel = NSSavePanel()
            savePanel.canCreateDirectories = true
            savePanel.allowedFileTypes = ["json"]
            savePanel.begin { result in
                if result == NSApplication.ModalResponse.OK {
                    guard let url = savePanel.url else {return}
                    do {
                        try json_string.write(to: url, atomically: false, encoding: String.Encoding.utf8)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    
    //-----------------------------------------------------------------------------
    //------checks--------------------
    //-----------------------------------------------------------------------------
    @IBAction func showGridCheckChanged(_ sender: NSButton) {
        if showGridCheck.state == .on{
            simulationView.showGridCheck = true
        }else{
            simulationView.showGridCheck = false
        }
        simulationView.needsDisplay = true
    }
    @IBAction func frictionCheckChanged(_ sender: NSButton) {
        if frictionCheck.state == .on {
            muStaticTextField.isHidden = false
            muStaticLabel.isHidden = false
            dissipationFactorTextField.isHidden = false
            dissipationFactorLabel.isHidden = false
        }else{
            muStaticTextField.isHidden = true
            muStaticTextField.stringValue = ""
            muStaticLabel.isHidden = true
            dissipationFactorTextField.isHidden = true
            dissipationFactorTextField.stringValue = ""
            dissipationFactorLabel.isHidden = true
        }
    }
    
    func getStateCheckfromBool(check: Bool) -> NSControl.StateValue{
        return check ? .on : .off
    }
    
    
    
    //-----------------------------------------------------------------------------
    //------method to generate parameters:--------------------
    //-----------------------------------------------------------------------------
    @IBAction func generateSimulationParametersFromRadius(_ sender: NSButton) {
        let r : Double? = Double(radiusSphereTextfield.stringValue)
        let funnelBaseLength : Double? = Double(funnelBigDiameterTextfield.stringValue)
        let rho: Double? = Double(rhoTextField.stringValue)
        if let radius = r, let funnelBaseLength=funnelBaseLength, let rho=rho, radius>0 && funnelBaseLength>0 && rho>0{
            if simulation != nil{
                //alert delete current simulation
                let answer = dialogOKCancel(question: "You're about to delete the current simulation.", text: "Continue?")
                if answer  { //ok button tape
                    self.simulation = nil
                    simulationView.simulation = self.simulation
                    i = 0
                    j = 0
                    lineChartEp.clear()
                    lineChartEk.clear()
                    lineChartFlow.clear()
                    self.progressIndicatorDataSet.values[0].y = 0
                    self.progressIndicatorDataSet.values[1].y = 100
                    self.startButton.title = "Create Simulation"
                    frictionCheck.isEnabled = true
                    generateParameters(radius: radius, funnelBaseLength: funnelBaseLength, rho: rho)
                    reloadUI()
                }
            } else {
                generateParameters(radius: radius, funnelBaseLength: funnelBaseLength, rho: rho)
            }
        }else{
            // alert not valide input rho,funnel size or radius
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.informativeText = "Please enter valide radius, rho and funnel size"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
            stopButton.isEnabled = false
            startButton.isEnabled = true
            allTextFieldAreEditable(true)
        }
    }
    
    func generateParameters(radius: Double, funnelBaseLength: Double, rho: Double){
        let mass = round((rho*4/3*3.1415*pow(radius,3)), to: 3)
        massSphereTextfield.stringValue = String(mass)
        let ksphere = round(mass*9.81/(0.05*radius) * 20, to:4)
        springConstantSphereTextfield.stringValue = String(ksphere)
        springConstantWallTextfield.stringValue = String(ksphere*2)
        let deltaT = round(0.05*radius/sqrt(2*9.81*funnelBaseLength)*2, to: 3)
        deltaTTextfield.stringValue = String(deltaT)
        let nbIterationInitialRepartition:Int = Int(2*round(ceil(2/radius), to: 3))
        nbOfIterationsFirstPartTextField.stringValue = String(nbIterationInitialRepartition)
        dissipationFactorTextField.stringValue = String(0.0005*ksphere)
        muStaticTextField.stringValue = String(0.1)
    }
    
}



