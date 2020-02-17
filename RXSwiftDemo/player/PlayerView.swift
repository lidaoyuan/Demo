//
//  PlayerView.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/13.
//  Copyright © 2020 NULL. All rights reserved.
//

import UIKit
import AVKit
import RxCocoa
import RxSwift
class PlayerView: UIView {

    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var url: URL? {
        didSet {
            
        }
    }
    

    lazy var slider : UISlider = { [unowned self] in
        let slider  = UISlider(frame: CGRect(x: 20, y: 300 + 30, width:self.frame.width - 40, height: 20))
        return slider
    }()
    
    lazy var loadTimeLabel : UILabel = { [unowned self] in
        let loadTimeLabel = UILabel(frame: CGRect(x: 20, y: (self.slider.frame.maxY), width: 100, height: 20))
        loadTimeLabel.text = "00:00:00"
        return loadTimeLabel
    }()
    
    lazy var totalTimeLabel : UILabel = { [unowned self] in
        let totalTimeLabel =  UILabel(frame: CGRect(x: self.slider.frame.maxX - 100, y: self.slider.frame.maxY, width: 100, height: 20))
        totalTimeLabel.text = "00:00:00"
        return totalTimeLabel
    }()
    
    lazy var pasueButton : UIButton = { [unowned self] in
        let button = UIButton(frame: CGRect(x: 20, y: 280, width: 60, height: 30))
        button.setTitle("暂停", for: .normal)
        button.setTitle("播放", for: .selected)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.black
        return button
    }()
    let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPlayer()
        self.addSubview(slider)
        self.addSubview(loadTimeLabel)
        self.addSubview(totalTimeLabel)
        self.addSubview(pasueButton)
        
        slider.rx.value.subscribe { (event) in
            self.sliderValueChange(sender: self.slider)
        }.disposed(by: disposeBag)

        pasueButton.rx.tap.subscribe { (event) in
            self.pauseButtonSelected(sender: self.pasueButton)
        }.disposed(by: self.disposeBag)
        
        
    }
    
    
    func setupPlayer() {
        // 创建媒体资源管理对象
        playerItem = AVPlayerItem(url: URL(string: "http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4")!)
        //创建player
        player = AVPlayer(playerItem: playerItem)
        //播放速度 播放前设置
        player.rate = 1.0
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: 300)
        self.layer.addSublayer(playerLayer)
        
        addObserve()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlayerView {
    func addObserve() {

        playerItem.rx.observe(AVPlayerItem.Status.self, "status").subscribe(onNext: { (item) in
            switch item {
                case .readyToPlay:
                    self.play()
                case .failed:
                    print("failed")
                case.unknown:
                    print("unkonwn")
                default:
                    break
            }
        }).disposed(by: disposeBag)
        
        playerItem.rx.observe(Array<NSValue>.self, "loadedTimeRanges").subscribe(onNext: { (item) in
        
            if let loadTimeArray = item {
                // 获取最新缓存的区间
                guard let newTimeRange : CMTimeRange = loadTimeArray.first as? CMTimeRange else { return }
                let startSeconds = CMTimeGetSeconds(newTimeRange.start)
                let durationSeconds = CMTimeGetSeconds(newTimeRange.duration)
                let totalBuffer = startSeconds + durationSeconds //缓冲总长度
                print("当前缓冲时间：%f",totalBuffer)
            }
            
        }).disposed(by: disposeBag)
        
        playerItem.rx.observeWeakly(AVPlayerItem.self, "playbackBufferEmpty").subscribe(onNext: { (item) in
        
        }).disposed(by: disposeBag)
        
        playerItem.rx.observe(AVPlayerItem.self, "playbackLikelyToKeepUp").subscribe(onNext: { (item) in
            self.play()
        }).disposed(by: disposeBag)
        
        player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: DispatchQueue.main) { [weak self] (time) in
            guard let sself = self else { return }
            // 当前正在播放的时间
            let loadTime = CMTimeGetSeconds(time)
            // 视频总时间
            let totalTime = CMTimeGetSeconds((sself.player.currentItem?.duration)!)
            // 滑块进度
            sself.slider.value = Float(loadTime/totalTime)
            sself.loadTimeLabel.text = sself.changeTimeFormat(timeInterval: loadTime)
            sself.totalTimeLabel.text = sself.changeTimeFormat(timeInterval: CMTimeGetSeconds((sself.player.currentItem?.duration)!))
            
        }
        
        
        NotificationCenter.default.rx
            .notification(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { (noti) in
                self.playToEndTime()
            }).disposed(by: disposeBag)
    }
    
    // 播放
    func play() {
        print("播放")
        player.play()
    }
    
    // 暂停
    func pause() {
        player.pause()
    }
    
    //暂停
    @objc func pauseButtonSelected(sender:UIButton)  {
        sender.isSelected = !sender.isSelected
        if sender.isSelected{
            pause()
        }else{
            play()
        }
    }
    
    // 播放进度
    @objc func sliderValueChange(sender:UISlider){
        if player.status == .readyToPlay {
            let time = Float64(sender.value) * CMTimeGetSeconds((player.currentItem?.duration)!)
            let seekTime = CMTimeMake(value: Int64(time), timescale: 1)
            player.seek(to: seekTime)
        }
    }
    
    // 转时间格式
    func changeTimeFormat(timeInterval:TimeInterval) -> String{
        return String(format: "%02d:%02d:%02d",(Int(timeInterval) % 3600) / 60,  Int(timeInterval) / 3600, Int(timeInterval) % 60)
    }
    
    @objc func playToEndTime(){
        print("播放完成")
    }
    
}
