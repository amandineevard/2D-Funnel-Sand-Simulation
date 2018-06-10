//
//  FlowRateData.swift
//  bachelorProjectGraphics
//
//  Created by Amandine Evard on 10.05.18.
//  Copyright © 2018 Amandine Evard. All rights reserved.
//

import Foundation
class FlowRateData: Codable{
    let radius: Double
    let bottleneck: Double
    let mass: Double
    let flowrate : [[Double]]
    
    init(radius: Double, bottleneck: Double, mass:Double, flowrateDictionnary: [Double:Double]) {
        self.radius = radius
        self.bottleneck = bottleneck
        self.mass = mass
        let resultsSorted = flowrateDictionnary.sorted(by: { $0.0 < $1.0 })
        var saving: [[Double]] = []
        for (key , value) in resultsSorted {
            saving.append([key,value])
        }
        self.flowrate = saving
    }
}
