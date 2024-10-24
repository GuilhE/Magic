@file:OptIn(ExperimentalObjCRefinement::class)

package com.magic.core.network.api.requests

import io.ktor.client.request.HttpRequestBuilder
import io.ktor.http.HttpMethod
import kotlin.experimental.ExperimentalObjCRefinement
import kotlin.native.HiddenFromObjC

@HiddenFromObjC
interface BaseRequest {
    val path: String
    val method: HttpMethod
    fun requestBuilder(): HttpRequestBuilder.() -> Unit
}