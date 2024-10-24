import app.cash.sqldelight.driver.jdbc.sqlite.JdbcSqliteDriver
import com.magic.core.database.MagicDao
import com.magic.core.database.MagicDatabase
import org.koin.core.module.Module
import org.koin.dsl.module
import java.util.Properties

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