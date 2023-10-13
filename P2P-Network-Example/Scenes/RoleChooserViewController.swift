//
//  RoleChooserViewController.swift
//  P2P-Network-Example
//
//  Created by cleanmac on 10/10/23.
//

import UIKit

class RoleChooserViewController: UIViewController {
    
    private var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var browserButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Browser", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.addTarget(self, action: #selector(browserAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var listenerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Listener", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.addTarget(self, action: #selector(listenerAction), for: .touchUpInside)
        return button
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(browserButton)
        buttonStackView.addArrangedSubview(listenerButton)
        
        NSLayoutConstraint.activate([
            buttonStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func browserAction() {
        navigationController?.pushViewController(PeerListViewController(), animated: true)
    }
    
    @objc private func listenerAction() {
        navigationController?.pushViewController(RemoteViewController(), animated: true)
    }
    
}
