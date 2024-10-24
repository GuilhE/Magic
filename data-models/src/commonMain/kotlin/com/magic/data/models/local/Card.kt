package com.magic.data.models.local

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class Card(
    val id: String = "",
    @SerialName("set") val setCode: String = "",
    val name: String = "",
    val text: String = "",
    val imageUrl: String = "",
    val artist: String = ""
)