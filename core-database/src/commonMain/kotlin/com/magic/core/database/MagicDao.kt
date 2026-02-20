package com.magic.core.database

import app.cash.sqldelight.coroutines.asFlow
import app.cash.sqldelight.coroutines.mapToList
import app.cash.sqldelight.coroutines.mapToOne
import app.cash.sqldelight.db.SqlDriver
import kotlin.experimental.ExperimentalObjCRefinement
import kotlin.native.HiddenFromObjC
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.flow.Flow

@OptIn(ExperimentalObjCRefinement::class)
@HiddenFromObjC
class MagicDao(driver: SqlDriver) {
    private val database = MagicDatabase(driver)
    private val queries = database.magicDatabaseQueries

    fun insertSet(code: String, name: String, releaseDate: String) {
        queries.insertCardSet(code, name, releaseDate)
    }

    fun insertCard(id: String, setCode: String, name: String, text: String, imageUrl: String, artist: String) {
        queries.insertCard(id, setCode, name, text, imageUrl, artist)
    }

    fun setExist(code: String): Boolean {
        return queries.getSet(code).executeAsOneOrNull() != null
    }

    fun deleteAllSets() {
        queries.deleteAllSets()
    }

    fun deleteCardSet(setCode: String) {
        queries.deleteCardSetAndCards(setCode)
    }

    fun cardsStream(): Flow<List<Card>> {
        return queries
            .getAllCards()
            .asFlow()
            .mapToList(Dispatchers.IO)
    }

    fun cards(): List<Card> {
        return queries
            .getAllCards()
            .executeAsList()
    }

    fun cardCountStream(): Flow<Long> {
        return queries
            .getCardsCount()
            .asFlow()
            .mapToOne(Dispatchers.IO)
    }

    fun cardCount(): Long {
        return queries
            .getCardsCount()
            .executeAsOne()
    }

    fun setsStream(): Flow<List<CardSet>> {
        return queries
            .getAllCardSets()
            .asFlow()
            .mapToList(Dispatchers.IO)
    }

    fun sets(): List<CardSet> {
        return queries
            .getAllCardSets()
            .executeAsList()
    }

    fun setCountStream(): Flow<Long> {
        return queries
            .getSetsCount()
            .asFlow()
            .mapToOne(Dispatchers.IO)
    }

    fun setCount(): Long {
        return queries
            .getSetsCount()
            .executeAsOne()
    }

    fun cardsFromSetStream(setCode: String): Flow<List<Card>> {
        return queries
            .getCardsBySetCode(setCode)
            .asFlow()
            .mapToList(Dispatchers.IO)
    }

    fun cardsFromSet(setCode: String): List<Card> {
        return queries
            .getCardsBySetCode(setCode)
            .executeAsList()
    }
}