import Foundation

// pretty print json data
extension Data {
    var prettyJson: String? {
        guard
            let obj = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]),
            let prettyPrintedString = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        
        return prettyPrintedString
    }
}
