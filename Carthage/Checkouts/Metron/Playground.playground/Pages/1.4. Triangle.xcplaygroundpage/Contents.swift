import CoreGraphics
import Metron

/*: Triangle
 # Triangle
 A shape formed by three connected line segments and defined by three vertices.
 */

let a = CGPoint.zero
let b = CGPoint(x: 5.0, y: 0.0)
let c = CGPoint(x: 2.5, y: 5.0)

let triangle1 = Triangle(a: a, b: b, c: c)

// A triplet represents three related values (a, b and c) of a single type:

let triplet = Triplet(a: a, b: b, c: c)
let triangle2 = Triangle(triplet)

// Each vertex corresponds to the point (a, b, c) given on init:

triangle1.vertices
triangle1.vertexA
triangle1.vertexB
triangle1.vertexC

// Side {A} is opposite vertex {A}:

triangle1.sides
triangle1.sideA
triangle1.sideB
triangle1.sideC

let lengths = triangle1.sides.asArray.map { $0.length }
lengths

// Angle {A} is the angle at vertex {A}:

triangle1.angles
triangle1.angleA
triangle1.angleB
triangle1.angleC

// An angle bisector is a line from a vertex to the opposite side, that divides the angle in two with equal measures:

triangle1.angleBisectors
triangle1.angleBisectorA
triangle1.angleBisectorB
triangle1.angleBisectorC

// An altitude of a triangle is a straight line through a vertex perpendicular to the opposite side. `altitude{A}` goes 
// perpendicular from `side{A}` to `vertex{A}`:

triangle1.altitudes
triangle1.altitudeA
triangle1.altitudeB
triangle1.altitudeC

// Classification

triangle1.isEquilateral // True if all sides are equal.
triangle1.isIsosceles   // True iff two sides are equal.
triangle1.isScalene     // True if all sides are different.
triangle1.isRight       // True if one angle is exactly 90°.
triangle1.isOblique     // True of no angle is 90°.
triangle1.isAcute       // True if all angles are less than 90°.
triangle1.isObtuse      // True if one angle is more than 90°.

// Centers

triangle1.centroid
triangle1.circumcenter
triangle1.incenter
triangle1.orthocenter

// `Triangle` type conforms to `PolygonType` protocol, which has the following properties:

triangle1.edgeCount
triangle1.points
triangle1.lineSegments

// `PolygonType` inherits from `Shape` protocol, which has the following properties:

triangle1.area
triangle1.perimeter
triangle1.center // Is the most common: the centroid.

triangle1.minX
triangle1.minY

triangle1.maxX
triangle1.maxY

triangle1.midX
triangle1.midY

triangle1.width
triangle1.height
triangle1.boundingRect

triangle1.contains(CGPoint(x: 2.5, y: 2.5))

//: ---

//: [BACK: Circle](@previous)     |     [NEXT: Square](@next)
