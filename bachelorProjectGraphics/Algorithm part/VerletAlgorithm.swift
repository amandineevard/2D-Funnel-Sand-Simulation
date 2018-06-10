//
//  VerletAlgorithm.swift
//  bachelorProjectGraphics
//
//  Created by Amandine Evard on 03.03.18.
//  Copyright © 2018 Amandine Evard. All rights reserved.
//

import Foundation

//VerletAlgorithm:
func VerletAlgorithm(simulation : Simulation) -> Double{
    var displacementMax: Double = 0
    // calulate new position
    simulation.listOfSpheres.forEach{sphere in
        let dx: Double = sphere.Vx * simulation.deltaT + 0.5 * sphere.EnergyAndForce.forcex / simulation.massSphere * pow(simulation.deltaT,2)
        let dy: Double = sphere.Vy * simulation.deltaT + 0.5 * sphere.EnergyAndForce.forcey / simulation.massSphere * pow(simulation.deltaT,2)
        sphere.x = sphere.x + dx
        sphere.y = sphere.y + dy
        let displacement = sqrt(pow(dx,2) + pow(dy,2))
        if (displacement > displacementMax){
            displacementMax = displacement
        }
    }
    simulation.listOfSpheres.forEach{sphere in
        sphere.Vx = sphere.Vx + 0.5 * (sphere.EnergyAndForce.forcex)/simulation.massSphere * simulation.deltaT
        sphere.Vy = sphere.Vy + 0.5 * (sphere.EnergyAndForce.forcey)/simulation.massSphere * simulation.deltaT
    }
    simulation.updateEnergyAndForcesForListOfSpheres()
    simulation.listOfSpheres.forEach{sphere in
        sphere.Vx += 0.5 * (sphere.EnergyAndForce.forcex)/simulation.massSphere * simulation.deltaT
        sphere.Vy += 0.5 * (sphere.EnergyAndForce.forcey)/simulation.massSphere * simulation.deltaT
    }
    return displacementMax
}


// gridNeedReload:
var displacementTotal : Double = 0
func gridNeedReload(displacementMaxOneIteration: Double, simulation : Simulation) -> Bool{
    displacementTotal += displacementMaxOneIteration
    if (displacementTotal >= 0.1*simulation.radiusSphere*2){
        displacementTotal = 0
        return true
    }else{
        return false
    }
}

//extension
func round(_ num: Double, to places: Int) -> Double {
    let p = log10(abs(num))
    let f = pow(10, p.rounded() - Double(places) + 1)
    let rnum = (num / f).rounded() * f
    
    return rnum
}



