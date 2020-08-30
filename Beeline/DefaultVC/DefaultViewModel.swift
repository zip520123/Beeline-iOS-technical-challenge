import Foundation
import RxSwift
import RxCocoa
import CoreLocation
import MapKit

final class DefaultViewModel {
  
  struct DefaultViewModelInputs {
    let requestAlwaysAuthorization: PublishRelay<Void>
    let requestDirections: PublishRelay<CLLocationCoordinate2D>
  }
  
  struct DefaultViewModelOutputs {
    let authoriztionStatus: Driver<CLAuthorizationStatus>
    let location: Driver<CLLocationCoordinate2D>
    let heading: Driver<CLHeading>
    let directions: Driver<MKDirections.Response>
  }
  
  var inputs: DefaultViewModelInputs
  var outputs: DefaultViewModelOutputs
  
  private let locationManager = CLLocationManager()
  
  let disposeBag = DisposeBag()
  
  init() {
    let requestAlwaysAuthorization = PublishRelay<Void>()
    let requestDirections = PublishRelay<CLLocationCoordinate2D>()
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
    
    let directions = requestDirections.withLatestFrom(location) { ($0, $1) }
      .flatMap { (startCoordinate, destinationCoordinate) -> Observable<MKDirections.Response> in
        
        let startingLocaiton = MKPlacemark(coordinate: startCoordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocaiton)
        request.destination = MKMapItem(placemark: destination)
        
        let directions = MKDirections(request: request)
        
        let observable = Observable<MKDirections.Response>.create { (observer) in
          
          directions.calculate { (response, error) in
            if response != nil {
              observer.onNext(response!)
              observer.onCompleted()
            }
          }
          
          return Disposables.create{
            directions.cancel()
          }
        }
        
        return observable
    }.asDriverOnErrorJustIgnored()
    
    let heading = locationManager.rx.didUpdateHeading.asDriver(onErrorJustReturn: CLHeading())
    
    inputs = DefaultViewModelInputs(requestAlwaysAuthorization: requestAlwaysAuthorization, requestDirections: requestDirections)
    outputs = DefaultViewModelOutputs(authoriztionStatus: authoriztionStatus, location: location, heading: heading, directions: directions)
  }
  
}
