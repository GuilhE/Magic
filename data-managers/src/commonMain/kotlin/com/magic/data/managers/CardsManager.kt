package com.magic.data.managers

import co.touchlab.kermit.Logger
import com.magic.core.database.MagicDao
import com.magic.core.network.api.ApiClient
import com.magic.core.network.api.core.ApiResult
import com.magic.data.managers.toCard
import com.magic.data.models.exceptions.RateLimitException
import com.magic.data.models.local.Card
import com.magic.data.models.local.CardSet
import com.magic.data.models.local.Result
import com.magic.data.models.remote.CardListResponse
import com.magic.data.models.remote.CardSetResponse
import com.rickclephas.kmp.nativecoroutines.NativeCoroutineScope
import com.rickclephas.kmp.nativecoroutines.NativeCoroutines
import com.rickclephas.kmp.nativecoroutines.NativeCoroutinesState
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject

/**
 * Manager class for handling card and card set operations. This class interacts with the remote API and
 * local database to fetch, store, and observe card and card set data.
 */
class CardsManager : KoinComponent {
    @NativeCoroutineScope
    internal val coroutineScope: CoroutineScope = MainScope()
    private val logger = Logger.withTag("CardsManager")
    private val remote: ApiClient by inject()
    private val local: MagicDao by inject()

    @Suppress("unused")
    @Throws(RateLimitException::class)
    fun exportedExceptions() {
    }

    /**
     *  If [CardSet] is not cached, it will be fetched from the API along with its cards and then inserted into the local database.
     *  It will fetch 3 pages of cards from the API, each containing 100 cards.
     *
     * @param setCode The code of the [CardSet] to fetch and insert.
     * @return A [Result] containing a list of [Card] on success or a [Throwable] on error.
     */
    @NativeCoroutines
    suspend fun getSet(setCode: String): Result<List<Card>> {
        logger.i { "> Fetching booster cards from set $setCode" }
        if (!local.setExist(setCode)) {
            val setResult = remote.perform<CardSetResponse>(CardRequests.GetSet(setCode))
            if (setResult is ApiResult.Error) {
                logger.i { "> Error fetching card set: ${setResult.exception.message}" }
                return Result.Error(RateLimitException(setResult.exception.message ?: ""))
            }
            val set = (setResult as ApiResult.Success).data.set
            if (!local.setExist(set.code)) {
                local.insertSet(set.code, set.name, set.releaseDate)
            }
        } else {
            logger.i { "> Card set in cache!" }
        }

        val localBooster = local.cardsFromSet(setCode)
        if (localBooster.isEmpty()) {
            val cards = mutableListOf<Card>()
            for (page in 1..3) {
                val boosterResult = remote.perform<CardListResponse>(CardRequests.GetCardsFromSet(setCode, page))
                if (boosterResult is ApiResult.Error) {
                    logger.i { "> Error fetching booster: ${boosterResult.exception.message}" }
                    return Result.Error(RateLimitException(boosterResult.exception.message ?: ""))
                }
                cards.addAll((boosterResult as ApiResult.Success).data.cards)
                cards.forEach { card ->
                    local.insertCard(card.id, card.setCode, card.name, card.text, card.imageUrl, card.artist)
                }
            }
            return Result.Success(cards)
        } else {
            logger.i { "> Booster in cache!" }
        }
        return Result.Success(localBooster.map { it.toCard() })
    }

    /**
     * Executes [getSet] in parallel for each setCode in [setCodes].
     *
     * @param setCodes A list of set codes to be fetched.
     * @return A [Result] indicating success or failure of the operation. In case of error, a [Throwable] inside [Result.Error].
     */
    @NativeCoroutines
    suspend fun getSets(setCodes: List<String>): Result<Unit> {
        logger.i { "> Starting parallel database population with booster sets" }
        return try {
            coroutineScope {
                val results = setCodes.map { setCode ->
                    async {
                        getSet(setCode)
                    }
                }
                val resultsList = results.awaitAll()
                val errors = resultsList.filterIsInstance<ApiResult.Error>()
                if (errors.isNotEmpty()) {
                    val firstError = errors.first()
                    logger.e { "> Error populating database: ${firstError.exception.message}" }
                    Result.Error(firstError.exception)
                } else {
                    logger.i { "> Successfully populated database with booster sets" }
                    Result.Success(Unit)
                }
            }
        } catch (e: Exception) {
            logger.e { "> Exception during database population: ${e.message}" }
            Result.Error(e)
        }
    }

