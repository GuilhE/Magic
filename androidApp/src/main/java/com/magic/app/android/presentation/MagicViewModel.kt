package com.magic.app.android.presentation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.magic.data.managers.CardsManager
import com.magic.data.models.local.CardImpl
import com.magic.data.models.local.CardSetImpl
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.onSubscription
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject

data class MagicScreenState(
    val set: CardSetImpl = CardSetImpl(),
    val cards: List<CardImpl> = emptyList(),
    val availableSets: List<CardSetImpl> = emptyList(),
    val setCount: Int = 0,
    val cardsTotalCount: Int = 0,
    val isLoading: Boolean = false
)

class MagicViewModel : ViewModel(), KoinComponent {
    //https://en.wikipedia.org/wiki/List_of_Magic:_The_Gathering_sets
    private val cardSetsCodes = listOf("4ED", "5ED", "TMP", "MIR")
    private val manager: CardsManager by inject()

    private val observeCurrentSet = MutableStateFlow(CardSetImpl())
    private val _state = MutableStateFlow(MagicScreenState())
    val state = _state
        .onSubscription { safeCall(call = { manager.getSets(cardSetsCodes) }) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000L), MagicScreenState(isLoading = true))

    init {
        viewModelScope.launch {
            observeCurrentSet
                .flatMapLatest { set ->
                    combine(
                        manager.observeSets,
                        manager.observeCardsFromSet(set.code),
                        manager.observeCardCount,
                        manager.observeSetCount
                    ) { sets, cards, cardsCount, setCount ->
                        MagicScreenState(set, cards, sets, setCount.toInt(), cardsCount.toInt())
                    }
                }
                .collect { new ->
                    _state.update {
                        it.copy(
                            set = new.set,
                            availableSets = new.availableSets,
                            cards = new.cards,
                            cardsTotalCount = new.cardsTotalCount,
                            setCount = new.setCount
                        )
                    }
                }
        }
    }

    fun changeSet(set: CardSetImpl) {
        observeCurrentSet.update { set }
    }

    fun getCardsFromCurrentSet() {
        viewModelScope.launch {
            safeCall(
                onCallStateChange = { running -> _state.update { it.copy(isLoading = running) } },
                call = { manager.getSet(observeCurrentSet.value.code) }
            )
        }
    }

    fun deleteCardsFromCurrentSet() {
        manager.removeSet(observeCurrentSet.value.code)
    }
}

private suspend fun <T : Any> safeCall(onCallStateChange: (suspend (running: Boolean) -> Unit)? = null, call: suspend () -> T): T? {
    try {
        onCallStateChange?.invoke(true)
        return call()
    } catch (e: Throwable) {
        println(e) //to simplify
    } finally {
        onCallStateChange?.invoke(false)
    }
    return null
}