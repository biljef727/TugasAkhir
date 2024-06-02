import SwiftUI
import UIKit
import PDFKit

// MARK: - Extensions for CGRect and CGPoint

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: self.size.width / 2.0, y: self.size.height / 2.0)
    }
}

extension CGPoint {
    func vector(to p1: CGPoint) -> CGVector {
        return CGVector(dx: p1.x - self.x, dy: p1.y - self.y)
    }
}

// MARK: - Extension for UIBezierPath

extension UIBezierPath {
    func moveCenter(to: CGPoint) -> Self {
        let bound = self.cgPath.boundingBox
        let center = bounds.center
        
        let zeroedTo = CGPoint(x: to.x - bound.origin.x, y: to.y - bound.origin.y)
        let vector = center.vector(to: zeroedTo)
        
        offset(to: CGSize(width: vector.dx, height: vector.dy))
        return self
    }
    
    func offset(to offset: CGSize) -> Self {
        let t = CGAffineTransform(translationX: offset.width, y: offset.height)
        applyCentered(transform: t)
        return self
    }
    
    func fit(into: CGRect) -> Self {
        let bounds = self.cgPath.boundingBox
        
        let sw = into.size.width / bounds.width
        let sh = into.size.height / bounds.height
        let factor = min(sw, max(sh, 0.0))
        
        return scale(x: factor, y: factor)
    }
    
    func scale(x: CGFloat, y: CGFloat) -> Self {
        let scale = CGAffineTransform(scaleX: x, y: y)
        applyCentered(transform: scale)
        return self
    }
    
    func applyCentered(transform: @autoclosure () -> CGAffineTransform) -> Self {
        let bound = self.cgPath.boundingBox
        let center = CGPoint(x: bound.midX, y: bound.midY)
        var xform = CGAffineTransform.identity
        
        xform = xform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        xform = xform.concatenating(transform())
        xform = xform.concatenating(CGAffineTransform(translationX: center.x, y: center.y))
        apply(xform)
        
        return self
    }
}

// MARK: - Drawing Gesture Recognizer Delegate Protocol

protocol DrawingGestureRecognizerDelegate: AnyObject {
    func gestureRecognizerBegan(_ location: CGPoint)
    func gestureRecognizerMoved(_ location: CGPoint)
    func gestureRecognizerEnded(_ location: CGPoint)
}

// MARK: - Drawing Gesture Recognizer

class DrawingGestureRecognizer: UIGestureRecognizer {
    weak var drawingDelegate: DrawingGestureRecognizerDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first,
           // touch.type == .pencil, // Uncomment this line to test on device with Apple Pencil
           let numberOfTouches = event?.allTouches?.count,
           numberOfTouches == 1 {
            state = .began
            
            let location = touch.location(in: self.view)
            drawingDelegate?.gestureRecognizerBegan(location)
        } else {
            state = .failed
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .changed
        
        guard let location = touches.first?.location(in: self.view) else { return }
        drawingDelegate?.gestureRecognizerMoved(location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self.view) else {
            state = .ended
            return
        }
        drawingDelegate?.gestureRecognizerEnded(location)
        state = .ended
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .failed
    }
}

// MARK: - Drawing Tool Enum

enum DrawingTool: Int {
    case eraser = 0
    case pen = 1
    
    var width: CGFloat {
        switch self {
        case .pen:
            return 1
        default:
            return 0
        }
    }
}

// MARK: - PDF Drawer

class PDFDrawer: ObservableObject {
    weak var pdfView: PDFView!
    private var path: UIBezierPath?
    private var currentAnnotation: DrawingAnnotation?
    private var currentPage: PDFPage?
    var color = UIColor.black
    @Published var drawingTool = DrawingTool.pen
    
    func setDrawingTool(_ tool: DrawingTool) {
        drawingTool = tool
    }
}

// MARK: - PDFDrawer: DrawingGestureRecognizerDelegate

extension PDFDrawer: DrawingGestureRecognizerDelegate {
    func gestureRecognizerBegan(_ location: CGPoint) {
        guard let page = pdfView.page(for: location, nearest: true) else { return }
        currentPage = page
        let convertedPoint = pdfView.convert(location, to: currentPage!)
//        path = UIBezierPath()
//        path?.move(to: convertedPoint)
        if drawingTool == .eraser { // ini ga dianggep == nya
            removeAnnotationAtPoint(point: convertedPoint, page: page)
            return
        }
        if drawingTool == .pen {
            path = UIBezierPath()
            path?.move(to: convertedPoint)
        }
    }
    
    func gestureRecognizerMoved(_ location: CGPoint) {
        guard let page = currentPage else { return }
        let convertedPoint = pdfView.convert(location, to: page)
        
        print("Touch moved to: \(location) converted to: \(convertedPoint)")
        print(drawingTool)
        
        if drawingTool == .eraser {
            removeAnnotationAtPoint(point: convertedPoint, page: page)
            return
        }
        if drawingTool == .pen {
            path?.addLine(to: convertedPoint)
            path?.move(to: convertedPoint)
            drawAnnotation(onPage: page)
        }
    }
    
