//
//  WeatherViewModel.swift
//  EdstemTest
//
//  Created by FARIS CP on 09/12/24.
//

import Foundation
import CoreLocation
import MapKit
class WeatherViewModel: NSObject,ObservableObject,CLLocationManagerDelegate{
    @Published var currentWeather : CurrentWeather?
    @Published var forcastWeather : DaysForecast?
    @Published var forcastList : [ForcastList]? = []
    @Published var isLoading : Bool = false
    @Published var showingAlert : Bool = false
    @Published var locationTitle : String?
    @Published var locationSubTitle : String?
    @Published var locationTemp : Double?
    @Published var annotationItems: [AnnotationItem] = []
    @Published var title : String = ""
    @Published var subTitle : String = ""
    var errorString : String?
    var image : String?
    private let locationManager = CLLocationManager()
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    // MARK: - LocationFetching
    func getCurrentLocation() -> (CGFloat, CGFloat) {
        if let location = locationManager.location {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print("Latitude: \(latitude), Longitude: \(longitude)")
            return (latitude, longitude)
        } else {
            print("Location is not available.")
            return (0.0, 0.0)
        }
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private var onLocationUpdate: ((CLLocation) -> Void)?
    private var onLocationError: ((Error) -> Void)?
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            onLocationUpdate?(location)
            onLocationUpdate = nil
            onLocationError = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onLocationError?(error)
        onLocationUpdate = nil
        onLocationError = nil
    }
    
    enum LocationError: Error {
        case servicesDisabled
        case unauthorized
    }
    
    // MARK: - GetLatitudeAndLongitudeFromselectedPlace
    func getPlace(from address: AddressResult) {
        let request = MKLocalSearch.Request()
        let title = address.title
        let subTitle = address.subtitle
        request.naturalLanguageQuery = subTitle.contains(title)
        ? subTitle : title + ", " + subTitle
        self.title = title
        self.subTitle = subTitle
        Task {
            let response = try await MKLocalSearch(request: request).start()
            await MainActor.run {
                self.annotationItems = response.mapItems.map {
                    AnnotationItem(
                        latitude: $0.placemark.coordinate.latitude,
                        longitude: $0.placemark.coordinate.longitude
                    )
                }
                UserDefaults.standard.set(annotationItems[0].latitude, forKey: "PLACE_LATITUDE")
                UserDefaults.standard.set(annotationItems[0].longitude, forKey: "PLACE_LONGITUDE")
                print("LAT:\(annotationItems[0].latitude) LONG:\(annotationItems[0].longitude) ")
            }
        }
    }
    
    // MARK: - GetCurrentWeatherAPICall
    func getCurrentWeather(){
        isLoading = true
        let (currentLat, currentLong) = getCurrentLocation()
        let latitude = UserDefaults.standard.string(forKey: "PLACE_LATITUDE")
        let longitude = UserDefaults.standard.string(forKey: "PLACE_LONGITUDE")
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude ?? "\(currentLat)")&lon=\(longitude ?? "\(currentLong)")&appid=6f5af6262fdbd0d3a71a4ae5e6551f4e"
        NetworkManager.shared.getData(urlPath: urlString, queryParams: nil, completion: { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    DispatchQueue.main.async { [self] in
                        self.isLoading = false
                        currentWeather = try? decoder.decode(CurrentWeather.self, from: data)
                        locationTitle = self.currentWeather?.name ?? ""
                        locationTemp = self.currentWeather?.main?.temp ?? 0.0
                        if !(self.currentWeather?.cod == 200) {
                                self.showingAlert = true
                        }
                        self.getFiveDayWeather()
                    }
                    
                    if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                       let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                        print(String(decoding: jsonData, as: UTF8.self))
                    } else {
                        print("json data malformed")
                        self.isLoading = false
                        self.showingAlert = true
                    }
                }catch{
                    self.isLoading = false
                    print("error",error.localizedDescription)
                    self.showingAlert = true
                    self.errorString = error.localizedDescription
                }
            case .failure(let error):
                print("error",error.localizedDescription)
                self.isLoading = false
                self.showingAlert = true
                self.errorString = error.localizedDescription
            }
        })
    }
    
    // MARK: - GetForecastWeatherAPICall
    func getFiveDayWeather(){
        let (currentLat, currentLong) = getCurrentLocation()
        isLoading = true
        let latitude = UserDefaults.standard.string(forKey: "PLACE_LATITUDE")
        let longitude = UserDefaults.standard.string(forKey: "PLACE_LONGITUDE")
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude ?? "\(currentLat)")&lon=\(longitude ?? "\(currentLong)")&appid=6f5af6262fdbd0d3a71a4ae5e6551f4e"
        NetworkManager.shared.getData(urlPath: urlString, queryParams: nil, completion: { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.forcastWeather = try? decoder.decode(DaysForecast.self, from: data)
                        self.forcastList?.append(contentsOf: self.forcastWeather?.list ?? [])
                        if self.forcastWeather?.cod != "200" {
                            self.showingAlert = true
                        }
                    }
                    if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                       let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                        print(String(decoding: jsonData, as: UTF8.self))
                    } else {
                        print("json data malformed")
                        self.isLoading = false
                        self.showingAlert = true
                        
                    }
                }catch{
                    self.isLoading = false
                    print("error",error.localizedDescription)
                    self.showingAlert = true
                    self.errorString = error.localizedDescription
                }
            case .failure(let error):
                print("error",error.localizedDescription)
                self.isLoading = false
                self.showingAlert = true
                self.errorString = error.localizedDescription
            }
        })
    }
    // MARK: - SetWeatherImage
    func setForcastImage(weather : String) -> String{
        image = weather ?? ""
        if image == "Clouds"{
            image = "cloudy"
        }else if image == "Snow"{
            image = "snow"
        }else if image == "Rain"{
            image = "rain"
        }else{
            image = "clear-day"
        }
        return image ?? ""
    }
    
    // MARK: - DateFormatChanging
    func dateReFormat(dateString: String) -> String{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "E, h:mm a"
        if let date = dateFormatterGet.date(from: dateString) {
            print(dateFormatterPrint.string(from: date))
            return dateFormatterPrint.string(from: date)
        } else {
            print("There was an error decoding the string")
            return ""
        }
    }
}
