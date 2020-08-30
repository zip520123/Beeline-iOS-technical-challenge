import Foundation
import RxSwift
import RxCocoa
import CoreLocation

final class DefaultViewModel {

  struct DefaultViewModelInputs {
    let requestAlwaysAuthorization: PublishRelay<Void>
    let requestDirections: PublishRelay<Void>
  }

  struct DefaultViewModelOutputs {
    let authoriztionStatus: Driver<CLAuthorizationStatus>
    let location: Driver<CLLocationCoordinate2D>
    let heading: Driver<CLHeading>
  }

  var inputs: DefaultViewModelInputs
  var outputs: DefaultViewModelOutputs

  private let locationManager = CLLocationManager()
  
  let disposeBag = DisposeBag()

  init() {
    let requestAlwaysAuthorization = PublishRelay<Void>()
    let requestDirections = PublishRelay<Void>()
    requestAlwaysAuthorization.subscribe(onNext: {[weak locationManager] (_) in
      locationManager?.requestAlwaysAuthorization()
      
    }).disposed(by: disposeBag)
    
    locationManager.startUpdatingLocation()
    locationManager.startUpdatingHeading()
    
    
    
    let authoriztionStatus = Observable.deferred { [weak locationManager] in
      let status = CLLocationManager.authorizationStatus()
      guard let locationManager = locationManager else {
        return Observable.just(status)
      }
      return locationManager
        .rx.didChangeAuthorizationStatus
        .startWith(status)
    }
    .asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined)

    let location = locationManager.rx.didUpdateLocations
      .asDriver(onErrorJustReturn: [])
      .flatMap {
        return $0.last.map(Driver.just) ?? Driver.empty()
    }
    .map { $0.coordinate }
    
    requestDirections.withLatestFrom(location).subscribe(onNext: { (coordinate) in
      
    }).disposed(by: disposeBag)
    
    let heading = locationManager.rx.didUpdateHeading.asDriver(onErrorJustReturn: CLHeading())
    
    inputs = DefaultViewModelInputs(requestAlwaysAuthorization: requestAlwaysAuthorization, requestDirections: requestDirections)
    outputs = DefaultViewModelOutputs(authoriztionStatus: authoriztionStatus, location: location, heading: heading)
  }

}
