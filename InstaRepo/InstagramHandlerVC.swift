import UIKit

class InstagramHandlerVC: BaseViewController {
    
    var instagramApi = InstagramApi.shared
    var testUserData = InstagramTestUser(access_token: "", user_id: 0)
    var instagramUser: InstagramUser?
    var signedIn = false
    
    let stackView = UIStackView()
    var label = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticateUser()
        
    }
    
    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        fetchUserData()
    }
    
    func authenticateUser(){
        if self.testUserData.user_id == 0 {
            presentWebViewController()
        }else{
            print("Errrror......")
        }
    }
    
    func fetchUserData(){
        if self.testUserData.user_id != 0{
            self.instagramApi.getInstagramUser(testUserData: self.testUserData) { [weak self] (user) in
                self?.instagramUser = user
                self?.signedIn = true
                self?.showUserData()
//                DispatchQueue.main.async {
//
//                }
            }
        }
    }
    
    func presentWebViewController() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let webVC = storyBoard.instantiateViewController(withIdentifier: "WebView") as! WebViewController
        webVC.instagramApi = self.instagramApi
        webVC.mainVC = self
        self.present(webVC, animated:true)
    }
    
    func showUserData() {
        print("#################")
        print(".....Happened..... from data")
        print("#################")
        
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 15.0
        label = UILabel(frame:CGRect(x: 100.0, y: 200.0, width: 200.00, height: 60.0))
        label.widthAnchor.constraint(equalToConstant: 150).isActive = true
        label.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        stackView.addArrangedSubview(label)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = self.instagramUser?.username
        self.view.addSubview(label)
        self.view.addSubview(stackView)
        
        //Constraints
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
}
