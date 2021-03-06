//
//  NowWeatherView.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/03/24.
//

import UIKit

class NowWeatherView: UIView {

    @IBOutlet weak var lblNowT1H: UILabel!
    @IBOutlet weak var lblNowRN1: UILabel!
    @IBOutlet weak var imgNowPTY: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    func initialize() {
        if let view = Bundle.main.loadNibNamed("NowWeatherView", owner: self)?.first as? UIView {
            view.frame = self.bounds
            addSubview(view)
        }

    }
}
