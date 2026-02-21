import app.cash.turbine.test
import com.magic.core.database.databaseDiTestModule
import com.magic.core.network.api.ApiClient
import com.magic.data.managers.CardsManager
import com.magic.data.managers.managersDiModule
import com.magic.data.models.exceptions.RateLimitException
import com.magic.data.models.local.Result
import io.ktor.client.HttpClient
import io.ktor.client.engine.mock.MockEngine
import io.ktor.client.engine.mock.respond
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.http.HttpHeaders
import io.ktor.http.HttpStatusCode
import io.ktor.http.headersOf
import io.ktor.serialization.kotlinx.json.json
import io.ktor.utils.io.ByteReadChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import kotlinx.serialization.json.Json
import org.koin.core.context.startKoin
import org.koin.core.context.stopKoin
import org.koin.dsl.module
import org.koin.test.KoinTest
import org.koin.test.get
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class CardsManagerTest : KoinTest {

    private val json: String = """
    {
        "set": {
            "code": "SET001",
            "name": "Test Set",
            "releaseDate": "2024-01-01"
        },
        "cards": [
            {
                "id":"1",
                "set": "SET001",
                "name": "Card 1",
                "text": "Text 1",
                "imageUrl": "url1",
                "artist": "Artist 1"
            },
            {
                "id":"2",
                "set": "SET001",
                "name": "Card 2",
                "text": "Text 2",
                "imageUrl": "url2",
                "artist": "Artist 2"
            }
        ]
    }
    """

    @BeforeTest
    fun setUp() {
        startKoin {
            modules(
                module {
                    val mockEngine = MockEngine {
                        respond(
                            content = ByteReadChannel(json),
                            status = HttpStatusCode.OK,
                            headers = headersOf(HttpHeaders.ContentType, "application/json")
                        )
                    }
                    single {
                        ApiClient(
                            client = HttpClient(mockEngine) { install(ContentNegotiation) { json(Json { ignoreUnknownKeys = true }) } },
                            baseUrl = "https://api.example.com"
                        )
                    }
                },
                databaseDiTestModule(),
                managersDiModule(),
            )
        }
        Dispatchers.setMain(StandardTestDispatcher())
    }

    @AfterTest
    fun finish() {
        stopKoin()
        Dispatchers.resetMain()
    }

    @Test
    fun `getSets should return success when all API calls are successful`() = runTest {
        val manager = get<CardsManager>()
        val result = manager.getSets(listOf("SET001", "SET002"))
        assertTrue(result is Result.Success)
    }

    @Test
    fun `getSet should return success with cards when both API calls are successful`() = runTest {
        val manager = get<CardsManager>()
        val result = manager.getSet("SET001")
        assertTrue(result is Result.Success)
        assertEquals(6, result.data.size)
        assertEquals("Card 1", result.data[0].name)
        assertEquals("Card 2", result.data[1].name)
    }

    @Test
    fun `getSet should return error when API call fails`() = runTest {
        stopKoin()
        startKoin {
            modules(
                module {
                    val errorEngine = MockEngine {
                        respond(
                            content = ByteReadChannel(""),
                            status = HttpStatusCode.TooManyRequests,
                            headers = headersOf(HttpHeaders.ContentType, "application/json")
                        )
                    }
                    single {
                        ApiClient(
                            client = HttpClient(errorEngine) { install(ContentNegotiation) { json() } },
                            baseUrl = "https://api.example.com"
                        )
                    }
                },
                databaseDiTestModule(),
                managersDiModule(),
            )
        }
        val manager = get<CardsManager>()
        val result = manager.getSet("SET001")
        assertTrue(result is Result.Error)
        assertTrue(result.exception is RateLimitException)
        assertTrue { result.exception.message.equals(HttpStatusCode.TooManyRequests.description) }
    }

    @Test
    fun `observeSetCount should reflect changes in database`() = runTest {
        val manager = get<CardsManager>()
        manager.observeSetCount().stateIn(CoroutineScope(Dispatchers.Default)).test {
            assertEquals(0, awaitItem().toInt())

            manager.getSet("SET001")
            assertEquals(1,awaitItem().toInt())

            manager.removeAllSets()
            assertEquals(0,awaitItem().toInt())

            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `observeCardCount should reflect changes in database`() = runTest {
        val manager = get<CardsManager>()
        manager.observeCardCount().stateIn(CoroutineScope(Dispatchers.Default)).test {
            assertEquals(0,awaitItem().toInt())

            manager.getSet("SET001")
            assertEquals(2,awaitItem().toInt())

            manager.removeAllSets()
            assertEquals(0,awaitItem().toInt())

            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `observeSets should reflect changes in database`() = runTest {
        val manager = get<CardsManager>()
        manager.observeSets().stateIn(CoroutineScope(Dispatchers.Default)).test {
            assertTrue(awaitItem().isEmpty())

            manager.getSet("SET001")
            assertTrue(awaitItem().isNotEmpty())

            manager.removeAllSets()
            assertTrue(awaitItem().isEmpty())

            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `observeCardsFromSet should reflect changes in database`() = runTest {
        val manager = get<CardsManager>()
        manager.observeCardsFromSet("SET001").stateIn(CoroutineScope(Dispatchers.Default)).test {
            assertTrue(awaitItem().isEmpty())

            manager.getSet("SET001")
            assertTrue(awaitItem().isNotEmpty())

            manager.removeAllSets()
            assertTrue(awaitItem().isEmpty())

            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `observeCards should reflect changes in database`() = runTest {
        val manager = get<CardsManager>()
        manager.observeCards().stateIn(CoroutineScope(Dispatchers.Default)).test {
            assertTrue(awaitItem().isEmpty().also { println(">>>>> $it ${manager.getCardCount()}") })

            manager.getSet("SET001")
            assertTrue(awaitItem().isNotEmpty().also { println(">>>>> $it ${manager.getCardCount()}") })

            manager.removeSet("SET001")
            assertTrue(awaitItem().isEmpty().also { println(">>>>> $it ${manager.getCardCount()}") })

            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `getSetCount should return the correct count of sets`() = runTest {
        val manager = get<CardsManager>()
        assertEquals(0, manager.getSetCount())

        manager.getSet("SET001")
        assertEquals(1, manager.getSetCount())

        manager.removeAllSets()
        assertEquals(0, manager.getSetCount())
    }

    @Test
    fun `getCardCount should return the correct count of sets`() = runTest {
        val manager = get<CardsManager>()
        assertEquals(0, manager.getCardCount())

        manager.getSet("SET001")
        assertTrue { manager.getCardCount().toInt() > 0 }

        manager.removeAllSets()
        assertEquals(0, manager.getCardCount())
    }

    @Test
    fun `getSets should return the correct list of sets`() = runTest {
        val manager = get<CardsManager>()
        assertTrue(manager.getSets().isEmpty())

        manager.getSet("SET001")
        val sets = manager.getSets()
        assertEquals(1, sets.size)
        assertEquals("SET001", sets[0].code)
        assertEquals("Test Set", sets[0].name)

        manager.removeAllSets()
        assertTrue(manager.getSets().isEmpty())
    }

    @Test
    fun `getCardsFromSet should return the correct list of cards for a set`() = runTest {
        val manager = get<CardsManager>()
        assertTrue(manager.getCardsFromSet("SET001").isEmpty())

        manager.getSet("SET001")
        val cards = manager.getCardsFromSet("SET001")
        assertEquals(2, cards.size)
        assertEquals("Card 1", cards[0].name)
        assertEquals("Card 2", cards[1].name)

        manager.removeSet("SET001")
        assertTrue(manager.getCardsFromSet("SET001").isEmpty())
    }

    @Test
    fun `getCards should return the correct list of cards`() = runTest {
        val manager = get<CardsManager>()
        assertTrue(manager.getCards().isEmpty())

        manager.getSet("SET001")
        val cards = manager.getCards()
        assertEquals(2, cards.size)
        assertEquals("Card 1", cards[0].name)
        assertEquals("Card 2", cards[1].name)

        manager.removeAllSets()
        assertTrue(manager.getCards().isEmpty())
    }

    @Test
    fun `removeAllSets should remove all cards from the database`() = runTest {
        val manager = get<CardsManager>()
        manager.getSet("SET001")
        assertTrue(manager.getCardCount() > 0)
        manager.removeAllSets()
        assertEquals(manager.getCardCount().toInt(), 0)
    }

    @Test
    fun `removeCardsFromSet should remove all cards for a given set`() = runTest {
        val manager = get<CardsManager>()
		manager.observeCards().stateIn(CoroutineScope(Dispatchers.Default)).test {
			assertTrue(awaitItem().isEmpty().also { println(">>>>> $it ${manager.getCardCount()}") })

			manager.getSet("SET001")
			assertTrue(awaitItem().isNotEmpty().also { println(">>>>> $it ${manager.getCardCount()}") })

			manager.removeSet("SET001")
			assertTrue(awaitItem().isEmpty().also { println(">>>>> $it ${manager.getCardCount()}") })

			cancelAndIgnoreRemainingEvents()

			val cardsAfterRemoval = manager.getCardsFromSet("SET001")
			assertTrue(cardsAfterRemoval.isEmpty())
		}
    }
}