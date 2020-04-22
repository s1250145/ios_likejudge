//
//  Judge.swift
//  LikeJudge
//
//  Created by 山口瑞歩 on 2019/09/20.
//  Copyright © 2019 山口瑞歩. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

class Judge {
    var headers: [String: String] = [:]
    var parameters: [String: Any] = [:]

    func similarityByPython(name: String, user_img: String, resultClosure: @escaping(String) -> ()) {
        headers = ["Content-Type": "application/json"]
        parameters = [
                "url": user_img,
                "q": name
        ]

        Alamofire.request("https://sunny-studio-254101.appspot.com/graph/getLike",
                          method: .post, parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers).responseString { response in
            switch response.result {
            case .success:
                resultClosure(response.result.value!)
            case .failure(let error):
                print(error)
            }
        }
    }
}