    /**
     * Observes the count of card set in the local database.
     *
     * @return A [StateFlow] of [Long] representing the current count of card sets in the database.
     */
    @NativeCoroutinesState
    val observeSetCount: StateFlow<Long> = local.setCountStream()
        .stateIn(coroutineScope, SharingStarted.Lazily, 0)

    /**
     * Observes the count of cards in the local database.
     *
     * @return A [StateFlow] of [Long] representing the current count of cards in the database.
     */
    @NativeCoroutinesState
    val observeCardCount: StateFlow<Long> = local.cardCountStream()
        .stateIn(coroutineScope, SharingStarted.Lazily, 0)

    /**
     * Observes changes in the list of cards in the local database.
     *
     * @return A [StateFlow] of a list of [CardSet] representing the current state of card sets in the database.
     */
    @NativeCoroutinesState
    val observeSets: StateFlow<List<CardSet>> = local.setsStream()
        .map { dbSets -> dbSets.map { dbSet -> dbSet.toCardSet() } }
        .stateIn(coroutineScope, SharingStarted.Lazily, emptyList())

    /**
     * Returns an observable of all changes in the list of cards for a specific set in the local database.
     *
     * @param code The code of the [CardSet] for which cards should be observed.
     * @return A [StateFlow] of a list of [Card] representing the current state of all cards from a [CardSet] in the database.
     */
    @NativeCoroutines
    fun observeCardsFromSet(code: String): StateFlow<List<Card>> {
        return local.cardsFromSetStream(code)
            .map { dbCards -> dbCards.map { dbCard -> dbCard.toCard() } }
            .stateIn(coroutineScope, SharingStarted.Lazily, emptyList())
    }

    /**
     * Returns an observable of all cards in the local database.
     *
     * @return A [StateFlow] of a list of [Card] representing the current state of all cards in the database.
     */
    @NativeCoroutinesState
    val observeCards: StateFlow<List<Card>> = local.cardsStream()
        .map { dbCards -> dbCards.map { dbCard -> dbCard.toCard() } }
        .stateIn(coroutineScope, SharingStarted.Lazily, emptyList())

    /**
     * Gets the count of card sets in the local database.
     *
     * @return A [Long] representing the number of card sets in the database.
     */
    fun getSetCount(): Long = local.setCount()

    /**
     * Gets the count of cards in the local database.
     *
     * @return A [Long] representing the number of cards in the database.
     */
    fun getCardCount(): Long = local.cardCount()

    /**
     * Retrieves all card sets from the local database.
     *
     * @return A list of [CardSet] representing all card sets in the database.
     */
    fun getSets(): List<CardSet> = local.sets().map { it.toCardSet() }

    /**
     * Retrieves all cards for a specific set from the local database.
     *
     * @param setCode The code of the card set for which cards should be retrieved.
     * @return A list of [Card] representing all cards in the specified set.
     */
    fun getCardsFromSet(setCode: String): List<Card> = local.cardsFromSet(setCode).map { it.toCard() }

    /**
     * Retrieves all cards from the local database.
     *
     * @return A list of [Card] representing all cards in the database.
     */
    fun getCards(): List<Card> = local.cards().map { it.toCard() }

    /**
     * Removes all card sets and their associated cards from the local database.
     */
    fun removeAllSets() = local.deleteAllSets()

    /**
     * Removes card set and its associated cards from the local database.
     *
     * @param setCode The code of the card set for which cards should be removed.
     */
    fun removeSet(setCode: String) = local.deleteCardSet(setCode)
}

private fun com.magic.core.database.CardSet.toCardSet(): CardSet {
    return CardSet(
        code = code,
        name = name,
        releaseDate = releaseDate
    )
}

private fun com.magic.core.database.Card.toCard(): Card {
    return Card(
        id = this.id,
        setCode = this.setCode,
        name = this.name,
        text = this.text,
        imageUrl = this.imageUrl ?: "",
        artist = this.artist
    )
}
