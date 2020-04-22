//
//  SetupObj.swift
//  LikeJudge
//
//  Created by 山口瑞歩 on 2019/10/30.
//  Copyright © 2019 山口瑞歩. All rights reserved.
//

import Foundation
import UIKit

class SetupObj {
    static func label(title: String, size: Int) -> UILabel {
        let label = UILabel(frame: CGRect.zero)
        label.text = title
        label.font = UIFont(name: "Avenir-Book", size: CGFloat(size))
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    static func imageView() -> UIImageView {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 0.4
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    static func button(title: String) -> UIButton {
        let button = UIButton(frame: CGRect.zero)
        button.setTitle(title, for: .normal)
        button.titleLabel!.font = UIFont(name: "Avenir-Heavy", size: 20)
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    static func textView() -> UITextView {
        let view = UITextView(frame: CGRect.zero)
        view.layer.cornerRadius = 5.0
        view.textColor = UIColor(red: 25/255, green: 25/255, blue: 112/255, alpha: 1)
        view.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        view.font = UIFont(name: "Avenir-Book", size: 15)
        view.isSelectable = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func toolBar(view: UIView, doneBtn: UIBarButtonItem) -> UIToolbar {
        let height = view.frame.size.height
        let width = view.frame.size.width
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: height / 6, width: width, height: 40.0))
        toolBar.layer.position = CGPoint(x: height / 6, y: height - 20.0)
        toolBar.barStyle = .blackTranslucent
        toolBar.tintColor = UIColor.white
        toolBar.setItems([doneBtn], animated: true)
        return toolBar
    }
}
