package com.magic.data.managers

import com.magic.data.models.exceptions.RateLimitException
import com.magic.data.models.local.Card
import com.magic.data.models.local.CardSet
import com.magic.data.models.local.Result
import com.rickclephas.kmp.nativecoroutines.NativeCoroutines
import com.rickclephas.kmp.nativecoroutines.NativeCoroutinesState
import kotlinx.coroutines.flow.StateFlow

/**
 * Manager class for handling card and card set operations. This class interacts with the remote API and
 * local database to fetch, store, and observe card and card set data.
 */
interface CardsManager {

    /**
     * If Swift or Objective-C code calls a Kotlin method that throws an exception, the Kotlin method should be marked with the @Throws annotation,
     * specifying a list of "expected" exception classes. However, KMP-NC hides the original declaration and removes the @Throws from the generated
     * functions since the generated functions are not designed to throw exceptions. The solution is straightforward: we create a public function
     * that explicitly exposes the types of exceptions that may be thrown, thus adding them to the public API.
     */
    @Throws(RateLimitException::class)
    fun exportedExceptions()

    /**
     *  If [CardSet] is not cached, it will be fetched from the API along with its cards and then inserted into the local database.
     *  It will fetch 3 pages of cards from the API, each containing 100 cards.
     *
     * @param setCode The code of the [CardSet] to fetch and insert.
     * @return A [Result] containing a list of [Card] on success or a [Throwable] on error.
     */
    @NativeCoroutines
    suspend fun getSet(setCode: String): Result<List<Card>>

    /**
     * Executes [getSet] in parallel for each setCode in [setCodes].
     *
     * @param setCodes A list of set codes to be fetched.
     * @return A [Result] indicating success or failure of the operation. In case of error, a [Throwable] inside [Result.Error].
     */
    @NativeCoroutines
    suspend fun getSets(setCodes: List<String>): Result<Unit>

    /**
     * Observes the count of card set in the local database.
     *
     * @return A [StateFlow] of [Long] representing the current count of card sets in the database.
     */
    @NativeCoroutinesState
    val observeSetCount: StateFlow<Long>

    /**
     * Observes the count of cards in the local database.
     *
     * @return A [StateFlow] of [Long] representing the current count of cards in the database.
     */
    @NativeCoroutinesState
    val observeCardCount: StateFlow<Long>

    /**
     * Observes changes in the list of cards in the local database.
     *
     * @return A [StateFlow] of a list of [CardSet] representing the current state of card sets in the database.
     */
    @NativeCoroutinesState
    val observeSets: StateFlow<List<CardSet>>

    /**
     * Returns an observable of all changes in the list of cards for a specific set in the local database.
     *
     * @param code The code of the [CardSet] for which cards should be observed.
     * @return A [StateFlow] of a list of [Card] representing the current state of all cards from a [CardSet] in the database.
     */
    @NativeCoroutines
    fun observeCardsFromSet(code: String): StateFlow<List<Card>>

    /**
     * Returns an observable of all cards in the local database.
     *
     * @return A [StateFlow] of a list of [Card] representing the current state of all cards in the database.
     */
    @NativeCoroutinesState
    val observeCards: StateFlow<List<Card>>

    /**
     * Gets the count of card sets in the local database.
     *
     * @return A [Long] representing the number of card sets in the database.
     */
    fun getSetCount(): Long

    /**
     * Gets the count of cards in the local database.
     *
     * @return A [Long] representing the number of cards in the database.
     */
    fun getCardCount(): Long

    /**
     * Retrieves all card sets from the local database.
     *
     * @return A list of [CardSet] representing all card sets in the database.
     */
    fun getSets(): List<CardSet>

    /**
     * Retrieves all cards for a specific set from the local database.
     *
     * @param setCode The code of the card set for which cards should be retrieved.
     * @return A list of [Card] representing all cards in the specified set.
     */
    fun getCardsFromSet(setCode: String): List<Card>

    /**
     * Retrieves all cards from the local database.
     *
     * @return A list of [Card] representing all cards in the database.
     */
    fun getCards(): List<Card>

    /**
     * Removes all card sets and their associated cards from the local database.
     */
    fun removeAllSets()

    /**
     * Removes card set and its associated cards from the local database.
     *
     * @param setCode The code of the card set for which cards should be removed.
     */
    fun removeSet(setCode: String)
}