//
//  API.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 3/20/25.
//

import Foundation
//function to call to any endpoint from our db api!
class APIManager {
    static let shared = APIManager() //singleton instance
    private let baseURL = "http://192.168.1.42:8800/api" //when we go live update this when deployed
    
    //generic functiosn for sending requests
    private func request<T: Decodable>(endpoint: String, method: String = "GET", body: Data? = nil, completion: @escaping (Result<T, Error>) -> Void){
        guard let url = URL(string: "\(baseURL)\(endpoint)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //attach token
        if let token = UserDefaults.standard.string(forKey: "authToken"){
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("Sending request with Authorization: Bearer \(token)")
        } else {
            print("No token found in UserDefaults!")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data{
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    DispatchQueue.main.async{
                        completion(.success(decodedData))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
            
        }.resume()
    }
}//end class

//extention housing crud operations to db endpoints
extension APIManager {
    //fetch all plants
    func fetchPlants(completion: @escaping (Result<[Plant], Error>) -> Void){
        request(endpoint: "/plants", completion: completion)
    }
    
    //create water record
    func createWaterRecord(plantId: Int, amount: Int, date: String, completion: @escaping (Result<String, Error>) -> Void){
        let endpoint = "/water/\(plantId)"
        let body = ["waterAmount": amount, "waterDate": date] as [String : Any]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {return}
        
        request(endpoint: endpoint, method: "POST", body: jsonData) {(result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                completion(.success(response["message"] ?? "Success"))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    //login function for user
    func login(username: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
            let endpoint = "/auth/login"
            let body = ["username": username, "password": password]

            guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }

            request(endpoint: endpoint, method: "POST", body: jsonData) { (result: Result<LoginResponse, Error>) in
                switch result {
                case .success(let loginResponse):
                    //Store token in UserDefaults
                    UserDefaults.standard.set(loginResponse.token, forKey: "authToken")
                    print("Token Stored:", loginResponse.token)
                    completion(.success(loginResponse))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    
}//end extension
