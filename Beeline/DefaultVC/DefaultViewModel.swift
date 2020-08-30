import Foundation
import RxSwift
import RxCocoa


final class DefaultViewModel {

  struct DefaultViewModelInputs {

  }

  struct DefaultViewModelOutputs {

  }

  var inputs: DefaultViewModelInputs
  var outputs: DefaultViewModelOutputs

  let disposeBag = DisposeBag()

  init() {


    inputs = DefaultViewModelInputs()
    outputs = DefaultViewModelOutputs()
  }

}
