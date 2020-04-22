//
//  OutputViewController.swift
//  LikeJudge
//
//  Created by 山口瑞歩 on 2019/09/18.
//  Copyright © 2019 山口瑞歩. All rights reserved.
//

import UIKit

class OutputViewController: UIViewController {
    var text: String! // From inputVC
    var image: UIImage!

    var resultLabel: UILabel!

    lazy private var shareButton = SetupObj.button(title: "Share Instagram")

    lazy private var picArea: UIImageView = SetupObj.imageView()

    var controller: UIDocumentInteractionController! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        self.title = "Result"
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.init(name: "Bradley Hand", size: 30) as Any]

        resultLabel = SetupObj.label(title: text, size: 20)
        picArea.image = image

        shareButton.addTarget(self, action: #selector(shareButtonTapped(sender:)), for: .touchUpInside)

        view.addSubview(picArea)
        view.addSubview(resultLabel)
        view.addSubview(shareButton)
    }

    @objc func shareButtonTapped(sender: UIButton) {
        let data = picArea.image?.pngData()
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("photo.png")
        do {
            try data?.write(to: url!)
            controller = UIDocumentInteractionController.init(url: url!)
            controller!.uti = "public.jpeg"
            controller.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
        } catch {
            print("error")
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.layoutViews()
    }

    private func layoutViews() {
        let pos = view.frame.size.height * 0.12
        NSLayoutConstraint.activate([
            picArea.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            picArea.topAnchor.constraint(equalTo: view.topAnchor, constant: pos),
            picArea.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            picArea.heightAnchor.constraint(equalTo: picArea.widthAnchor),
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultLabel.topAnchor.constraint(equalTo: picArea.bottomAnchor, constant: 10),
            resultLabel.heightAnchor.constraint(equalToConstant: 35),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 30),
            shareButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
}
