//
//  VisionAPI.swift
//  LikeJudge
//
//  Created by 山口瑞歩 on 2019/09/25.
//  Copyright © 2019 山口瑞歩. All rights reserved.
//

// アップロードした画像の解析を行う
// ハッシュタグの提案をする

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

class VisionAPI {
    var API_KEY = "AIzaSyA8pH3Fgk0EL3qb0UCDXTGWJruVj4iij_E"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(API_KEY)")!
    }
    var headers: HTTPHeaders = [:]
    var parameters: [String: [String: Any]] = [:]

    var results: [String] = []

    func start(image: UIImage) -> String {
        let imgData = base64EncodeImage(image)
        createRequest(with: imgData)
        return imgData
    }

    func getResult(_ after: @escaping([String]) -> ()) {
        Alamofire.request(googleURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                let json = JSON(response.result.value ?? kill)
                let responses: JSON = json["responses"][0]
                let objectAnnotations: JSON = responses["localizedObjectAnnotations"]
                for i in stride(from: 0, to: objectAnnotations.count, by: 1) {
                    self.results.append("#" + objectAnnotations[i]["name"].stringValue)
                }
                after(self.results)

            case .failure(let error):
                print(error)
            }
        }
    }

    func createRequest(with imageBase64: String) {
        headers = ["Content-Type": "application/json", "X-Ios-Bundle-Identifier": Bundle.main.bundleIdentifier ?? ""]
        parameters = [
            "requests": [
                "image": ["content": imageBase64],
                "features": [
                    [
                        "type": "OBJECT_LOCALIZATION",
                        "maxResults": 20
                    ]
                ]
            ]
        ]
    }

    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = image.pngData()
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata!.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }

    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = newImage!.pngData()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}
