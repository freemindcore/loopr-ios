//
//  BuyViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/10/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Geth
import StepSlider
import NotificationBannerSwift

class BuyViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, NumericKeyboardDelegate, NumericKeyboardProtocol, StepSliderDelegate {

    var market: Market!
    
    // container
    @IBOutlet weak var containerView: UIView!
    
    // TokenS
    @IBOutlet weak var tokenSButton: UIButton!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var estimateValueInCurrencyLabel: UILabel!
    @IBOutlet weak var sellTipLabel: UILabel!

    // TokenB
    @IBOutlet weak var tokenBButton: UIButton!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var buyTipLabel: UILabel!
    
    // Slider
    @IBOutlet weak var sliderView: UIView!
    
    // TTL Buttons
    @IBOutlet weak var hourButton: UIButton!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var customButton: UIButton!
    
    // Container
    @IBOutlet weak var canTipLabel: UILabel!
    @IBOutlet weak var canInfoLabel: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    var maxBuy: Double = 0
    
    // Place button
    @IBOutlet weak var nextButton: UIButton!
    
    // Scroll view
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewButtonLayoutConstraint: NSLayoutConstraint!
    
    var blurVisualEffectView = UIView()
    
    // Drag down to close a present view controller.
    var dismissInteractor: MiniToLargeViewInteractive!

    // Numeric keyboard
    var isNumericKeyboardShow: Bool = false
    var numericKeyboardView: DefaultNumericKeyboard!
    var activeTextFieldTag = -1
    var stepSlider: StepSlider = StepSlider()
    
    // Expires
    var buttons: [UIButton] = []
    var intervalValue = 1
    var intervalUnit: Calendar.Component = .hour
    
    // config
    var type: TradeType
    var orderAmount: Double = 0
    var tokenS: String = ""
    var tokenB: String = ""

    convenience init(type: TradeType) {
        self.init(nibName: nil, bundle: nil)
        self.type = type
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        type = .buy
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        // First row: TokenS
        priceTextField.delegate = self
        priceTextField.tag = 0
        priceTextField.inputView = UIView()
        priceTextField.font = FontConfigManager.shared.getDigitalFont()
        priceTextField.theme_tintColor = GlobalPicker.contrastTextColor
        priceTextField.placeholder = LocalizedString("", comment: "")
        priceTextField.setLeftPaddingPoints(40)
        priceTextField.setRightPaddingPoints(60)
        priceTextField.textAlignment = .right
        priceTextField.contentMode = UIViewContentMode.bottom
        
        estimateValueInCurrencyLabel.text = "≈ $0"
        estimateValueInCurrencyLabel.font = FontConfigManager.shared.getMediumFont(size: 12)
        estimateValueInCurrencyLabel.theme_textColor = GlobalPicker.textLightColor
        
        sellTipLabel.theme_textColor = GlobalPicker.textColor
        sellTipLabel.font = FontConfigManager.shared.getMediumFont(size: 16)
        
        // Second row: TokenB
        amountTextField.delegate = self
        amountTextField.tag = 1
        amountTextField.inputView = UIView()
        amountTextField.font = FontConfigManager.shared.getDigitalFont()
        amountTextField.theme_tintColor = GlobalPicker.contrastTextColor
        amountTextField.placeholder = LocalizedString("", comment: "")
        amountTextField.setLeftPaddingPoints(40)
        amountTextField.setRightPaddingPoints(50)
        amountTextField.textAlignment = .right
        amountTextField.contentMode = UIViewContentMode.bottom

        buyTipLabel.theme_textColor = GlobalPicker.textColor
        buyTipLabel.font = FontConfigManager.shared.getMediumFont(size: 16)
        buyTipLabel.text = LocalizedString("Amount", comment: "")
        
        // Slider
        let screenWidth = UIScreen.main.bounds.width
        stepSlider.frame = CGRect(x: 16, y: sliderView.frame.minY, width: screenWidth-64, height: 20)
        stepSlider.delegate = self
        stepSlider.maxCount = 4
        stepSlider.labelFont = FontConfigManager.shared.getMediumFont(size: 12)
        stepSlider.labelColor = UIColor.init(white: 0.6, alpha: 1)
        stepSlider.setIndex(0, animated: false)
        stepSlider.labels = ["0%", "25%", "50%", "75%", "100%"]
        stepSlider.trackHeight = 2
        stepSlider.trackCircleRadius = 3
        stepSlider.trackColor = UIColor.init(white: 0.6, alpha: 1)
        stepSlider.tintColor = UIColor.themeGreen
        stepSlider.sliderCircleRadius = 10
        stepSlider.sliderCircleColor = UIColor.themeGreen
        stepSlider.labelOffset = 10
        stepSlider.isDotsInteractionEnabled = true
        stepSlider.adjustLabel = true
        containerView.addSubview(stepSlider)
        
        // Buttons
        hourButton.round(corners: [.topLeft, .bottomLeft], radius: 8)
        customButton.round(corners: [.topRight, .bottomRight], radius: 8)
        hourButton.title = LocalizedString("1 Hour", comment: "")
        dayButton.title = LocalizedString("1 Day", comment: "")
        monthButton.title = LocalizedString("1 Month", comment: "")
        customButton.title = LocalizedString("Custom", comment: "")
        buttons = [hourButton, dayButton, monthButton, customButton]
        buttons.forEach {
            $0.titleLabel?.font = FontConfigManager.shared.getRegularFont(size: 13)
            $0.theme_setTitleColor(GlobalPicker.textColor, forState: .selected)
            $0.theme_setTitleColor(GlobalPicker.textLightColor, forState: .normal)
        }
        
        // Total
        canTipLabel.font = FontConfigManager.shared.getRegularFont(size: 13)
        canTipLabel.theme_textColor = GlobalPicker.textLightColor
        canTipLabel.text = LocalizedString("Total", comment: "")

        canInfoLabel.setTitleCharFont()
        
        label3.font = FontConfigManager.shared.getRegularFont(size: 13)
        label3.theme_textColor = GlobalPicker.textLightColor
        label3.text = LocalizedString("Can Buy", comment: "")

        label4.setTitleCharFont()
        
        // Place button
        if type == .buy {
            nextButton.title = LocalizedString("Buy", comment: "") + " " + market.tradingPair.tradingA
            nextButton.setupPrimary(height: 44)
        } else {
            nextButton.title = LocalizedString("Sell", comment: "") + " " + market.tradingPair.tradingA
            nextButton.setupSecondary(height: 44)
        }
        
        // Scroll view
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(scrollViewTap)
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: containerView.frame.maxY)
        
