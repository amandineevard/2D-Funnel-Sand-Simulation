//
//  Grid.swift
//  bachelorProjectGraphics
//
//  Created by Amandine Evard on 24.04.18.
//  Copyright © 2018 Amandine Evard. All rights reserved.
//

import Foundation

class Grid {
    var gridMain: [[[Int]]]
    var gridWalls: [[[Int]]]
    var nbColumn: Int
    var nbRow: Int
    var sizeCell: Double
    var height: Double
    var length: Double
    var minX: Double
    var maxX: Double
    var minY: Double
    var maxY: Double
    var lengthWallgrid: [Double]
    
    init?(listOfSphere: [Sphere], radius: Double, listOfWalls: [Wall] ){
        guard let minXunwrap = (listOfWalls.map{wall in return min(wall.Xa, wall.Xb)}).min() else {return nil}
        guard let maxXunwrap = (listOfWalls.map{wall in return max(wall.Xa, wall.Xb)}).max() else {return nil }
        guard let minYunwrap = (listOfWalls.map{wall in return min(wall.Ya, wall.Yb)}).min() else {return nil}
        guard let maxYunwrap = (listOfWalls.map{wall in return max(wall.Ya, wall.Yb)}).max() else {return nil }
        self.minX = minXunwrap
        self.maxX = maxXunwrap
        self.minY = minYunwrap
        self.maxY = maxYunwrap
        //main grid:
        self.length = (maxX - minX)
        self.nbColumn = Int(floor(length/(1.1*radius*2)))
        self.sizeCell = length/Double(nbColumn)
        self.nbRow = Int(ceil((maxY-minY)/(length/Double(nbColumn))))
        self.height = Double(nbRow)*sizeCell
        self.gridMain = [[[Int]]](repeating: [[Int]](repeating: [], count: nbColumn), count: nbRow)
        
        //walls grid:
        self.gridWalls = []
        self.lengthWallgrid = []
        for (_,wall) in listOfWalls.enumerated(){
            let totalLengthWall: Double = wall.length + 2*radius
            let nbCell: Int = Int(ceil(totalLengthWall/sizeCell))
            self.lengthWallgrid.append(Double(nbCell)*sizeCell)
            self.gridWalls.append([[Int]](repeating: [], count: nbCell))
        }
        updateSpheresInGrid(listOfSphere: listOfSphere)
    }

    func updateSpheresInGrid(listOfSphere: [Sphere]){
        gridMain = [[[Int]]](repeating: [[Int]](repeating: [], count: nbColumn), count: nbRow)
        guard let minY = SimulationView.generalMinY, let minX = SimulationView.generalMinX, let maxY = SimulationView.generalMaxY, let maxX = SimulationView.generalMaxX else{return}
        for (index,sphere) in listOfSphere.enumerated(){
            let column = Int(floor((sphere.x-minX)/(maxX - minX)*Double(nbColumn)))
            let row = Int(floor((sphere.y-minY)/(maxY-minY)*Double(nbRow)))
            if( row >= 0 && row <= nbRow-1 && column >= 0 && column <= nbColumn-1){
                gridMain[row][column].append(index)
            }
        }
    }
    
    func getColumn(_ sphere: Sphere) -> Int{
        return Int(floor((sphere.x-minX)/(maxX - minX)*Double(nbColumn)))
    }
    func getRow(_ sphere: Sphere) -> Int{
        return Int(floor((sphere.y-minY)/(maxY-minY)*Double(nbRow)))
    }
    func getListOfSpheresInCell(row: Int, column: Int) -> [Int]?{
        if( row >= 0 && row <= nbRow-1 && column >= 0 && column <= nbColumn-1){
            return gridMain[row][column]
        }
        else{
            return nil
        }
    }
}
