import SwiftUI

class ExternalModel: ObservableObject {
    // configuration for LoginView - add ur config
    @Published var loginId: String = "2000000016697" // login id in format like this 2000000004586
    @Published var language: String = "de" // language
    @Published var templateName: String = "s_mobile" // template_name
    
    // result parameter for login View - dont modify
    @Published var response: String = ""
    @Published var userInfo: [ResponseEntry] = [ResponseEntry]()
}
