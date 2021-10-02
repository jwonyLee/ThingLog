//
//  LogoView.swift
//  ThingLog
//
//  Created by hyunsu on 2021/09/30.
//

import UIKit.UILabel

/// NavigationBar에 좌측에 들어가는 Logo를 가지는 Label이다.
final class LogoView: UILabel {
    init(_ title: String) {
        super.init(frame: .zero)
        text = title
        textColor = SwiftGenColors.black.color
        font = UIFont.Pretendard.headline3
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
