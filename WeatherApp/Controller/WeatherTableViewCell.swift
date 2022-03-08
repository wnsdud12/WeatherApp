//
//  WeatherTableViewCell.swift
//  WeatherApp
//
//  Created by sumwb on 2022/02/21.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblTMP: UILabel!
    @IBOutlet weak var imgSKY: UIImageView!
    @IBOutlet weak var lblSKY: UILabel!
    @IBOutlet weak var lblPOP: UILabel!
    @IBOutlet weak var lblPCP: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
