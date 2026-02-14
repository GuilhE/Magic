package com.magic.data.models.local

import kotlin.experimental.ExperimentalObjCRefinement
import kotlin.native.HiddenFromObjC
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@OptIn(ExperimentalObjCRefinement::class)
@HiddenFromObjC
@Serializable
data class CardImpl(
    override val id: String = "",
    @SerialName("set") override val setCode: String = "",
    override val name: String = "",
    override val text: String = "",
    override val imageUrl: String = "",
    override val artist: String = ""
) : Card
