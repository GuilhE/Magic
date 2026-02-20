package com.magic.core.database

import kotlin.experimental.ExperimentalObjCRefinement
import kotlin.native.HiddenFromObjC
import org.koin.core.module.Module

@OptIn(ExperimentalObjCRefinement::class)
@HiddenFromObjC
expect fun databaseDiModule(): Module

@OptIn(ExperimentalObjCRefinement::class)
@HiddenFromObjC
expect fun databaseDiTestModule(): Module

internal const val DATABASE_NAME = "magic_database.db"