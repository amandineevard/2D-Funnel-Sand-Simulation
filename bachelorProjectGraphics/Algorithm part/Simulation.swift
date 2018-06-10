//
//  Simulation.swift
//  bachelorProjectGraphics
//
//  Created by Amandine Evard on 17.03.18.
//  Copyright © 2018 Amandine Evard. All rights reserved.
//

import Foundation

struct SpherePair: Hashable, Equatable {
    static func == (lhs: SpherePair, rhs: SpherePair) -> Bool {
        return ((lhs.s1 == rhs.s1 && lhs.s2 == rhs.s2)||(lhs.s1 == rhs.s2 && lhs.s2 == rhs.s1))
    }
    var hashValue: Int {return s1.hashValue + s2.hashValue}
    let s1: Sphere
    let s2: Sphere
}


class Simulation{
    var flowrate: Double = 0
    typealias SphereToSphereFriction = [SpherePair: Double]
    let frictionCheck: Bool
    //before simulation
    let deltaT : Double
    let nbOfSteps : Int
    let nbIterationsInitialRepartition: Int
    var listOfWalls: [Wall]
    var listOfSpheres : [Sphere]
    let springConstantSphere : Double
    let springConstantWall : Double
    let massSphere : Double
    let radiusSphere : Double
    let funnelBottleneck : Double
    let inclinaisonDegreFunnel : Double
    let funnelBase : Double
    let funnelBottleneckLength : Double
    let funnelBaseHeigth : Double
    let grid: Grid
    let muStatic: Double?
    let dissipationFactor: Double?
    var springFrictionTab: SphereToSphereFriction?
    //after simulation
    var results : Result?
    
    init(mainInformations: SimulationData) {
        flowrate = 0
        self.deltaT = mainInformations.deltaT
        self.nbOfSteps = mainInformations.nbOfSteps
        self.springConstantSphere = mainInformations.springConstantSphere
        self.springConstantWall = mainInformations.springConstantWall
        self.massSphere = mainInformations.massSphere
        self.radiusSphere = mainInformations.radiusSphere
        self.funnelBottleneck = mainInformations.funnelBottleneck
        self.inclinaisonDegreFunnel = mainInformations.inclinaisonDegreFunnel
        self.funnelBase = mainInformations.funnelBase
        self.funnelBottleneckLength = mainInformations.funnelBottleneckLength
        self.funnelBaseHeigth = mainInformations.funnelBaseHeigth
        self.nbIterationsInitialRepartition = mainInformations.nbIterationsInitialRepartition
        
        //________________
        //creation funnel:
        let l: Double  = funnelBase/2 - funnelBottleneck/2
        let h: Double = tan(inclinaisonDegreFunnel/180 * 3.1415) * l
        let secureHeigth : Double = (h + funnelBaseHeigth) * 0.2
        
        self.listOfWalls = [Wall(Xa: l, Ya: 0, Xb: l, Yb: funnelBottleneckLength, k: springConstantWall),Wall(Xa: l, Ya: funnelBottleneckLength, Xb: 0, Yb: funnelBottleneckLength + h, k: springConstantWall),Wall(Xa: 0, Ya: funnelBottleneckLength + h, Xb: 0, Yb: funnelBottleneckLength + h + funnelBaseHeigth + secureHeigth, k: springConstantWall),Wall(Xa: l+funnelBottleneck, Ya: 0, Xb: l + funnelBottleneck, Yb: funnelBottleneckLength, k: springConstantWall),Wall(Xa: l+funnelBottleneck, Ya: funnelBottleneckLength, Xb: l + funnelBottleneck + l, Yb: funnelBottleneckLength + h, k: springConstantWall),Wall(Xa: l + funnelBottleneck + l, Ya: funnelBottleneckLength + h, Xb: l + funnelBottleneck + l, Yb: funnelBottleneckLength + h + funnelBaseHeigth + secureHeigth, k: springConstantWall)]
        self.listOfSpheres = []
        
        //________________
        //creation Spheres:
        let heigthZero : Double = h + funnelBaseHeigth
        let nbOfSpheresPerColumn = Int(floor(heigthZero / (radiusSphere * 2)))
        for j in 1...(nbOfSpheresPerColumn)  {
            let dh = 2 * radiusSphere
            let dx = (Double(j) * dh - radiusSphere) * l / h
            var distance : Double = 0
            if (dx<l){
                distance = funnelBottleneck + 2 * dx
            } else {
                distance = funnelBottleneck + 2 * l
            }
            let nbOfSpheresPerLigne = Int(floor(distance / (radiusSphere * 2)))
            let Vmax = 0.005*radiusSphere/deltaT //initial velocity with random repartition:
            for i in 1...(nbOfSpheresPerLigne) {
                if (dx<l){
                    listOfSpheres.append(Sphere(x: (l - dx) + (Double(i)*2*radiusSphere) - radiusSphere, y: funnelBottleneckLength + Double(j)*dh, Vx: (drand48()*2-1)*Vmax, Vy: (drand48()*2-1)*Vmax))
                } else {
                    listOfSpheres.append(Sphere(x: (Double(i)*2*radiusSphere) - radiusSphere, y: funnelBottleneckLength + Double(j)*dh,  Vx: (drand48()*2-1)*Vmax, Vy: (drand48()*2-1)*Vmax))
                }
            }
        }
        self.grid = Grid(listOfSphere: listOfSpheres, radius: radiusSphere, listOfWalls: listOfWalls)!
        self.results = mainInformations.results
        
        if mainInformations.dissipationFactor==nil || mainInformations.muStatic==nil{
            self.frictionCheck = false
            self.springFrictionTab = nil
            self.muStatic = nil
            self.dissipationFactor = nil
        }else{
            self.frictionCheck = true
            self.springFrictionTab = [:]
            self.muStatic = mainInformations.muStatic
            self.dissipationFactor = mainInformations.dissipationFactor
        }
    }
    //-----------------------------------------------------------------------------
    //------saving the result--------------------
    //-----------------------------------------------------------------------------
    
