import Foundation
import SwiftUI

// simple key value struct for one entry
struct ResponseEntry: Identifiable {
    let id = UUID()
    let key: String
    let value: String?
    
    func valueOrEmpty() -> String {
        guard let result = value else {
            return ""
        }
        return result
    }
}


// a view that shows one entry
struct ResponseEntryView: View {
    var entry: ResponseEntry
    
    var body: some View {
        HStack {
            Text("\(entry.key):")
            Text("\(entry.valueOrEmpty())")
        }
        .background(Color.white)
    }
}

// a simple wrapper for the list View
struct ResponseListView: View {
    var entries: [ResponseEntry]
    
    init(entries: [ResponseEntry]) {
        self.entries = entries
        UITableView.appearance().backgroundColor = .white
    }
    
    var body: some View {
        List(entries) { entry in
            ResponseEntryView(entry: entry)
        }
    }
}

#if DEBUG
struct ResponseListView_Previews: PreviewProvider {
    static var previews: some View {
        ResponseListView(entries: [
            ResponseEntry(key: "Test", value: "Testing"),
            ResponseEntry(key: "Test2", value: nil)
        ])
    }
}
#endif
