@file:OptIn(ExperimentalObjCRefinement::class)

package com.magic.core.network.api.errors

import kotlin.experimental.ExperimentalObjCRefinement
import kotlin.native.HiddenFromObjC
import kotlinx.serialization.Serializable

@Serializable
@HiddenFromObjC
data class ApiError(val status: Int, val error: String) : Throwable(error)