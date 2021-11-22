//
//  PostViewController+DataSource.swift
//  ThingLog
//
//  Created by 이지원 on 2021/11/09.
//

import UIKit

extension PostViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.fetchedResultsController.fetchedObjects?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: PostTableCell = tableView.dequeueReusableCell(withIdentifier: PostTableCell.reuseIdentifier, for: indexPath) as? PostTableCell else {
            return PostTableCell()
        }

        let item: PostEntity = viewModel.fetchedResultsController.object(at: indexPath)
        cell.configure(with: item)

        cell.commentButton.rx.tap
            .bind { [weak self] in
                let viewModel: CommentViewModel = CommentViewModel(postEntity: item)
                self?.coordinator?.showCommentViewController(with: viewModel)
            }.disposed(by: cell.disposeBag)

        cell.commentMoreButton.rx.tap
            .bind { [weak self] in
                let viewModel: CommentViewModel = CommentViewModel(postEntity: item)
                self?.coordinator?.showCommentViewController(with: viewModel)
            }.disposed(by: cell.disposeBag)
        
        return cell
    }
}
