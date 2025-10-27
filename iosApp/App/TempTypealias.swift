import ExportedKotlinPackages

//Until we can use flattenPackage in swiftExport gradle configuration we need this typealias
//https://youtrack.jetbrains.com/issue/KT-81270/K-N-Build-fails-when-exposing-suspend-functions

typealias DependencyInjection = ExportedKotlinPackages.com.magic.core.di.DependencyInjection
typealias KmpInstancesProvider = ExportedKotlinPackages.com.magic.data.managers.KmpInstancesProvider
