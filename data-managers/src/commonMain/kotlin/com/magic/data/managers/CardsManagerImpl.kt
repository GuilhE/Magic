package com.magic.data.managers

import co.touchlab.kermit.Logger
import com.magic.core.database.MagicDao
import com.magic.core.network.api.ApiClient
import com.magic.core.network.api.core.ApiResult
import com.magic.data.models.exceptions.RateLimitException
import com.magic.data.models.local.CardImpl
import com.magic.data.models.local.CardSetImpl
import com.magic.data.models.local.Result
import com.magic.data.models.remote.CardListResponse
import com.magic.data.models.remote.CardSetResponse
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject

internal class CardsManagerImpl : CardsManager, KoinComponent {
    private val coroutineScope: CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private val logger = Logger.withTag("CardsManager")
    private val remote: ApiClient by inject()
    private val local: MagicDao by inject()

    override suspend fun getSet(setCode: String): Result<List<CardImpl>> {
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
            val cards = mutableListOf<CardImpl>()
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

    override suspend fun getSets(setCodes: List<String>): Result<Unit> {
        logger.i { "> Starting parallel database population with booster sets" }
        return try {
            coroutineScope {
                val results = setCodes.map { setCode ->
                    async {
                        getSet(setCode)
                    }
                }
                val resultsList = results.awaitAll()
                resultsList.forEach { result ->
                    if (result is Result.Error) {
                        logger.e { "> Error populating database: ${result.exception.message}" }
                        return@coroutineScope Result.Error(result.exception)
                    }
                }

                logger.i { "> Successfully populated database with booster sets" }
                Result.Success(Unit)
            }
        } catch (e: Exception) {
            logger.e { "> Exception during database population: ${e.message}" }
            Result.Error(e)
        }
    }

    override val observeSetCount: StateFlow<Long> = local.setCountStream()
        .stateIn(coroutineScope, SharingStarted.Lazily, 0)

    override val observeCardCount: StateFlow<Long> = local.cardCountStream()
        .stateIn(coroutineScope, SharingStarted.Lazily, 0)

    override val observeSets: StateFlow<List<CardSetImpl>> = local.setsStream()
        .map { dbSets -> dbSets.map { dbSet -> dbSet.toCardSet() } }
        .stateIn(coroutineScope, SharingStarted.Lazily, emptyList())

    override fun observeCardsFromSet(code: String): StateFlow<List<CardImpl>> {
        return local.cardsFromSetStream(code)
            .map { dbCards -> dbCards.map { dbCard -> dbCard.toCard() } }
            .stateIn(coroutineScope, SharingStarted.Lazily, emptyList())
    }

    override val observeCards: StateFlow<List<CardImpl>> = local.cardsStream()
        .map { dbCards -> dbCards.map { dbCard -> dbCard.toCard() } }
        .stateIn(coroutineScope, SharingStarted.Lazily, emptyList())

    override fun getSetCount(): Long = local.setCount()

    override fun getCardCount(): Long = local.cardCount()

    override fun getSets(): List<CardSetImpl> = local.sets().map { it.toCardSet() }

    override fun getCardsFromSet(setCode: String): List<CardImpl> = local.cardsFromSet(setCode).map { it.toCard() }

    override fun getCards(): List<CardImpl> = local.cards().map { it.toCard() }

    override fun removeAllSets() = local.deleteAllSets()

    override fun removeSet(setCode: String) = local.deleteCardSet(setCode)
}

private fun com.magic.core.database.CardSet.toCardSet(): CardSetImpl {
    return CardSetImpl(
        code = code,
        name = name,
        releaseDate = releaseDate
    )
}

private fun com.magic.core.database.Card.toCard(): CardImpl {
    return CardImpl(
        id = this.id,
        setCode = this.setCode,
        name = this.name,
        text = this.text,
        imageUrl = this.imageUrl ?: "",
        artist = this.artist
    )
}