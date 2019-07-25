//
//  ViewController.swift
//  Drawing
//
//  Created by Reza Mohseni on 5/13/19.
//  Copyright © 2019 rezamohseni. All rights reserved.
//
//Drawing Gesture2
import UIKit
import Metron

class GestureTest: UIViewController, UIGestureRecognizerDelegate {
    var touchStartPoint : CGPoint?
    var touchCurrentPoint : CGPoint?
    var newLine : HLine? = nil
    var touchStatus : TouchStatus?
    var graph : Graph = Graph()
    var touchedPoint : HPoint?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var drawingArea: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let Configuration = (
        linePointsRadius : CGFloat(5),
        linePointsGrabDistanceTrashold : Float(20),
        linePointsAttachDistanceTrashold : Float(25),
        minimumDragDistanceToDrawLine : Float(10),
        drawingAreaHeight: CGFloat(3000),
        drawingAreaWidth: CGFloat(3000)
    )
    
    enum TouchStatus {
        case drawLine
        case dragLine
        case continuousDrawLine
    }
    
    class HPoint {
        var circle : Circle!
        var circleShape : CAShapeLayer!
        var lines : [HLine] = Array()
        
        init() {
            self.circleShape = CAShapeLayer()
            //circleShape.path = circle.path
        }
        
        func setCircle(circle : Circle){
            self.circle = circle
            circleShape.path = circle.path
            for line in self.lines{
                line.updateLineSegmentByPoints()
            }
        }
    }
    
    class HLine {
        var lineSegment : LineSegment
        var lineSegmentShape : CAShapeLayer
        var startPoint : HPoint?
        var endPoint : HPoint?
        
        init() {
            self.lineSegment = LineSegment(a: .zero, b: .zero)
            self.lineSegmentShape = CAShapeLayer()
        }
        
        func setLineSegment(lineSegment : LineSegment){
            self.lineSegment = lineSegment
            self.lineSegmentShape.path = lineSegment.path
        }
        
        func updateLineSegmentByPoints(){
            if let startPoint = startPoint {
                if let endPoint = endPoint{
                    self.lineSegment.a = startPoint.circle.center
                    self.lineSegment.b = endPoint.circle.center
                    self.lineSegmentShape.path = self.lineSegment.path
                }
            }
        }
        
        func setStartPoint(startPoint : HPoint){
            self.startPoint = startPoint
            self.updateLineSegmentByPoints()
        }
        
        func setEndPoint(endPoint : HPoint){
            self.endPoint = endPoint
            self.updateLineSegmentByPoints()
        }
    }
    