    func updateSimulationResult(currentN : Int, reloadfactor : Int){
        if(results == nil) {
            var tabPositions : [[Double]] = []
            self.listOfSpheres.forEach{sphere in
                tabPositions.append([sphere.x,sphere.y])
            }
            self.results = Result(positionsResultsTab: [0: []], energyResultsTab: [0 : []], flowRateTab : [0: 0])
            self.results?.positionsResultsTab[0] = tabPositions
            updateEnergyAndForcesForListOfSpheres()
            self.results?.energyResultsTab[0] = [self.totalPotentialEnergy(),self.totalKineticEnergy()]
        }
        var tabPositions : [[Double]] = []
        self.listOfSpheres.forEach{sphere in
            tabPositions.append([sphere.x,sphere.y])
        }
        self.results?.positionsResultsTab[(Double(currentN) * deltaT)] = tabPositions
        self.results?.energyResultsTab[(Double(currentN) * deltaT)] = [self.totalPotentialEnergy(),self.totalKineticEnergy()]
        if ((Double(currentN) * deltaT) > 200*self.deltaT*Double(self.results!.flowRateTab.count)){
           self.results?.flowRateTab[(Double(currentN) * deltaT)] = flowrate/(200*self.deltaT)
            flowrate = 0
        }
    }
    //remove sphere
    func removeSpheres(){
        self.listOfSpheres.forEach{sphere in
            if(sphere.y<0){
                listOfSpheres.remove(at: listOfSpheres.index(of: sphere)!)
                flowrate+=1
            }
        }
    }
    
