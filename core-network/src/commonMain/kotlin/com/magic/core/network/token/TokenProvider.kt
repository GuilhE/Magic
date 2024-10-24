@file:OptIn(ExperimentalObjCRefinement::class)

package com.magic.core.network.token

import kotlin.experimental.ExperimentalObjCRefinement
import kotlin.native.HiddenFromObjC

@HiddenFromObjC
interface TokenProvider {
    fun getAccessToken(): String
}