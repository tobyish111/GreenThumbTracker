//
//  TrefleAPI.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/3/25.
//

import Foundation

//MARK: Token manager class
class TrefleTokenManager: ObservableObject {
    static let shared = TrefleTokenManager()
    
    @Published var token: String? = nil
    @Published var expirationDate: Date? = nil
    
    private init() {
        //persist previously requested tokens across app sessions
        // Load from UserDefaults if available
        if let savedToken = UserDefaults.standard.string(forKey: "TrefleClientToken") {
            self.token = savedToken
        }
        if let savedExpirationTimestamp = UserDefaults.standard.object(forKey: "TrefleClientTokenExpiration") as? Double {
            self.expirationDate = Date(timeIntervalSince1970: savedExpirationTimestamp)
        }
    }

    func fetchClientToken(completion: @escaping (Bool) -> Void) {
        let dev: String = "http://192.168.1.11:8800/api/trefle-client-token"
            let prod: String = "https://greenthumbtracker.org/api/trefle-client-token"
            guard let url = URL(string: dev) else {
                print("❗Invalid backend URL for fetching client token.")
                completion(false)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❗Error fetching client token: \(error)")
                    completion(false)
                    return
                }

                guard let data = data else {
                    print("❗No data received while fetching client token.")
                    completion(false)
                    return
                }

                if let rawJson = String(data: data, encoding: .utf8) {
                    print("🔍 Raw JSON response from backend:\n\(rawJson)")
                }

                do {
                    let decoded = try JSONDecoder().decode(ClientTokenResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.token = decoded.token
                        self.expirationDate = self.parseExpirationDate(decoded.expiration)

                        // ✅ NEW: Save to UserDefaults
                        UserDefaults.standard.set(self.token, forKey: "TrefleClientToken")
                        if let expirationDate = self.expirationDate {
                            UserDefaults.standard.set(expirationDate.timeIntervalSince1970, forKey: "TrefleClientTokenExpiration")
                        }

                        print("✅ Successfully fetched Trefle client token.")
                        if let expirationDate = self.expirationDate {
                            print("🕒 Token expires at: \(expirationDate)")
                        }
                        completion(true)
                    }

                } catch {
                    print("❗Failed to decode client token: \(error)")
                    completion(false)
                }
            }.resume()
        }
    // MARK: - Helper to check if token is expired
       func isTokenExpired() -> Bool {
           guard let expiration = expirationDate else {
                  return true // If we don't know the expiration, treat as expired
              }

              let now = Date()
              // Give a 5-minute safety buffer
              let safetyBuffer: TimeInterval = 5 * 60

              return now >= expiration.addingTimeInterval(-safetyBuffer)
       }
       
       // MARK: - Helper to parse the expiration date string
       private func parseExpirationDate(_ expirationString: String) -> Date? {
           let formatter = DateFormatter()
           formatter.dateFormat = "MM-dd-yyyy HH:mm"
           formatter.timeZone = TimeZone(identifier: "UTC") //trefle likely sends UTC
           return formatter.date(from: expirationString)
       }
}
//response struct for trefle token endpoint
struct ClientTokenResponse: Codable {
    let token: String
    let expiration: String
}
//end token management class

struct StringOrInt: Codable {
    let value: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let intValue = try? container.decode(Int.self) {
            value = String(intValue)
        } else {
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected String or Int"))
        }
    }
}


// private let token = "X2-PP5itzEF85qDb4Xp6O-68S9T49xFK632ZUDZ8N3Y" // Replace with your own token
//private let token = "X2-PP5itzEF85qDb4Xp6O-68S9T49xFK632ZUDZ8N3Y"
//private let token = "jjjzih8UMR2Qvx7zy9aeimsEsVY5j-xVb7qDkmrvKk8"
// MARK: - API Handler
class TrefleAPI {
    static let shared = TrefleAPI()
       private let baseURL = "https://trefle.io/api/v1"

       // Helper to get the client token
       private func getClientToken() -> String? {
           return TrefleTokenManager.shared.token
       }

