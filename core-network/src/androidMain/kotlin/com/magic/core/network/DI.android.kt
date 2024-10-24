@file:Suppress("ACTUAL_ANNOTATIONS_NOT_MATCH_EXPECT")

package com.magic.core.network

import com.magic.core.network.api.ApiClient
import io.ktor.client.engine.okhttp.OkHttp
import org.koin.core.module.Module
import org.koin.dsl.module

actual fun networkDiModule(baseUrl: String, enableNetworkLogs: Boolean): Module = module {
    single {
        ApiClient(
            client = createHttpClient(
                engine = OkHttp.create(),
                networkLogger = if (enableNetworkLogs) co.touchlab.kermit.Logger else null,
            ),
            baseUrl = baseUrl
        )
    }
}