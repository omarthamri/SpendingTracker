//
//  CategoriesListView.swift
//  SpendingTracker
//
//  Created by omar thamri on 17/12/2022.
//

import SwiftUI


struct CategoriesListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.timestamp, ascending: false)],
        animation: .default)
    private var categories: FetchedResults<TransactionCategory>
    @State private var name = ""
    @State private var color = Color.red
    @Binding var selectedCategories: Set<TransactionCategory>
    var body: some View {
        Form {
            Section(header: Text("Select a category")) {
                ForEach(categories) { category in
                    Button {
                        if selectedCategories.contains(category) {
                            selectedCategories.remove(category)
                        } else {
                            selectedCategories.insert(category)
                        }
                        
                    } label: {
                        HStack(spacing: 12) {
                            if let data = category.colorData,let uicolor = UIColor.color(data: data) {
                                let color = Color(uicolor)
                                Spacer()
                                    .frame(width: 30, height: 10)
                                    .background(color)
                            }
                            Text(category.name ?? "")
                                .foregroundColor(Color(.label))
                            Spacer()
                            if selectedCategories.contains(category) {
                            Image(systemName: "checkmark")
                            }
                        }
                    }
                    
                }
                .onDelete { indexSet in
                    indexSet.forEach { i in
                        viewContext.delete(categories[i])
                    }
                    try? viewContext.save()
                }
            }
            Section(header: Text("Create a category")) {
                TextField("name", text: $name)
                ColorPicker("Color", selection: $color)
                Button {
                    handleCreate()
                } label: {
                    
                    HStack {
                        Spacer()
                        Text("Create")
                        Spacer()
                    }
                    .padding(.vertical,8)
                    .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }.buttonStyle(.plain)

            }
        }
    }

private func handleCreate() {
    let context = PersistenceController.shared.container.viewContext
    let category = TransactionCategory(context: context)
    category.name = self.name
    category.colorData = UIColor(color).encode()
    category.timestamp = Date()
    do {
        try context.save()
        self.name = ""
    } catch {
        print(error)
    }
}
}

struct CategoriesListView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesListView(selectedCategories: .constant(Set<TransactionCategory>()))
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
