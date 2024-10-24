package com.magic.data.models.local

import kotlinx.serialization.Serializable

@Serializable
data class CardSet(
    val code: String = "",
    val name: String = "",
    val releaseDate: String = ""
)