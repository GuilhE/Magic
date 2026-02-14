import app.cash.sqldelight.driver.jdbc.sqlite.JdbcSqliteDriver
import com.magic.core.database.MagicDao
import com.magic.core.database.MagicDatabase
import java.util.Properties
import org.koin.core.module.Module
import org.koin.dsl.module

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