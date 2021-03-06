//
//  StatsDailyReportView.swift
//  COVID-19 Stats
//
//  Created by Busi Andrea on 24/04/2020.
//  Copyright © 2020 BubiDevs. All rights reserved.
//

import SwiftUI


struct StatsDailyReportView: View {
   @ObservedObject var viewModel: StatsDailyReportViewModel
   @State var searchText: String = ""
   
   // MARK: - Init
   
   init(viewModel: StatsDailyReportViewModel) {
      self.viewModel = viewModel
   }
   
   // MARK: - View
   
   var body: some View {
      NavigationView {
         VStack {
            SearchBar(text: $searchText, placeholder: "Search a country")
            Form {
               filtersSection
               
               if viewModel.isLoadingData {
                  loadingDataSection
               } else if viewModel.dataSource.isEmpty {
                  emptySection
               } else {
                  dailyReportSection
               }
            }
         }
         .navigationBarTitle("Daily Report")
      }
      .navigationViewStyle(DoubleColumnNavigationViewStyle())
      .padding(.leading, leadingPadding)
   }
   
   // MARK: - Private
   
   var filtersSection: some View {
      Section {
         Picker(selection: $viewModel.date, label: Text("Select a date")) {
            ForEach(viewModel.allDates, id: \.self) {
               Text(self.formatted(date: $0)).tag($0)
            }
         }
         
         Picker(selection: $viewModel.sort, label: Text("Select a sorting")) {
            ForEach(viewModel.allSorts, id:\.self) {
               Text("\($0.description)")
            }
         }
      }
   }
   
   var dailyReportSection: some View {
      Section {
         List(filteredDataSource) { row in
            NavigationLink(destination: row.timeSeriesView(with: self.viewModel.statsFetcher)) {
               StatsDailyReportRow(viewModel: row)
            }
         }
      }
   }
   
   var filteredDataSource: [StatsDailyReportRowViewModel] {
      return viewModel.dataSource.filter { (rowViewModel) -> Bool in
         self.searchText.isEmpty
            ? true
            : rowViewModel.title.lowercased().contains(searchText.lowercased())
      }
   }
   
   var emptySection: some View {
      Section {
         VStack {
            HStack {
               Spacer()
               Image(systemName: "tray")
                  .resizable()
                  .frame(width: 40.0, height: 40.0, alignment: .center)
                  .foregroundColor(.gray)
               Spacer()
            }
            HStack {
               Spacer()
               Text("There are no data for the selected date")
                  .multilineTextAlignment(.center)
                  .foregroundColor(.gray)
               Spacer()
            }
         }
         .padding(10)
      }
   }
   
   private var loadingDataSection: some View {
      Section {
         HStack {
            ActivityIndicator(isAnimating: $viewModel.isLoadingData, style: .medium)
            Text("Loading data...")
         }
      }
   }
   
   private func formatted(date: Date) -> String {
      return Constants.displayDateFormatter.string(from: date)
   }
   
   /// This is a workaround to always show master controller on iPad split view
   private var leadingPadding: CGFloat {
      UIDevice.current.userInterfaceIdiom == .pad ? 0.5 : 0.0
   }
}


struct StatsDailyReportView_Previews: PreviewProvider {
   static var previews: some View {
      StatsDailyReportView(viewModel: StatsDailyReportViewModel.preview_viewModel())
   }
}