    //-----------------------------------------------------------------------------
    //------update energy and forces--------------------
    //-----------------------------------------------------------------------------
    func updateEnergyAndForcesForListOfSpheres(){
        var EnergyAndForceTab = [EnergyAndForces](repeating: EnergyAndForces(Ep: 0, forcex: 0, forcey: 0), count: listOfSpheres.count)
        //interaction between spheres using grid
        for (indexMainSphere,mainSphere) in listOfSpheres.enumerated(){
            let column = grid.getColumn(mainSphere)
            let row = grid.getRow(mainSphere)
            for i in column-1...column+1{
                for j in row-1...row+1{
                    if let indexSpheresTab = grid.getListOfSpheresInCell(row: j, column: i){
                        indexSpheresTab.forEach{indexSphere in
                            let sphere = listOfSpheres[indexSphere]
                            if (indexSphere != indexMainSphere && indexMainSphere<indexSphere){
                                let r: Double = sqrt((mainSphere.x - sphere.x)*(mainSphere.x - sphere.x) + (mainSphere.y - sphere.y)*(mainSphere.y - sphere.y))
                                let R: Double = 2*radiusSphere
                                if (r < R){
                                    let rx = (mainSphere.x - sphere.x)/r
                                    let ry = (mainSphere.y - sphere.y)/r
                                    if frictionCheck {
                                        var epsilon: Double? = self.springFrictionTab![SpherePair(s1: mainSphere, s2: sphere)]
                                        if epsilon == nil{
                                            epsilon = 0
                                        } else {
                                            //tangential unit vector
                                            let nx = ry
                                            let ny = -rx
                                            //relative velocity:
                                            let relativeV: Double = nx*(mainSphere.Vx - sphere.Vx) + ny*(mainSphere.Vy - sphere.Vy)
                                            //updating epsilon
                                            epsilon = epsilon! + relativeV*Double(self.deltaT)
                                            //forces:
                                            var friction = -springConstantSphere*epsilon! - dissipationFactor!*relativeV
                                            let fnormal = -springConstantSphere * (r - R)
                                            if abs(friction) > abs(fnormal*muStatic!){
                                                friction = friction/abs(friction)*muStatic!*fnormal
                                            }
                                            EnergyAndForceTab[indexMainSphere].forcex += friction*nx
                                            EnergyAndForceTab[indexMainSphere].forcey += friction*ny
                                            EnergyAndForceTab[indexMainSphere].Ep += 0.125*friction*friction/springConstantSphere
                                            EnergyAndForceTab[indexSphere].forcex -= friction*nx
                                            EnergyAndForceTab[indexSphere].forcey -= friction*ny
                                            EnergyAndForceTab[indexSphere].Ep += 0.125*friction*friction/springConstantSphere
                                        }
                                        self.springFrictionTab![SpherePair(s1: mainSphere, s2: sphere)] = epsilon
                                    }
                                    let forceCollisionX = springConstantSphere * (r - R) * rx
                                    let forceCollisionY = springConstantSphere * (r - R) * ry
                                    //on main sphere
                                    EnergyAndForceTab[indexMainSphere].forcex -= forceCollisionX
                                    EnergyAndForceTab[indexMainSphere].forcey -= forceCollisionY
                                    EnergyAndForceTab[indexMainSphere].Ep +=  0.25*springConstantSphere*(r - R)*(r - R)
                                    //on second sphere
                                    EnergyAndForceTab[indexSphere].forcex -= -forceCollisionX
                                    EnergyAndForceTab[indexSphere].forcey -= -forceCollisionY
                                    EnergyAndForceTab[indexSphere].Ep += 0.25*springConstantSphere*(r - R)*(r - R)
                                }
                                else {//if r>R
                                    if frictionCheck{
                                        let epsilon = self.springFrictionTab![SpherePair(s1: mainSphere, s2: sphere)]
                                        if epsilon != nil{
                                            self.springFrictionTab!.removeValue(forKey: SpherePair(s1: mainSphere, s2: sphere))
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
            //interaction between the sphere and walls
            self.listOfWalls.forEach{wall in
                //rotation spheres and calculations
                let Xsphere_translateAndRotate : Double = wall.rotationMatrix[0][0] * (mainSphere.x - wall.Xa) + wall.rotationMatrix[0][1] * (mainSphere.y - wall.Ya) //is the segment's length
                let Ysphere_translateAndRotate : Double = wall.rotationMatrix[1][0] * (mainSphere.x - wall.Xa) + wall.rotationMatrix[1][1] * (mainSphere.y - wall.Ya)
                let distance = abs(Xsphere_translateAndRotate)
                let R: Double = radiusSphere
                if (distance < R && -R <= Ysphere_translateAndRotate && Ysphere_translateAndRotate <= wall.Yb_translateAndRotate + R){
                    // projection in the segment
                    if(0 <= Ysphere_translateAndRotate && Ysphere_translateAndRotate <= wall.Yb_translateAndRotate ){
                        let forcex_beforeTranslate: Double = wall.k * (distance - R) * (Xsphere_translateAndRotate)/distance
                        EnergyAndForceTab[indexMainSphere].forcex -= wall.rotationMatrixInverse[0][0] * forcex_beforeTranslate
                        EnergyAndForceTab[indexMainSphere].forcey -= wall.rotationMatrixInverse[1][0] * forcex_beforeTranslate
                        EnergyAndForceTab[indexMainSphere].Ep += 0.5 * wall.k * (distance - R)*(distance - R)
                    }
                        //touch edge point A
                    else if(-R <= Ysphere_translateAndRotate && Ysphere_translateAndRotate < 0) {
                        //work with real points (not rotate)
                        let distancePointA = sqrt((mainSphere.x-wall.Xa)*(mainSphere.x-wall.Xa) + (mainSphere.y-wall.Ya)*(mainSphere.y-wall.Ya))
                        if (distancePointA < R){
                            EnergyAndForceTab[indexMainSphere].forcex -= wall.k * (distancePointA - R) * (mainSphere.x - wall.Xa)/distancePointA
                            EnergyAndForceTab[indexMainSphere].forcey -= wall.k * (distancePointA - R) * (mainSphere.y - wall.Ya)/distancePointA
                            EnergyAndForceTab[indexMainSphere].Ep += 0.5 * wall.k * pow(distancePointA - R,2)
                        }
                    }
                        //touch edge point B
                    else if (wall.Yb_translateAndRotate < Ysphere_translateAndRotate && Ysphere_translateAndRotate <= wall.Yb_translateAndRotate + R){
                        //work with real points (not rotate)
                        let distancePointB = sqrt((mainSphere.x-wall.Xb)*(mainSphere.x-wall.Xb) + (mainSphere.y-wall.Yb)*(mainSphere.y-wall.Yb))
                        if (distancePointB < R){
                            EnergyAndForceTab[indexMainSphere].forcex -= wall.k * (distancePointB - R) * (mainSphere.x - wall.Xb)/distancePointB
                            EnergyAndForceTab[indexMainSphere].forcey -= wall.k * (distancePointB - R) * (mainSphere.y - wall.Yb)/distancePointB
                            EnergyAndForceTab[indexMainSphere].Ep += 0.5 * wall.k * pow(distancePointB - R,2)
                        }
                    }
                }
            }
            //gravity
            EnergyAndForceTab[indexMainSphere].forcey -= massSphere * 9.81
            EnergyAndForceTab[indexMainSphere].Ep +=  massSphere * 9.81 * (mainSphere.y - (SimulationView.generalMinY ?? 0))
        }
        //update for the sphere
        for (index,sphere) in listOfSpheres.enumerated(){
            sphere.EnergyAndForce = EnergyAndForceTab[index]
        }
    }

    
    //-----------------------------------------------------------------------------
    //------total energy potential--------------------
    //-----------------------------------------------------------------------------
    func totalPotentialEnergy() -> Double{
        var totalPotentialEnergy : Double = 0
        self.listOfSpheres.forEach{ sphere in
            totalPotentialEnergy += sphere.EnergyAndForce.Ep
        }
        return totalPotentialEnergy
    }
    
    //-----------------------------------------------------------------------------
    //------total kinetic potential--------------------
    //-----------------------------------------------------------------------------
    func totalKineticEnergy() -> Double{
        var totalKineticEnergy : Double = 0
        self.listOfSpheres.forEach{ sphere in
            totalKineticEnergy +=  0.5 * massSphere * (sphere.Vx*sphere.Vx + sphere.Vy*sphere.Vy)
        }
        return totalKineticEnergy
    }
 
    
    //-----------------------------------------------------------------------------
    //------divers--------------------
    //-----------------------------------------------------------------------------
    
    //describing
    func describing()-> String{
        var tot: Double = 0
        self.listOfSpheres.forEach{sphere in
            tot += abs(sphere.Vx) + abs(sphere.Vy)
        }
        return " simulation : deltaT = \(self.deltaT)  number Of Steps = \(self.nbOfSteps)  numberOfSpheres = \(self.listOfSpheres.count)  sumVelocity = \(tot) Potenergy = \(self.totalPotentialEnergy()) Kinenergy = \(self.totalKineticEnergy())"
    }
    
}
