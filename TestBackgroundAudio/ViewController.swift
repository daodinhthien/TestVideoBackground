//
//  ViewController.swift
//  TestBackgroundAudio
//
//  Created by ThienDD9 on 24/4/25.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func actionPlayVideo(_ sender: Any) {
        playLocalVideo()
    }
    
    private func playLocalVideo(isLocal: Bool = true) {
        if isLocal {
            if let path = Bundle.main.path(forResource: "mov", ofType: "MOV") {
                let url = URL(fileURLWithPath: path)
                let vc = VideoPlayerController()
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overFullScreen
                vc.videoURL = url
                self.present(vc, animated: true)
            }
        }
        else {
            if let url = URL(string: "https://www.w3schools.com/html/mov_bbb.mp4") {
                
                // Tạo AVPlayer với URL của video
                let player = AVPlayer(url: url)
                
                // Tạo AVPlayerViewController để phát video
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                
                // Hiển thị video
                self.present(playerViewController, animated: true) {
                    player.play()
                }
            }
        }
    }
}

class VideoPlayerController: UIViewController {

    var player: AVPlayer?
    var playerViewController: AVPlayerViewController!
    var videoURL: URL!
    var playerLayer: AVPlayerLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupVideoPlayer()
        configureAudioSession()
        observeAppState()
    }

    func setupVideoPlayer() {
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)

        player?.play()
    }

    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Lỗi Audio Session: \(error)")
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }

    func observeAppState() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    @objc func appDidEnterBackground() {
        // Không cần làm gì cả!
        // Nếu audio session set đúng thì AVPlayer vẫn tiếp tục chạy
        print("App vào nền → Âm thanh vẫn phát 🎧")
        let currentTime = player?.currentTime().seconds ?? 0
        UserDefaults.standard.set(currentTime, forKey: "lastPlayedTime")
        playerLayer.removeFromSuperlayer()
        
        let seekTime = CMTime(seconds: currentTime, preferredTimescale: 1)
        player = AVPlayer(url: videoURL)
        player?.seek(to: seekTime) { finished in
            if finished {
                self.player?.play()
                       print("▶️ Tiếp tục phát từ \(currentTime) giây")
            }
        }
    }

    @objc func appWillEnterForeground() {
        print("App quay lại → tiếp tục hiển thị video")
        if player != nil {
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = view.bounds
            view.layer.addSublayer(playerLayer)

            player?.play()
        }
    }
}
