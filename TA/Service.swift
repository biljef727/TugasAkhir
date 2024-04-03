//
//  Service.swift
//  TA
//
//  Created by Billy Jefferson on 22/02/24.
//

import SwiftUI
import Foundation

class ServiceRoute:ObservableObject{
    @Published var path:[String] = []
    @Published var classID:Int?
    
    func navigate(to pathComponent: String) {
        self.path.append(pathComponent)
    }
}
