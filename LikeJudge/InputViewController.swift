//
//  InputViewController.swift
//  LikeJudge
//
//  Created by 山口瑞歩 on 2019/09/18.
//  Copyright © 2019 山口瑞歩. All rights reserved.
//

import UIKit

class InputViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate {
    lazy private var upButton: UIButton = SetupObj.button(title: "Upload")
    lazy private var judgeButton: UIButton = SetupObj.button(title: "Judge")
    lazy private var clearButton: UIButton = SetupObj.button(title: "Clear All")

    let text1 = "Please Enter the Most One Appropriate Tag."
    lazy private var descLabel: UILabel = SetupObj.label(title: text1, size: 15)
    let text2 = "Tag Recommended by automatic analysis."
    lazy private var analyzeLabel: UILabel = SetupObj.label(title: text2, size: 15)

    lazy private var tagField: UITextField = createTextField()
    let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))

    lazy private var approTagArea: UITextView = SetupObj.textView()

    lazy private var picArea: UIImageView = SetupObj.imageView()

    var picPicker: UIImagePickerController! = UIImagePickerController()

    var userImageData = "" // UIImage2Base64

    let indicator = Indicator() // Indicator for during judge

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        self.title = "LikeJudge"
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.init(name: "Bradley Hand", size: 30) as Any]

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor.gray

        view.addSubview(upButton)
        view.addSubview(judgeButton)
        view.addSubview(descLabel)
        view.addSubview(tagField)
        view.addSubview(picArea)
        view.addSubview(clearButton)
        view.addSubview(analyzeLabel)
        view.addSubview(approTagArea)

        upButton.addTarget(self, action: #selector(upButtonTapped(sender:)), for: .touchUpInside)
        judgeButton.addTarget(self, action: #selector(judgeButtonTapped(sender:)), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearButtonTapped(sender:)), for: .touchUpInside)
    }

    @objc func upButtonTapped(sender: UIButton) {
        picPicker.sourceType = .photoLibrary
        picPicker.delegate = self
        present(picPicker, animated: true, completion: nil)
    }

    @objc func judgeButtonTapped(sender: UIButton) {
        if !tagField.text!.isEmpty && picArea.image != nil {
            // animation開始
            indicator.show(view: self.view)

            // OutputVCに遷移
            let outputVc: OutputViewController = OutputViewController()

            let judge: Judge = Judge()
            judge.similarityByPython(name: tagField.text!, user_img: userImageData, resultClosure: { (estimate_good) in
                outputVc.text = estimate_good
                outputVc.image = self.picArea.image!

                // animation停止
                self.indicator.hide(view: self.view)
                self.show(outputVc, sender: nil)
            })
        } else {
            showErrorDialog()
        }
    }

    private func showErrorDialog() {
        let text = "Hash tag must need."
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    @objc func clearButtonTapped(sender: UIButton) {
        picArea.image = nil
        tagField.text = nil
        approTagArea.text = nil
    }

    @objc func doneButtonTapped() {
        tagField.endEditing(true)
    }

    private func createTextField() -> UITextField {
        let field = UITextField(frame: CGRect.zero)
        field.layer.borderWidth = 0.5
        field.delegate = self
        field.inputAccessoryView = SetupObj.toolBar(view: self.view, doneBtn: doneBtn)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }

    // start vision API when uploaded user image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            picArea.image = image
            // GoogleCloudVisionで解析する
            let api: VisionAPI = VisionAPI()
            userImageData = api.start(image: image)
            api.getResult({(results) in
                self.showHashTagsByVisionAPI(list: results)
            })
        }
        dismiss(animated: true, completion: nil)
    }

    func showHashTagsByVisionAPI(list: [String]) {
        for i in stride(from: 0, through: list.count-1, by: 1) {
            approTagArea.text += (list[i] + " ")
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureObserver()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObserver()
    }

    // Notification設定
    func configureObserver() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // Notificaiton削除
    func removeObserver() {
        let notification = NotificationCenter.default
        notification.removeObserver(self)
    }

    // Keyboardが出現したら画面を上にずらす
    @objc func keyboardWillShow(notification: Notification?) {
        let rect = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
            self.view.transform = transform
        })
    }

    // Keyboardが消えたら戻す
    @objc func keyboardWillHide(notification: Notification?) {
        let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            self.view.transform = CGAffineTransform.identity
        })
    }

    // Layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.layoutUploadPart()
        self.layoutInputPart()
    }

    // ImageViewとButton
    private func layoutUploadPart() {
        let pos = view.frame.size.height * 0.12 // 親Viewに合わせて位置を決める
        NSLayoutConstraint.activate([
            // ImageView Layout
            picArea.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            picArea.topAnchor.constraint(equalTo: view.topAnchor, constant: pos),
            picArea.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            picArea.heightAnchor.constraint(equalTo: picArea.widthAnchor),
            // Button Layout
            upButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            upButton.topAnchor.constraint(equalTo: picArea.bottomAnchor, constant: 10),
            upButton.widthAnchor.constraint(equalToConstant: 150)
        ])
    }

    // textFieldとButton
    private func layoutInputPart() {
        let pos = view.frame.size.height * 0.1
        NSLayoutConstraint.activate([
            descLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descLabel.topAnchor.constraint(equalTo: upButton.bottomAnchor, constant: 10),
            descLabel.heightAnchor.constraint(equalToConstant: 35),
            tagField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tagField.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 0),
            tagField.widthAnchor.constraint(equalTo: picArea.widthAnchor, multiplier: 0.9),
            tagField.heightAnchor.constraint(equalToConstant: 35),

            judgeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            judgeButton.topAnchor.constraint(equalTo: approTagArea.bottomAnchor, constant:10),
            judgeButton.widthAnchor.constraint(equalToConstant: 150),

            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clearButton.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -pos),
            clearButton.widthAnchor.constraint(equalToConstant: 150),

            analyzeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            analyzeLabel.topAnchor.constraint(equalTo: tagField.bottomAnchor, constant: 0),
            analyzeLabel.heightAnchor.constraint(equalToConstant: 35),

            approTagArea.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            approTagArea.topAnchor.constraint(equalTo: analyzeLabel.bottomAnchor, constant: 0),
            approTagArea.heightAnchor.constraint(equalToConstant: 40),
            approTagArea.widthAnchor.constraint(equalTo: picArea.widthAnchor, multiplier: 0.9),
        ])
    }
}
