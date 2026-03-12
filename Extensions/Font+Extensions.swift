//
//  Font+Extensions.swift
//  CareAssistance
//
//  Created by Lara Dubs on 01/08/2022.
//

import SwiftUI

extension Font {
    fileprivate static var regularFontName: String {
        "FiraSans-Regular"
    }
    
    fileprivate static var mediumFontName: String {
        "FiraSans-Medium"
    }
    
    fileprivate static var semiboldFontName: String {
        "FiraSans-Semibold"
    }

    fileprivate static var boldFontName: String {
        "FiraSans-Bold"
    }
    fileprivate static var italicFontName: String {
        "FiraSans-Italic"
    }
    fileprivate static var tabFontName: String {
        "Roboto-Medium"
    }
    
    static var appHugeTitle: Self {
        Font.custom(boldFontName, size: 100.0)
    }

    static var appLargeTitle: Self {
        Font.custom(boldFontName, size: 40.0)
    }
    
    static var appTitle: Self {
        Font.custom(regularFontName, size: 40.0)
    }
    
    static var appSubtitleBold: Self {
        Font.custom(boldFontName, size: 30.0)
    }
    
    static var appSubtitleBoldForProgramCard: Self {
        Font.custom(boldFontName, size: 20.0)
    }
    
    static var appSubtitle: Self {
        Font.custom(regularFontName, size: 25.0)
    }
    
    static var appSubtitleMedium: Self {
        Font.custom(mediumFontName, size: 25.0)
    }
    
    static var appSubheadRegular: Self {
        Font.custom(regularFontName, size: 20.0)
    }
    
    static var appSubheadMedium: Self {
        Font.custom(mediumFontName, size: 20.0)
    }
    
    static var appSubheadLargeBold: Self {
        Font.custom(boldFontName, size: 20.0)
    }
    
    static var appSubheadBold: Self {
        Font.custom(boldFontName, size: 18.0)
    }
    
    static var appTabTitleBold: Self {
        Font.custom(tabFontName, size: 17.0)
    }

    static var appBody: Self {
        Font.custom(regularFontName, size: 18.0)
    }
    
    static var appBodyCheckbox: Self {
        Font.custom(boldFontName, size: 15.0)
    }
    
    static var appBodyMedium: Self {
        Font.custom(mediumFontName, size: 18.0)
    }
    
    static var appBodyBold: Self {
        Font.custom(boldFontName, size: 18.0)
    }
    
    static var appCallout: Self {
        Font.custom(regularFontName, size: 16.0)
    }
    
    static var appCalloutBold: Self {
        Font.custom(boldFontName, size: 16.0)
    }
    
    static var appCalloutSemibold: Self {
        Font.custom(semiboldFontName, size: 16.0)
    }
    
    static var appSubhead: Self {
        Font.custom(mediumFontName, size: 16.0)
    }
    
    static var appSmallMedium: Self {
        Font.custom(mediumFontName, size: 15.0)
    }
    
    static var appSmallMediumForTasks: Self {
        Font.custom(mediumFontName, size: 14.0)
    }
    
    static var appCaptionLarge: Self {
        Font.custom(regularFontName, size: 14.0)
    }
    
    static var appCaptionMedium: Self {
        Font.custom(mediumFontName, size: 12.0)
    }
    
    static var appCaption: Self {
        Font.custom(regularFontName, size: 12.0)
    }
    
    static var appCaptionSemibold: Self {
        Font.custom(semiboldFontName, size: 12.0)
    }
    static var appMiniCaption: Self {
        Font.custom(regularFontName, size: 10.0)
    }
    static var appMiniCaptionSemibold: Self {
        Font.custom(semiboldFontName, size: 10.0)
    }
}
