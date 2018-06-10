//
//  Wall.swift
//  bachelorProjectGraphics
//
//  Created by Amandine Evard on 04.03.18.
//  Copyright © 2018 Amandine Evard. All rights reserved.
//

import Foundation
public struct Equation {
    var a: Double
    var b: Double
    var c: Double
    
    func describing()-> String{
        return " \(a) x + \(b) y + \(c)"
    }
}

class Wall{
    var Xa : Double
    var Ya: Double
    var Xb : Double
    var Yb: Double
    var k: Double
    lazy var vectorX : Double = {
        [unowned self] in return (Xa-Xb)
    }()
    lazy var vectorY : Double = {
        [unowned self] in return (Ya-Yb)
    }()
    lazy var equation : Equation = {
        [unowned self] in return Equation(a:vectorY, b: -vectorX, c: -vectorY*Xa + vectorX*Ya)
    }()
    //parameters for rotation walls:
    lazy var row : Double = {
        [unowned self] in return 1/sqrt(pow(Xb-Xa,2) + pow(Yb-Ya,2))
        }() //combinaison d'une computed proprieties avec lazy war, ne le recalcul par à chaque fois
    lazy var length : Double = {
        [unowned self] in return sqrt(pow(Xb-Xa,2) + pow(Yb-Ya,2))
        }()
    lazy var rotationMatrix : [[Double]] = {
        [unowned self] in return [[row * (Yb - Ya), row * (-Xb + Xa)],[row * (Xb - Xa), row * (Yb - Ya)]]}()
    lazy var Yb_translateAndRotate : Double = {
        [unowned self] in return rotationMatrix[1][0] * (Xb - Xa) + rotationMatrix[1][1] * (Yb - Ya)}()
    lazy var rotationMatrixInverse : [[Double]] = {
        return [[row * (Yb - Ya), row * (Xb - Xa)],[-row * (Xb - Xa), row * (Yb - Ya)]]}()
    
    init(Xa : Double, Ya: Double, Xb : Double,Yb : Double, k:Double) {
        self.Xa = Xa
        self.Ya = Ya
        self.Xb = Xb
        self.Yb = Yb
        self.k = k
    }
}
