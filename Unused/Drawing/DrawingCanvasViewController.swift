////
////  DrawingCanvasViewController.swift
////  MC3_Mathopia
////
////  Created by Manuel Johan Tito on 17/08/23.
////
//
//import SwiftUI
//import PencilKit
//
//protocol MyViewControllerDelegate: AnyObject {
//    func didUpdateState(newValue: Data)
//}
//
//class DrawingCanvasViewController: UIViewController {
//    
//    static var shared = DrawingCanvasViewController()
//    
//    lazy var canvas: PKCanvasView = {
//        let view = PKCanvasView()
//        view.backgroundColor = .clear
//        view.drawingPolicy = .anyInput
//        view.minimumZoomScale = 1
//        view.maximumZoomScale = 1
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    lazy var toolPicker: PKToolPicker = {
//        let toolPicker = PKToolPicker()
//        toolPicker.addObserver(self)
//        return toolPicker
//    }()
//    
//    var drawingData = Data()
//    var drawingChanged: (Data) -> Void = {_ in}
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.addSubview(canvas)
//        NSLayoutConstraint.activate([
//            canvas.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            canvas.topAnchor.constraint(equalTo: view.topAnchor),
//            canvas.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
//        toolPicker.setVisible(true, forFirstResponder: canvas)
//        toolPicker.addObserver(canvas)
//        canvas.delegate = self
//        canvas.becomeFirstResponder()
//        if let drawing = try? PKDrawing(data: drawingData){
//            canvas.drawing = drawing
//        }
//    }
//    func preprocessImage(completion:(String)->()) {
//        var image = canvas.drawing.image(from: canvas.drawing.bounds, scale: 10.0)
//        if let newImage = UIImage(color: .black, size: CGSize(width: view.frame.width, height: view.frame.height)){
//            if let overlayedImage = newImage.image(byDrawingImage: image, inRect: CGRect(x: view.center.x, y: view.center.y, width: view.frame.width, height: view.frame.height)) {
//                image = overlayedImage
//                
//            }
//        }
//    }
//    
//    func clearCanvas() {
//            canvas.drawing = PKDrawing()
//        }
//    
//    weak var delegate: MyViewControllerDelegate?
//        
//    func updateMyVariable(newValue: Data, currentPage: Binding<Int>, previousPage: Binding<Int>) {
//            // Perform any necessary logic when myVariable changes
//         //   print("data update di UIKIT")
//        //if(previousPage.wrappedValue != currentPage.wrappedValue){
//           // previousPage = currentPage.wrappedValue
//            canvas = PKCanvasView()
//            canvas.backgroundColor = .clear
//            canvas.drawingPolicy = .anyInput
//            canvas.minimumZoomScale = 1
//            canvas.maximumZoomScale = 1
//            canvas.translatesAutoresizingMaskIntoConstraints = false
//            drawingData = newValue
//        
//        //canvas.delegate = self
//        //canvas.becomeFirstResponder()
//            
//            if let drawing = try? PKDrawing(data: drawingData){
//                canvas.drawing = drawing
//                print("bisa drawing")
//            } else {
//                canvas.drawing = PKDrawing()
//                
//                print("gagal drawing")
//            }
//        
//            //print("data dibersihkan \(previousPage) : \(currentPage)")
//      //  }
//            
//            // Step 3: Communicate state changes back to SwiftUI
//            delegate?.didUpdateState(newValue: newValue)
//        }
//}
//
//extension DrawingCanvasViewController:PKToolPickerObserver, PKCanvasViewDelegate{
//    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
//        drawingChanged(canvasView.drawing.dataRepresentation())
//    }
//}
//
//// read this
//extension UIImage {
//    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
//        let rect = CGRect(origin: .zero, size: size)
//        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
//        color.setFill()
//        UIRectFill(rect)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        guard let cgImage = image?.cgImage else { return nil }
//        self.init(cgImage: cgImage)
//        
//    }
//    func resize(newSize: CGSize) -> UIImage? {
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
//        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return newImage
//    }
//    
//    func toCVPixelBuffer() -> CVPixelBuffer? { var pixelBuffer: CVPixelBuffer? = nil
//        let attr = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
//        let width = Int(self.size.width)
//        let height = Int(self.size.height)
//        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_OneComponent8, attr, &pixelBuffer)
//        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue:0))
//        let colorspace = CGColorSpaceCreateDeviceGray()
//        let bitmapContext = CGContext(data:
//                                        CVPixelBufferGetBaseAddress(pixelBuffer!), width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: colorspace, bitmapInfo: 0)!
//        guard let cg = self.cgImage else {
//            return nil }
//        bitmapContext.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
//        return pixelBuffer
//    }
//    
//    func image(byDrawingImage image: UIImage, inRect rect: CGRect) -> UIImage! {
//        UIGraphicsBeginImageContext(size)
//        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
//        image.draw(in: rect)
//        let result = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return result // resulting image
//    }
//}
//extension CGRect {
//    var center: CGPoint {
//        return CGPoint(x: midX, y: midY)
//        
//    }
//    
//}
