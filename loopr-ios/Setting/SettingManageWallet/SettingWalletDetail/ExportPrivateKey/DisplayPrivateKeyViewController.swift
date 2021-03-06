//
//  DisplayPrivateKeyViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/7/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class DisplayPrivateKeyViewController: UIViewController {

    var navigationTitle = LocalizedString("Export Private Key", comment: "")
    var copyButtonTitle = LocalizedString("Copy Private Key", comment: "")
    var bannerMessage = LocalizedString("Copy private key to clipboard successfully!", comment: "")
    var displayValue: String = ""
    
    var hideCopyButton: Bool = false

    @IBOutlet weak var privateKeyTextView: UITextView!
    @IBOutlet weak var copyButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = navigationTitle
        setBackButton()
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        privateKeyTextView.contentInset = UIEdgeInsets.init(top: 17, left: 20, bottom: 15, right: 20)
        privateKeyTextView.cornerRadius = 6
        privateKeyTextView.font = FontConfigManager.shared.getRegularFont(size: 14)
        privateKeyTextView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        privateKeyTextView.theme_textColor = GlobalPicker.textColor
        privateKeyTextView.isEditable = false
        // privateKeyTextView.isScrollEnabled = false
        
        privateKeyTextView.text = displayValue
        
        copyButton.title = copyButtonTitle
        copyButton.setupSecondary(height: 44)
        copyButton.isHidden = hideCopyButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        privateKeyTextView.applyShadow()
    }

    @IBAction func pressedCopyButton(_ sender: Any) {
        print("pressedCopyButton")
        UIPasteboard.general.string = displayValue
        let banner = NotificationBanner.generate(title: bannerMessage, style: .success)
        banner.duration = 1
        banner.show()
    }
    
}
