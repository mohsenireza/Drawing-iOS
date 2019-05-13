import CoreGraphics
import Metron

/*: Corner
 # Corner
 Represents a location where two edges meet.
 */

let corner = Corner(x: .minXEdge, y: .minYEdge)

corner.edges
corner.xEdge
corner.yEdge
corner.edge(on: .xAxis)
corner.edge(on: .yAxis)

corner.opposite
corner.opposite(on: .xAxis)
corner.opposite(on: .yAxis)

//: ---

//: [BACK: Polygon](@previous)     |     [NEXT: Angle](@next)
