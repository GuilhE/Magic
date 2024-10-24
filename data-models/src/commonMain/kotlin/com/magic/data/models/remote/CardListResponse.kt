package com.magic.data.models.remote

import com.magic.data.models.local.Card
import kotlinx.serialization.Serializable
import kotlin.experimental.ExperimentalObjCRefinement
import kotlin.native.HiddenFromObjC

@OptIn(ExperimentalObjCRefinement::class)
@Serializable
@HiddenFromObjC
data class CardListResponse(val cards: List<Card>)
