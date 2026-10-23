package com.apps.iatinyfish.data.repository

import com.apps.iatinyfish.data.remote.ProductOfferDto
import com.apps.iatinyfish.data.remote.SearchProductsRequest
import com.apps.iatinyfish.data.remote.SearchProductsResponse
import com.apps.iatinyfish.data.remote.TinyPriceApi
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.test.runTest
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.ResponseBody.Companion.toResponseBody
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import retrofit2.Response

class RemoteDealsRepositoryTest {
    @Test fun cancellationIsNotTurnedIntoANetworkFailure() = runTest {
        val repository = RemoteDealsRepository(object : TinyPriceApi {
            override suspend fun searchProducts(request: SearchProductsRequest): Response<SearchProductsResponse> {
                throw CancellationException("User started another search")
            }
        })
        val failure = try { repository.search("Switch"); null } catch (error: Exception) { error }
        assertTrue("Cancellation must remain cancellation", failure is CancellationException)
    }

    @Test fun hostedErrorPreservesTheReadableMessage() = runTest {
        val repository = RemoteDealsRepository(object : TinyPriceApi {
            override suspend fun searchProducts(request: SearchProductsRequest): Response<SearchProductsResponse> =
                Response.error(503, """{"error":"Servicio pendiente de configurar"}""".toResponseBody("application/json".toMediaType()))
        })
        val failure = try { repository.search("Switch"); null } catch (error: RemoteSearchException) { error }
        assertEquals("Servicio pendiente de configurar", failure?.message)
    }

    @Test fun successfulResponseRetainsTheSourceUrl() = runTest {
        val repository = RemoteDealsRepository(object : TinyPriceApi {
            override suspend fun searchProducts(request: SearchProductsRequest): Response<SearchProductsResponse> =
                Response.success(SearchProductsResponse(listOf(ProductOfferDto(
                    id = "offer-1", productName = "Switch OLED", sourceUrl = "https://example.com/switch",
                ))))
        })
        val offers = repository.search("Switch")
        assertEquals("Switch OLED", offers.single().productName)
        assertEquals("https://example.com/switch", offers.single().sourceUrl)
        assertEquals("Ver en fuente", offers.single().price)
    }
}
