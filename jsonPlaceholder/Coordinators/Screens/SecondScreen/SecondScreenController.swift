import RxCocoa
import RxSwift
import RxSwiftExt

final class SecondScreenController: RxViewController {

    @IBOutlet private weak var lowerBoundTxtFld: UITextField!
    @IBOutlet private weak var upperBoundTxtFld: UITextField!

    @IBOutlet private weak var continueBtn: UIButton!
    
    private let viewModel: SecondScreenViewModelInterface

    init(viewModel: SecondScreenViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: SecondScreenController.identifier, bundle: SecondScreenController.bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    #warning("Localisation is required")
    override func setupViews() {
        lowerBoundTxtFld.keyboardType = .numberPad
        lowerBoundTxtFld.contentHorizontalAlignment = .center

        upperBoundTxtFld.keyboardType = .numberPad
        upperBoundTxtFld.contentHorizontalAlignment = .center

        continueBtn.setTitle("Continue", for: .normal)
    }

    override func setupRxBindings() {
        bindLoader(loadable: viewModel, onCancelled: {
            // TODO:
        })
        bindBounds()
        bindContinueBtn()
    }
}

private extension SecondScreenController {
    func bindBounds() {
        let lowerBoundObs = lowerBoundTxtFld.rx
            .text
            .map { text -> Int? in
                guard let txt = text, let lowerBound = Int(txt) else { return nil }
                return lowerBound
            }

        lowerBoundObs
            .unwrap()
            .bind(to: viewModel.lowerBound)
            .disposed(by: bag)

        let upperBoundObs = upperBoundTxtFld.rx
            .text
            .map { text -> Int? in
                guard let txt = text, let upperBound = Int(txt) else { return nil }
                return upperBound
            }

        upperBoundObs
            .unwrap()
            .bind(to: viewModel.upperBound)
            .disposed(by: bag)

        Observable.combineLatest(lowerBoundObs, upperBoundObs)
            .map { lowerBound, upperBound in
                guard let _ = lowerBound, let _ = upperBound else { return false }
                return true
            }
            .bind(to: continueBtn.rx.isEnabled)
            .disposed(by: bag)
    }

    func bindContinueBtn() {
        continueBtn.rx.tap.bind(to: viewModel.onContinue).disposed(by: bag)
    }
}
