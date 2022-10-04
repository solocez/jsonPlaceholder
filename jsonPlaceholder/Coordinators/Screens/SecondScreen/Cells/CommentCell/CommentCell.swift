import RxCocoa
import RxSwift

final class CommentCell: RxTableViewCell {
    
    private var viewModel: CommentCellViewModelInterface!
    
    func setup(with viewModel: CommentCellViewModelInterface) {
        self.viewModel = viewModel
        setupViews()
        setupRxBindings()
    }
}

extension CommentCell {
    func setupViews() {

    }

    func setupRxBindings() {
    }
}
