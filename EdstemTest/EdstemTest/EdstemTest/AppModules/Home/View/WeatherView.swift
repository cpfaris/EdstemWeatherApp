//
//  WeatherView.swift
//  EdstemTest
//
//  Created by FARIS CP on 09/12/24.
//

import SwiftUI

struct WeatherView: View {
    @StateObject var viewModel : WeatherViewModel = WeatherViewModel()
    @State private var searchText: String = ""
    @State private var goToSearchView: Bool = false
    var body: some View {
        ZStack{
            backGroundView
            VStack(spacing:16 ){
                searchView
                    .padding(16)
                    .onTapGesture {
                        goToSearchView.toggle()                    }
                currentWeatherView
                fiveDayForecastView
                Spacer()
            }
            if viewModel.isLoading {
                HStack(spacing: 15) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(2)
                    Text("Loading…")
                }
            }
        }.onAppear(perform: {
            viewModel.requestAuthorization()
            viewModel.getCurrentWeather()
        })
        .alert(isPresented: $viewModel.showingAlert) {
            Alert(title: Text("Alert"), message: Text(viewModel.errorString ?? "Something went wrong!.."), dismissButton: .default(Text("Okay")))
                }
        .sheet(isPresented: $goToSearchView ,onDismiss: {
            viewModel.isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                viewModel.getCurrentWeather()
            }
        }) {
            LocationSearchView(viewModel: ContentViewModel(), mapViewModel: WeatherViewModel(), goToSearchView: $goToSearchView)
        }
    }
}
// MARK: - Extension
extension WeatherView{
    // MARK: - BackGroundView
    var backGroundView: some View{
        LinearGradient(gradient: Gradient(colors:[.blue, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
    // MARK: - SearchView
    var searchView: some View{
        HStack(spacing: 16) {
            Image("search-icon")
                .resizable()
                .frame(width: 18 ,height: 18)
            HStack{
                TextField("Search Location", text: $searchText)
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 0)
        )
    }
    // MARK: - CurrentWeatherView
    var currentWeatherView: some View{
        HStack{
            VStack(alignment: .leading){
                Text(viewModel.locationTitle ?? "")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .font(.system(size: 18))
                    .lineLimit(2)
                Text("\(Int(Double(viewModel.currentWeather?.main?.temp ?? 0.0)/10))°")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .font(.system(size: 50))
                Text(viewModel.currentWeather?.weather?[0].main ?? "")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
                    .lineLimit(2)
                Text("Humidity: \(viewModel.currentWeather?.main?.humidity ?? 0)")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
                    .lineLimit(2)
            }
            Spacer()
            Image("weather-icon")
                .resizable()
                .frame(width: 120 ,height: 120)
            
        }
        .padding(16)
        .frame(height: 130)
    }
    // MARK: - 5DayForcastView
    var fiveDayForecastView: some View {
        VStack {
            HStack {
                Text("5-Day Forecast")
                    .foregroundColor(.white)
                Spacer()
            }.padding(.leading)
            Divider()
                .padding([.leading, .trailing])
            ScrollView{
                ForEach(viewModel.forcastWeather?.list ?? [], id: \.dt) { data in
                    ZStack {
                        HStack {
                            Text(viewModel.dateReFormat(dateString: data.dtTxt ?? ""))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(Int(Double(data.main?.tempMin ?? 0.0)/10 ))°")
                                .foregroundColor(.white)
                                .padding(8)
                            Text("\(Int(Double(data.main?.tempMax ?? 0.0)/10 ))°")
                                .foregroundColor(.white)
                        }.padding([.leading, .trailing])
                        Image(viewModel.setForcastImage(weather: data.weather?[0].main ?? ""))
                            .resizable()
                            .frame(width: 25, height: 25)
                    }
                }.listRowBackground(Color.clear)
            }
        }
    }
}
struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}
