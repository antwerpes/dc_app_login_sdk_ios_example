import Foundation

/// NSURLSession synchronous behavior
/// Particularly for playground sessions that need to run sequentially
public extension URLSession {
    
    /// Return data from synchronous URL request
    static func requestSynchronousData(_ request: URLRequest) -> Data? {
        var data: Data? = nil
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            taskData, _, error -> () in
            data = taskData
            if data == nil, let error = error {print(error)}
            semaphore.signal();
        })
        task.resume()
        semaphore.wait(timeout: DispatchTime.now() + .seconds(5))
        return data
    }
    
    /// Return data synchronous from specified endpoint
    static func requestSynchronousDataWithURLString(requestString: String) -> Data? {
        guard let url = URL(string: requestString) else {
            return nil
            
        }
        let request = URLRequest(url: url)
        return URLSession.requestSynchronousData(request)
    }
}
