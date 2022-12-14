import RxCocoa
import RxSwift
import RxSwiftExt

final class FirstScreenController: RxViewController, KeyboardDismissableOnTap {

    @IBOutlet private weak var lowerBoundLbl: UILabel!
    @IBOutlet private weak var lowerBoundTxtFld: UITextField!
    @IBOutlet private weak var upperBoundLbl: UILabel!
    @IBOutlet private weak var upperBoundTxtFld: UITextField!
    @IBOutlet private weak var helpLbl: UILabel!
    

    @IBOutlet private weak var continueBtn: UIButton!

    private let viewModel: FirstScreenViewModelInterface

    init(viewModel: FirstScreenViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: FirstScreenController.identifier, bundle: FirstScreenController.bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    #warning("Localisation is required")
    override func setupViews() {
        hideKeyboardWhenTappedAround(bag: bag)

        lowerBoundLbl.text = "Lower Bound:"
        upperBoundLbl.text = "Upper Bound:"

        lowerBoundTxtFld.keyboardType = .numberPad
        lowerBoundTxtFld.contentHorizontalAlignment = .center

        upperBoundTxtFld.keyboardType = .numberPad
        upperBoundTxtFld.contentHorizontalAlignment = .center

        helpLbl.font = UIFont.italicSystemFont(ofSize: 12)
        helpLbl.textAlignment = .center

        continueBtn.setTitle("Continue", for: .normal)
    }

    override func setupRxBindings() {
        bindLoader(loadable: viewModel, onCancelled: { [unowned self] in
            self.viewModel.onCancel.onNext(Void())
        })
        bindBounds()
        bindContinueBtn()
    }
}

private extension FirstScreenController {
    #warning("Localisation is required")
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

        viewModel.maxComments
            .map { "Enter bounds from 1 to \($0)" }
            .bind(to: helpLbl.rx.text)
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
