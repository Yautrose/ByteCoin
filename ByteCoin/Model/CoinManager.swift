import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoin(_ coinManager: CoinManager, coin: Double?)
    func didFailWithError(error: Error)
}


struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "0F30819D-5E5A-4915-9146-96504FD1E992"
    var delegate: CoinManagerDelegate?
    
    
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
        
    func fetchCurrency(currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performReques(with: urlString)
    }
    
    func performReques(with urlString: String) {
        // 1. Create a URL
        if let url = URL(string: urlString) {
            // 2. Create a URL session.
            let session = URLSession(configuration: .default)
            // 3. Give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    return
                }
                if let safeData = data {
                    if let bitcoinPrice = parseJSON(currencyData: safeData) {
                        delegate?.didUpdateCoin(self, coin: bitcoinPrice)
                    }
                }
            }
            // 4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(currencyData: Data) -> Double?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: currencyData)
            return decodedData.rate
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