        // TODO: This cause wired animation.
        scrollView.delaysContentTouches = false

        self.scrollViewButtonLayoutConstraint.constant = 0
        
        blurVisualEffectView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        blurVisualEffectView.alpha = 1
        blurVisualEffectView.frame = UIScreen.main.bounds
        
        containerView.applyShadow()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        customButton.round(corners: [.topRight, .bottomRight], radius: 8)
    }
    
    func update() {
        var message: String = ""
        if self.type == .buy {
            self.tokenB = PlaceOrderDataManager.shared.tokenA.symbol
            self.tokenS = PlaceOrderDataManager.shared.tokenB.symbol
        } else {
            self.tokenB = PlaceOrderDataManager.shared.tokenB.symbol
            self.tokenS = PlaceOrderDataManager.shared.tokenA.symbol
        }
        
        if type == .buy {
            sellTipLabel.text = LocalizedString("买入价格", comment: "") + "(" + self.tokenS + ")"
        } else {
            sellTipLabel.text = LocalizedString("卖出价格", comment: "") + "(" + self.tokenB + ")"
        }
        
        if let asset = CurrentAppWalletDataManager.shared.getAsset(symbol: tokenS) {
            message = "\(asset.display) \(self.tokenS)"
        } else {
            message = "0.0 \(tokenS)"
        }
        canInfoLabel.text = message
        
        updateMaxBuyValue()
    }
    
    func updateMaxBuyValue() {
        if type == .buy {
            if let value = Double(priceTextField.text!) {
                if value > 0.0 {
                    maxBuy = getBalance() / value
                    label4.text = "\(maxBuy.withCommas()) \(self.tokenB)"
                    return
                }
            }
            label4.text = "-- \(tokenB)"
        } else {
            maxBuy = getBalance()
            if maxBuy > 0.0 {
                let total = (Double(priceTextField.text!) ?? 0) * maxBuy
                label4.text = "\(total.withCommas()) \(self.tokenB)"
            } else {
                label4.text = "-- \(tokenB)"
            }
        }
    }
    
    @objc func scrollViewTapped() {
        print("scrollViewTapped")
        priceTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        hideNumericKeyboard()
    }
    
    @IBAction func pressedUpdatePriceButton(_ sender: Any) {
        print("pressedUpdatePriceButton")
        presentMarketDetailDepthModalViewController()
    }

    @IBAction func pressedUpdateAmountButton(_ sender: Any) {
        print("pressedUpdateAmountButton")
        presentMarketDetailDepthModalViewController()
    }
    
    func presentMarketDetailDepthModalViewController() {
        let nextViewController = MarketDetailDepthModalViewController()
        nextViewController.market = market
        nextViewController.delegate = self
        nextViewController.transitioningDelegate = self
        nextViewController.modalPresentationStyle = .overFullScreen
        
        // presentInteractor = MiniToLargeViewInteractive()
        // presentInteractor.attachToViewController(viewController: self, withView: view, presentViewController: nextViewController)
        
        dismissInteractor = MiniToLargeViewInteractive()
        dismissInteractor.attachToViewController(viewController: nextViewController, withView: nextViewController.view, presentViewController: nil, backgroundView: blurVisualEffectView)
        
        self.present(nextViewController, animated: true) {
            
        }
        
        self.navigationController?.view.addSubview(self.blurVisualEffectView)
        UIView.animate(withDuration: 0.3, animations: {
            self.blurVisualEffectView.alpha = 1.0
        }, completion: {(_) in
            
        })
    }

    @IBAction func pressedExpiresButton(_ sender: UIButton) {
        let dict: [Int: Calendar.Component] = [0: .hour, 1: .day, 2: .month]
        for (index, button) in buttons.enumerated() {
            button.titleLabel?.font = FontConfigManager.shared.getRegularFont(size: 13)
            button.theme_setTitleColor(GlobalPicker.textLightColor, forState: .normal)
            if button == sender {
                if index < 3 {
                    self.intervalValue = 1
                    self.intervalUnit = dict[index]!
                } else if index == 3 {
                    self.present()
                }
            }
            button.isSelected = false
        }
        sender.isSelected = true
        sender.titleLabel?.font = FontConfigManager.shared.getBoldFont()
    }
    
    func present() {
        self.hideNumericKeyboard()
        let parentView = self.parent!.view!
        parentView.alpha = 0.25
        let vc = TTLViewController()
        vc.dismissClosure = {
            parentView.alpha = 1
            self.intervalUnit = vc.intervalUnit
            self.intervalValue = vc.intervalValue
        }
        vc.parentNavController = self.navigationController
        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.present(vc, animated: true, completion: nil)
    }
    
    func stepSliderValueChanged(_ value: Double) {
        var message: String = ""
        let length = Asset.getLength(of: tokenS) ?? 4
        let title = LocalizedString("Available Balance", comment: "")
        if let asset = CurrentAppWalletDataManager.shared.getAsset(symbol: tokenS) {
            message = "\(title) \(asset.display) \(tokenS)"
            amountTextField.text = String((maxBuy * value)).trailingZero()
        } else {
            message = "\(title) 0.0 \(tokenS)"
            amountTextField.text = "0.0"
        }
        activeTextFieldTag = amountTextField.tag
    }

    // To avoid gesture conflicts in swiping to back and UISlider
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != nil && touch.view!.isKind(of: StepSlider.self) {
            return false
        }
        return true
    }

    func getBalance() -> Double {
        if let asset = CurrentAppWalletDataManager.shared.getAsset(symbol: tokenS) {
            return asset.balance
        }
        return 0
    }
    
    func constructOrder() -> OriginalOrder? {
        var buyNoMoreThanAmountB: Bool
        var side, tokenSell, tokenBuy: String
        var amountBuy, amountSell, lrcFee: Double
        if self.type == .buy {
            side = "buy"
            tokenBuy = PlaceOrderDataManager.shared.tokenA.symbol
            tokenSell = PlaceOrderDataManager.shared.tokenB.symbol
            buyNoMoreThanAmountB = true
            amountBuy = Double(amountTextField.text!)!
            amountSell = self.orderAmount
        } else {
            side = "sell"
            tokenBuy = PlaceOrderDataManager.shared.tokenB.symbol
            tokenSell = PlaceOrderDataManager.shared.tokenA.symbol
            buyNoMoreThanAmountB = false
            amountBuy = self.orderAmount
            amountSell = Double(amountTextField.text!)!
        }

        lrcFee = getLrcFee(amountSell, tokenSell)
        let delegate = RelayAPIConfiguration.delegateAddress
        let address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address
        let since = Int64(Date().timeIntervalSince1970)
        let until = Int64(Calendar.current.date(byAdding: intervalUnit, value: intervalValue, to: Date())!.timeIntervalSince1970)
        var order = OriginalOrder(delegate: delegate, address: address, side: side, tokenS: tokenSell, tokenB: tokenBuy, validSince: since, validUntil: until, amountBuy: amountBuy, amountSell: amountSell, lrcFee: lrcFee, buyNoMoreThanAmountB: buyNoMoreThanAmountB)
        PlaceOrderDataManager.shared.completeOrder(&order)
        return order
    }

    @IBAction func pressedPlaceOrderButton(_ sender: Any) {
        print("pressedPlaceOrderButton")
        
        if !validate() {
            return
        }
        
        hideNumericKeyboard()
        priceTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        
        let isAmountValid = validateAmount()
        if isAmountValid {
            self.pushController()
        }
    }

    func pushController() {
        if let order = constructOrder() {
            let parentView = self.parent!.view!
            parentView.alpha = 0.25
            let viewController = PlaceOrderConfirmationViewController()
            viewController.order = order
            viewController.dismissClosure = { parentView.alpha = 1 }
            viewController.parentNavController = self.navigationController
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    func validateTokenPrice() -> Bool {
        if let value = Double(priceTextField.text ?? "0") {
            if value > 0.0 {
                return true
            }
        }
        let notificationTitle = LocalizedString("请输入单价", comment: "")
        let banner = NotificationBanner.generate(title: notificationTitle, style: .danger)
        banner.duration = 1
        banner.show()
        return false
    }

    func validateAmount() -> Bool {
        /*
        if let value = Double(amountTextField.text ?? "0") {
            if value > 0.0 {
                return true
            }
        }
        let notificationTitle = LocalizedString("请输入数量", comment: "")
        let banner = NotificationBanner.generate(title: notificationTitle, style: .danger)
        banner.duration = 1
        banner.show()
        return false
        */
        if let value = Double(amountTextField.text ?? "0") {
            let validate = value <= maxBuy
            if !validate {
                let notificationTitle = LocalizedString("余额不足", comment: "")
                let banner = NotificationBanner.generate(title: notificationTitle, style: .danger)
                banner.duration = 1
                banner.show()
            }
            return validate
        } else {
            return false
        }
    }

    func validate() -> Bool {
        guard validateTokenPrice() && validateAmount()else {
            return false
        }

        var total, amount: Double
        total = Double(priceTextField.text!)! * Double(amountTextField.text!)!
        amount = total
        self.orderAmount = amount

        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")
        activeTextFieldTag = textField.tag
        showNumericKeyboard(textField: textField)
        return true
    }
    
    func getActiveTextField() -> UITextField? {
        if activeTextFieldTag == priceTextField.tag {
            return priceTextField
        } else if activeTextFieldTag == amountTextField.tag {
            return amountTextField
        } else {
            return nil
        }
    }
    
    func showNumericKeyboard(textField: UITextField) {
        if !isNumericKeyboardShow {
            let width = self.view.frame.width
            let height = self.view.frame.height

            scrollViewButtonLayoutConstraint.constant = DefaultNumericKeyboard.height
            
            numericKeyboardView = DefaultNumericKeyboard(frame: CGRect(x: 0, y: height, width: width, height: DefaultNumericKeyboard.height))
            numericKeyboardView.delegate = self
            view.addSubview(numericKeyboardView)
            
            let destinateY = height - DefaultNumericKeyboard.height
            
            // TODO: improve the animation.
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.numericKeyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: DefaultNumericKeyboard.height)
            }, completion: { finished in
                self.isNumericKeyboardShow = true
            })
        }
    }
    
    func hideNumericKeyboard() {
        if isNumericKeyboardShow {
            let width = self.view.frame.width
            let height = self.view.frame.height
            let destinateY = height
            self.scrollViewButtonLayoutConstraint.constant = 0
            // TODO: improve the animation.
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                // animation for layout constraint change.
                self.view.layoutIfNeeded()
                self.numericKeyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: DefaultNumericKeyboard.height)
            }, completion: { finished in
                self.isNumericKeyboardShow = false
                if finished {
                }
            })
        } else {
            self.scrollView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
    func numericKeyboard(_ numericKeyboard: NumericKeyboard, itemTapped item: NumericKeyboardItem, atPosition position: Position) {
        print("pressed keyboard: (\(position.row), \(position.column))")
        let activeTextField = getActiveTextField()
        guard activeTextField != nil else {
            return
        }
        var currentText = activeTextField!.text ?? ""
        switch (position.row, position.column) {
        case (3, 0):
            if !currentText.contains(".") {
                currentText += "."
                // TODO: add a shake animation to the item at (3, 0)
            }
            activeTextField!.text = currentText
        case (3, 1):
            activeTextField!.text = currentText + "0"
        case (3, 2):
            if currentText.count > 0 {
                currentText = String(currentText.dropLast())
            }
            activeTextField!.text = currentText
        default:
            let itemValue = position.row * 3 + position.column + 1
            activeTextField!.text = currentText + String(itemValue)
        }
        
        // TODO: need to handle the wired value
        let tokenBPrice = PriceDataManager.shared.getPrice(of: self.tokenB)!
        let estimateValue: Double = (Double(priceTextField.text!) ?? 0) * tokenBPrice
        estimateValueInCurrencyLabel.text = "≈ \(estimateValue.currency)"
        
        updateMaxBuyValue()
    }

    func numericKeyboard(_ numericKeyboard: NumericKeyboard, itemLongPressed item: NumericKeyboardItem, atPosition position: Position) {
        print("Long pressed keyboard: (\(position.row), \(position.column))")
        
        let activeTextField = getActiveTextField()
        guard activeTextField != nil else {
            return
        }
        var currentText = activeTextField!.text ?? ""
        if (position.row, position.column) == (3, 2) {
            if currentText.count > 0 {
                currentText = String(currentText.dropLast())
            }
            activeTextField!.text = currentText
        }
    }
}

