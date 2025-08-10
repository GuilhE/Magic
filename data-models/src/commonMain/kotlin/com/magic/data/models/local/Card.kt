package com.magic.data.models.local

interface Card {
    val id: String
    val setCode: String
    val name: String
    val text: String
    val imageUrl: String
    val artist: String
}
