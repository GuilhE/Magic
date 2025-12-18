package com.magic.data.managers

import io.ktor.utils.io.core.Closeable
import org.koin.core.module.Module
import org.koin.dsl.module
import org.koin.dsl.onClose
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
@Suppress("unused")
object KmpInstancesProvider {
    fun cardsManager(): CardsManager = CardsManagerImpl()
}