@file:OptIn(ExperimentalObjCRefinement::class)

package com.magic.core.di

import com.magic.core.database.databaseDiModule
import com.magic.core.network.networkDiModule
import com.magic.data.managers.CardsManager
import com.magic.data.managers.managersDiModule
import kotlin.experimental.ExperimentalObjCRefinement
import kotlin.native.HiddenFromObjC
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject
import org.koin.core.context.startKoin
import org.koin.dsl.KoinAppDeclaration

object DependencyInjection {
    /**
     * DI engine initialization.
     * This function must be called by the iOS app inside the respective App struct.
     */
    @Suppress("unused")
    fun init(enableNetworkLogs: Boolean) = initKoin(enableNetworkLogs = enableNetworkLogs, appDeclaration = {})

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

internal object KoinHelper : KoinComponent {
	val cardsManager: CardsManager by inject()
}

/**
 * This object is used to provide Koin instances to the iOS app.
 * The functions must be called after the DI engine initialization, otherwise they will fail.
 */
@Suppress("unused")
object KmpInstancesProvider {
	fun cardsManager(): CardsManager = KoinHelper.cardsManager
}