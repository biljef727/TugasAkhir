import Foundation

class APIManager {
    func addTeacher(userEmail: String, userPassword: String, userFullname: String, userNoInduk: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "http://localhost:8000/api/addTeacher"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "UserEmail": userEmail,
            "UserPassword": userPassword,
            "UserFullname": userFullname,
            "UserNoInduk": userNoInduk
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 201 {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to add teacher"])))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    
    func addStudent(userEmail: String, userPassword: String, userFullname: String, userNoInduk: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "http://localhost:8000/api/addStudent"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "UserEmail": userEmail,
            "UserPassword": userPassword,
            "UserFullname": userFullname,
            "UserNoInduk": userNoInduk
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 201 {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to add teacher"])))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    
    func addClass(className: String, classSemester: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "http://localhost:8000/api/addClass"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "ClassName": className,
            "ClassSemester": classSemester
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 201 {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to add class"])))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    
    func getClassNames(completion: @escaping (Result<(classNames: [String], classSemester: [String]), Error>) -> Void) {
        let urlString = "http://localhost:8000/api/getClassNames"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON Data: \(jsonString)")
            } else {
                print("Unable to convert data to string.")
            }
            
            do {
                let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
                guard let classNames = decodedData["class_names"], let classSemester = decodedData["class_semester"] else {
                    throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                }
                completion(.success((classNames, classSemester)))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    func fetchClassID(className: String, classSemester: String, completion: @escaping (Int?) -> Void) {
        guard let url = URL(string: "http://localhost:8000/api/getClassChoosen") else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "ClassName": className,
            "ClassSemester": classSemester
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let classID = json["ClassID"] as? Int {
                        print("ClassID: \(classID)")
                        completion(classID)
                    } else {
                        print("Class ID not found in response")
                        completion(nil)
                    }
                } else {
                    print("Invalid JSON response")
                    completion(nil)
                }
            } else {
                print("HTTP Error: \(response.debugDescription)")
                completion(nil)
            }
        }.resume()
    }
    
    func getTeacherNames(ClassID: String,completion: @escaping(Result<(teacherNames: [String], teacherIds: [String]), Error>) -> Void){
        let urlString = "http://localhost:8000/api/getTeacherNames?ClassID=\(ClassID)"
//        let _ = print("1")
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
//        let _ = print("10")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
//        let _ = print("11")

//        let _ = print("2")
        URLSession.shared.dataTask(with: request) { data, response, error in
//            let _ = print("3")
            guard let data = data, error == nil else {
//                let _ = print("4")
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
//                let _ = print("5")
                do {
                    let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
                    guard let teacherNames = decodedData["TeacherNames"], let teacherIds = decodedData["TeacherID"] else {
//                        let _ = print("6")
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
//                    let _ = print("7")
                    completion(.success((teacherNames, teacherIds)))
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            } else {
                if let errorMessage = String(data: data, encoding: .utf8) {
                    //                    loginError = errorMessage
                } else {
                    //                    loginError = "Unknown error occurred."
                }
            }
        }.resume()
    }
    
    func getStudentNames(completion: @escaping(Result<(studentNames: [String], studentIds: [String]), Error>) -> Void){
        let urlString = "http://localhost:8000/api/getStudentNames"
        //           let _ = print("1")
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        //        let _ = print("2")
        URLSession.shared.dataTask(with: url) { data, response, error in
            //               let _ = print("3")
            guard let data = data, error == nil else {
                //                   let _ = print("4")
                completion(.failure(error ?? NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            //               let _ = print("5")
            do {
                //                   let _ = print("6")
                let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
                guard let studentNames = decodedData["StudentNames"], let studentIds = decodedData["StudentID"] else {
                    //                       let _ = print("7")
                    throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                }
                //                   let _ = print("8")
                completion(.success((studentNames, studentIds)))
            } catch {
                //                   let _ = print("9")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func admissionTeacher(classID: Int, userID: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "http://localhost:8000/api/admissionTeacher"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "ClassID": classID,
            "UserID": userID
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 201 {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to add teacher"])))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    
    func admissionStudent(classID: Int, userID: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "http://localhost:8000/api/admissionStudent"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "ClassID": classID,
            "UserID": userID
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 201 {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to add student"])))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    func fetchAlreadyTeacher(ClassID: String,completion: @escaping(Result<(teacherNamesInsideClass:[String],teacherIDInsideClass:[String]), Error>) -> Void){
        let urlString = "http://localhost:8000/api/getTeacherInsideClass?ClassID=\(ClassID)"
        let _ = print("1")
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        let _ = print("10")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let _ = print("11")

        let _ = print("2")
        URLSession.shared.dataTask(with: request) { data, response, error in
            let _ = print("3")
            guard let data = data, error == nil else {
//                let _ = print("4")
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
//                let _ = print("5")
                do {
                    let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
                    guard let teacherNamesInsideClass = decodedData["TeacherNameInsideClass"], let teacherIDInsideClass = decodedData["TeacherIDInsideClass"] else {
//                        let _ = print("6")
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
//                    let _ = print("7")
                    completion(.success((teacherNamesInsideClass,teacherIDInsideClass)))
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            } else {
                if let errorMessage = String(data: data, encoding: .utf8) {
                    //                    loginError = errorMessage
                } else {
                    //                    loginError = "Unknown error occurred."
                }
            }
        }.resume()
    }
    
}
