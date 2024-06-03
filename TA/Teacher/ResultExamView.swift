import SwiftUI
import Combine
import Photos

struct ResultExamView: View {
    @EnvironmentObject var routerView : ServiceRoute
    @State private var isEditExamStatus = false
    @State var listStudentName: [String] = []
    @State var listStudentID: [String] = []
    @State var studentScore : [String] = []
    @State var selectedID: String? = nil
    @State var studentStatusExam : [String] = []
    @State var nilaiFile :[String] = []
    @State var alertSave: Bool = false
    var examNames: String?
    var examIDs: String?
    var examDates: String?
    var gradeIDs: String?
    let refreshSubject = PassthroughSubject<UUID, Never>()
    let apiManager = ApiManagerTeacher()
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    Text("Name").font(.headline)
                    Text("Student ID").font(.headline)
                    Text("Exam Name").font(.headline)
                    Text("Exam Date").font(.headline)
                    Text("Score").font(.headline)
                    Text("File").font(.headline)
                    Text("Status").font(.headline)
                    Text("Edit Status").font(.headline)
                    
                    ForEach(0..<listStudentName.count, id: \.self) { index in
                        let selectedUserID = listStudentID[index]
                        Text(listStudentName[index])
                        Text(listStudentID[index])
                        Text(examNames ?? "")
                        Text(examDates ?? "")
                        Text(String(studentScore[index]))
                        
                        Button(action: {
                            convertAndDownload(datafile: nilaiFile[index])
                        }) {
                            Text("FileSoal")
                        }
                        Text(studentStatusExam[index])
                        
                        if (studentStatusExam[index] == "Not Graded") {
                            Button(action: {
                                print("Selected userID:", selectedUserID)
                                self.selectedID = listStudentID[index]
                                self.isEditExamStatus.toggle()
                            }) {
                                Text("Edit")
                            }
                        } else {
                            Text("Already Edited")
                        }
                    }
                }
                .border(Color.black)
                .padding()
                .sheet(isPresented: $isEditExamStatus) {
                    EditStatusExam(isPresented: $isEditExamStatus, userID: $selectedID, examIDs: examIDs ,refreshSubject: refreshSubject)
                }
            }
            VStack(alignment: .leading) {
                Spacer()
                Text("Lowest Score")
                let sortedStudents = Array(zip(listStudentName, studentScore)).sorted { $0.1 < $1.1 }
                let lowestThreeStudents = Array(sortedStudents.prefix(3))
                ForEach(lowestThreeStudents, id: \.0) { student in
                    Text("\(student.0) - \(student.1)")
                }
                .frame(width: UIScreen.main.bounds.width / 3 * 2)
                .border(Color.black)
                Spacer()
            }
            .font(.title)
        }
        .alert(isPresented: $alertSave) {
            Alert(
                title: Text("Image Saved"),
                message: Text("Successfully saved to Photos")
            )
        }
        .onAppear {
            fetchStudentNameAndID()
        }
        .onReceive(refreshSubject) { _ in
            fetchStudentNameAndID()
        }
    }
    
    func fetchStudentNameAndID() {
        apiManager.fetchStudentIDandNames(classID: self.gradeIDs!, examID: self.examIDs!) { result in
            switch result {
            case .success(let (studentNames, studentID, nilaiTotal, statusScore, nilaiFile)):
                DispatchQueue.main.async {
                    self.listStudentName = studentNames
                    self.listStudentID = studentID
                    self.studentScore = nilaiTotal
                    self.studentStatusExam = statusScore
                    self.nilaiFile = nilaiFile
                }
            case .failure(let error):
                print("Error fetching class names: \(error)")
            }
        }
    }
    
    func convertAndDownload(datafile: String) {
        guard let data = Data(base64Encoded: datafile) else {
            print("Failed to decode base64 data.")
            return
        }

        guard let image = UIImage(data: data) else {
            print("Failed to create UIImage from data.")
            return
        }

        let albumName = "\(examNames ?? "Exam") | \(examDates ?? "Dates")"
        createAlbumIfNeeded(albumName: albumName) { album in
            guard let album = album else {
                print("Failed to create or fetch album.")
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                let assetPlaceholder = request.placeholderForCreatedAsset
                albumChangeRequest?.addAssets([assetPlaceholder] as NSFastEnumeration)
            }) { success, error in
                if success {
                    DispatchQueue.main.async {
                        self.alertSave = true
                    }
                } else if let error = error {
                    print("Error saving photo: \(error)")
                }
            }
        }
    }

    func createAlbumIfNeeded(albumName: String, completion: @escaping (PHAssetCollection?) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let existingCollection = collection.firstObject {
            completion(existingCollection)
            return
        }
        
        var albumPlaceholder: PHObjectPlaceholder?
        
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            albumPlaceholder = creationRequest.placeholderForCreatedAssetCollection
        }) { success, error in
            if success, let placeholder = albumPlaceholder {
                let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                completion(fetchResult.firstObject)
            } else {
                completion(nil)
            }
        }
    }
}

#Preview {
    ResultExamView()
}
