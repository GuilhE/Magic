@file:OptIn(ExperimentalObjCRefinement::class)

package com.magic.core.network.api

import com.magic.core.network.api.core.ApiCall
import com.magic.core.network.api.core.ApiCallBehavior
import com.magic.core.network.api.core.ApiResult
import com.magic.core.network.api.errors.ApiError
import com.magic.core.network.api.requests.BaseRequest
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.request.request
import io.ktor.client.request.url
import io.ktor.client.statement.HttpResponse
import io.ktor.http.isSuccess
import kotlin.experimental.ExperimentalObjCRefinement
import kotlin.native.HiddenFromObjC

@HiddenFromObjC
class ApiClient(
    val client: HttpClient,
    val baseUrl: String
) : ApiCallBehavior by ApiCall() {
    suspend inline fun <reified T : Any> perform(request: BaseRequest): ApiResult<T> {
        return apiCall {
            val response: HttpResponse = client.request {
                url("$baseUrl/${request.path}")
                method = request.method
                request.requestBuilder().apply {
                    this()
                }
            }

            if (response.status.isSuccess()) {
                response.body<T>()
            } else {
                try {
                    throw response.body<ApiError>()
                } catch (e: Exception) {
                    throw ApiError(response.status.value, response.status.description)
                }
            }
        }
    }
}