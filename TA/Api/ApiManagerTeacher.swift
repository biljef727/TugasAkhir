//
//  ApiManagerTeacher.swift
//  TA
//
//  Created by Billy Jefferson on 04/04/24.
//

import Foundation

class ApiManagerTeacher {
    func addNewExam(examName: String, section1: Int, section2: Int, section3: Int, file: Data?, userId: String, completion: @escaping (Error?) -> Void) {
        let apiUrl = URL(string: "https://indramaryati.xyz/iph_exam/public/api/addNewExam")!
        
        var requestBody : [String : Any] = [
            "ExamName": examName,
            "ExamSection1": section1,
            "ExamSection2": section2,
            "ExamSection3": section3,
            "UserID": userId
        ]
        
        if let fileData = file {
            // Convert file data to base64 string
            let fileBase64String = fileData.base64EncodedString()
            requestBody["ExamFile"] = fileBase64String
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(error)
                    return
                }
                completion(nil)
            }.resume()
        } catch {
            completion(error)
        }
    }
    
    func fetchClassID(userID: String, completion: @escaping(Result<([String], [String],[Data]), Error>) -> Void) {
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/fetchExamData?UserID=\(userID)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(.failure(error!))
                return
            }
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                do {
                    let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
                    guard let examNames = decodedData["ExamName"], 
                            let examSectionCounter = decodedData["ExamCounter"],
                            let examFileStrings = decodedData["ExamFile"] else {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    let examFiles: [Data] = try examFileStrings.map { base64String in
                                       guard let fileData = Data(base64Encoded: base64String) else {
                                           throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode base64 file data"])
                                       }
                                       return fileData
                                   }
                    completion(.success((examNames, examSectionCounter,examFiles)))
                } catch {
                    print("Error parsing JSON: \(error)")
                    completion(.failure(error))
                }
            } else {
                if let errorMessage = String(data: data, encoding: .utf8) {
                    // Handle error message
                } else {
                    // Handle unknown error
                }
            }
        }.resume()
    }
    func fetchExamCounter(examID: String, completion: @escaping(Result<(String), Error>) -> Void) {
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/fetchExamCounter?ExamID=\(examID)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(.failure(error!))
                return
            }
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                do {
                    let decodedData = try JSONDecoder().decode([String: String].self, from: data)
                    guard let examCounter = decodedData["ExamCounter"] else {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    completion(.success(examCounter))
                } catch {
                    print("Error parsing JSON: \(error)")
                    completion(.failure(error))
                }
            } else {
                if let errorMessage = String(data: data, encoding: .utf8) {
                    // Handle error message
                } else {
                    // Handle unknown error
                }
            }
        }.resume()
    }
    
    func fetchScheduleID(userID: String, completion: @escaping(Result<([String]), Error>) -> Void) {
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/scheduleExamID?UserID=\(userID)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(.failure(error!))
                return
            }
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                do {
                    let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
                    guard let examID = decodedData["ExamID"]else {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    completion(.success(examID))
                } catch {
                    print("Error parsing JSON: \(error)")
                    completion(.failure(error))
                }
            } else {
                if let errorMessage = String(data: data, encoding: .utf8) {
                    // Handle error message
                } else {
                    // Handle unknown error
                }
            }
        }.resume()
    }
    
    func fetchClassTeacher(userID: String, completion: @escaping(Result<([String],[String]), Error>) -> Void) {
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/teacherClassID?UserID=\(userID)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(.failure(error!))
                return
            }
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                do {
                    let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
                    guard let teacherClassID = decodedData["TeacherClass"],let classID = decodedData["TeacherID"] else {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    completion(.success((teacherClassID,classID)))
                } catch {
                    print("Error parsing JSON: \(error)")
                    completion(.failure(error))
                }
            } else {
                if let errorMessage = String(data: data, encoding: .utf8) {
                    // Handle error message
                } else {
                    // Handle unknown error
                }
            }
        }.resume()
    }
    
    func addNewScheduleExam(examID: String, classID: String, examDate: Double, startExamTime: Double, endExamTime: Double, completion: @escaping (Error?) -> Void) {
        let apiUrl = URL(string: "https://indramaryati.xyz/iph_exam/public/api/addScheduleExam")!
        //        let _ = print("1")
        var requestBody : [String : Any] = [
            "ExamID": examID,
            "ClassID": classID,
            "ExamDate": examDate,
            "StartExamTime": startExamTime,
            "EndExamTime": endExamTime
        ]
        //        let _ = print("2")
        //        let _ = print(requestBody)
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //        let _ = print("3")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
            //            let _ = print("4")
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                //                let _ = print("5")
                if let error = error {
                    //                    let _ = print("6")
                    completion(error)
                    return
                }
                //                let _ = print("7")
                completion(nil)
            }.resume()
        } catch {
            //            let _ = print("8")
            completion(error)
        }
    }
    
    func getScheduleExamName(userID:String, completion: @escaping (Result<(examIDs:[String],examNames: [String], examDates: [String],startExamTimes: [String], endExamTimes: [String], classNames:[String],classID:[String]), Error>) -> Void) {
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/scheduleExamData?UserID=\(userID)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(.failure(error!))
                return
            }
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                do {
                    let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
                    guard let examIDs = decodedData["ExamID"],let examNames = decodedData["ExamName"], let examDates = decodedData["ExamDate"],let startExamTimes = decodedData["StartExamTime"], let endExamTimes = decodedData["EndExamTime"],let classNames = decodedData["ClassName"], let classID = decodedData["ClassID"] else {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    completion(.success((examIDs,examNames, examDates,startExamTimes,endExamTimes,classNames,classID)))
                } catch {
                    print("Error parsing JSON: \(error)")
                    completion(.failure(error))
                }
            } else {
                if let errorMessage = String(data: data, encoding: .utf8) {
                    // Handle error message
                } else {
                    // Handle unknown error
                }
            }
        }.resume()
    }
    func fetchClassIDandNames(userID: String, completion: @escaping(Result<([String], [String]), Error>) -> Void) {
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/getClassIDandNames?UserID=\(userID)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(.failure(error!))
                return
            }
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                do {
                    let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
                    guard let examNames = decodedData["ExamName"], let examID = decodedData["ExamID"] else {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    completion(.success((examNames, examID)))
                } catch {
                    print("Error parsing JSON: \(error)")
                    completion(.failure(error))
                }
            } else {
                if let errorMessage = String(data: data, encoding: .utf8) {
                    // Handle error message
                } else {
                    // Handle unknown error
                }
            }
        }.resume()
    }
    
    func fetchStudentIDandNames(classID: String, examID: String, completion: @escaping(Result<([String], [String],[String],[String],[String]), Error>) -> Void) {
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/studentExamResult?ClassID=\(classID)&ExamID=\(examID)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(.failure(error!))
                return
            }
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                do {
                    let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
                    guard let studentNames = decodedData["studentName"], let studentID = decodedData["studentID"],let nilaiTotal = decodedData["nilaiTotal"],let statusScore = decodedData["statusScore"], let nilaiFile = decodedData["nilaiFile"]else {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    completion(.success((studentNames, studentID,nilaiTotal,statusScore,nilaiFile)))
                } catch {
                    print("Error parsing JSON: \(error)")
                    completion(.failure(error))
                }
            } else {
                if let errorMessage = String(data: data, encoding: .utf8) {
                    // Handle error message
                } else {
                    // Handle unknown error
                }
            }
        }.resume()
    }
    
    func fetchNilaiStudent(userID: String, completion: @escaping(Result<(String,String,String,String), Error>) -> Void) {
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/requestDataEdit?UserID=\(userID)"
        //        let _ = print("1")
        guard let url = URL(string: urlString) else {
            //            let _ = print("2")
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        //        let _ = print("3")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //        let _ = print("4")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                //                let _ = print("5")
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(.failure(error!))
                return
            }
            //            let _ = print("6")
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                do {
                    //                    let _ = print("7")
                    let decodedData = try JSONDecoder().decode([String: String].self, from: data)
                    guard let studentName = decodedData["studentName"],
                          let studentID = decodedData["studentID"],
                          let examName = decodedData["examName"],
                          let examCounter = decodedData["examCounter"]
                    else {
                        //                        let _ = print("8")
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    //                    let _ = print("9")
                    completion(.success((studentName, studentID, examName, examCounter)))
                } catch {
                    //                    let _ = print("10")
                    completion(.failure(error))
                }
            } else {
                if let errorMessage = String(data: data, encoding: .utf8) {
                    // Handle error message
                } else {
                    // Handle unknown error
                }
            }
        }.resume()
    }
    
    func editStatusScore(userID: String,examID:String, NilaiSection1: Int, NilaiSection2: Int, NilaiSection3: Int,NilaiTotal:Int,feedback:String,completion: @escaping (Error?) -> Void) {
        let apiUrl = URL(string: "https://indramaryati.xyz/iph_exam/public/api/editStatusScore")!
                        let _ = print("1")
        var requestBody : [String : Any] = [
            "UserID": userID,
            "ExamID":examID,
            "NilaiSection1": NilaiSection1,
            "NilaiSection2": NilaiSection2,
            "NilaiSection3": NilaiSection3,
            "NilaiTotal": NilaiTotal,
            "NilaiCatTambahan" : feedback
        ]
        let _ = print(userID)
        let _ = print(NilaiSection1)
        let _ = print(NilaiSection2)
        let _ = print(NilaiSection3)
        let _ = print(NilaiTotal)
        let _ = print(feedback)
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let _ = print("3")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
            let _ = print("4")
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                let _ = print("5")
                if let error = error {
                    let _ = print("6")
                    completion(error)
                    return
                }
                let _ = print("7")
                completion(nil)
            }.resume()
        } catch {
            let _ = print("8")
            completion(error)
        }
    }
}

