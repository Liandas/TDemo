//
//  TopBannerAlert.swift
//  TDemo
//
//  Created by Arda Doğantemur on 2.05.2025.
//


import UIKit

final class TopBannerAlert: UIView {
    private let label = UILabel()

    init(message: String) {
        super.init(frame: .zero)
        backgroundColor = UIColor.systemRed
        label.text = message
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 2
        setupLayout()
    }

    private func setupLayout() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    required init?(coder: NSCoder) { fatalError() }

    func show(in view: UIView, duration: TimeInterval = 3.0) {
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            
            window.addSubview(self)

            let topInset = window.safeAreaInsets.top
            let bannerHeight: CGFloat = topInset + 60

            frame = CGRect(x: 0, y: -bannerHeight, width: window.frame.width, height: bannerHeight)

            UIView.animate(withDuration: 0.3) {
                self.frame.origin.y = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                UIView.animate(withDuration: 0.3, animations: {
                    self.frame.origin.y = -bannerHeight
                }, completion: { _ in
                    self.removeFromSuperview()
                })
            }
        }
    }
}
