package com.magic.data.models.remote

import com.magic.data.models.local.CardSet
import kotlinx.serialization.Serializable
import kotlin.experimental.ExperimentalObjCRefinement
import kotlin.native.HiddenFromObjC

@OptIn(ExperimentalObjCRefinement::class)
@Serializable
@HiddenFromObjC
data class CardSetResponse(val set: CardSet)