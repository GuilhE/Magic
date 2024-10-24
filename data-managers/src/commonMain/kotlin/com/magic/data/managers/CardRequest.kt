package com.magic.data.managers

import com.magic.core.network.api.requests.BaseRequest
import io.ktor.client.request.HttpRequestBuilder
import io.ktor.client.request.parameter
import io.ktor.http.ContentType
import io.ktor.http.HttpMethod
import io.ktor.http.contentType

/**
 * https://docs.magicthegathering.io/
 */
internal sealed class CardRequests(
    override val path: String,
    override val method: HttpMethod
) : BaseRequest {

    data class GetSet(private val code: String) : CardRequests("sets/$code", HttpMethod.Get) {
        override fun requestBuilder(): HttpRequestBuilder.() -> Unit = {
            contentType(ContentType.Application.Json)
        }
    }

    data class GetBooster(private val setCode: String) : CardRequests("sets/$setCode/booster", HttpMethod.Get) {
        override fun requestBuilder(): HttpRequestBuilder.() -> Unit = {
            contentType(ContentType.Application.Json)
        }
    }

    /**
     * The Api is failing to get Boosters, we'll simulate that with this
     */
    data class GetCardsFromSet(private val setCode: String) : CardRequests("cards", HttpMethod.Get) {
        override fun requestBuilder(): HttpRequestBuilder.() -> Unit = {
            contentType(ContentType.Application.Json)
            parameter("set", setCode)
            parameter("page", 1)
            parameter("pageSize", 100)
        }
    }
}