extension BuyViewController: UIViewControllerTransitioningDelegate {

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = MiniToLargeViewAnimator()
        animator.initialY = 0
        animator.transitionType = .Dismiss
        return animator
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // guard !disableInteractivePlayerTransitioning else { return nil }
        return dismissInteractor
    }

}

extension BuyViewController: MarketDetailDepthModalViewControllerDelegate {
    
    func dismissedMarketDetailDepthModalViewController() {
        UIView.animate(withDuration: 0.1, animations: {
            self.blurVisualEffectView.alpha = 0.0
        }, completion: {(_) in
            self.blurVisualEffectView.removeFromSuperview()
        })
    }

    func dismissWithSelectedDepth(amount: String, price: String) {
        amountTextField.text = amount.trailingZero()
        priceTextField.text = price.trailingZero()
        
        let tokenBPrice = PriceDataManager.shared.getPrice(of: self.tokenB)!
        let estimateValue: Double = (Double(priceTextField.text!) ?? 0) * tokenBPrice
        estimateValueInCurrencyLabel.text = "≈ \(estimateValue.currency)"
        
        updateMaxBuyValue()

        var percentage = Float((Double(amount) ?? 0.0) / maxBuy)
        print(percentage)
        if percentage > 1 {
            percentage = 1
            // Get the max value.
            amountTextField.text = String(maxBuy).trailingZero()
        }
        stepSlider.setPercentageValue(percentage)
        
        UIView.animate(withDuration: 0.1, animations: {
            self.blurVisualEffectView.alpha = 0.0
        }, completion: {(_) in
            self.blurVisualEffectView.removeFromSuperview()
        })
    }

}

extension BuyViewController {
    
    func getLrcFee(_ amountS: Double, _ tokenS: String) -> Double {
        var result: Double = 0
        let pair = tokenS + "/LRC"
        let ratio = SettingDataManager.shared.getLrcFeeRatio()
        if let market = MarketDataManager.shared.getMarket(byTradingPair: pair) {
            result = market.balance * amountS * ratio
        } else if let price = PriceDataManager.shared.getPrice(of: tokenS),
            let lrcPrice = PriceDataManager.shared.getPrice(of: "LRC") {
            result = price * amountS * ratio / lrcPrice
        }
        let minLrc = GasDataManager.shared.getGasAmount(by: "lrcFee", in: "LRC") / 2
        return max(result, minLrc)
    }
}
