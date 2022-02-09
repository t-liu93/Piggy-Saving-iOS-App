//
//  SavingsListView.swift
//  PiggySaving
//
//  Created by Tianyu Liu on 28/01/2022.
//

import SwiftUI

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

struct SavingsListView: View {
    @ObservedObject var configs: ConfigStore
    @StateObject var allSaving: SavingDataStore = SavingDataStore()
    @State var sumSaving: Double = 0.0
    @State var listItemHasChange: Bool = false
    @State private var errorWrapper: [ErrorWrapper] = []
    let displayOptions = ["Saving", "Cost"]
    @State var displayOption = "Saving"
    @State var hasError = false
    
    private func getAllSavingFromServer(sortDesc: Bool) {
        Task {
            do {
                self.allSaving.savings = try await ServerApi.getAllSaving(externalURL: configs.configs.externalURL!)
                self.allSaving.savings = self.allSaving.savings.sorted {
                    if sortDesc {
                        return $0.dateFormatted > $1.dateFormatted
                    } else {
                        return $0.dateFormatted < $1.dateFormatted
                    }
                }
            } catch {
                self.errorWrapper.append(ErrorWrapper(error: error, guidance: NSLocalizedString("Cannot retrieve all savings from server. Please check your network connection and try again later. If you are sure that your network connection is working properly, please contact the developer. You can safely dismiss this page for now.", comment: "Get all saving from server error guidance.")))
            }
        }
    }
    
    private func getAllCostFromServer(sortDesc: Bool) {
        Task {
            do {
                self.allSaving.costs = try await ServerApi.getAllCost(externalURL: configs.configs.externalURL!)
                self.allSaving.costs = self.allSaving.costs.sorted {
                    if sortDesc {
                        return $0.dateFormatted > $1.dateFormatted
                    } else {
                        return $0.dateFormatted < $1.dateFormatted
                    }
                }
            } catch {
                self.errorWrapper.append(ErrorWrapper(error: error, guidance: "Cannot retrieve all costs from server. Please check your network connection and try again later. If you are sure that your network connection is working properly, please contact the developer. You can safely dismiss this page for now."))
            }
        }
    }
    
    private func getSum() {
        Task {
            do {
                self.sumSaving = try await ServerApi.getSum(externalURL: self.configs.configs.externalURL!).sum
            } catch {
                self.errorWrapper.append(ErrorWrapper(error: error, guidance: "Cannot retrieve sum from server. Please check your network connection and try again later. If you are sure that your network connection is working properly, please contact the developer. You can safely dismiss this page for now."))
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SavingListOverviewView(sumSaving: self.sumSaving, totalSaving: allSaving.totalSaving, totalCost: allSaving.totalCost)
            if configs.configs.ableToWithdraw {
                Picker("", selection: $displayOption) {
                    ForEach(displayOptions, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
            }
            List {
                if self.displayOption == "Saving" {
                    ForEach(allSaving.savings) { saving in
                        SavingListItemView(externalURL: $configs.configs.externalURL ?? "", itemUpdated: $listItemHasChange, saving: saving)
                    }
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(allSaving.costs) { cost in
                        CostListItemView(cost: cost)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .zIndex(-1)
            .onChange(of: self.listItemHasChange) { value in
                // TODO: In the future implement a better event
                if value == true {
                    self.getAllSavingFromServer(sortDesc: true)
                    self.getSum()
                    self.listItemHasChange = false
                }
            }
            .onChange(of: self.allSaving.savings) { value in
                self.allSaving.updateFromSelfSavingArray()
            }
            .onChange(of: self.allSaving.costs) { value in
                self.allSaving.updateFromSelfCostArray()
            }
            .onChange(of: self.errorWrapper.count) { value in
                self.hasError = value > 0 ? true : false
            }
            .onAppear {
                // TODO: Ths and condition is a temporary fix for crashing when resetting
                if configs.configs.isInitialized {
                    self.getAllSavingFromServer(sortDesc: true)
                    self.getAllCostFromServer(sortDesc: true)
                    self.getSum()
                }
            }
            .refreshable {
                self.getAllSavingFromServer(sortDesc: true)
                self.getSum()
            }
        }
        .sheet(isPresented: $hasError, onDismiss: {
            self.errorWrapper.removeAll()
            self.hasError = false
        }) {
            ErrorView(errorWrapper: errorWrapper)
        }
        .background(Color.clear)
    }
}

struct SavingsListView_Previews: PreviewProvider {
    static var previews: some View {
        SavingsListView(configs: ConfigStore(), allSaving: SavingDataStore(savings: Saving.sampleData1, cost: Cost.sampleData))
    }
}