//
//  RemoteViewController.swift
//  P2P-Network-Example
//
//  Created by cleanmac on 06/10/23.
//

import UIKit
import Network
import AVKit

class RemoteViewController: UIViewController {
    private var listener: PeerListener!
    private var connection: PeerConnection?
    
    private var dateFormatter: DateFormatter!
    private var dataChunks: [Data] = []
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Play", style: .plain, target: self, action: #selector(playAction))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupListener()
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy :: HH:mm:ss.SSS"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        connection?.stopConnection()
        listener.stopListening()
    }
    
    private func setupListener() {
        do {
            listener = PeerListener(name: UUID().uuidString, delegate: self)
            try listener.setupListener()
            listener.startListening { [unowned self] connection in
                self.connection = PeerConnection(connection: connection, delegate: self)
            }
        } catch {
            return
        }
    }
    
    private func showMessageAlert(title: String, message: String) {
        DispatchQueue.main.async { [unowned self] in
            self.presentedViewController?.dismiss(animated: true)
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
    
    @objc private func playAction() {
        guard !dataChunks.isEmpty else { return }
        
        var combinedData = Data()
        
        dataChunks.forEach { data in
            combinedData.append(data)
        }
        
        let tempFile = TemporaryMediaFile(withData: combinedData)
        if let asset = tempFile.avAsset {
            let player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
            let playerVC = AVPlayerViewController()
            playerVC.player = player
            present(playerVC, animated: true) {
                player.play()
            }
        }
    }

}

extension RemoteViewController: PeerConnectionDelegate {
    func connectionDidReady(_ connection: PeerConnection) {
        print(#function)
        showMessageAlert(title: "Connection established", message: "Connected to host: \(connection.endpointName ?? "Unrecognized endpoint")")
    }
    
    func connectionDidFailed(_ connection: PeerConnection, error: NWError) {
        print("\(#function); \(error.localizedDescription)")
        showMessageAlert(title: "Connection Failed", message: "Failed to connect to host: \(connection.endpointName ?? "Unrecognized endpoint")")
    }
    
    func didReceiveMessage(_ connection: PeerConnection, content: Data?, message: NWProtocolFramer.Message) {
        print("\(#function); Date received \(dateFormatter.string(from: Date()))")
        let type = message.peerMessageType
        
        switch type {
        case .invalid:
            break
        case .message:
            guard let content else { break }
            showMessageAlert(title: "Received message", message: "Data: \(String(decoding: content, as: UTF8.self))")
        case .videoData:
            if let content {
                dataChunks.append(content)
                print("dataChunks.count \(dataChunks.count)")
            }
        case .disconnect:
            break
        }
    }
    
    func connectionDidCancelled(_ connection: PeerConnection) {
        print("\(#function); \(connection.endpointName ?? "nil")")
    }
    
    func didReceiveError(_ connection: PeerConnection, error: NWError) {
        print(#function)
    }
    
}

extension RemoteViewController: PeerListenerDelegate {
    func listenerDidReady(_ listener: NWListener) {}
    func listenerDidFailed(_ error: NWError) {}
    func listenerDidCancelled() {}
}
