//
//  DeviceIdiomView.swift
//  SpendingTracker
//
//  Created by omar thamri on 18/12/2022.
//

import SwiftUI

struct DeviceIdiomView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            Color.red
        } else {
            if horizontalSizeClass == .compact {
            Color.blue
            } else {
                Color.green
            }
        }
    }
}

struct SeviceIdiomView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceIdiomView()
            .previewInterfaceOrientation(.landscapeLeft)
        DeviceIdiomView()
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
            .environment(\.horizontalSizeClass, .regular)
        DeviceIdiomView()
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
            .environment(\.horizontalSizeClass, .compact)
    }
}
