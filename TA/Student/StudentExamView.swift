import SwiftUI

struct StudentExamView: View {
    @StateObject var pdfDrawer = PDFDrawer()
    
    var body: some View {
        ZStack{
            DocumentDrawingViewControllerWrapper()
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading:HStack{
            Button(action:{
                pdfDrawer.setDrawingTool(.pen)
            }){
                Image(systemName: "pencil")
            }
            Button(action:{
                pdfDrawer.setDrawingTool(.eraser)
            }){
                Image(systemName: "eraser.fill")
            }
        },trailing:  Button(action:{
            // Saving
            // takeScreenshot()
        },label:{
            Text("Submit")
        }))
        .environmentObject(pdfDrawer)
    }
}
