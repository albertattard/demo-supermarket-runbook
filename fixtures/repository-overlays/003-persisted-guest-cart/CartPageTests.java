package demo.supermarket;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.matchesPattern;
import static org.hamcrest.Matchers.not;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrlPattern;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.regex.Pattern;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class CartPageTests {

    private static final Pattern CART_LOCATION = Pattern.compile(".*/cart/([^/?]+)");

    @Autowired
    private MockMvc mockMvc;

    @Test
    void startingCartCreatesOpaquePublicUrl() throws Exception {
        mockMvc.perform(post("/cart/start").with(csrf()))
            .andExpect(status().is3xxRedirection())
            .andExpect(redirectedUrlPattern("/cart/*"))
            .andExpect(header().string("Location", matchesPattern("/cart/[A-Za-z0-9_-]{32}")));
    }

    @Test
    void addingSameProductTwiceIncrementsExistingLineAndSubtotal() throws Exception {
        var token = startCartWithProduct(1L);

        mockMvc.perform(post("/cart/{cartToken}/items", token).with(csrf()).param("productId", "1"))
            .andExpect(status().is3xxRedirection());

        mockMvc.perform(get("/cart/{cartToken}", token))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("Bananas")))
            .andExpect(content().string(containsString("value=\"2\"")))
            .andExpect(content().string(containsString("€0.70")));
    }

    @Test
    void quantityUpdatesRejectOutOfRangeValues() throws Exception {
        var token = startCartWithProduct(1L);
        var itemId = firstItemId(token);

        mockMvc.perform(post("/cart/{cartToken}/items/{itemId}", token, itemId).with(csrf()).param("quantity", "0"))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("value=\"1\"")))
            .andExpect(content().string(containsString("Quantity must be between 1 and 99.")));

        mockMvc.perform(post("/cart/{cartToken}/items/{itemId}", token, itemId).with(csrf()).param("quantity", "100"))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("value=\"1\"")));
    }

    @Test
    void addingExistingProductAtMaximumQuantityIsRejected() throws Exception {
        var token = startCartWithProduct(1L);
        var itemId = firstItemId(token);

        mockMvc.perform(post("/cart/{cartToken}/items/{itemId}", token, itemId).with(csrf()).param("quantity", "99"))
            .andExpect(status().is3xxRedirection());

        mockMvc.perform(post("/cart/{cartToken}/items", token).with(csrf()).param("productId", "1"))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("value=\"99\"")))
            .andExpect(content().string(containsString("Quantity must be between 1 and 99.")));
    }

    @Test
    void removingCartLineWorks() throws Exception {
        var token = startCartWithProduct(1L);
        var itemId = firstItemId(token);

        mockMvc.perform(post("/cart/{cartToken}/items/{itemId}/remove", token, itemId).with(csrf()))
            .andExpect(status().is3xxRedirection());

        mockMvc.perform(get("/cart/{cartToken}", token))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("Your bag is empty")))
            .andExpect(content().string(not(containsString("Bananas"))));
    }

    @Test
    void unknownCartTokenShowsUnavailablePage() throws Exception {
        mockMvc.perform(get("/cart/does-not-exist"))
            .andExpect(status().isNotFound())
            .andExpect(content().string(containsString("This cart is not available.")));
    }

    private String startCartWithProduct(Long productId) throws Exception {
        var response = mockMvc.perform(post("/cart/start").with(csrf()).param("productId", productId.toString()))
            .andExpect(status().is3xxRedirection())
            .andReturn()
            .getResponse();
        var matcher = CART_LOCATION.matcher(response.getHeader("Location"));
        if (!matcher.matches()) {
            throw new IllegalStateException("Unexpected cart redirect: " + response.getHeader("Location"));
        }
        return matcher.group(1);
    }

    private String firstItemId(String token) throws Exception {
        var html = mockMvc.perform(get("/cart/{cartToken}", token))
            .andExpect(status().isOk())
            .andReturn()
            .getResponse()
            .getContentAsString();
        var matcher = Pattern.compile("/cart/" + Pattern.quote(token) + "/items/(\\d+)").matcher(html);
        if (!matcher.find()) {
            throw new IllegalStateException("Could not find cart item id in cart page.");
        }
        return matcher.group(1);
    }
}
