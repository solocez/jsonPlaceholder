import RxCocoa
import RxSwift

final class SecondScreenController: RxViewController {

    @IBOutlet private weak var commentsTbl: UITableView!
    
    private let viewModel: SecondScreenViewModelInterface

    init(viewModel: SecondScreenViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: SecondScreenController.identifier, bundle: SecondScreenController.bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupViews() {
        
    }

    override func setupRxBindings() {
        bindLoader(loadable: viewModel, onCancelled: {
            // TODO:
        })
    }
}

private extension SecondScreenController {
    func setupCommentsTable() {
        let cells: [UITableViewCell.Type] = [
            CommentCell.self
        ]
        cells.forEach(commentsTbl.register)
        commentsTbl.rx.setDataSource(self).disposed(by: bag)
    }
}

// MARK: - UITableViewDataSource
extension SecondScreenController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.commentsNumber
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }
        cell.setup(with: viewModel.viewModelForComment(with: indexPath.row))
        return cell
    }
}
