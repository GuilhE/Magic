import app.cash.turbine.test
import com.magic.core.database.MagicDao
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import kotlinx.coroutines.test.runTest
import org.koin.core.context.startKoin
import org.koin.core.context.stopKoin
import org.koin.test.KoinTest
import org.koin.test.get

class MagicDaoTest : KoinTest {

    private lateinit var dao: MagicDao

    @BeforeTest
    fun setUp() {
        startKoin {
            modules(
                databaseDiTestModule()
            )
        }
        dao = get<MagicDao>()
        dao.deleteAllSets()
    }

    @AfterTest
    fun finish() {
        stopKoin()
    }

    @Test
    fun `When inserting a Set it should be retrievable with correct data`() = runTest {
        val code = "SET001"
        val name = "Test Set"
        val releaseDate = "2024-01-01"
        dao.insertSet(code, name, releaseDate)

        val sets = dao.sets()
        assertEquals(1, sets.size)

        val set = sets[0]
        assertEquals(code, set.code)
        assertEquals(name, set.name)
        assertEquals(releaseDate, set.releaseDate)
    }

    @Test
    fun `Searching for a Set by code should return true if exists`() = runTest {
        val code = "SET001"
        val name = "Test Set"
        val releaseDate = "2024-01-01"

        dao.insertSet(code, name, releaseDate)
        assertTrue { dao.setExist(code) }

        dao.deleteCardSet(code)
        assertFalse { dao.setExist(code) }
    }

    @Test
    fun `Deleting a Set should remove all associated cards`() = runTest {
        dao.insertSet("SET001", "Test Set", "2024-01-01")
        dao.insertCard("1", "SET001", "Card 1", "Text 1", "url1", "Artist 1")
        dao.insertCard("2", "SET001", "Card 2", "Text 2", "url2", "Artist 2")
        assertEquals(2, dao.cards().size)

        dao.deleteCardSet("SET001")
        assertEquals(0, dao.cards().size)
        assertEquals(0, dao.sets().size)
    }

    @Test
    fun `Deleting all Sets should empty the database`() = runTest {
        dao.insertSet("SET001", "Test Set", "2024-01-01")
        dao.insertCard("1", "SET001", "Card 1", "Text 1", "url1", "Artist 1")
        assertEquals(1, dao.cards().size)
        assertEquals(1, dao.sets().size)

        dao.deleteAllSets()
        assertEquals(0, dao.cardCount())
        assertEquals(0, dao.setCount())
    }

    @Test
    fun `Set count should update after insertion or deletion`() = runTest {
        assertEquals(0, dao.setCount())
        dao.insertSet("SET001", "Test Set", "2024-01-01")
        dao.insertSet("SET002", "Test Set", "2024-01-01")
        assertEquals(2, dao.setCount())
    }

    @Test
    fun `Set count stream should reflect real-time changes accurately`() = runTest {
        dao.setCountStream().test {
            assertEquals(0, awaitItem())

            dao.insertSet("SET001", "Set 1", "2024-01-01")
            assertEquals(1, awaitItem())

            dao.insertSet("SET002", "Set 2", "2024-02-01")
            assertEquals(2, awaitItem())

            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `Card count should update after insertion or deletion`() = runTest {
        assertEquals(0, dao.cardCount())
        dao.insertSet("SET001", "Test Set", "2024-01-01")
        dao.insertCard("1", "SET001", "Card 1", "Text 1", "url1", "Artist 1")
        assertEquals(1, dao.cardCount())
    }

    @Test
    fun `Card count stream should reflect real-time changes accurately`() = runTest {
        dao.insertSet("SET001", "Test Set", "2024-01-01")
        dao.cardCountStream().test {
            assertEquals(0, awaitItem())

            dao.insertCard("1", "SET001", "Card 1", "Text 1", "url1", "Artist 1")
            assertEquals(1, awaitItem())

            dao.insertCard("2", "SET001", "Card 2", "Text 2", "url2", "Artist 2")
            assertEquals(2, awaitItem())

            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `Sets should return correct list of sets`() = runTest {
        dao.insertSet("SET001", "Set 1", "2024-01-01")
        dao.insertSet("SET002", "Set 2", "2023-01-01")

        val sets = dao.sets()
        assertEquals(2, sets.size)
    }

    @Test
    fun `Sets stream should reflect real-time changes accurately`() = runTest {
        dao.setsStream().test {
            assertEquals(0, awaitItem().size)

            dao.insertSet("SET001", "Set 1", "2024-01-01")
            with(awaitItem()) {
                assertEquals(1, this.size)
                assertEquals("SET001", this[0].code)
            }

            dao.insertSet("SET002", "Set 2", "2024-02-01")
            with(awaitItem()) {
                assertEquals(2, this.size)
                assertEquals("SET002", this[1].code)
            }

            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `Cards from Set should return correct list of cards`() = runTest {
        dao.insertSet("SET001", "Set 1", "2024-01-01")
        dao.insertCard("1", "SET001", "Card 1", "Text 1", "url1", "Artist 1")
        dao.insertCard("2", "SET001", "Card 2", "Text 2", "url2", "Artist 2")

        val cards = dao.cardsFromSet("SET001")
        assertEquals(2, cards.size)
        assertEquals("1", cards[0].id)
        assertEquals("2", cards[1].id)
    }

    @Test
    fun `Cards from Set stream should reflect real-time changes accurately`() = runTest {
        dao.insertSet("SET001", "Set 1", "2024-01-01")
        dao.cardsFromSetStream("SET001").test {
            assertEquals(0, awaitItem().size)

            dao.insertCard("1", "SET001", "Card 1", "Text 1", "url1", "Artist 1")
            with(awaitItem()) {
                assertEquals(1, this.size)
                assertEquals("1", this[0].id)
            }

            dao.insertCard("2", "SET001", "Card 2", "Text 2", "url2", "Artist 2")
            with(awaitItem()) {
                assertEquals(2, this.size)
                assertEquals("2", this[1].id)
            }

            cancelAndIgnoreRemainingEvents()
        }
    }
}
