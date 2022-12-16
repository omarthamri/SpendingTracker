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
    
    var body: some View {
        VStack {
            Text("Get started by adding your first transaction!")
            Button {
                shouldShowAddTransactionForm.toggle()
            } label: {
                Text("+ Transaction")
                    .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
                    .background(Color(.label))
                    .foregroundColor(Color(.systemBackground))
                    .font(.headline)
            }.fullScreenCover(isPresented: $shouldShowAddTransactionForm) {
                AddTransactionForm(card: self.card)
            }
            ForEach(fetchRequest.wrappedValue) { transaction in
                CardTransactionView(transaction: transaction)
            } 
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
    
        if let photoData = transaction.photoData,let uiImage = UIImage(data: photoData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        }
    }
    .foregroundColor(Color(.label))
        .padding()
        .background(.white)
        .cornerRadius(5)
        .shadow(radius: 5)
        .padding()
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
        ScrollView {
            if let card = firstCard {
            TransactionListView(card: card )
            }
        }
        .environment(\.managedObjectContext, context)
    }
}
