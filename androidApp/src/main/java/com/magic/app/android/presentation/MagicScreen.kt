@file:OptIn(ExperimentalMaterial3Api::class)

package com.magic.app.android.presentation

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MenuAnchorType
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.magic.data.models.local.Card
import com.magic.data.models.local.CardSet
import org.koin.androidx.compose.koinViewModel

@Composable
fun MagicScreen(viewModel: MagicViewModel = koinViewModel()) {
    with(viewModel.state.collectAsStateWithLifecycle().value) {
        MagicScreenContent(
            set = set,
            sets = availableSets,
            setCount = setCount,
            cards = cards,
            cardsTotalCount = cardsTotalCount,
            isLoading = isLoading,
            onSetSelected = { viewModel.changeSet(it) },
            onGetCards = { viewModel.getCardsFromCurrentSet() },
            onDelete = { viewModel.deleteCardsFromCurrentSet() }
        )
    }
}

@Composable
private fun MagicScreenContent(
    set: CardSet,
    sets: List<CardSet>,
    setCount: Int,
    cards: List<Card>,
    cardsTotalCount: Int,
    isLoading: Boolean,
    onSetSelected: (CardSet) -> Unit,
    onGetCards: () -> Unit,
    onDelete: () -> Unit,
) {
    Column(Modifier.fillMaxSize(), horizontalAlignment = Alignment.CenterHorizontally) {
        Column(
            modifier = Modifier.padding(top = 20.dp, start = 20.dp, end = 20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Dropdown(
                enabled = !isLoading,
                selectedOption = set,
                options = sets,
                onOptionSelected = { onSetSelected(it) }
            )
            Row(
                modifier = Modifier.padding(20.dp),
                horizontalArrangement = Arrangement.spacedBy(20.dp)
            ) {
                Button(
                    enabled = set.code.isNotEmpty(),
                    onClick = { onGetCards() }
                ) {
                    Text("Get cards")
                }
                Button(
                    enabled = set.code.isNotEmpty(),
                    onClick = { onDelete() }
                ) {
                    Text("Delete set")
                }
            }
        }
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .height(80.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text("Number of cards: $cardsTotalCount")
            Text("Number of sets: $setCount")
            Spacer(modifier = Modifier.size(5.dp))
            AnimatedVisibility(visible = isLoading, modifier = Modifier.size(20.dp)) {
                CircularProgressIndicator()
            }
        }
        HorizontalDivider(Modifier.padding(horizontal = 10.dp))
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(top = if (set.code.isEmpty() || cards.isEmpty()) 50.dp else 0.dp),
            contentAlignment = Alignment.TopCenter,
        ) {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(10.dp)
            ) {
                items(items = cards, key = { it.id }) { card ->
                    Text(
                        modifier = Modifier.animateItem(),
                        text = card.name
                    )
                }
            }
            if (set.code.isEmpty()) {
                Text("Choose a card set...")
            } else {
                if (cards.isEmpty()) {
                    Text("No cards...")
                }
            }
        }
    }
}

@Composable
private fun Dropdown(
    enabled: Boolean,
    selectedOption: CardSet,
    options: List<CardSet>,
    onOptionSelected: (CardSet) -> Unit
) {
    var expanded by remember { mutableStateOf(false) }
    ExposedDropdownMenuBox(
        expanded = enabled && expanded,
        onExpandedChange = { expanded = !expanded }
    ) {
        OutlinedTextField(
            enabled = enabled,
            value = selectedOption.name,
            onValueChange = {},
            label = { Text("Card Set") },
            readOnly = true,
            modifier = Modifier
                .fillMaxWidth()
                .menuAnchor(MenuAnchorType.PrimaryNotEditable)
        )

        ExposedDropdownMenu(
            expanded = enabled && expanded,
            onDismissRequest = { expanded = false }
        ) {
            options.forEach { option ->
                DropdownMenuItem(
                    text = { Text("${option.name}, ${option.releaseDate}") },
                    onClick = {
                        onOptionSelected(option)
                        expanded = false
                    },
                    modifier = Modifier.padding(8.dp)
                )
            }
        }
    }
}

@Composable
@Preview
private fun MagicScreenPreview() {
    MagicScreenContent(
        set = CardSet("SET01", "SET01"),
        sets = listOf(CardSet("SET01", "SET01"),CardSet("SET02", "SET02")),
        setCount = 50,
        cards = emptyList(),
        cardsTotalCount = 123,
        isLoading = true,
        onSetSelected = { },
        onGetCards = { },
        onDelete = { }
    )
}