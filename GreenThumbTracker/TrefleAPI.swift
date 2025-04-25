//
//  TrefleAPI.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/3/25.
//

import Foundation

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
// MARK: - API Handler
class TrefleAPI {
    static let shared = TrefleAPI()
    private let baseURL = "https://trefle.io/api/v1"
    //private let token = "X2-PP5itzEF85qDb4Xp6O-68S9T49xFK632ZUDZ8N3Y"
    private let token = "jjjzih8UMR2Qvx7zy9aeimsEsVY5j-xVb7qDkmrvKk8"
    private func request<T: Decodable>(urlString: String, decodeAs: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
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
            // 🔍 Log raw response as string
                if let jsonString = String(data: data, encoding: .utf8) {
                     print("📦 JSON from \(urlString):\n\(jsonString)")
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

    func getAllPlants(page: Int, completion: @escaping (Result<[TreflePlant], Error>) -> Void) {
        let urlString = "\(baseURL)/plants?token=\(token)&page=\(page)&per_page=20"
        request(urlString: urlString, decodeAs: TrefleResponse.self) { result in
            completion(result.map { $0.data })
        }
    }

    func getPlantDetails(id: Int, completion: @escaping (Result<TreflePlantDetails, Error>) -> Void) {
        let urlString = "\(baseURL)/plants/\(id)?token=\(token)"
        request(urlString: urlString, decodeAs: SingleTrefleResponse.self) { result in
            completion(result.map { $0.data })
        }
    }


    func getPlantDistributions(slug: String, completion: @escaping (Result<[DistributionRegion], Error>) -> Void) {
        let urlString = "\(baseURL)/plants/\(slug)/distributions?token=\(token)"
        request(urlString: urlString, decodeAs: DistributionResponse.self) { result in
            completion(result.map { $0.data })
        }
    }
    func preloadAllFamilies(
        delay: TimeInterval = 0.3,
        progress: @escaping (_ loaded: Int,_ total: Int,_ page: Int,_ totalPages: Int) -> Void,
           completion: @escaping (Result<[TrefleFamily], Error>) -> Void
       ) {
           var allFamilies: [TrefleFamily] = []
           var totalCount = 1

           func fetchPage(_ page: Int) {
               let url = "\(baseURL)/families?token=\(token)&page=\(page)"
               request(urlString: url, decodeAs: FamilyResponse.self) { result in
                   switch result {
                   case .success(let response):
                       allFamilies.append(contentsOf: response.data)

                       // ✅ Capture total family count from meta
                       if page == 1, let total = response.meta?.total {
                           totalCount = total
                       }

                       // ✅ Get total pages
                       let totalPages = response.meta?.totalPages ?? page

                       // ✅ Report progress: familiesLoaded, totalFamilies, currentPage, totalPages
                       progress(allFamilies.count, totalCount, page, totalPages)

                       // ✅ Check if there's another page
                       if let _ = response.links?.next {
                           DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                               fetchPage(page + 1)
                           }
                       } else {
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
        let urlString = "\(baseURL)/families/\(slug)?token=\(token)"
        request(urlString: urlString, decodeAs: SingleFamilyResponse.self) { result in
            completion(result.map { $0.data })
        }
    }

    func searchPlants(query: String, completion: @escaping (Result<[TreflePlant], Error>) -> Void) {
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

            // Debugging
            if let jsonStr = String(data: data, encoding: .utf8) {
                print("🔍 Raw search response:\n\(jsonStr)")
            }

            // Attempt to decode as normal TrefleResponse
            if let result = try? JSONDecoder().decode(TrefleResponse.self, from: data) {
                completion(.success(result.data))
            } else {
                // Try decoding known error format
                struct TrefleError: Codable {
                    let error: Bool
                    let message: String
                }

                if let apiError = try? JSONDecoder().decode(TrefleError.self, from: data) {
                    completion(.failure(NSError(domain: "Trefle API", code: 500, userInfo: [NSLocalizedDescriptionKey: apiError.message])))
                } else {
                    completion(.failure(NSError(domain: "Decoding", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid or unexpected format."])))
                }
            }
        }.resume()
    }
    func preloadAllPlants(
        delay: TimeInterval = 0.4,
        progress: @escaping (_ loaded: Int, _ total: Int, _ page: Int, _ totalPages: Int) -> Void,
        completion: @escaping (Result<[TreflePlant], Error>) -> Void
    ) {
        var allPlants: [TreflePlant] = []
        var totalCount = 1

        func fetchPage(_ page: Int) {
            let url = "\(baseURL)/plants?token=\(token)&page=\(page)&per_page=20"
            request(urlString: url, decodeAs: TrefleResponse.self) { result in
                switch result {
                case .success(let response):
                    allPlants.append(contentsOf: response.data)

                    if page == 1, let meta = response.meta {
                        totalCount = meta.total ?? allPlants.count
                    }

                    let totalPages = response.meta?.totalPages ?? page
                    progress(allPlants.count, totalCount, page, totalPages)

                    if let next = response.links?.next {
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            fetchPage(page + 1)
                        }
                    } else {
                        completion(.success(allPlants))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }

        fetchPage(1)
    }
    // MARK: - Distributions
    func preloadAllDistributionRegions(
        delay: TimeInterval = 0.4,
          progress: @escaping (_ loaded: Int, _ total: Int, _ page: Int, _ totalPages: Int) -> Void,
          completion: @escaping (Result<[TrefleDistributionRegion], Error>) -> Void
      ) {
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
          let url = "\(baseURL)/distributions/\(slug)?token=\(token)"
          request(urlString: url, decodeAs: TrefleSingleDistributionResponse.self) { result in
              completion(result.map { $0.data })
          }
      }

      func getPlantsInRegion(slug: String, page: Int = 1, completion: @escaping (Result<[TreflePlant], Error>) -> Void) {
          let url = "\(baseURL)/distributions/\(slug)/plants?token=\(token)&page=\(page)&per_page=20"
          request(urlString: url, decodeAs: TrefleResponse.self) { result in
              completion(result.map { $0.data })
          }
      }
    

}
