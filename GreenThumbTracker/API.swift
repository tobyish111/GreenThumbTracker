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
    private let baseURL = "http://localhost:8800/api"         //dev endpoint
    //private let baseURL = "https://greenthumbtracker.org/api" //prod endpoint (aws)
    
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
            if let error = error {
                   print("❌ Network error: \(error.localizedDescription)")
                   DispatchQueue.main.async {
                       completion(.failure(error))
                   }
                   return
               }

            if let data = data{
                print("📦 Raw response: \(String(data: data, encoding: .utf8) ?? "Unreadable")")
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
    //adding a plant
    func addPlant(name: String, species: String, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "/plants"
        let body: [String: Any] = [
            "name": name,
            "species": species
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Failed to encode JSON")
            return
        }

        request(endpoint: endpoint, method: "POST", body: jsonData) { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                let message = response["message"] ?? "Plant created!"
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    //fetch all plants
    func fetchPlants(completion: @escaping (Result<[Plant], Error>) -> Void){
        request(endpoint: "/plants", completion: completion)
    }
    //update a plant (edit)
    func updatePlant(id: Int, name: String, species: String, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "/plants/\(id)"
        let body: [String: Any] = [
            "name": name,
            "species": species
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Failed to encode JSON")
            return
        }

        request(endpoint: endpoint, method: "PUT", body: jsonData) { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                let message = response["message"] ?? "Plant updated!"
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    //delete plant
    func deletePlant(id: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "/plants/\(id)"
        
        request(endpoint: endpoint, method: "DELETE") { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                completion(.success(response["message"] ?? "Plant deleted successfully!"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


    
    //WATER RECORD METHODS
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
    //get water records
    func fetchWaterRecords(forPlantId plantId: Int, completion: @escaping (Result<[WaterRecord], Error>) -> Void) {
        let endpoint = "/water/\(plantId)"
        request(endpoint: endpoint, completion: completion)
    }
    //update water record
    func updateWaterRecord(plantId: Int, recordId: Int, amount: Int, date: String, uomID: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "/water/\(plantId)/\(recordId)"
        let body: [String: Any] = [
            "waterAmount": amount,
            "waterDate": date,
            "uomId": uomID
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        request(endpoint: endpoint, method: "PUT", body: jsonData) { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                completion(.success(response["message"] ?? "Update successful"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    //delete water record
    func deleteWaterRecord(plantId: Int, recordId: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "/water/\(plantId)/\(recordId)"
        
        request(endpoint: endpoint, method: "DELETE") { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                completion(.success(response["message"] ?? "Deleted"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /*
     Growth Record crud operations
     */

    func fetchGrowthRecords(forPlantId plantId: Int, completion: @escaping (Result<[GrowthRecord], Error>) -> Void) {
        let endpoint = "/growth/\(plantId)"
        request(endpoint: endpoint, completion: completion)
    }

    func createGrowthRecord(plantId: Int, height: Double, date: String, uomID: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "/growth/\(plantId)"
        let body: [String: Any] = [
            "height": height,
            "date": date,
            "uomId": uomID
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        request(endpoint: endpoint, method: "POST", body: jsonData) { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                completion(.success(response["message"] ?? "Success"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func updateGrowthRecord(plantId: Int, recordId: Int, height: Double, date: String, uomID: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "/growth/\(plantId)/\(recordId)"
        let body: [String: Any] = [
            "height": height,
            "date": date,
            "uomId": uomID
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        request(endpoint: endpoint, method: "PUT", body: jsonData) { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                completion(.success(response["message"] ?? "Updated"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func deleteGrowthRecord(plantId: Int, recordId: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "/growth/\(plantId)/\(recordId)"
        request(endpoint: endpoint, method: "DELETE") { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                completion(.success(response["message"] ?? "Deleted"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
//end growth record operations
    
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
