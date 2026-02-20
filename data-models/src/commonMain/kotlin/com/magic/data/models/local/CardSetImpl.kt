package com.magic.data.models.local

import kotlin.experimental.ExperimentalObjCRefinement
import kotlin.native.HiddenFromObjC
import kotlinx.serialization.Serializable

@OptIn(ExperimentalObjCRefinement::class)
@HiddenFromObjC
@Serializable
data class CardSetImpl(
    override val code: String = "",
    override val name: String = "",
    override val releaseDate: String = ""
) : CardSet
