import Foundation
import RxSwift
import RxCocoa


final class AppDelegateViewModel {

  struct AppDelegateViewModelInputs {

  }

  struct AppDelegateViewModelOutputs {

  }

  var inputs: AppDelegateViewModelInputs
  var outputs: AppDelegateViewModelOutputs

  let disposeBag = DisposeBag()

  init() {


    inputs = AppDelegateViewModelInputs()
    outputs = AppDelegateViewModelOutputs()
  }

}
