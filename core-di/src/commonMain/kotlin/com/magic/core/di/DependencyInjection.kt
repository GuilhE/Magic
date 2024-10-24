@file:OptIn(ExperimentalObjCRefinement::class)

package com.magic.core.di

import com.magic.core.database.databaseDiModule
import com.magic.core.network.networkDiModule
import com.magic.data.managers.managersDiModule
import org.koin.core.context.startKoin
import org.koin.dsl.KoinAppDeclaration
import kotlin.experimental.ExperimentalObjCRefinement
import kotlin.native.HiddenFromObjC

object DependencyInjection {
    /**
     * DI engine initialization.
     * This function must be called by the iOS app inside the respective App struct.
     */
    @Suppress("unused")
    fun initKoin(enableNetworkLogs: Boolean) = initKoin(enableNetworkLogs = enableNetworkLogs, appDeclaration = {})

    /**
     * DI engine initialization.
     * This function must be called by the Android app inside the respective Application class.
     */
    @HiddenFromObjC
    fun initKoin(enableNetworkLogs: Boolean = false, appDeclaration: KoinAppDeclaration) {
        startKoin {
            appDeclaration()
            modules(
                networkDiModule("https://api.magicthegathering.io/v1/", enableNetworkLogs),
                databaseDiModule(),
                managersDiModule()
            )
        }
    }
}