//
//  TransactionListView.swift
//  SpendingTracker
//
//  Created by omar thamri on 16/12/2022.
//

import SwiftUI

struct TransactionListView: View {
    
    let card: Card
    
    init(card: Card) {
        self.card = card 
        fetchRequest = FetchRequest<CardTransaction>(entity: CardTransaction.entity(), sortDescriptors: [
            .init(key: "timestamp", ascending: false)
        ], predicate: .init(format: "card == %@",self.card))
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    var fetchRequest: FetchRequest<CardTransaction>
/*    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CardTransaction.timestamp, ascending: false)],
        animation: .default)
    private var transactions: FetchedResults<CardTransaction>*/
    @State private var shouldShowAddTransactionForm = false
    @State private var shouldShowFilterSheet = false
    
    var body: some View {
        VStack {
            if fetchRequest.wrappedValue.isEmpty {
                Text("Get started by adding your first transaction!")
                Button {
                    shouldShowAddTransactionForm.toggle()
                } label: {
                    Text("+ Transaction")
                        .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
                        .background(Color(.label))
                        .foregroundColor(Color(.systemBackground))
                        .font(.headline)
                }
            } else {
                HStack {
                    Spacer()
                    addTransactionButton
                    filterButton
                        .sheet(isPresented: $shouldShowFilterSheet) {
                            FilerSheet(selectedCategories: self.selectedCategories){ categories in
                                self.selectedCategories = categories
                            }
                        }
                }
                .padding(.horizontal)
                ForEach(filterTransactions(selectedCategories: self.selectedCategories)) { transaction in
                    CardTransactionView(transaction: transaction)
                }
            }
        }.fullScreenCover(isPresented: $shouldShowAddTransactionForm) {
            AddTransactionForm(card: self.card)
        }
    }
    
    @State var selectedCategories = Set<TransactionCategory>()
    
    private func filterTransactions(selectedCategories:Set<TransactionCategory>) -> [CardTransaction] {
        if selectedCategories.isEmpty {
            return Array(fetchRequest.wrappedValue)
        }
        return fetchRequest.wrappedValue.filter { transaction in
            var shouldKeep = false
            if let categories = transaction.categories as? Set<TransactionCategory> {
                categories.forEach({ category in
                    if selectedCategories.contains(category) {
                        shouldKeep = true
                    }
                })
            }
            
            return shouldKeep
        }
    }
    
    private var filterButton: some View {
        Button {
            shouldShowFilterSheet.toggle()
        } label: {
            HStack {
                Image(systemName: "line.horizontal.3.decrease.circle")
                Text("Filter")
            }
                .foregroundColor(Color(.systemBackground))
                .padding(.vertical,6)
                .padding(.horizontal,8)
                .background(Color(.label))
                .font(.system(size: 16,weight: .semibold))
                .cornerRadius(5)
        }

    }
    
    private var addTransactionButton: some View {
        Button {
            shouldShowAddTransactionForm.toggle()
        } label: {
            Text("+ Transaction")
                .foregroundColor(Color(.systemBackground))
                .padding(.vertical,6)
                .padding(.horizontal,8)
                .background(Color(.label))
                .font(.system(size: 16,weight: .semibold))
                .cornerRadius(5)
        }

    }
    
}

struct CardTransactionView: View {
    
    private let dateFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    private func handleDelete() {
        withAnimation {
            let context = PersistenceController.shared.container.viewContext
            context.delete(transaction)
            do {
                try context.save()
            } catch {
                print("failed to delete transaction",error)
            }
        }
    }
    
    let transaction: CardTransaction
    @State var shouldPresentActionSheet = false
    var body: some View {
    VStack {
        HStack {
            VStack(alignment: .leading) {
            Text(transaction.name ?? "")
                    .font(.headline)
                if let date = transaction.timestamp {
                    Text(dateFormatter.string(from: date))
                }
                
            }
            Spacer()
            VStack(alignment: .trailing) {
                Button {
                    shouldPresentActionSheet.toggle()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 24))
                }
                .padding(EdgeInsets(top: 6, leading: 8, bottom: 4, trailing: 0))
                .actionSheet(isPresented: $shouldPresentActionSheet) {
                    .init(title: Text(transaction.name ?? ""), message: nil, buttons: [.destructive(Text("Delete"), action: handleDelete),.cancel()])
                }
                Text(String(format: "$%.2f", transaction.amount))
                
            }
            
            
        }
        if let categories = transaction.categories as? Set<TransactionCategory>{
            let sortedByTimestampCategories = Array(categories).sorted(by: {$0.timestamp?.compare($1.timestamp ?? Date()) == .orderedDescending})
                HStack {
                    ForEach(sortedByTimestampCategories) { category in
                    if let data = category.colorData,let uicolor = UIColor.color(data: data) {
                        let color = Color(uicolor)
                        Text(category.name ?? "")
                            .font(.system(size: 16,weight:.semibold))
                            .padding(.vertical,6)
                            .padding(.horizontal,8)
                            .background(color)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                
                }
                    Spacer()
            }
        }
    
        if let photoData = transaction.photoData,let uiImage = UIImage(data: photoData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        }
    }
    .foregroundColor(Color(.label))
        .padding()
        //.background(colorScheme == .dark ? Color.gray : Color.white)
        .background(Color.CardTransactionBackground)
        .cornerRadius(5)
        .shadow(radius: 5)
        .padding()
    }
    @Environment(\.colorScheme) var colorScheme
}

struct FilerSheet: View {
    @State var selectedCategories: Set<TransactionCategory>
    let didSaveFilters: (Set<TransactionCategory>) -> ()
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.timestamp, ascending: false)],
        animation: .default)
    private var categories: FetchedResults<TransactionCategory>
   // @State var selectedCategories = Set<TransactionCategory>()
    
    var body: some View {
        NavigationView {
            Form {
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
            }.navigationTitle("Select filters")
                .navigationBarItems(trailing: saveButton)
        }
    }
    @Environment(\.presentationMode) var presentationMode
    
    var saveButton: some View {
        Button {
            didSaveFilters(selectedCategories)
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Save")
        }

    }
    
    
}



struct TransactionListView_Previews: PreviewProvider {
    
    static let firstCard: Card? = {
        let context = PersistenceController.shared.container.viewContext
        let request = Card.fetchRequest()
        request.sortDescriptors = [.init(key: "timestamp", ascending: false)]
        return try? context.fetch(request).first
    }()
    
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        NavigationView {
        ScrollView {
            if let card = firstCard {
            TransactionListView(card: card )
            }
        }
        }
        .colorScheme(.dark)
        .environment(\.managedObjectContext, context)
    }
}
