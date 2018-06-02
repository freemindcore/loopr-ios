//
//  AssetTableViewCell.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetTableViewCell: UITableViewCell {

    var asset: Asset?
    
    // TODO: We may deprecate IBOutlet
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconView: IconView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var seperateLine: UIView!
    
    // @IBOutlet weak var forwardImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        theme_backgroundColor = GlobalPicker.backgroundColor
        symbolLabel.setHeaderFont()
        amountLabel.setTitleFont()
        amountLabel.baselineAdjustment = .alignCenters
        balanceLabel.setSubTitleFont()
        balanceLabel.baselineAdjustment = .alignCenters
        seperateLine.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        accessoryType = .disclosureIndicator
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        if let asset = asset {
            if asset.icon != nil {
                iconImageView.image = asset.icon
                iconImageView.isHidden = false
                iconView.isHidden = true
            } else {
                iconView.isHidden = false
                iconView.symbol = asset.symbol
                iconView.symbolLabel.text = asset.symbol
                iconImageView.isHidden = true
            }

            symbolLabel.text = asset.symbol
            // TODO: price unit get from setting
            balanceLabel.text = asset.currency
            amountLabel.text = "\(asset.display) \(asset.symbol)"
        }
    }
    
    class func getCellIdentifier() -> String {
        return "AssetTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 72*UIStyleConfig.scale
    }
}
