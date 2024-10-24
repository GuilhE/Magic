import com.magic.core.network.api.ApiClient
import com.magic.core.network.api.core.ApiResult
import com.magic.core.network.api.errors.ApiError
import com.magic.core.network.api.requests.BaseRequest
import io.ktor.client.HttpClient
import io.ktor.client.engine.mock.MockEngine
import io.ktor.client.engine.mock.respond
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.HttpRequestBuilder
import io.ktor.http.ContentType
import io.ktor.http.HttpHeaders
import io.ktor.http.HttpMethod
import io.ktor.http.HttpStatusCode
import io.ktor.http.contentType
import io.ktor.http.headersOf
import io.ktor.serialization.kotlinx.json.json
import io.ktor.utils.io.ByteReadChannel
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.json.Json
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class ApiClientTest {

    @Test
    fun `Client perform succeeds`() = runTest {
        val mockEngine = MockEngine {
            respond(
                content = ByteReadChannel("""{"ip":"127.0.0.1"}"""),
                status = HttpStatusCode.OK,
                headers = headersOf(HttpHeaders.ContentType, "application/json")
            )
        }
        val httpClient = HttpClient(mockEngine) {
            install(ContentNegotiation) {
                json()
            }
        }
        val apiClient = ApiClient(httpClient, "https://api.example.com")

        val request = object : BaseRequest {
            override val path = "test-path"
            override val method = HttpMethod.Get
            override fun requestBuilder(): HttpRequestBuilder.() -> Unit = {
                contentType(ContentType.Application.Json)
            }
        }

        val result = apiClient.perform<Map<String, String>>(request)
        assertTrue(result is ApiResult.Success)
        assertEquals(mapOf("ip" to "127.0.0.1"), result.data)
    }

    @Test
    fun `Client perform fails with ApiError`() = runTest {
        val mockEngine = MockEngine {
            respond(
                content = ByteReadChannel("""{"status":"123", "error":"Ups!"}"""),
                status = HttpStatusCode.InternalServerError,
                headers = headersOf(HttpHeaders.ContentType, "application/json")
            )
        }
        val httpClient = HttpClient(mockEngine) {
            install(ContentNegotiation) {
                json(Json {
                    ignoreUnknownKeys = true
                })
            }
        }
        val apiClient = ApiClient(httpClient, "https://api.example.com")

        val request = object : BaseRequest {
            override val path = "test-path"
            override val method = HttpMethod.Get
            override fun requestBuilder(): HttpRequestBuilder.() -> Unit = {
                contentType(ContentType.Application.Json)
            }
        }

        val result = apiClient.perform<Map<String, String>>(request)
        assertTrue(result is ApiResult.Error)
        assertTrue(result.exception is ApiError)
        assertEquals((result.exception as ApiError).status, 123)
        assertEquals((result.exception as ApiError).error, "Ups!")
    }

    @Test
    fun `When client perform fails and ApiError deserialization fails the HttpStatusCode is delivered as ApiError `() = runTest {
        val mockEngine = MockEngine {
            respond(
                content = ByteReadChannel(""),
                status = HttpStatusCode.Unauthorized,
                headers = headersOf(HttpHeaders.ContentType, "application/json")
            )
        }
        val httpClient = HttpClient(mockEngine) {
            install(ContentNegotiation) {
                json()
            }
        }
        val apiClient = ApiClient(httpClient, "https://api.example.com")

        val request = object : BaseRequest {
            override val path = "test-path"
            override val method = HttpMethod.Get
            override fun requestBuilder(): HttpRequestBuilder.() -> Unit = {
                contentType(ContentType.Application.Json)
            }
        }

        val result = apiClient.perform<Map<String, String>>(request)
        assertTrue(result is ApiResult.Error)
        val error = result.exception
        assertTrue(error is ApiError)
        assertEquals(HttpStatusCode.Unauthorized.value, error.status)
        assertEquals(HttpStatusCode.Unauthorized.description, error.message)
    }
}