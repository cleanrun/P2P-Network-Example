//
//  PeerListViewController.swift
//  P2P-Network-Example
//
//  Created by cleanmac on 05/10/23.
//

import UIKit
import Network
import AVKit

class PeerListViewController: UIViewController {
    
    private lazy var resultTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private var browser: PeerBrowser!
    private var connections: [PeerConnection] = []
    private var peerResults: [NWBrowser.Result] = []
    private var name = "Default"
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .systemBackground
        
        view.addSubview(resultTableView)
        
        NSLayoutConstraint.activate([
            resultTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            resultTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            resultTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            resultTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        resultTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ResultCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        browser = PeerBrowser(delegate: self)
        browser.startBrowsing()
    }
    
    private func createNewConnection(for result: NWBrowser.Result) {
        let newConnection = PeerConnection(endpoint: result.endpoint, interface: result.interfaces.first, delegate: self)
        connections.append(newConnection)
        resultTableView.reloadData()
    }
    
    private func sendVideo(using connection: PeerConnection) {
        if let dataExampleURL = Bundle.main.url(forResource: "data-example", withExtension: "mov"), let dataExample = try? Data(contentsOf: dataExampleURL) {
            autoreleasepool {
                let chunkedData = dataExample.chunked()
                chunkedData.forEach { data in
                    connection.send(type: .videoData, data: data)
                }
            }
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
    
    private func showPeerActionAlert(for connection: PeerConnection) {
        presentedViewController?.dismiss(animated: true)
        
        let alert = UIAlertController(title: "Select action", message: nil, preferredStyle: .actionSheet)
        
        let messageAction = UIAlertAction(title: "Send message", style: .default) { _ in
            connection.send(type: .message, data: "ExampleMessage".data(using: .utf8)!)
        }
        let sendVideoAction = UIAlertAction(title: "Send video", style: .default) { [unowned self] _ in
            //self.sendVideo(using: connection)
        }
        let disconnectAction = UIAlertAction(title: "Disconnect", style: .destructive) { _ in
            connection.send(type: .disconnect, data: "Disconnect".data(using: .utf8)!)
        }
        
        alert.addAction(messageAction)
        alert.addAction(sendVideoAction)
        alert.addAction(disconnectAction)
        
        present(alert, animated: true)
    }

}

extension PeerListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? peerResults.count : connections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Available Peers" : "Connected Peers"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell")!
        
        if indexPath.section == 0 {
            let peerEndpoint = peerResults[indexPath.row].endpoint
            if case let NWEndpoint.service(name: name, type: _, domain: _, interface: _) = peerEndpoint {
                cell.textLabel?.text = name
                cell.textLabel?.textColor = .label
                
                if connections.firstIndex(where: { $0.endpointName == name }) != nil {
                    cell.textLabel?.textColor = .lightGray
                }
            } else {
                cell.textLabel?.text = "Unknown Endpoint"
            }
            
        } else {
            let endpointName = connections[indexPath.row].endpointName ?? "Unrecognized endpoint"
            cell.textLabel?.text = endpointName
            cell.textLabel?.textColor = .label
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let peerEndpoint = peerResults[indexPath.row].endpoint
            if case let NWEndpoint.service(name: name, type: _, domain: _, interface: _) = peerEndpoint {
                if connections.firstIndex(where: { $0.endpointName == name }) == nil {
                    createNewConnection(for: peerResults[indexPath.row])
                }
            }
        } else {
            showPeerActionAlert(for: connections[indexPath.row])
        }
    }
    
}

extension PeerListViewController: PeerBrowserDelegate {
    func didRefreshResults(_ results: Set<NWBrowser.Result>) {
        print("\(#function); results count \(results.count)")
        peerResults = [NWBrowser.Result]()
        for result in results {
            if case let NWEndpoint.service(name: name, type: _, domain: _, interface: _) = result.endpoint {
                if name != self.name {
                    peerResults.append(result)
                }
            }
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.resultTableView.reloadData()
        }
    }
    
    func didReceiveError(_ error: NWError) {
        print(error.localizedDescription)
    }
}

extension PeerListViewController: PeerConnectionDelegate {
    func connectionDidReady(_ connection: PeerConnection) {
        print("\(#function); connections.count \(connections.count)")
        showMessageAlert(title: "Connection established", 
                         message: "Connected to peer: \(connection.endpointName ?? "Unrecognized endpoint")")
    }
    
    func connectionDidFailed(_ connection: PeerConnection, error: NWError) {
        print(#function)
        showMessageAlert(title: "Connection Failed", 
                         message: "Failed to connect to peer: \(connection.endpointName ?? "Unrecognized endpoint")")
    }
    
    func connectionDidCancelled(_ connection: PeerConnection) {
        connections.removeAll(where: { $0.endpointName == connection.endpointName })
        DispatchQueue.main.async { [unowned self] in
            self.resultTableView.reloadData()
        }
        print("\(#function); \(connection.endpointName ?? "nil"); connections.count \(connections.count)")
    }
    
    func didReceiveMessage(_ connection: PeerConnection, content: Data?, message: NWProtocolFramer.Message) {
        print(#function)
    }
    
    func didReceiveError(_ connection: PeerConnection, error: NWError) {}
    
}
