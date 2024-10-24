@file:Suppress("ACTUAL_ANNOTATIONS_NOT_MATCH_EXPECT")

package com.magic.core.database

import androidx.sqlite.db.SupportSQLiteDatabase
import app.cash.sqldelight.driver.android.AndroidSqliteDriver
import app.cash.sqldelight.driver.jdbc.sqlite.JdbcSqliteDriver
import org.koin.core.module.Module
import org.koin.dsl.module
import java.util.Properties

actual fun databaseDiModule(): Module = module {
    single {
        MagicDao(
            AndroidSqliteDriver(
                schema = MagicDatabase.Schema,
                context = get(),
                name = DATABASE_NAME,
                callback = object : AndroidSqliteDriver.Callback(MagicDatabase.Schema) {
                    override fun onOpen(db: SupportSQLiteDatabase) {
                        db.setForeignKeyConstraintsEnabled(true)
                    }
                })
        )
    }
}

actual fun databaseDiTestModule(): Module = module {
    single {
        MagicDao(
            JdbcSqliteDriver(
                url = JdbcSqliteDriver.IN_MEMORY,
                schema = MagicDatabase.Schema,
                properties = Properties().apply { put("foreign_keys", "true") })
        )
    }
}