import SwiftUI
import DocCheckAppLoginSDK

struct LoginView: View {
    @ObservedObject var viewModel: ExternalModel
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    var body: some View {
        DocCheckLoginViewController(controller: [], viewModel: viewModel) {
            self.mode.wrappedValue.dismiss()
        }
    }
}

/* Wrapper to use UIViewController in Swift UI */
struct DocCheckLoginViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = DocCheckLogin
    var controller: [UIViewController] = []
    var dismiss: (() -> Void)?
    var viewModel: ExternalModel
    var docCheckController: DocCheckLogin? = nil
    
    /**
        init(controller: [UIViewController], dismiss: @escaping () -> Void)
        dismiss will be called in the cancel method of the delegate to dismiss this view from the viewstack
     */
    init(controller: [UIViewController], viewModel: ExternalModel, dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
        self.viewModel = viewModel
    }
    
    func makeUIViewController(context: Context) -> DocCheckLogin {
        print("make vc")
        
        
        return context.coordinator.vc
    }
    
    func updateUIViewController(_ uiViewController: DocCheckLogin, context: Context) {
        print("update vc")
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(
            vc: DocCheckLogin(
                with: viewModel.loginId,
                language: viewModel.language,
                templateName: viewModel.templateName
            ),
            viewModel: viewModel,
            dismiss: self.dismiss
        )
    }
    
    class Coordinator: NSObject {
        var dismiss: (() -> Void)?
        var viewModel: ExternalModel
        var vc: DocCheckLogin
        init(vc: DocCheckLogin, viewModel: ExternalModel, dismiss: (() -> Void)?) {
            self.dismiss = dismiss
            self.viewModel = viewModel
            self.vc = vc
            super.init()
            vc.loginSuccesful = docCheckLoginSuccessful
            vc.loginFailed = docCheckLoginFailedWithError(_:)
            vc.loginCanceled = docCheckLoginCanceled
            vc.receivedUserInformations = { userInfo in
                
            }
        }
        
        func docCheckLoginSuccessful() {
            print("login succesful")
            self.viewModel.response =  "login succesful"
            self.dismiss?()
        }
        
        func docCheckLoginFailedWithError(_ error: DocCheckLoginError!) {
            print("login failed")
            self.viewModel.response =  "login failed"
            self.dismiss?()
        }
        
        func docCheckLoginCanceled(){
            print("login canceled")
            self.viewModel.response =  "login canceled"
            self.dismiss?()
        }
        
        func docCheckLoginReceivedUserInfo(_ userInfo: [AnyHashable : Any]? = [:]) {
            guard let userInfo = userInfo else {
                return
            }
            var info = [ResponseEntry]()
            userInfo.forEach { entry in
                info += [ResponseEntry(key: String(describing: entry.key), value: String(describing: entry.value))]
            }
            
            self.viewModel.userInfo = info
        }
    }
}
