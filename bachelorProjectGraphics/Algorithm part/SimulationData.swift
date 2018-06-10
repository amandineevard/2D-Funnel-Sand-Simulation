//
//  SavingInfos.swift
//  bachelorProjectGraphics
//
//  Created by Amandine Evard on 02.05.18.
//  Copyright © 2018 Amandine Evard. All rights reserved.
//

import Foundation

struct Result: Codable{
    var positionsResultsTab : [Double:[[Double]]]
    var energyResultsTab : [Double:[Double]]
    var flowRateTab : [Double:Double]
}

class SimulationData: Codable {
    //before simulation
    var deltaT : Double
    var nbOfSteps : Int
    var nbIterationsInitialRepartition: Int
    var springConstantSphere : Double
    var springConstantWall : Double
    var massSphere : Double
    var radiusSphere : Double
    var funnelBottleneck : Double
    var inclinaisonDegreFunnel : Double
    var funnelBase : Double
    let funnelBottleneckLength : Double
    let funnelBaseHeigth : Double
    let muStatic: Double?
    let dissipationFactor: Double?
    //after simulation
    var results : Result?
    
    init(deltaT: Double, nbOfSteps: Int, results : Result?, springConstantSphere : Double,
         springConstantWall : Double, massSphere : Double, radiusSphere : Double, funnelDiameter : Double,inclinaisonDegreFunnel : Double,funnelBigDiameter : Double, funnelSmallHeigth : Double, funnelBigHeigth : Double, nbIterationsInitialRepartition: Int, muStatic: Double?, dissipationFactor: Double?) {
        self.deltaT = deltaT
        self.nbOfSteps = nbOfSteps
        self.springConstantSphere = springConstantSphere
        self.springConstantWall = springConstantWall
        self.massSphere = massSphere
        self.radiusSphere = radiusSphere
        self.funnelBottleneck = funnelDiameter
        self.inclinaisonDegreFunnel = inclinaisonDegreFunnel
        self.funnelBase = funnelBigDiameter
        self.funnelBottleneckLength = funnelSmallHeigth
        self.funnelBaseHeigth = funnelBigHeigth
        self.nbIterationsInitialRepartition = nbIterationsInitialRepartition
        self.results = results
        self.muStatic = muStatic
        self.dissipationFactor = dissipationFactor
    }
}



