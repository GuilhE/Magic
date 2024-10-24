package com.magic.core.database

import app.cash.sqldelight.driver.native.NativeSqliteDriver
import app.cash.sqldelight.driver.native.wrapConnection
import co.touchlab.sqliter.DatabaseConfiguration
import org.koin.core.module.Module
import org.koin.dsl.module
import kotlin.experimental.ExperimentalObjCRefinement

@OptIn(ExperimentalObjCRefinement::class)
@HiddenFromObjC
actual fun databaseDiModule(): Module = module {
    single {
        MagicDao(
            NativeSqliteDriver(
                schema = MagicDatabase.Schema,
                name = DATABASE_NAME,
                onConfiguration = { config: DatabaseConfiguration ->
                    config.copy(
                        extendedConfig = DatabaseConfiguration.Extended(foreignKeyConstraints = true)
                    )
                })
        )
    }
}

@OptIn(ExperimentalObjCRefinement::class)
@HiddenFromObjC
actual fun databaseDiTestModule(): Module = module {
    single {
        val schema = MagicDatabase.Schema
        MagicDao(
            NativeSqliteDriver(
                DatabaseConfiguration(
                    name = null,
                    inMemory = true,
                    version = if (schema.version > Int.MAX_VALUE) error("Schema version is larger than Int.MAX_VALUE: ${schema.version}.") else schema.version.toInt(),
                    create = { connection -> wrapConnection(connection) { schema.create(it) } },
                    upgrade = { connection, oldVersion, newVersion ->
                        wrapConnection(connection) { schema.migrate(it, oldVersion.toLong(), newVersion.toLong()) }
                    },
                    extendedConfig = DatabaseConfiguration.Extended(foreignKeyConstraints = true)
                )
            )
        )
    }
}