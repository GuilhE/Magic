package com.magic.core.database

import org.koin.core.module.Module
import kotlin.experimental.ExperimentalObjCRefinement
import kotlin.native.HiddenFromObjC

@OptIn(ExperimentalObjCRefinement::class)
@HiddenFromObjC
expect fun databaseDiModule(): Module

@OptIn(ExperimentalObjCRefinement::class)
@HiddenFromObjC
expect fun databaseDiTestModule(): Module

internal const val DATABASE_NAME = "magic_database.db"