package com.magic.core.network.api.core

internal class ApiCall : ApiCallBehavior {
    override suspend fun <T : Any> apiCall(call: suspend () -> T): ApiResult<T> {
        return kotlin.runCatching {
            val response = call.invoke()
            ApiResult.Success(response)
        }.getOrElse {
            ApiResult.Error(it)
        }
    }
}