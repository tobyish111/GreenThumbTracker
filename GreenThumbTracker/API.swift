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
    private let baseURL = "http://192.168.1.11:8800/api"         //dev endpoint
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
    //MARK: Plants
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
    //MARK: Water Record operations
    //create water record
    func createWaterRecord(plantId: Int, amount: Int, date: String, completion: @escaping (Result<String, Error>) -> Void){
        let endpoint = "/water/\(plantId)"
        let body = ["amount": amount, "date": date] as [String : Any]
        
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
            "amount": amount,
            "date": date,
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
    //MARK: Growth Operations
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
    //MARK: - Humidity Record CRUD
    func fetchHumidityRecords(forPlantId plantId: Int, completion: @escaping (Result<[HumidityRecord], Error>) -> Void) {
        request(endpoint: "/humidity/\(plantId)", completion: completion)
    }

    func createHumidityRecord(plantId: Int, humidity: Double, date: String, uomID: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "/humidity/\(plantId)"
        let body: [String: Any] = [
            "humidity": humidity,
            "date": date,
            "uomId": uomID
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }

        request(endpoint: endpoint, method: "POST", body: jsonData) { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                completion(.success(response["message"] ?? "Humidity record created"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func updateHumidityRecord(plantId: Int, recordId: Int, humidity: Double, date: String, uomID: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "/humidity/\(plantId)/\(recordId)"
        let body: [String: Any] = [
            "humidity": humidity,
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

    func deleteHumidityRecord(plantId: Int, recordId: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "/humidity/\(plantId)/\(recordId)"
        request(endpoint: endpoint, method: "DELETE") { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                completion(.success(response["message"] ?? "Deleted"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    // MARK: - Light Record CRUD
    func fetchLightRecords(forPlantId plantId: Int, completion: @escaping (Result<[LightRecord], Error>) -> Void) {
        request(endpoint: "/light/\(plantId)", completion: completion)
    }

    func createLightRecord(plantId: Int, light: Double, date: String, uomID: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let body: [String: Any] = [
            "light": light,
            "date": date,
            "uomId": uomID
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }

        request(endpoint: "/light/\(plantId)", method: "POST", body: jsonData) { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                completion(.success(response["message"] ?? "Light record created"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func updateLightRecord(plantId: Int, recordId: Int, light: Double, date: String, uomID: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let body: [String: Any] = [
            "light": light,
            "date": date,
            "uomId": uomID
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }

        request(endpoint: "/light/\(plantId)/\(recordId)", method: "PUT", body: jsonData) { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                completion(.success(response["message"] ?? "Light record updated"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func deleteLightRecord(plantId: Int, recordId: Int, completion: @escaping (Result<String, Error>) -> Void) {
        request(endpoint: "/light/\(plantId)/\(recordId)", method: "DELETE") { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                completion(.success(response["message"] ?? "Light record deleted"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    // MARK: - Soil Moisture Record CRUD

    func fetchSoilMoistureRecords(forPlantId plantId: Int, completion: @escaping (Result<[SoilMoistureRecord], Error>) -> Void) {
        request(endpoint: "/soil-moisture/\(plantId)", completion: completion)
    }

    func createSoilMoistureRecord(plantId: Int, moisture: Double, date: String, uomID: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let body: [String: Any] = [
            "soilMoisture": moisture,
            "date": date,
            "uomId": uomID
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }

        request(endpoint: "/soil-moisture/\(plantId)", method: "POST", body: jsonData) { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                completion(.success(response["message"] ?? "Soil moisture record created"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func updateSoilMoistureRecord(plantId: Int, recordId: Int, moisture: Double, date: String, uomID: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let body: [String: Any] = [
            "soilMoisture": moisture,
            "date": date,
            "uomId": uomID
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }

        request(endpoint: "/soil-moisture/\(plantId)/\(recordId)", method: "PUT", body: jsonData) { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                completion(.success(response["message"] ?? "Soil moisture record updated"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func deleteSoilMoistureRecord(plantId: Int, recordId: Int, completion: @escaping (Result<String, Error>) -> Void) {
        request(endpoint: "/soil-moisture/\(plantId)/\(recordId)", method: "DELETE") { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                completion(.success(response["message"] ?? "Soil moisture record deleted"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    // MARK: - Temperature Record CRUD
    func fetchTemperatureRecords(forPlantId plantId: Int, completion: @escaping (Result<[TemperatureRecord], Error>) -> Void) {
        request(endpoint: "/temperature/\(plantId)", completion: completion)
        
    }

    func createTemperatureRecord(plantId: Int, temperature: Double, date: String, uomID: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let body: [String: Any] = [
            "temperature": temperature,
            "date": date,
            "uomId": uomID
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }

        request(endpoint: "/temperature/\(plantId)", method: "POST", body: jsonData) { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                completion(.success(response["message"] ?? "Temperature record created"))
                print("✅ Decoded Temperature Records: \(response)")

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func updateTemperatureRecord(plantId: Int, recordId: Int, temperature: Double, date: String, uomID: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let body: [String: Any] = [
            "temperature": temperature,
            "date": date,
            "uomId": uomID
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }

        request(endpoint: "/temperature/\(plantId)/\(recordId)", method: "PUT", body: jsonData) { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                completion(.success(response["message"] ?? "Temperature record updated"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func deleteTemperatureRecord(plantId: Int, recordId: Int, completion: @escaping (Result<String, Error>) -> Void) {
        request(endpoint: "/temperature/\(plantId)/\(recordId)", method: "DELETE") { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                completion(.success(response["message"] ?? "Temperature record deleted"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


    //MARK: Login functions
    //login function for user
    func login(username: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
            let endpoint = "/auth/login"
            let body = ["username": username, "password": password]

            guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }

            request(endpoint: endpoint, method: "POST", body: jsonData) { (result: Result<LoginResponse, Error>) in
                switch result {
                case .success(let loginResponse):
                    // Store token in UserDefaults
                                UserDefaults.standard.set(loginResponse.token, forKey: "authToken")
                                print("Token Stored:", loginResponse.token)

                                // ✅ Fetch Trefle Client Token right after login
                                TrefleTokenManager.shared.fetchClientToken { success in
                                    if success {
                                        print("✅ Successfully fetched Trefle client token after login!")
                                    } else {
                                        print("❌ Failed to fetch Trefle client token after login.")
                                    }
                                    // After trying to fetch, complete login
                                    completion(.success(loginResponse))
                                }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    //logging a user out
    func logout(completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "/auth/logout"
        
        request(endpoint: endpoint, method: "POST") { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                UserDefaults.standard.removeObject(forKey: "authToken")
                completion(.success(response["message"] ?? "Logged out successfully"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    func register(username: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/register") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // ✅ Confirm we are NOT sending confirmPassword
        let body: [String: String] = [
            "username": username,
            "email": email,
            "password": password
        ]
        print("📤 Registering user with body:", body)

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("❌ Failed to serialize register body:", error)
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Registration failed with status code \(httpResponse.statusCode)"])))
                return
            }

            completion(.success(()))
        }.resume()
    }
//syncing plant
    func syncPlant(_ local: LocalPlant) async -> Bool {
            await withCheckedContinuation { continuation in
                addPlant(name: local.name, species: local.species) { result in
                    switch result {
                    case .success:
                        continuation.resume(returning: true)
                    case .failure:
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    func syncWaterRecord(_ record: LocalWaterRecord) async -> Bool {
            guard let plantId = record.plant?.backendId else { return false }

            return await withCheckedContinuation { continuation in
                createWaterRecord(
                    plantId: plantId,
                    amount: Int(record.amount),
                    date: ISO8601DateFormatter().string(from: record.date)
                ) { result in
                    continuation.resume(returning: result.isSuccess)
                }
            }
        }

        func syncGrowthRecord(_ record: LocalGrowthRecord) async -> Bool {
            guard let plantId = record.plant?.backendId else { return false }

            return await withCheckedContinuation { continuation in
                createGrowthRecord(
                    plantId: plantId,
                    height: record.height,
                    date: ISO8601DateFormatter().string(from: record.date),
                    uomID: 1 // Adjust as needed
                ) { result in
                    continuation.resume(returning: result.isSuccess)
                }
            }
        }

        func syncHumidityRecord(_ record: LocalHumidityRecord) async -> Bool {
            guard let plantId = record.plant?.backendId else { return false }

            return await withCheckedContinuation { continuation in
                createHumidityRecord(
                    plantId: plantId,
                    humidity: record.humidity,
                    date: ISO8601DateFormatter().string(from: record.date),
                    uomID: 1
                ) { result in
                    continuation.resume(returning: result.isSuccess)
                }
            }
        }

        func syncLightRecord(_ record: LocalLightRecord) async -> Bool {
            guard let plantId = record.plant?.backendId else { return false }

            return await withCheckedContinuation { continuation in
                createLightRecord(
                    plantId: plantId,
                    light: record.light,
                    date: ISO8601DateFormatter().string(from: record.date),
                    uomID: 1
                ) { result in
                    continuation.resume(returning: result.isSuccess)
                }
            }
        }

        func syncSoilMoistureRecord(_ record: LocalSoilMoistureRecord) async -> Bool {
            guard let plantId = record.plant?.backendId else { return false }

            return await withCheckedContinuation { continuation in
                createSoilMoistureRecord(
                    plantId: plantId,
                    moisture: record.soilMoisture,
                    date: ISO8601DateFormatter().string(from: record.date),
                    uomID: 1
                ) { result in
                    continuation.resume(returning: result.isSuccess)
                }
            }
        }

    func syncTemperatureRecord(_ record: LocalTemperatureRecord) async -> Bool {
        guard let plantId = record.plant?.backendId else { return false }
        
        return await withCheckedContinuation { continuation in
            createTemperatureRecord(
                plantId: plantId,
                temperature: record.temperature,
                date: ISO8601DateFormatter().string(from: record.date),
                uomID: 1
            ) { result in
                continuation.resume(returning: result.isSuccess)
            }
        }
    }

}//end extension
struct WikipediaSummary: Codable {
    let extract: String
    let title: String
    let thumbnail: Thumbnail?

    struct Thumbnail: Codable {
        let source: String
    }
}
//getter
func fetchWikipediaSummary(for familyName: String, completion: @escaping (WikipediaSummary?) -> Void) {
    let encodedName = familyName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? familyName
    guard let url = URL(string: "https://en.wikipedia.org/api/rest_v1/page/summary/\(encodedName)") else {
        completion(nil)
        return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            let summary = try? JSONDecoder().decode(WikipediaSummary.self, from: data)
            completion(summary)
        } else {
            completion(nil)
        }
    }.resume()
}
//for caching
class WikipediaSummaryCache {
    static let shared = WikipediaSummaryCache()

    private var cache: [String: WikipediaSummary] = [:]
    private let fileURL: URL

    private init() {
        let filename = "WikipediaSummaryCache.json"
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        self.fileURL = urls[0].appendingPathComponent(filename)
        loadFromDisk()
    }

    func get(for key: String) -> WikipediaSummary? {
        return cache[key.lowercased()]
    }

    func set(_ summary: WikipediaSummary, for key: String) {
        let lowerKey = key.lowercased()
        cache[lowerKey] = summary
        saveToDisk()
    }

    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(cache)
            try data.write(to: fileURL)
        } catch {
            print("❌ Failed to save WikipediaSummaryCache:", error.localizedDescription)
        }
    }

    private func loadFromDisk() {
        do {
            let data = try Data(contentsOf: fileURL)
            cache = try JSONDecoder().decode([String: WikipediaSummary].self, from: data)
        } catch {
            print("⚠️ No previous summary cache or failed to load:", error.localizedDescription)
        }
    }
}