    private func request<T: Decodable>(urlString: String, decodeAs: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        func performRequest(with token: String) {
            let finalURLString = urlString.replacingOccurrences(of: "{token}", with: token)
            
            guard let url = URL(string: finalURLString) else {
                completion(.failure(NSError(domain: "Invalid URL", code: 0)))
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: 0)))
                    return
                }

                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 JSON from \(finalURLString):\n\(jsonString)")
                }

                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    print("Decoding failed: \(error)")
                    completion(.failure(error))
                }
            }.resume()
        }

        // Check if token is available and not expired
        if TrefleTokenManager.shared.isTokenExpired() {
            print("🔁 Token expired or missing. Fetching new one...")
            TrefleTokenManager.shared.fetchClientToken { success in
                if success, let token = TrefleTokenManager.shared.token {
                    performRequest(with: token)
                } else {
                    completion(.failure(NSError(domain: "TrefleAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unable to refresh Trefle client token."])))
                }
            }
        } else if let token = TrefleTokenManager.shared.token {
            performRequest(with: token)
        } else {
            completion(.failure(NSError(domain: "TrefleAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "Client token not available."])))
        }
    }


       // MARK: - Trefle API Functions

       func getAllPlants(page: Int, completion: @escaping (Result<[TreflePlant], Error>) -> Void) {
           guard let token = getClientToken() else {
               completion(.failure(NSError(domain: "TrefleAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "Client token not available."])))
               return
           }
           let urlString = "\(baseURL)/plants?token=\(token)&page=\(page)&per_page=20"
           request(urlString: urlString, decodeAs: TrefleResponse.self) { result in
               completion(result.map { $0.data })
           }
       }

       func getPlantDetails(id: Int, completion: @escaping (Result<TreflePlantDetails, Error>) -> Void) {
           guard let token = getClientToken() else {
               completion(.failure(NSError(domain: "TrefleAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "Client token not available."])))
               return
           }
           let urlString = "\(baseURL)/plants/\(id)?token=\(token)"
           request(urlString: urlString, decodeAs: SingleTrefleResponse.self) { result in
               completion(result.map { $0.data })
           }
       }

       func getPlantDistributions(slug: String, completion: @escaping (Result<[DistributionRegion], Error>) -> Void) {
           guard let token = getClientToken() else {
               completion(.failure(NSError(domain: "TrefleAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "Client token not available."])))
               return
           }
           let urlString = "\(baseURL)/plants/\(slug)/distributions?token=\(token)"
           request(urlString: urlString, decodeAs: DistributionResponse.self) { result in
               completion(result.map { $0.data })
           }
       }

       func preloadAllFamilies(delay: TimeInterval = 0.3, progress: @escaping (_ loaded: Int, _ total: Int, _ page: Int, _ totalPages: Int) -> Void, completion: @escaping (Result<[TrefleFamily], Error>) -> Void) {
           guard let token = getClientToken() else {
               completion(.failure(NSError(domain: "TrefleAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "Client token not available."])))
               return
           }
           var allFamilies: [TrefleFamily] = []
           var totalCount = 1

           func fetchPage(_ page: Int) {
               let url = "\(baseURL)/families?token=\(token)&page=\(page)"
               request(urlString: url, decodeAs: FamilyResponse.self) { result in
                   switch result {
                   case .success(let response):
                       allFamilies.append(contentsOf: response.data)
                       if page == 1, let total = response.meta?.total {
                           totalCount = total
                       }
                       let totalPages = response.meta?.totalPages ?? page
                       progress(allFamilies.count, totalCount, page, totalPages)
                       if let _ = response.links?.next {
                           DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                               fetchPage(page + 1)
                           }
                       } else {
                           TrefleFamilyCache.shared.allFamilies = allFamilies
                           TreflePersistentCacheManager.shared.save(allFamilies, to: "families.json")
                           completion(.success(allFamilies))
                       }
                   case .failure(let error):
                       completion(.failure(error))
                   }
               }
           }

           fetchPage(1)
       }

       func getFamilyDetails(slug: String, completion: @escaping (Result<FamilyDetails, Error>) -> Void) {
           guard let token = getClientToken() else {
               completion(.failure(NSError(domain: "TrefleAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "Client token not available."])))
               return
           }
           let urlString = "\(baseURL)/families/\(slug)?token=\(token)"
           request(urlString: urlString, decodeAs: SingleFamilyResponse.self) { result in
               completion(result.map { $0.data })
           }
       }

       func searchPlants(query: String, completion: @escaping (Result<[TreflePlant], Error>) -> Void) {
           guard let token = getClientToken() else {
                   completion(.failure(NSError(domain: "TrefleAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "Client token not available."])))
                   return
               }
               guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                   completion(.failure(NSError(domain: "Invalid Query", code: 400)))
                   return
               }

               let urlString = "\(baseURL)/plants/search?token=\(token)&q=\(encodedQuery)"
               
               URLSession.shared.dataTask(with: URL(string: urlString)!) { data, response, error in
                   if let error = error {
                       completion(.failure(error))
                       return
                   }

                   guard let data = data else {
                       completion(.failure(NSError(domain: "No Data", code: 0)))
                       return
                   }

                   // 📦 Check if server returns HTML error page
                   if let raw = String(data: data, encoding: .utf8),
                      raw.starts(with: "<!DOCTYPE html>") {
                       completion(.failure(NSError(domain: "TrefleAPI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Trefle server error (500)."])))
                       return
                   }

                   do {
                       let decoded = try JSONDecoder().decode(TrefleResponse.self, from: data)
                       completion(.success(decoded.data))
                   } catch {
                       completion(.failure(error))
                   }
               }.resume()
           }
    
    //preload all the plants
    var didComplete = false
    func preloadAllPlants(
        delay: TimeInterval = 0.4,
        startingAt startPage: Int = 1,
        shouldCancel: @escaping () -> Bool,
        progress: @escaping (_ loaded: Int, _ total: Int, _ page: Int, _ totalPages: Int, _ elapsed: TimeInterval) -> Void,
        completion: @escaping (Result<[TreflePlant], Error>) -> Void
    ) {
        guard let token = getClientToken() else {
            completion(.failure(NSError(domain: "TrefleAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "Client token not available."])))
            return
        }

        var allPlants: [TreflePlant] = []
        var totalCount = 1
        var currentPage = startPage
        var totalPages = 1
        var elapsedTimeBeforeResume: TimeInterval = 0

        // ⏱ Attempt to resume progress
        if let savedProgress = TreflePersistentCacheManager.shared.load(PlantDownloadProgress.self, from: "plant_progress.json") {
            allPlants = savedProgress.partialPlants
            currentPage = savedProgress.currentPage + 1
            totalCount = savedProgress.totalPlants
            totalPages = savedProgress.totalPages
            elapsedTimeBeforeResume = savedProgress.elapsedTimeSoFar ?? 0
        }

        let startTime = Date()

        func fetchPage(_ page: Int) {
            if shouldCancel() {
                print("⛔️ Cancelled before page \(page)")
                return
            }

            let url = "\(baseURL)/plants?token=\(token)&page=\(page)&per_page=20"
            request(urlString: url, decodeAs: TrefleResponse.self) { result in
                switch result {
                case .success(let response):
                    allPlants.append(contentsOf: response.data)

                    if page == startPage, let meta = response.meta {
                        totalCount = meta.total ?? allPlants.count
                    }

                    totalPages = response.meta?.totalPages ?? page
                    let elapsed = Date().timeIntervalSince(startTime)
                    let totalElapsed = elapsed + elapsedTimeBeforeResume

                    progress(allPlants.count, totalCount, page, totalPages, totalElapsed)

                    // ✅ Save partial progress
                    let partialProgress = PlantDownloadProgress(
                        currentPage: page,
                        totalPages: totalPages,
                        totalPlants: totalCount,
                        lastUpdated: Date(),
                        partialPlants: allPlants,
                        elapsedTimeSoFar: totalElapsed
                    )
                    TreflePersistentCacheManager.shared.save(partialProgress, to: "plant_progress.json")

                    // Next page or finish
                    if let _ = response.links?.next {
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            fetchPage(page + 1)
                        }
                    } else {
                        TreflePlantCache.shared.allPlants = allPlants
                        TreflePersistentCacheManager.shared.save(allPlants, to: "plants.json")
                        TreflePersistentCacheManager.shared.clear(filename: "plant_progress.json")
                        completion(.success(allPlants))
                    }

                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }

        fetchPage(currentPage)
    }

       func preloadAllDistributionRegions(delay: TimeInterval = 0.4, progress: @escaping (_ loaded: Int, _ total: Int, _ page: Int, _ totalPages: Int) -> Void, completion: @escaping (Result<[TrefleDistributionRegion], Error>) -> Void) {
           guard let token = getClientToken() else {
               completion(.failure(NSError(domain: "TrefleAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "Client token not available."])))
               return
           }
           var allRegions: [TrefleDistributionRegion] = []
           var totalCount = 1

           func fetchPage(_ page: Int) {
               let url = "\(baseURL)/distributions?token=\(token)&page=\(page)"
               request(urlString: url, decodeAs: TrefleDistributionListResponse.self) { result in
                   switch result {
                   case .success(let response):
                       allRegions.append(contentsOf: response.data)
                       if page == 1, let total = response.meta?.total {
                           totalCount = total
                       }
                       let totalPages = (totalCount + 19) / 20
                       progress(allRegions.count, totalCount, page, totalPages)
                       if let _ = response.links?.next {
                           DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                               fetchPage(page + 1)
                           }
                       } else {
                           completion(.success(allRegions))
                       }
                   case .failure(let error):
                       completion(.failure(error))
                   }
               }
           }

           fetchPage(1)
       }

       func getDistributionDetails(slug: String, completion: @escaping (Result<TrefleDistributionRegionDetails, Error>) -> Void) {
           guard let token = getClientToken() else {
               completion(.failure(NSError(domain: "TrefleAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "Client token not available."])))
               return
           }
           let urlString = "\(baseURL)/distributions/\(slug)?token=\(token)"
           request(urlString: urlString, decodeAs: TrefleSingleDistributionResponse.self) { result in
               completion(result.map { $0.data })
           }
       }

       func getPlantsInRegion(slug: String, page: Int = 1, completion: @escaping (Result<[TreflePlant], Error>) -> Void) {
           guard let token = getClientToken() else {
               completion(.failure(NSError(domain: "TrefleAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "Client token not available."])))
               return
           }
           let urlString = "\(baseURL)/distributions/\(slug)/plants?token=\(token)&page=\(page)&per_page=20"
           request(urlString: urlString, decodeAs: TrefleResponse.self) { result in
               completion(result.map { $0.data })
           }
       }
   }

