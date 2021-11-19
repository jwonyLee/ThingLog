//
//  PostViewController.swift
//  ThingLog
//
//  Created by 이지원 on 2021/11/09.
//

import UIKit

/// 게시물을 표시하는 뷰 컨트롤러
final class PostViewController: BaseViewController {
    // MARK: - View Properties
    let tableView: UITableView = {
        let tableView: UITableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }()

    // MARK: - Properties
    var coordinator: Coordinator?
    private(set) var viewModel: PostViewModel

    init(viewModel: PostViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let startIndexPath: IndexPath = IndexPath(row: viewModel.startIndexPath.row, section: 0)
        tableView.scrollToRow(at: startIndexPath, at: .top, animated: false)
    }

    // MARK: - Setup
    override func setupNavigationBar() {
        setupBaseNavigationBar()

        let logoView: LogoView = LogoView("게시물")
        navigationItem.titleView = logoView

        let backButton: UIButton = UIButton()
        backButton.setImage(SwiftGenIcons.longArrowR.image, for: .normal)
        backButton.tintColor = SwiftGenColors.primaryBlack.color
        backButton.rx.tap
            .bind { [weak self] in
                self?.coordinator?.back()
            }
            .disposed(by: disposeBag)
        let backBarButton: UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButton
    }

    override func setupView() {
        setupTableView()
    }
}