//
//  LocationSearchView.swift
//  EdstemTest
//
//  Created by FARIS CP on 10/12/24.
//

import SwiftUI
import MapKit
struct LocationSearchView: View {
    @StateObject var viewModel: ContentViewModel
    @StateObject var mapViewModel: WeatherViewModel
    @FocusState private var isFocusedTextField: Bool
    @Binding var goToSearchView : Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack{
                Image("search-icon")
                    .padding(.leading,16)
                    .padding(.top,16)
                    .padding(.bottom,16)
                TextField("Search for locality or landmark", text: $viewModel.searchableText)
                    .font(
                        Font.custom("", size: 16)
                            .weight(.medium)
                    )
                    .focused($isFocusedTextField)
                    .font(.title)
                    .onReceive(
                        viewModel.$searchableText.debounce(
                            for: .seconds(1),
                            scheduler: DispatchQueue.main
                        )
                    ) {
                        viewModel.searchAddress($0)
                    }
                    .background(Color.white)
                    .onAppear {
                        isFocusedTextField = true
                    }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0.87, green: 0.89, blue: 0.9), lineWidth: 1)
            )
            .padding(16)
            if self.viewModel.results.count == 0{
                noPlaceRow()
                Spacer()
            }else{
                List(self.viewModel.results) { address in
                    
                    getAddressRow(address: address)
                        .listRowBackground(backgroundColor)
                        .onTapGesture {
                            debugPrint(address)
                            DispatchQueue.main.async {
                                mapViewModel.getPlace(from: address)
                                goToSearchView.toggle()
                            }
                        }
                }
                .listStyle(.plain)
            }
        }
        .background(backgroundColor)
        .edgesIgnoringSafeArea(.bottom)
    }
}

var backgroundColor: Color = Color.white
extension LocationSearchView{
    func getAddressRow(address:AddressResult ) -> some View {
        VStack(alignment: .leading) {
            Text(address.title)
            Text(address.subtitle)
                .font(.caption)
        }
        .padding(.bottom, 2)
    }
    func noPlaceRow() -> some View {
        HStack {
            Spacer()
            Text("No place found!...")
            Spacer()
        }
        .padding(.bottom, 2)
    }
}
struct LocationSearchView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchView(viewModel: ContentViewModel(), mapViewModel: WeatherViewModel(), goToSearchView: .constant(false))
    }
}