    func gestureRecognizerEnded(_ location: CGPoint) {
        guard let page = currentPage else { return }
        let convertedPoint = pdfView.convert(location, to: page)
        
        // Erasing
        if drawingTool == .eraser {
            removeAnnotationAtPoint(point: convertedPoint, page: page)
            return
        }
        
        // Drawing
        if drawingTool == .pen
        {
            guard let _ = currentAnnotation else { return }
            
            path?.addLine(to: convertedPoint)
            path?.move(to: convertedPoint)
            
            // Final annotation
            page.removeAnnotation(currentAnnotation!)
            let finalAnnotation = createFinalAnnotation(path: path!, page: page)
            currentAnnotation = nil
        }
    }
    
    private func createAnnotation(path: UIBezierPath, page: PDFPage) -> DrawingAnnotation {
        let border = PDFBorder()
        border.lineWidth = drawingTool.width
        
        let annotation = DrawingAnnotation(bounds: page.bounds(for: pdfView.displayBox), forType: .ink, withProperties: nil)
        annotation.color = color.withAlphaComponent(1.0) // Adjust alpha as needed
        annotation.border = border
        return annotation
    }
    
    private func drawAnnotation(onPage: PDFPage) {
        guard let path = path else { return }
        
        if currentAnnotation == nil {
            currentAnnotation = createAnnotation(path: path, page: onPage)
        }
        
        currentAnnotation?.path = path
        forceRedraw(annotation: currentAnnotation!, onPage: onPage)
    }
    
    private func createFinalAnnotation(path: UIBezierPath, page: PDFPage) -> PDFAnnotation {
        let border = PDFBorder()
        border.lineWidth = drawingTool.width
        
        let bounds = CGRect(x: path.bounds.origin.x - 5,
                            y: path.bounds.origin.y - 5,
                            width: path.bounds.size.width + 10,
                            height: path.bounds.size.height + 10)
        var signingPathCentered = UIBezierPath()
        signingPathCentered.cgPath = path.cgPath
        signingPathCentered.moveCenter(to: bounds.center)
        
        let annotation = PDFAnnotation(bounds: bounds, forType: .ink, withProperties: nil)
        annotation.color = color.withAlphaComponent(1.0) // Adjust alpha as needed
        annotation.border = border
        annotation.add(signingPathCentered)
        page.addAnnotation(annotation)
        
        return annotation
    }
    
    private func removeAnnotationAtPoint(point: CGPoint, page: PDFPage) {
        if let selectedAnnotation = page.annotationWithHitTest(at: point) {
            print("Removing annotation: \(selectedAnnotation)")
            selectedAnnotation.page?.removeAnnotation(selectedAnnotation)
        } else {
            print("No annotation found at point: \(point)")
        }
    }
    
    private func forceRedraw(annotation: PDFAnnotation, onPage: PDFPage) {
        onPage.removeAnnotation(annotation)
        onPage.addAnnotation(annotation)
    }
}

// MARK: - Drawing Annotation

class DrawingAnnotation: PDFAnnotation {
    public var path = UIBezierPath()
    
    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        let pathCopy = path.copy() as! UIBezierPath
        UIGraphicsPushContext(context)
        context.saveGState()
        
        context.setShouldAntialias(true)
        
        color.set()
        pathCopy.lineJoinStyle = .round
        pathCopy.lineCapStyle = .round
        pathCopy.lineWidth = border?.lineWidth ?? 1.0
        pathCopy.stroke()
        
        context.restoreGState()
        UIGraphicsPopContext()
    }
}

// MARK: - NonSelectablePDFView

class NonSelectablePDFView: PDFView {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer is UILongPressGestureRecognizer {
            gestureRecognizer.isEnabled = false
        }
        
        super.addGestureRecognizer(gestureRecognizer)
    }
}

// MARK: - PDFAnnotation Extension

extension PDFAnnotation {
    func contains(point: CGPoint) -> Bool {
        var hitPath: CGPath?
        
        if let path = paths?.first {
            hitPath = path.cgPath.copy(strokingWithWidth: 10.0, lineCap: .round, lineJoin: .round, miterLimit: 0)
        }
        
        let contains = hitPath?.contains(point) ?? false
        print("Checking point \(point): \(contains ? "Inside" : "Outside") annotation \(self)")
        return contains
    }
}

// MARK: - PDFPage Extension

extension PDFPage {
    func annotationWithHitTest(at: CGPoint) -> PDFAnnotation? {
        for annotation in annotations {
            if annotation.contains(point: at) {
                return annotation
            }
        }
        return nil
    }
}

