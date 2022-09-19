//
//  SettingsView.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/19/22.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var metricWeights: Bool = Config.instance.metricWeights
    @State var metricDistances: Bool = Config.instance.metricDistances
    
    var body: some View {
        Form {
            Button(metricWeights ? "Using metric weights" : "Using imperial weights") {
                metricWeights.toggle()
            }
            Button(metricDistances ? "Using metric distances" : "Using imperial distances") {
                metricDistances.toggle()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    do {
                        let newConfig = Config(metricWeights: metricWeights, metricDistances: metricDistances)
                        try Config.update(config: newConfig)
                        dismiss()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}


