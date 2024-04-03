//
//  FixAdminView.swift
//  TA
//
//  Created by Billy Jefferson on 22/03/24.
//

import SwiftUI
import Combine

struct RoundedCorners: View {
    var color: Color = .blue
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                
                let w = geometry.size.width
                let h = geometry.size.height
                
                // Make sure we do not exceed the size of the rectangle
                let tr = min(min(self.tr, h/2), w/2)
                let tl = min(min(self.tl, h/2), w/2)
                let bl = min(min(self.bl, h/2), w/2)
                let br = min(min(self.br, h/2), w/2)
                
                path.move(to: CGPoint(x: w / 2.0, y: 0))
                path.addLine(to: CGPoint(x: w - tr, y: 0))
                path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                path.addLine(to: CGPoint(x: w, y: h - br))
                path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                path.addLine(to: CGPoint(x: bl, y: h))
                path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                path.addLine(to: CGPoint(x: 0, y: tl))
                path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
                path.closeSubpath()
            }
            .fill(self.color)
        }
    }
}

struct FixAdminView: View {
    @EnvironmentObject var routerView: ServiceRoute
    @State var className: [String] = []
    @State var classSemester: [String] = []
    @State private var isAddClassPresented = false
    @State private var showNewTeacherView = false

    let refreshSubject = PassthroughSubject<Void, Never>()
    let apiManager = APIManager()
    
    @State private var shouldRefresh: Bool = false
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Rectangle()
                        .foregroundColor(.white)
                        .overlay(
                            VStack(alignment:.leading) {
                                Button(action: {
                                    if routerView.path.last == "admin" {
                                    } else {
                                        routerView.navigate(to:"admin")
                                    }
                                }, label: {
                                    Image(systemName: "person.fill")
                                    Text("Admin")
                                })
                                .frame(width: 200)
                                .padding(.vertical)
                                .font(.title)
                                Divider()
                                HStack {
                                    Button(action: {
                                        if routerView.path.last == "newTeacher" {
                                        } else {
                                            routerView.navigate(to:"newTeacher")
                                        }
                                    }, label: {
                                        Image(systemName: "person.fill")
                                        Text("New Teacher")
                                    })
                                }
                                .frame(width: 200)
                                .padding(.vertical)
                                .font(.title)
                                HStack {
                                    Button(action: {
                                        if routerView.path.last == "newStudent" {
                                        } else {
                                            routerView.navigate(to:"newStudent")
                                        }
                                    }, label: {
                                        Image(systemName: "person.fill")
                                        Text("New Student")
                                    })
                                }
                                .frame(width: 200)
                                .padding(.vertical)
                                .font(.title)
                                Divider()
                                Spacer()
                            }
                        )
                        .frame(width: 200, height: UIScreen.main.bounds.height/8*7)
                    Spacer()
                }
                ScrollView {
                    VStack(alignment:.leading) {
                        ForEach(0..<className.count / 4 + 1, id: \.self) { row in
                            HStack(spacing: 20) {
                                ForEach(0..<min(className.count - row * 4, 4), id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 16, style: .circular)
                                        .frame(width: 200, height: 200)
                                        .shadow(radius: 5)
                                        .foregroundColor(.white)
                                        .overlay(
                                            ZStack {
                                                Image("images")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 200, height: 150)
                                                    .cornerRadius(16)
                                                    .padding(.bottom, 50)
                                                VStack {
                                                    Spacer()
                                                    HStack {
                                                        Text("\(className[row * 4 + index]) | \(classSemester[row * 4 + index])".prefix(15))
                                                            .bold()
                                                            .foregroundColor(.white)
                                                            .font(.title3)
                                                            .padding(.vertical, 13)
                                                            .frame(maxWidth: .infinity)
                                                            .background(RoundedCorners(bl: 16, br: 16))
                                                    }
                                                }
                                            }
                                        )
                                        .onTapGesture {
                                            let selectedClassName = className[row * 4 + index]
                                            let selectedClassSemester = classSemester[row * 4 + index]
                                            apiManager.fetchClassID(className: selectedClassName, classSemester: selectedClassSemester) { classID in
                                                guard let classID = classID else {
                                                    return
                                                }
                                                DispatchQueue.main.async {
                                                    routerView.classID = classID
                                                    routerView.path.append("classAdmission")
                                                }
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .padding()
                }

                .padding()
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle("IPH Exam Management")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        Button(action: {
                            routerView.path.removeAll()
                        }) {
                            Image(systemName: "square.and.arrow.up.circle")
                            Text("Log Out")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button(action: {
                            self.isAddClassPresented.toggle()
                        }) {
                            Image(systemName: "plus")
                            Text("Add New Class")
                        }
                        .sheet(isPresented: $isAddClassPresented) {
                            NewClassView(isPresented: $isAddClassPresented, refreshSubject: refreshSubject, className: $className)
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchClassNames()
        }
        .onReceive(refreshSubject) { _ in
            fetchClassNames()
        }
    }
    private func fetchClassNames() {
        apiManager.getClassNames { result in
            switch result {
            case .success(let (classNames, classSemester)):
                DispatchQueue.main.async {
                    self.className = classNames
                    self.classSemester = classSemester
                }
            case .failure(let error):
                print("Error fetching class names: \(error)")
            }
        }
        
    }
}

#Preview {
    FixAdminView()
}

