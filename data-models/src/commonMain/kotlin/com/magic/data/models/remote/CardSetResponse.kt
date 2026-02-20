package com.magic.data.models.remote

import com.magic.data.models.local.CardSetImpl
import kotlin.experimental.ExperimentalObjCRefinement
import kotlin.native.HiddenFromObjC
import kotlinx.serialization.Serializable

@OptIn(ExperimentalObjCRefinement::class)
@Serializable
@HiddenFromObjC
data class CardSetResponse(val set: CardSetImpl)