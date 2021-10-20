//
//  LoginTopHeaderView.swift
//  ThingLog
//
//  Created by hyunsu on 2021/10/19.
//

import UIKit

/// 로그인 화면에 상단에 나타나는 뷰다.  왼쪽에 2열로 보여주는 Label과 우측에 버튼이 있는 Collection HeaderView다.
/// [이미지](https://www.notion.so/LoginTopHeaderView-bb63faf9cb56461b9a06dd4bc345e584)
final class LoginTopHeaderView: UICollectionReusableView {
    let titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = SwiftGenFonts.Pretendard.regular.font(size: 24)
        label.text = "안녕하세요\n띵로그입니다."
        label.numberOfLines = 2
        label.textColor = SwiftGenColors.black.color
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    let laterButton: UIButton = {
        let button: UIButton = UIButton()
        button.titleLabel?.font = UIFont.Pretendard.body1
        button.setTitleColor(SwiftGenColors.black.color, for: .normal)
        button.setTitle("나중에", for: .normal)
        return button
    }()
    
    var leadingEmptyView: UIView = {
        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let stackView: UIStackView = UIStackView(arrangedSubviews: [
                                                    titleLabel,
                                                    leadingEmptyView,
                                                    laterButton])
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let paddingConstraint: CGFloat = 20.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not beem implemented")
    }
    
    private func setupView() {
        backgroundColor = SwiftGenColors.white.color
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: paddingConstraint),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -paddingConstraint),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 0)
        ])
    }
}