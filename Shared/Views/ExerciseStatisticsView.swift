//
//  ExerciseStatisticsView.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/23/22.
//

import SwiftUI

struct ExerciseStatisticsView: View {
    @State var weightliftingNotCardio: Bool = true
    @State var typeSelection: IdentifiableLabel = IdentifiableLabel()
    @State var tagSelection: [IdentifiableLabel] = []
    
    var body: some View {
        Form {
            Button("debug") {print("heeee")}
            Picker("picker", selection: $weightliftingNotCardio) {
                Text("Weightlifting")
                    .tag(true)
                    .onSubmit {
                        print("he")
                    }
                Text("Cardio")
                    .tag(false)
            }
            .pickerStyle(.segmented)
            
            NavigationLink(destination: IdentifiableLabelPickerView(
                selection: $typeSelection,
                getAllFunction: weightliftingNotCardio ? WeightliftingTypeDao.getAll : CardioTypeDao.getAll,
                createFunction: weightliftingNotCardio ? WeightliftingTypeDao.create : CardioTypeDao.create,
                deleteFunction: weightliftingNotCardio ? WeightliftingTypeDao.delete : CardioTypeDao.delete,
                warning: "Type can only be deleted if no workouts depend on it")) {
                    Text("Type")
                }
            
            NavigationLink(destination: IdentifiableLabelMultiSelectionView(
                selection: $tagSelection,
                getAllFunction: weightliftingNotCardio ? WeightliftingTagDao.getAll : CardioTagDao.getAll,
                createFunction: weightliftingNotCardio ? WeightliftingTagDao.create : CardioTagDao.create,
                deleteFunction: weightliftingNotCardio ? WeightliftingTagDao.delete : CardioTagDao.delete,
                warning: "Tag can only be deleted if no workouts depend on it")) {
                    Text("Tags")
                }
            
            
            

        }
    }
}

struct ExerciseStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseStatisticsView()
    }
}
