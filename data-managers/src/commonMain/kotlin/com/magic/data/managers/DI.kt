package com.magic.data.managers

import org.koin.core.component.KoinComponent
import org.koin.core.component.get
import org.koin.core.module.Module
import org.koin.dsl.module
import kotlin.experimental.ExperimentalObjCRefinement
import kotlin.native.HiddenFromObjC

@OptIn(ExperimentalObjCRefinement::class)
@HiddenFromObjC
fun managersDiModule(): Module = module {
    single<CardsManager> { CardsManagerImpl() }
}

/**
 * This function must be called by the iOS app inside CardsManagerFactory in AppFactories.swift to provide the CardsManager instance.
 */
object ManagersDi {
    fun cardsManager(): CardsManager = CardsManagerImpl()
}