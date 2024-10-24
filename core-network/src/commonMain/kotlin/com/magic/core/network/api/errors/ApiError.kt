@file:OptIn(ExperimentalObjCRefinement::class)

package com.magic.core.network.api.errors

import kotlinx.serialization.Serializable
import kotlin.experimental.ExperimentalObjCRefinement
import kotlin.native.HiddenFromObjC

@Serializable
@HiddenFromObjC
data class ApiError(val status: Int, val error: String) : Throwable(error)