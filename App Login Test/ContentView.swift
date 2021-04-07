import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ExternalModel
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Login ID")
                    TextField("Login ID", text: $viewModel.loginId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
                
                NavigationLink(destination: LoginView(viewModel: viewModel)) {
                    Text("Open LoginView")
                        .fontWeight(.bold)
                        .font(.title)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(40)
                        .foregroundColor(.white)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(Color.red, lineWidth: 5)
                        )
                }
                Text(self.viewModel.response)
                ResponseListView(entries: self.viewModel.userInfo)
                    
            }
            .background(Color.white)
        }
    }
}


#if DEBUG

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ExternalModel())
    }
}

#endif
