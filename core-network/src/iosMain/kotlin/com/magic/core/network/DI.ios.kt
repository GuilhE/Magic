package com.magic.core.network

import com.magic.core.network.api.ApiClient
import io.ktor.client.engine.darwin.Darwin
import kotlin.experimental.ExperimentalObjCRefinement
import org.koin.core.module.Module
import org.koin.dsl.module

@OptIn(ExperimentalObjCRefinement::class)
@HiddenFromObjC
actual fun networkDiModule(baseUrl: String, enableNetworkLogs: Boolean): Module = module {
    single {
        ApiClient(
            client = createHttpClient(
                engine = Darwin.create(),
                networkLogger = if (enableNetworkLogs) co.touchlab.kermit.Logger else null,
            ),
            baseUrl = baseUrl
        )
    }
}