//
//  MainView.swift
//  SpendingTracker
//
//  Created by omar thamri on 12/12/2022.
//

import SwiftUI

struct MainView: View {
    @State private var shouldPresentAddCardForm = false
    var body: some View {
        NavigationView {
            ScrollView {
                TabView {
                    ForEach(0..<3, id: \.self) { num in
                        CreditCardView()
                            .padding(.bottom,50)
                    }
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 280)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                Spacer().fullScreenCover(isPresented: $shouldPresentAddCardForm, onDismiss: nil) {
                    AddCardForm()
                }
                
            }.navigationTitle("Credit Cards")
                .navigationBarItems(trailing: addCardButton)
        }
    }
    
    var addCardButton: some View {
        Button(action: {
            shouldPresentAddCardForm.toggle()
        }, label: {
            Text("+ Card")
                .foregroundColor(.white)
                .font(.system(size: 16 ,weight: .bold))
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .background(Color.black)
                .cornerRadius(5)
        })
    }
}

struct CreditCardView: View {
    var body: some View {
        VStack(alignment: .leading,spacing: 16) {
            Text("Apple Blue Visa Card")
                .font(.system(size: 24,weight: .semibold))
            HStack {
                Image("visa")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 44)
                Spacer()
                Text("Balance: 5,000$")
                    .font(.system(size: 18,weight: .semibold))
            }
            Text("1234 1234 1234 1234")
            Text("Credit Limit: 50,000")
            HStack {Spacer()}
        }
        .foregroundColor(.white)
        .padding()
        .background(LinearGradient(colors: [.blue.opacity(0.6),.blue], startPoint: .center, endPoint: .bottom))
        .overlay(RoundedRectangle(cornerRadius: 8)
            .stroke(.black.opacity(0.5), lineWidth: 1))
        .cornerRadius(8)
        .shadow(radius: 5)
        .padding(.horizontal)
        .padding(.top,8)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}