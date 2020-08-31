//
//  ViewController.swift
//  Beeline
//
//  Created by zip520123 on 28/08/2020.
//  Copyright © 2020 zip520123. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
  let label = UILabel()
  let statusLabel = UILabel()
  let addressLabel = UILabel()
  let topView = UIView()
  let viewModel = DefaultViewModel()
  let askAlwaysAuthorizationButton = UIButton()
  let askDirectionsButton = UIButton()
  let mapView = MKMapView()
  var headingImageView : UIImageView?
  let pinView = UIImageView(image: UIImage(named: "pin"))
  let disposeBag = DisposeBag()
  var destinationString = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    binding()
    setupUI()
    
  }
  
  func setupUI() {
    view.backgroundColor = .white
    
    view.addSubview(topView)
    topView.backgroundColor = .white
    topView.snp.makeConstraints { (make) in
      make.top.left.right.equalToSuperview()
      make.height.equalTo(120)
    }
    
    view.addSubview(mapView)
    view.backgroundColor = .white
    mapView.snp.makeConstraints { (make) in
      make.top.equalTo(topView.snp.bottom)
      make.left.right.bottom.equalToSuperview()
    }
    mapView.showsUserLocation = true
    mapView.isZoomEnabled = true
    mapView.isScrollEnabled = true
    
    mapView.delegate = self
    
    topView.addSubview(label)
    
    label.numberOfLines = 0
    label.snp.makeConstraints { (make) in
      make.leftMargin.equalToSuperview().inset(16)
      make.rightMargin.equalToSuperview().inset(16)
      make.top.equalTo(topView.snp.top).inset(32)
    }
    
    topView.addSubview(statusLabel)
    statusLabel.snp.makeConstraints { (make) in
      make.leftMargin.equalToSuperview().inset(16)
      make.rightMargin.equalToSuperview().inset(16)
      make.top.equalTo(label.snp.bottom)
    }
    
    topView.addSubview(addressLabel)
    addressLabel.font = UIFont.boldSystemFont(ofSize: 20)
    addressLabel.textColor = .blue
    addressLabel.snp.makeConstraints { (make) in
      make.leftMargin.equalToSuperview().inset(16)
      make.rightMargin.equalToSuperview().inset(16)
      make.top.equalTo(statusLabel.snp.bottom).offset(8)
    }
    
    view.addSubview(askAlwaysAuthorizationButton)
    askAlwaysAuthorizationButton.snp.makeConstraints { (make) in
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
      make.height.equalTo(64)
      make.leftMargin.equalToSuperview()
      make.rightMargin.equalToSuperview()
    }
    
    askAlwaysAuthorizationButton.setTitle("Request the location Privacy Authorization", for: .normal)
    askAlwaysAuthorizationButton.setTitleColor(.systemBlue, for: .normal)
    askAlwaysAuthorizationButton.layer.cornerRadius = 5
    askAlwaysAuthorizationButton.layer.borderWidth = 1
    askAlwaysAuthorizationButton.layer.borderColor = UIColor.systemBlue.cgColor
    askAlwaysAuthorizationButton.backgroundColor = .white
    
    view.addSubview(askDirectionsButton)
    askDirectionsButton.snp.makeConstraints { (make) in
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
      make.height.equalTo(64)
      make.leftMargin.equalToSuperview()
      make.rightMargin.equalToSuperview()
    }
    askDirectionsButton.setTitle("Directions", for: .normal)
    askDirectionsButton.setTitleColor(.systemBlue, for: .normal)
    askDirectionsButton.layer.cornerRadius = 5
    askDirectionsButton.layer.borderWidth = 1
    askDirectionsButton.layer.borderColor = UIColor.systemBlue.cgColor
    askDirectionsButton.backgroundColor = .white
    
    
    mapView.addSubview(pinView)
    pinView.snp.makeConstraints { (make) in
      make.height.width.equalTo(24)
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().inset(12)
    }
  }
  
  func binding() {
    askAlwaysAuthorizationButton.rx.tap.bind(to: viewModel.inputs.requestAlwaysAuthorization)
      .disposed(by: disposeBag)
    
    askDirectionsButton.rx.tap.subscribe(onNext: {[weak self] (_) in
      guard let self = self else { return }
      self.viewModel.inputs.requestDirections.accept(self.mapView.centerCoordinate)
    })
      .disposed(by: disposeBag)
    
    viewModel.outputs.authoriztionStatus.drive(onNext: {[weak self] (status) in
      switch status {
      case .authorizedAlways:
        self?.updateText(string: "authorized Always")
      case .authorizedWhenInUse:
        self?.updateText(string: "authorized When In Use")
      case .denied:
        self?.updateText(string: "denied")
      case .notDetermined:
        self?.updateText(string: "notDetermined")
      case .restricted:
        self?.updateText(string: "restricted")
      default:
        self?.updateText(string: "unknow")
      }
      if status == .authorizedAlways || status == .authorizedWhenInUse {
        self?.askAlwaysAuthorizationButton.isHidden = true
        self?.askDirectionsButton.isHidden = false
        self?.label.text = "Please select your destination"
      } else {
        self?.askAlwaysAuthorizationButton.isHidden = false
        self?.askDirectionsButton.isHidden = true
        self?.label.text = "Welcome, please turn on the location Privacy to continue."
      }
    }).disposed(by: disposeBag)
    
    viewModel.outputs.location.asObservable().elementAt(0).subscribe(onNext: {[weak self] (coordinate) in
      let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: CLLocationDistance(floatLiteral: 500), longitudinalMeters: CLLocationDistance(floatLiteral: 500))
      self?.mapView.setRegion(region, animated: true)
      
    }).disposed(by: disposeBag)
    
    viewModel.outputs.heading.drive(onNext: {[weak self] (heading) in
      self?.updateHeadingRotation(heading: heading)
    }).disposed(by: disposeBag)
    
    viewModel.outputs.directions.drive(onNext: {[weak self] (response) in
      guard let self = self else { return }
      self.mapView.removeOverlays(self.mapView.overlays)
      var totalDistance: Double = 0
      var totalTime: Double = 0
      for route in response.routes {
        self.mapView.addOverlay(route.polyline)
        totalDistance += route.distance
        totalTime += route.expectedTravelTime
      }
      totalTime /= 60
      self.label.text = "From current to \(self.destinationString) \n\(totalDistance.rounded()) meters, \(totalTime.rounded()) minutes"
      self.statusLabel.text = ""
    }).disposed(by: disposeBag)
  }
  
  func updateText(string: String) {
    statusLabel.text = "Current status: \(string)"
    
  }
  
  // -- MARK: MapView
  func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
    for view in views {
      if view.annotation is MKUserLocation {
        addHeadingViewToAnnotationView(annotationView: view)
      }
    }
  }
  
  func addHeadingViewToAnnotationView(annotationView: MKAnnotationView) {
    if headingImageView == nil {
      if let image = UIImage(named: "arrow_up_black") {
        let headingImageView = UIImageView()
        headingImageView.image = image
        headingImageView.frame = CGRect(x: (annotationView.frame.size.width - image.size.width*2)/2, y: (annotationView.frame.size.height - image.size.height*2)/2, width: image.size.width*2 , height: image.size.height*2)
        self.headingImageView = headingImageView
      }
    }
    
    headingImageView?.removeFromSuperview()
    if let headingImageView = headingImageView {
      annotationView.addSubview(headingImageView)
    }
    
  }
  
  func updateHeadingRotation(heading: CLHeading) {
    
    if let headingImageView = headingImageView {
      
      headingImageView.isHidden = false
      let head = heading.trueHeading > 0 ? heading.trueHeading : heading.magneticHeading
      
      let rotation = CGFloat(head/180 * Double.pi)
      headingImageView.transform = CGAffineTransform(rotationAngle: rotation)
    }
  }
  
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    pinView.isHidden = true
    let latitude = mapView.centerCoordinate.latitude
    let longitude = mapView.centerCoordinate.longitude
    
    let center = CLLocation(latitude: latitude, longitude: longitude)
    
    let geoCoder = CLGeocoder()
    
    geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
      guard let self = self else { return }
      if let error = error {
        self.addressLabel.text = "error: \(error)"
        return
      }
      guard let placemark = placemarks?.first else { return }
      
      let streetNumber = placemark.subThoroughfare ?? ""
      let streetName = placemark.thoroughfare ?? ""
      
      DispatchQueue.main.async {
        self.addressLabel.text = "\(streetNumber) \(streetName)"
        self.destinationString = "\(streetNumber) \(streetName)"
      }
      
      mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
      
      let annotation = MKPointAnnotation()
      
      annotation.coordinate = mapView.centerCoordinate
      annotation.title = "\(streetNumber) \(streetName)"
      mapView.addAnnotation(annotation)
    }
  }
  
  func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    pinView.isHidden = false
  }
  
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
    renderer.strokeColor = .blue
    renderer.lineWidth = 2
    return renderer
  }
}