    class Graph {
        var points : [HPoint] = Array()
        var lines : [HLine] = Array()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollViewAndDrawingArea()
        updateTouchStatus()
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan))
        panGestureRecognizer.delegate = self
        //panGestureRecognizer.cancelsTouchesInView = true
        self.drawingArea.addGestureRecognizer(panGestureRecognizer)
        self.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            //print("Began")
            touchStartPoint = sender.location(in: drawingArea)
            let (nearestPoint,_) = snapToNearestPoint(currentPoint: touchStartPoint!)
            print(nearestPoint)
            if nearestPoint != nil {
                touchStartPoint = nearestPoint?.circle.center
            }
            for point in graph.points.reversed() {
                if point.circle.contains(touchStartPoint!) {
                    touchedPoint = point
                    touchStatus = TouchStatus.dragLine
                    break
                }
            }
        }
        else if sender.state == .changed {
            //print("Changed")
            touchCurrentPoint = sender.location(in: drawingArea)
            
            if touchStatus == TouchStatus.dragLine {
                let newCircle = Circle(center: CGPoint(x: touchCurrentPoint!.x, y: touchCurrentPoint!.y), radius: Configuration.linePointsRadius)
                touchedPoint?.setCircle(circle: newCircle)
                let (nearestPoint,_) = snapToNearestPoint(currentPoint: touchedPoint!)
                if nearestPoint != nil {
                    touchedPoint?.setCircle(circle: nearestPoint!.circle)
                }
            }
            else if touchStatus == TouchStatus.drawLine {
                //if newLine != nil || twoPointsDistance(firstPoint: touchStartPoint!, secondPoint: touchCurrentPoint!) > Configuration.minimumDragDistanceToDrawLine {
                touchCurrentPoint = sender.location(in: drawingArea)
                if(newLine == nil){
                    // add line
                    newLine = HLine()
                    newLine?.lineSegmentShape.strokeColor = UIColor.black.cgColor
                    newLine?.lineSegmentShape.lineWidth = 4
                    graph.lines.append(newLine!)
                    drawingArea.layer.addSublayer(newLine!.lineSegmentShape)
                    // add start point
                    let startPoint = HPoint()
                    let startPointCircle = Circle(center: CGPoint(x: touchStartPoint!.x, y: touchStartPoint!.y), radius: Configuration.linePointsRadius)
                    startPoint.setCircle(circle: startPointCircle)
                    graph.points.append(startPoint)
                    newLine?.setStartPoint(startPoint: startPoint)
                    startPoint.lines.append(newLine!)
                    drawingArea.layer.addSublayer(newLine!.startPoint!.circleShape)
                    // add end point
                    let endPoint = HPoint()
                    let endPointCircle = Circle(center: CGPoint(x: touchCurrentPoint!.x, y: touchCurrentPoint!.y), radius: Configuration.linePointsRadius)
                    endPoint.setCircle(circle: endPointCircle)
                    graph.points.append(endPoint)
                    newLine?.setEndPoint(endPoint: endPoint)
                    endPoint.lines.append(newLine!)
                    drawingArea.layer.addSublayer(newLine!.endPoint!.circleShape)
                }
                let endPointCircle = Circle(center: CGPoint(x: touchCurrentPoint!.x, y: touchCurrentPoint!.y), radius: Configuration.linePointsRadius)
                newLine?.endPoint!.setCircle(circle: endPointCircle)
                let (nearestPoint,_) = snapToNearestPoint(currentPoint: (newLine!.endPoint!))
                if nearestPoint != nil {
                    newLine?.endPoint!.setCircle(circle: nearestPoint!.circle)
                }
                //}
            }
            else if touchStatus == TouchStatus.continuousDrawLine {
                //if newLine != nil || twoPointsDistance(firstPoint: touchStartPoint!, secondPoint: touchCurrentPoint!) > Configuration.minimumDragDistanceToDrawLine {
                if newLine == nil {
                    // add line
                    newLine = HLine()
                    newLine?.lineSegmentShape.strokeColor = UIColor.black.cgColor
                    newLine?.lineSegmentShape.lineWidth = 4
                    graph.lines.append(newLine!)
                    drawingArea.layer.addSublayer(newLine!.lineSegmentShape)
                    // add start point
                    let startPoint : HPoint
                    if graph.points.count == 0 {
                        startPoint = HPoint()
                        let startPointCircle = Circle(center: CGPoint(x: touchStartPoint!.x, y: touchStartPoint!.y), radius: Configuration.linePointsRadius)
                        startPoint.setCircle(circle: startPointCircle)
                        graph.points.append(startPoint)
                        newLine?.setStartPoint(startPoint: startPoint)
                        startPoint.lines.append(newLine!)
                        drawingArea.layer.addSublayer(newLine!.startPoint!.circleShape)
                    }
                    else {
                        startPoint = graph.lines[graph.lines.count - 2].endPoint!
                        newLine?.setStartPoint(startPoint: startPoint)
                        startPoint.lines.append(newLine!)
                    }
                    // add end point
                    let endPoint = HPoint()
                    let endPointCircle = Circle(center: CGPoint(x: touchCurrentPoint!.x, y: touchCurrentPoint!.y), radius: Configuration.linePointsRadius)
                    endPoint.setCircle(circle: endPointCircle)
                    graph.points.append(endPoint)
                    newLine?.setEndPoint(endPoint: endPoint)
                    endPoint.lines.append(newLine!)
                    drawingArea.layer.addSublayer(newLine!.endPoint!.circleShape)
                }
                let endPointCircle = Circle(center: CGPoint(x: touchCurrentPoint!.x, y: touchCurrentPoint!.y), radius: Configuration.linePointsRadius)
                newLine?.endPoint!.setCircle(circle: endPointCircle)
                let (nearestPoint,_) = snapToNearestPoint(currentPoint: (newLine!.endPoint!))
                if nearestPoint != nil {
                    newLine?.endPoint!.setCircle(circle: nearestPoint!.circle)
                }
                //}
            }
        }
        else if sender.state == .ended {
            //print("Ended")
            if touchStatus == TouchStatus.dragLine {
                let pointsThatCanBeReplacedWithTouchedPoint = graph.points.filter { (point) -> Bool in
                    var canBeAdded = true
                    if point === touchedPoint{
                        canBeAdded = false
                    }
                    for line in touchedPoint!.lines {
                        if line.startPoint === point {
                            canBeAdded = false
                        }
                        if line.endPoint === point {
                            canBeAdded = false
                        }
                    }
                    return canBeAdded
                }
                for point in pointsThatCanBeReplacedWithTouchedPoint.reversed() {
                    if point.circle.center == touchedPoint?.circle.center {
                        for line in touchedPoint!.lines{
                            // TODO: implement setLine method
                            point.lines.append(line)
                            if line.startPoint === touchedPoint{
                                line.setStartPoint(startPoint: point)
                            }
                            else if line.endPoint === touchedPoint{
                                line.setEndPoint(endPoint: point)
                            }
                        }
                        //touchedPoint?.setCircle(circle: Circle(center: .zero, diameter: 0))
                        touchedPoint?.circleShape.removeFromSuperlayer()
                        graph.points.removeAll { $0 === touchedPoint }
                        break
                    }
                }
                touchedPoint = nil
                updateTouchStatus()
            }
            else if touchStatus == TouchStatus.drawLine || touchStatus == TouchStatus.continuousDrawLine {
                let pointsThatCanBeReplacedWithTouchedPoint = graph.points.filter { (point) -> Bool in
                    return point !== newLine?.startPoint && point !== newLine?.endPoint
                }
                for point in pointsThatCanBeReplacedWithTouchedPoint.reversed() {
                    if point.circle.center == newLine?.endPoint?.circle.center {
                        //newLine?.endPoint!.setCircle(circle: Circle(center: .zero, diameter: 0))
                        newLine?.endPoint!.circleShape.removeFromSuperlayer()
                        graph.points.removeAll { $0 === newLine?.endPoint }
                        // TODO: implement setLine method
                        point.lines.append(newLine!)
                        newLine?.setEndPoint(endPoint: point)
                        break
                    }
                }
                newLine = nil
            }
        }
    }
    
    func setupScrollViewAndDrawingArea(){
        scrollView.delegate = self
        scrollView.contentSize.height = Configuration.drawingAreaHeight
        scrollView.contentSize.width = Configuration.drawingAreaWidth
        scrollView.contentOffset.x = (scrollView.contentSize.width/2) - (scrollView.bounds.size.width/2);
        scrollView.contentOffset.y = (scrollView.contentSize.height/2) - (scrollView.bounds.size.height/2);
        (drawingArea.constraints.filter{$0.firstAttribute == .height}.first)?.constant = Configuration.drawingAreaHeight
        (drawingArea.constraints.filter{$0.firstAttribute == .width}.first)?.constant = Configuration.drawingAreaWidth
    }
    
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        //touchStatus = .drawLine
    //        let touch = touches.first
    //        touchStartPoint = touch!.location(in: drawingArea)
    //        let (nearestPoint,_) = snapToNearestPoint(currentPoint: touchStartPoint!)
    //        if nearestPoint != nil {
    //            touchStartPoint = nearestPoint?.circle.center
    //        }
    //        for point in graph.points.reversed() {
    //            if point.circle.contains(touchStartPoint!) {
    //                touchedPoint = point
    //                touchStatus = TouchStatus.dragLine
    //                break
    //            }
    //        }
    //    }
    
    func updateTouchStatus() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            touchStatus = .drawLine
            //scrollView.isScrollEnabled = false
        //scrollView.isUserInteractionEnabled = false
        case 1:
            touchStatus = .continuousDrawLine
            //scrollView.isScrollEnabled = false
        //scrollView.isUserInteractionEnabled = false
        case 2:
            touchStatus = nil
            scrollView.isScrollEnabled = true
        //scrollView.isUserInteractionEnabled = true
        default:
            break
        }
    }
    
    func twoPointsDistance(firstPoint : CGPoint, secondPoint : CGPoint) -> Float{
        let deltaX = secondPoint.x - firstPoint.x
        let deltaY = secondPoint.y - firstPoint.y
        return Float(sqrt(pow(deltaX, 2) + pow(deltaY, 2)))
    }
    
    func snapToNearestPoint(currentPoint : HPoint) -> (HPoint? , Float?){
        var nearestPointDistance : Float
        var nearestPoint : HPoint
        let points : [HPoint] = graph.points.filter { (point) -> Bool in
            var canBeAdded = true
            for line in currentPoint.lines {
                if line.startPoint === point || line.endPoint === point{
                    canBeAdded = false
                    break
                }
            }
            return canBeAdded
        }
        if points.count == 0 {
            return(nil, nil)
        }
        nearestPoint = points[0]
        nearestPointDistance = twoPointsDistance(firstPoint: currentPoint.circle.center, secondPoint: points[0].circle.center)
        for i in 1..<points.count{
            let pointsDistance = twoPointsDistance(firstPoint: currentPoint.circle.center, secondPoint: points[i].circle.center)
            if pointsDistance < nearestPointDistance {
                nearestPoint = points[i]
                nearestPointDistance = pointsDistance
            }
        }
        if nearestPointDistance < Configuration.linePointsAttachDistanceTrashold{
            return (nearestPoint, nearestPointDistance)
        }
        return (nil, nil)
    }
    
    func snapToNearestPoint(currentPoint : CGPoint) -> (HPoint? , Float?){
        var nearestPointDistance : Float
        var nearestPoint : HPoint
        let points : [HPoint] = graph.points
        if points.count == 0 {
            return(nil, nil)
        }
        nearestPoint = points[0]
        nearestPointDistance = twoPointsDistance(firstPoint: currentPoint, secondPoint: points[0].circle.center)
        for i in 1..<points.count{
            let pointsDistance = twoPointsDistance(firstPoint: currentPoint, secondPoint: points[i].circle.center)
            if pointsDistance < nearestPointDistance {
                nearestPoint = points[i]
                nearestPointDistance = pointsDistance
            }
        }
        if nearestPointDistance < Configuration.linePointsAttachDistanceTrashold{
            return (nearestPoint, nearestPointDistance)
        }
        return (nil, nil)
    }
    
    //    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        let touch = touches.first!
    //        touchCurrentPoint = touch.location(in: drawingArea)
    //
    //        if touchStatus == TouchStatus.dragLine {
    //            let newCircle = Circle(center: CGPoint(x: touchCurrentPoint!.x, y: touchCurrentPoint!.y), radius: Configuration.linePointsRadius)
    //            touchedPoint?.setCircle(circle: newCircle)
    //            let (nearestPoint,_) = snapToNearestPoint(currentPoint: touchedPoint!)
    //            if nearestPoint != nil {
    //                touchedPoint?.setCircle(circle: nearestPoint!.circle)
    //            }
    //        }
    //        else if touchStatus == TouchStatus.drawLine {
    //            if newLine != nil || twoPointsDistance(firstPoint: touchStartPoint!, secondPoint: touchCurrentPoint!) > Configuration.minimumDragDistanceToDrawLine {
    //                let touch = touches.first
    //                touchCurrentPoint = touch!.location(in: drawingArea)
    //                if(newLine == nil){
    //                    // add line
    //                    newLine = HLine()
    //                    newLine?.lineSegmentShape.strokeColor = UIColor.black.cgColor
    //                    newLine?.lineSegmentShape.lineWidth = 4
    //                    graph.lines.append(newLine!)
    //                    drawingArea.layer.addSublayer(newLine!.lineSegmentShape)
    //                    // add start point
    //                    let startPoint = HPoint()
    //                    let startPointCircle = Circle(center: CGPoint(x: touchStartPoint!.x, y: touchStartPoint!.y), radius: Configuration.linePointsRadius)
    //                    startPoint.setCircle(circle: startPointCircle)
    //                    graph.points.append(startPoint)
    //                    newLine?.setStartPoint(startPoint: startPoint)
    //                    startPoint.lines.append(newLine!)
    //                    drawingArea.layer.addSublayer(newLine!.startPoint!.circleShape)
    //                    // add end point
    //                    let endPoint = HPoint()
    //                    let endPointCircle = Circle(center: CGPoint(x: touchCurrentPoint!.x, y: touchCurrentPoint!.y), radius: Configuration.linePointsRadius)
    //                    endPoint.setCircle(circle: endPointCircle)
    //                    graph.points.append(endPoint)
    //                    newLine?.setEndPoint(endPoint: endPoint)
    //                    endPoint.lines.append(newLine!)
    //                    drawingArea.layer.addSublayer(newLine!.endPoint!.circleShape)
    //                }
    //                let endPointCircle = Circle(center: CGPoint(x: touchCurrentPoint!.x, y: touchCurrentPoint!.y), radius: Configuration.linePointsRadius)
    //                newLine?.endPoint!.setCircle(circle: endPointCircle)
    //                let (nearestPoint,_) = snapToNearestPoint(currentPoint: (newLine!.endPoint!))
    //                if nearestPoint != nil {
    //                    newLine?.endPoint!.setCircle(circle: nearestPoint!.circle)
    //                }
    //            }
    //        }
    //        else if touchStatus == TouchStatus.continuousDrawLine {
    //            if newLine != nil || twoPointsDistance(firstPoint: touchStartPoint!, secondPoint: touchCurrentPoint!) > Configuration.minimumDragDistanceToDrawLine {
    //                if newLine == nil {
    //                    // add line
    //                    newLine = HLine()
    //                    newLine?.lineSegmentShape.strokeColor = UIColor.black.cgColor
    //                    newLine?.lineSegmentShape.lineWidth = 4
    //                    graph.lines.append(newLine!)
    //                    drawingArea.layer.addSublayer(newLine!.lineSegmentShape)
    //                    // add start point
    //                    let startPoint : HPoint
    //                    if graph.points.count == 0 {
    //                        startPoint = HPoint()
    //                        let startPointCircle = Circle(center: CGPoint(x: touchStartPoint!.x, y: touchStartPoint!.y), radius: Configuration.linePointsRadius)
    //                        startPoint.setCircle(circle: startPointCircle)
    //                        graph.points.append(startPoint)
    //                        newLine?.setStartPoint(startPoint: startPoint)
    //                        startPoint.lines.append(newLine!)
    //                        drawingArea.layer.addSublayer(newLine!.startPoint!.circleShape)
    //                    }
    //                    else {
    //                        startPoint = graph.lines[graph.lines.count - 2].endPoint!
    //                        newLine?.setStartPoint(startPoint: startPoint)
    //                        startPoint.lines.append(newLine!)
    //                    }
    //                    // add end point
    //                    let endPoint = HPoint()
    //                    let endPointCircle = Circle(center: CGPoint(x: touchCurrentPoint!.x, y: touchCurrentPoint!.y), radius: Configuration.linePointsRadius)
    //                    endPoint.setCircle(circle: endPointCircle)
    //                    graph.points.append(endPoint)
    //                    newLine?.setEndPoint(endPoint: endPoint)
    //                    endPoint.lines.append(newLine!)
    //                    drawingArea.layer.addSublayer(newLine!.endPoint!.circleShape)
    //                }
    //                let endPointCircle = Circle(center: CGPoint(x: touchCurrentPoint!.x, y: touchCurrentPoint!.y), radius: Configuration.linePointsRadius)
    //                newLine?.endPoint!.setCircle(circle: endPointCircle)
    //                let (nearestPoint,_) = snapToNearestPoint(currentPoint: (newLine!.endPoint!))
    //                if nearestPoint != nil {
    //                    newLine?.endPoint!.setCircle(circle: nearestPoint!.circle)
    //                }
    //            }
    //        }
    //    }
    
    //    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        if touchStatus == TouchStatus.dragLine {
    //            let pointsThatCanBeReplacedWithTouchedPoint = graph.points.filter { (point) -> Bool in
    //                var canBeAdded = true
    //                if point === touchedPoint{
    //                    canBeAdded = false
    //                }
    //                for line in touchedPoint!.lines {
    //                    if line.startPoint === point {
    //                        canBeAdded = false
    //                    }
    //                    if line.endPoint === point {
    //                        canBeAdded = false
    //                    }
    //                }
    //                return canBeAdded
    //            }
    //            for point in pointsThatCanBeReplacedWithTouchedPoint.reversed() {
    //                if point.circle.center == touchedPoint?.circle.center {
    //                    for line in touchedPoint!.lines{
    //                        // TODO: implement setLine method
    //                        point.lines.append(line)
    //                        if line.startPoint === touchedPoint{
    //                            line.setStartPoint(startPoint: point)
    //                        }
    //                        else if line.endPoint === touchedPoint{
    //                            line.setEndPoint(endPoint: point)
    //                        }
    //                    }
    //                    //touchedPoint?.setCircle(circle: Circle(center: .zero, diameter: 0))
    //                    touchedPoint?.circleShape.removeFromSuperlayer()
    //                    graph.points.removeAll { $0 === touchedPoint }
    //                    break
    //                }
    //            }
    //            touchedPoint = nil
    //            updateTouchStatus()
    //        }
    //        else if touchStatus == TouchStatus.drawLine || touchStatus == TouchStatus.continuousDrawLine {
    //            let pointsThatCanBeReplacedWithTouchedPoint = graph.points.filter { (point) -> Bool in
    //                return point !== newLine?.startPoint && point !== newLine?.endPoint
    //            }
    //            for point in pointsThatCanBeReplacedWithTouchedPoint.reversed() {
    //                if point.circle.center == newLine?.endPoint?.circle.center {
    //                    //newLine?.endPoint!.setCircle(circle: Circle(center: .zero, diameter: 0))
    //                    newLine?.endPoint!.circleShape.removeFromSuperlayer()
    //                    graph.points.removeAll { $0 === newLine?.endPoint }
    //                    // TODO: implement setLine method
    //                    point.lines.append(newLine!)
    //                    newLine?.setEndPoint(endPoint: point)
    //                    break
    //                }
    //            }
    //            newLine = nil
    //        }
    //    }
    
    @IBAction func changeTouchType(_ sender: Any) {
        updateTouchStatus()
    }
}

extension ViewController : UIScrollViewDelegate {
    // zoom drawing area
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return drawingArea
    }
}
