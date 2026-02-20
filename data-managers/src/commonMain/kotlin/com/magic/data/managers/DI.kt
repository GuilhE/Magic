package com.magic.data.managers

import kotlin.experimental.ExperimentalObjCRefinement
import kotlin.native.HiddenFromObjC
import org.koin.core.module.Module
import org.koin.dsl.module

@OptIn(ExperimentalObjCRefinement::class)
@HiddenFromObjC
fun managersDiModule(): Module = module {
    single<CardsManager> { CardsManagerImpl() }
}