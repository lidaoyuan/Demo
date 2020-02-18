//
//  ViewController.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/10.
//  Copyright © 2020 NULL. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import Moya_ObjectMapper
class ViewController: UIViewController {

    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidationOutlet: UILabel!
    
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidationOutlet: UILabel!
    
    @IBOutlet weak var repeatedPasswordOutlet: UITextField!
    @IBOutlet weak var repeatedPasswordValidationOutlet: UILabel!
    @IBOutlet weak var signupOutlet: UIButton!
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame:self.view.frame, style:.plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0,
                                                   width: self.view.bounds.size.width, height: 56))
        return searchBar
    }()
    
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        codeStart()

//        request()
//        douBanList()
        
//        gitHub()
        
        login()
    }

    
    func login() {
        let viewModel = GitHubSignupViewModel(
            input: (
                username: usernameOutlet.rx.text.orEmpty.asDriver(),
                password: passwordOutlet.rx.text.orEmpty.asDriver(),
                repeatedPassword: repeatedPasswordOutlet.rx.text.orEmpty.asDriver(), loginTaps:
                signupOutlet.rx.tap.asSignal()),
            dependency: (
                networkService: GitHubNetworkService(),
                signupService: GitHubSignupService()))
        
        //用户名验证结果绑定
        viewModel.validatedUsername
            .drive(usernameValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        
        //密码验证结果绑定
        viewModel.validatedPassword
            .drive(passwordValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        
        //再次输入密码验证结果绑定
        viewModel.validatedPasswordRepeated
            .drive(repeatedPasswordValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        
        //注册按钮是否可用
        viewModel.signupEnabled.drive(onNext: { [unowned self] (valid) in
            self.signupOutlet.isEnabled = valid
            self.signupOutlet.alpha = valid ? 1.0 : 0.3
            }).disposed(by: disposeBag)
        
        //注册结果绑定
        viewModel.signupResult.drive(onNext: { (result) in
            print("注册" + (result ? "成功" : "失败") + "!")
            }).disposed(by: disposeBag)
    }
    
    func gitHub() {
        self.view.addSubview(tableView)
        tableView.tableHeaderView =  self.searchBar
        
//        let searchAction = searchBar.rx.text.orEmpty
//            .throttle(0.5, scheduler: MainScheduler.instance)
//            .distinctUntilChanged()
//            .asObservable()
        
        let searchAction = searchBar.rx.text.orEmpty.asDriver().throttle(0.5).distinctUntilChanged()
        
        let viewModel = ViewModel(searchAction: searchAction)
        
//        viewModel.navigationTitle.bind(to: self.navigationItem.rx.title).disposed(by: disposeBag)
//
//        viewModel.repositories.bind(to: tableView.rx.items(cellIdentifier: "cell")) { (index, element, cell) in
//            cell.textLabel?.text = element.name
//
//        }.disposed(by: disposeBag)
        
        viewModel.navigationTitle.drive(self.navigationItem.rx.title).disposed(by: disposeBag)
        
        viewModel.repositories.drive(tableView.rx.items(cellIdentifier: "cell")) { (index, element, cell) in
            cell.textLabel?.text = element.name

        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(GitHubRepository.self).subscribe(onNext: { (item) in
            print(item.fullName as Any)
            print(item.description as Any)
            }).disposed(by: disposeBag)
        
    
    }
    
    
    func douBanList() {
        self.view.addSubview(tableView)
        
//        let data = DouBanProvider.rx.request(.channels)
//            .mapObject(Douban.self)
//            .map{ $0.channels ?? [] }
//            .asObservable()
        
        let data = DouBanNetworkService().loadChannels()
        
        
        data.bind(to: tableView.rx.items(cellIdentifier: "cell")) { (index, element, cell) in
            cell.textLabel?.text = element.name
            cell.accessoryType = .disclosureIndicator
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Channel.self)
            .map { $0.channelId! }
            .flatMap {DouBanProvider.rx.request(.playList($0))}.mapObject(Playlist.self)
            .subscribe(onNext: { (playlist) in
                if playlist.song.count > 0 {
                    let artist = playlist.song[0].artist!
                    let title = playlist.song[0].title!
                    let message = "歌手：\(artist)\n歌曲：\(title)"
                    print("歌曲信息：" + message)
                }
                
            }).disposed(by: disposeBag)
    }
    
    
    func request() {
        DouBanProvider.rx.request(.channels)
            .mapObject(Douban.self)
            .subscribe(onSuccess: { (douban) in
//            let str = String(data: resp.data, encoding: String.Encoding.utf8)
//            print("返回的数据是：", str ?? "")
              if let channels = douban.channels {
                  print("--- 共\(channels.count)个频道 ---")
                  for channel in channels {
                      if let name = channel.name, let channelId = channel.channelId {
                          print("\(name) （id:\(channelId)）")
                      }
                  }
              }
                
                
        }) { (error) in
            print("数据请求失败!错误原因：", error)
        }.disposed(by: disposeBag)
    }
    
    //纯代码
    func codeStart() {
        let starview = StarView.init(frame: CGRect.init(x: (UIScreen.main.bounds.width - 320)/2, y: 100, width: 320, height: 100), starCount: 8, currentStar: 0, rateStyle: .half) { (current) -> (Void) in
            print(current)
        }
        self.view.addSubview(starview)
//        let starView = StarRateView(frame: CGRect(x: 0, y: 100, width: 414, height: 100), numberOfStars: 5, currentStarCount: 1.5)
//        starView.userPanEnabled = true
////        starView.isUserInteractionEnabled = false
//        self.view.addSubview(starView)
        
    }
   
}


extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
