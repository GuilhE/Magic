import ExportedKotlinPackages

//Until we can use flattenPackage in swiftExport gradle configuration we need this helper class
//https://youtrack.jetbrains.com/issue/KT-81270/K-N-Build-fails-when-exposing-suspend-functions

typealias CardsManager = ExportedKotlinPackages.com.magic.data.managers.CardsManager
typealias Card = ExportedKotlinPackages.com.magic.data.models.local.Card
typealias CardSet = ExportedKotlinPackages.com.magic.data.models.local.CardSet
