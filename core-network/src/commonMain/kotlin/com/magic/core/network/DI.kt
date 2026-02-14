package com.magic.core.network

import com.magic.core.network.token.TokenProvider
import io.ktor.client.HttpClient
import io.ktor.client.engine.HttpClientEngine
import io.ktor.client.plugins.HttpTimeout
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.defaultRequest
import io.ktor.client.plugins.logging.LogLevel
import io.ktor.client.plugins.logging.Logger
import io.ktor.client.plugins.logging.Logging
import io.ktor.client.request.header
import io.ktor.http.ContentType
import io.ktor.http.HttpHeaders
import io.ktor.http.contentType
import io.ktor.serialization.kotlinx.json.json
import kotlin.experimental.ExperimentalObjCRefinement
import kotlin.native.HiddenFromObjC
import kotlinx.serialization.json.Json
import kotlinx.serialization.modules.SerializersModule
import org.koin.core.module.Module

@OptIn(ExperimentalObjCRefinement::class)
@HiddenFromObjC
expect fun networkDiModule(baseUrl: String, enableNetworkLogs: Boolean): Module

internal fun createHttpClient(
    engine: HttpClientEngine,
    networkLogger: co.touchlab.kermit.Logger? = null,
    tokenProvider: TokenProvider? = null,
    customModule: SerializersModule? = null
): HttpClient {
    return HttpClient(engine) {
        if (networkLogger != null) {
            install(Logging) {
                logger = object : Logger {
                    override fun log(message: String) {
                        networkLogger.withTag("HTTP Client").v { message }
                    }
                }
                level = LogLevel.ALL
            }
        }
        install(ContentNegotiation) {
            json(Json {
                isLenient = true
                ignoreUnknownKeys = true
                explicitNulls = false
                prettyPrint = true
                if (customModule != null) {
                    serializersModule = customModule
                }
            })
        }
        install(HttpTimeout) {
            requestTimeoutMillis = 60000
            connectTimeoutMillis = 60000
            socketTimeoutMillis = 60000
        }
        defaultRequest {
            contentType(ContentType.Application.Json)
            tokenProvider?.let { header(HttpHeaders.Authorization, "Bearer ${it.getAccessToken()}") }
        }
    }
}