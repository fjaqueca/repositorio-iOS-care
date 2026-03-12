//
//  EducationalMaterialUIState.swift
//  CareAssistance
//
//  Created by The App Master on 01/09/2025.
//


import Foundation

struct EducationalMaterialUIState{
    var materialList = MaterialListUIState()
    var materialDetail = MaterialDetailUIState()
}

struct MaterialListUIState{
    var title = GreetingUIState()
    var colorBackArrow = ""
    var listText = GreetingUIState()
    var placeholderSearch = GreetingUIState()
    var colorSearch = ColorSearchBarUIState()
    var itemNames = GreetingUIState()
    var btnFavorite = ColorFavoriteBtn()
    var borderItem = ""
}
struct MaterialDetailUIState{
    var title = GreetingUIState()
    var description = GreetingUIState()
    var atrItems = GreetingUIState()
    var btnDownload = BtnActionMaterial()
    var btnShare = BtnActionMaterial()
    var artButtonAction = GreetingUIState()
}

struct ColorSearchBarUIState{
    var backgrountColor = ""
    var iconColor = ""
}
struct ColorFavoriteBtn{
    var active = ""
    var inActive = ""
}
struct BtnActionMaterial{
    var name = ""
    var show = ""
}
struct AtrBtnActionMaterial{
    var color = ""
    var size = ""
    var font = ""
    var alignment = ""
    var colorIcon = ""
    var colorBorderBtn = ""
}
