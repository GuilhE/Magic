package com.magic.core.network.api.core

@PublishedApi
internal interface ApiCallBehavior {
    suspend fun <T : Any> apiCall(call: suspend () -> T): ApiResult<T>
}