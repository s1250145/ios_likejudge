//
//  Indicator.swift
//  LikeJudge
//
//  Created by 山口瑞歩 on 2019/10/30.
//  Copyright © 2019 山口瑞歩. All rights reserved.
//

import Foundation
import UIKit

class Indicator {
    var indicatorBackgroundView: UIView!
    var indicator: UIActivityIndicatorView!

    func show(view: UIView) {
        indicatorBackgroundView = UIView(frame: view.bounds)
        indicatorBackgroundView?.backgroundColor = UIColor.black
        indicatorBackgroundView?.alpha = 0.4
        indicatorBackgroundView?.tag = 100100

        indicator = UIActivityIndicatorView()
        indicator?.style = .whiteLarge
        indicator?.center = view.center
        indicator?.color = UIColor.white

        indicator?.hidesWhenStopped = true

        indicatorBackgroundView?.addSubview(indicator!)
        view.addSubview(indicatorBackgroundView!)

        indicator?.startAnimating()
    }

    func hide(view: UIView) {
        if let viewWithTag = view.viewWithTag(100100) {
            viewWithTag.removeFromSuperview()
        }
    }
}
