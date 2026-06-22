package demo.supermarket.cart;

import java.util.regex.Pattern;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.matchesPattern;
import static org.hamcrest.Matchers.not;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class CartControllerTest {

    private static final Pattern CART_PATH = Pattern.compile("/cart/[A-Za-z0-9_-]{32,}");

    @Autowired
    private MockMvc mvc;

    @Autowired
    private JdbcTemplate jdbc;

    @Test
    void startsCartWithOpaqueTokenAndOptionalProductSlug() throws Exception {
        final String cartPath = startCart("sourdough-country-loaf");

        assertThat(cartPath).matches(CART_PATH);

        mvc.perform(get(cartPath))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("Sourdough Country Loaf")))
            .andExpect(content().string(containsString("3,95")))
            .andExpect(content().string(not(containsString("productId"))))
            .andExpect(content().string(not(containsString("cartId"))));
    }

    @Test
    void canReturnToCartScopedCatalogAfterStartingCartWithProductSlug() throws Exception {
        mvc.perform(post("/cart/start")
                .with(csrf())
                .param("productSlug", "sourdough-country-loaf")
                .param("returnTo", "catalog"))
            .andExpect(status().isSeeOther())
            .andExpect(header().string("Location", matchesPattern("/cart/[A-Za-z0-9_-]{32,}/products")));
    }

    @Test
    void addingSameProductTwiceIncrementsCurrentServerQuantity() throws Exception {
        final String cartPath = startCart("sourdough-country-loaf");

        mvc.perform(post(cartPath + "/items")
                .with(csrf())
                .param("productSlug", "sourdough-country-loaf"))
            .andExpect(status().isSeeOther())
            .andExpect(header().string("Location", cartPath));

        mvc.perform(get(cartPath))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("value=\"2\"")))
            .andExpect(content().string(containsString("7,90")));
    }

    @Test
    void catalogReturnMutationsRedirectBackToCartScopedCatalog() throws Exception {
        final String cartPath = startCart("sourdough-country-loaf");

        mvc.perform(post(cartPath + "/items")
                .with(csrf())
                .param("productSlug", "sourdough-country-loaf")
                .param("returnTo", "catalog"))
            .andExpect(status().isSeeOther())
            .andExpect(header().string("Location", cartPath + "/products"));

        mvc.perform(post(cartPath + "/items/sourdough-country-loaf")
                .with(csrf())
                .param("quantity", "1")
                .param("returnTo", "catalog"))
            .andExpect(status().isSeeOther())
            .andExpect(header().string("Location", cartPath + "/products"));

        mvc.perform(post(cartPath + "/items/sourdough-country-loaf/remove")
                .with(csrf())
                .param("returnTo", "catalog"))
            .andExpect(status().isSeeOther())
            .andExpect(header().string("Location", cartPath + "/products"));
    }

    @Test
    void updatesQuantityRemovesLineAndTreatsRepeatedRemoveAsLatestCartState() throws Exception {
        final String cartPath = startCart("sourdough-country-loaf");

        mvc.perform(post(cartPath + "/items/sourdough-country-loaf")
                .with(csrf())
                .param("quantity", "3"))
            .andExpect(status().isSeeOther())
            .andExpect(header().string("Location", cartPath));

        mvc.perform(get(cartPath))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("value=\"3\"")))
            .andExpect(content().string(containsString("11,85")));

        mvc.perform(post(cartPath + "/items/sourdough-country-loaf/remove").with(csrf()))
            .andExpect(status().isSeeOther());

        mvc.perform(post(cartPath + "/items/sourdough-country-loaf/remove").with(csrf()))
            .andExpect(status().isSeeOther());

        mvc.perform(get(cartPath))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("Your cart is empty")));
    }

    @Test
    void updatingKnownProductThatIsNotInCartReturnsLatestCartStateWithoutAddingLine() throws Exception {
        final String cartPath = startCart("sourdough-country-loaf");

        mvc.perform(post(cartPath + "/items/butter-croissants")
                .with(csrf())
                .param("quantity", "2"))
            .andExpect(status().isSeeOther())
            .andExpect(header().string("Location", cartPath));

        mvc.perform(get(cartPath))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("Sourdough Country Loaf")))
            .andExpect(content().string(not(containsString("Butter Croissants"))))
            .andExpect(content().string(containsString("value=\"1\"")));
    }

    @Test
    void removingKnownProductThatIsNotInCartReturnsLatestCartState() throws Exception {
        final String cartPath = startCart("sourdough-country-loaf");

        mvc.perform(post(cartPath + "/items/butter-croissants/remove").with(csrf()))
            .andExpect(status().isSeeOther())
            .andExpect(header().string("Location", cartPath));

        mvc.perform(get(cartPath))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("Sourdough Country Loaf")))
            .andExpect(content().string(not(containsString("Butter Croissants"))))
            .andExpect(content().string(containsString("value=\"1\"")));
    }

    @Test
    void rejectsInvalidQuantityWithoutMutation() throws Exception {
        final String cartPath = startCart("sourdough-country-loaf");

        mvc.perform(post(cartPath + "/items/sourdough-country-loaf")
                .with(csrf())
                .param("quantity", "100"))
            .andExpect(status().isBadRequest())
            .andExpect(content().string(containsString("Quantity must be between 1 and 99.")));

        mvc.perform(get(cartPath))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("value=\"1\"")));
    }

    @Test
    void rejectsAddingPastMaximumQuantityWithoutMutation() throws Exception {
        final String cartPath = startCart("sourdough-country-loaf");
        setQuantity(cartPath, "sourdough-country-loaf", "99");

        mvc.perform(post(cartPath + "/items")
                .with(csrf())
                .param("productSlug", "sourdough-country-loaf"))
            .andExpect(status().isBadRequest())
            .andExpect(content().string(containsString("Quantity must be between 1 and 99.")))
            .andExpect(content().string(containsString("value=\"99\"")));

        mvc.perform(get(cartPath))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("value=\"99\"")));
    }

    @Test
    void htmxGetAndInvalidMutationRenderCartFragment() throws Exception {
        final String cartPath = startCart("sourdough-country-loaf");

        mvc.perform(get(cartPath).header("HX-Request", "true"))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("id=\"cart-content\"")))
            .andExpect(content().string(not(containsString("<!doctype html>"))));

        mvc.perform(post(cartPath + "/items/sourdough-country-loaf")
                .with(csrf())
                .header("HX-Request", "true")
                .param("quantity", "0"))
            .andExpect(status().isBadRequest())
            .andExpect(content().string(containsString("id=\"cart-content\"")))
            .andExpect(content().string(not(containsString("<!doctype html>"))));
    }

    @Test
    void htmxSuccessfulMutationsRenderLatestCartFragment() throws Exception {
        final String cartPath = startCart("sourdough-country-loaf");

        mvc.perform(post(cartPath + "/items")
                .with(csrf())
                .header("HX-Request", "true")
                .param("productSlug", "sourdough-country-loaf"))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("id=\"cart-content\"")))
            .andExpect(content().string(containsString("value=\"2\"")))
            .andExpect(content().string(containsString("7,90")))
            .andExpect(content().string(not(containsString("<!doctype html>"))));

        mvc.perform(post(cartPath + "/items/sourdough-country-loaf")
                .with(csrf())
                .header("HX-Request", "true")
                .param("quantity", "3"))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("id=\"cart-content\"")))
            .andExpect(content().string(containsString("value=\"3\"")))
            .andExpect(content().string(containsString("11,85")))
            .andExpect(content().string(not(containsString("<!doctype html>"))));

        mvc.perform(post(cartPath + "/items/sourdough-country-loaf/remove")
                .with(csrf())
                .header("HX-Request", "true"))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("id=\"cart-content\"")))
            .andExpect(content().string(containsString("Your cart is empty")))
            .andExpect(content().string(not(containsString("<!doctype html>"))));
    }

    @Test
    void htmxCatalogMutationsRenderProductControlAndCartLinkOutOfBand() throws Exception {
        final String cartPath = startCart("sourdough-country-loaf");

        mvc.perform(post(cartPath + "/items")
                .with(csrf())
                .header("HX-Request", "true")
                .param("productSlug", "sourdough-country-loaf")
                .param("returnTo", "catalog"))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("id=\"catalog-cart-control-sourdough-country-loaf\"")))
            .andExpect(content().string(containsString("value=\"2\"")))
            .andExpect(content().string(containsString("id=\"catalog-cart-link\"")))
            .andExpect(content().string(containsString("hx-swap-oob=\"outerHTML\"")))
            .andExpect(content().string(containsString("class=\"cart-count\">2</span>")))
            .andExpect(content().string(not(containsString("<!doctype html>"))));

        mvc.perform(post(cartPath + "/items/sourdough-country-loaf/remove")
                .with(csrf())
                .header("HX-Request", "true")
                .param("returnTo", "catalog"))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("id=\"catalog-cart-control-sourdough-country-loaf\"")))
            .andExpect(content().string(containsString("Add to cart")))
            .andExpect(content().string(containsString("id=\"catalog-cart-link\"")))
            .andExpect(content().string(containsString("hx-swap-oob=\"outerHTML\"")))
            .andExpect(content().string(not(containsString("class=\"cart-count\""))))
            .andExpect(content().string(not(containsString("<!doctype html>"))));
    }

    @Test
    void htmxCatalogInvalidQuantityRendersProductControlAndCartLinkOutOfBand() throws Exception {
        final String cartPath = startCart("sourdough-country-loaf");

        mvc.perform(post(cartPath + "/items/sourdough-country-loaf")
                .with(csrf())
                .header("HX-Request", "true")
                .param("quantity", "0")
                .param("returnTo", "catalog"))
            .andExpect(status().isBadRequest())
            .andExpect(content().string(containsString("id=\"catalog-cart-control-sourdough-country-loaf\"")))
            .andExpect(content().string(containsString("Quantity must be between 1 and 99.")))
            .andExpect(content().string(containsString("value=\"1\"")))
            .andExpect(content().string(containsString("id=\"catalog-cart-link\"")))
            .andExpect(content().string(containsString("hx-swap-oob=\"outerHTML\"")))
            .andExpect(content().string(not(containsString("id=\"cart-content\""))))
            .andExpect(content().string(not(containsString("<!doctype html>"))));
    }

    @Test
    void htmxCatalogRejectsAddingPastMaximumQuantity() throws Exception {
        final String cartPath = startCart("sourdough-country-loaf");
        setQuantity(cartPath, "sourdough-country-loaf", "99");

        mvc.perform(post(cartPath + "/items")
                .with(csrf())
                .header("HX-Request", "true")
                .param("productSlug", "sourdough-country-loaf")
                .param("returnTo", "catalog"))
            .andExpect(status().isBadRequest())
            .andExpect(content().string(containsString("id=\"catalog-cart-control-sourdough-country-loaf\"")))
            .andExpect(content().string(containsString("Quantity must be between 1 and 99.")))
            .andExpect(content().string(containsString("value=\"99\"")))
            .andExpect(content().string(containsString("disabled")))
            .andExpect(content().string(containsString("id=\"catalog-cart-link\"")))
            .andExpect(content().string(containsString("hx-swap-oob=\"outerHTML\"")))
            .andExpect(content().string(not(containsString("<!doctype html>"))));
    }

    @Test
    void unknownTokenAndUnknownProductSlugReturnCustomerFacingNotFound() throws Exception {
        mvc.perform(get("/cart/not-a-real-token"))
            .andExpect(status().isNotFound())
            .andExpect(content().string(containsString("Cart not found")))
            .andExpect(content().string(containsString("Back to products")));

        final String cartPath = startCart("sourdough-country-loaf");

        mvc.perform(post(cartPath + "/items/does-not-exist")
                .with(csrf())
                .param("quantity", "2"))
            .andExpect(status().isNotFound())
            .andExpect(content().string(containsString("Product not found")));
    }

    @Test
    void unknownTokenMutationsReturnCustomerFacingNotFound() throws Exception {
        mvc.perform(post("/cart/not-a-real-token/items")
                .with(csrf())
                .param("productSlug", "sourdough-country-loaf"))
            .andExpect(status().isNotFound())
            .andExpect(content().string(containsString("Cart not found")))
            .andExpect(content().string(containsString("Back to products")));

        mvc.perform(post("/cart/not-a-real-token/items/sourdough-country-loaf")
                .with(csrf())
                .param("quantity", "2"))
            .andExpect(status().isNotFound())
            .andExpect(content().string(containsString("Cart not found")))
            .andExpect(content().string(containsString("Back to products")));

        mvc.perform(post("/cart/not-a-real-token/items/sourdough-country-loaf/remove").with(csrf()))
            .andExpect(status().isNotFound())
            .andExpect(content().string(containsString("Cart not found")))
            .andExpect(content().string(containsString("Back to products")));
    }

    @Test
    void nonActiveCartTokensAreNotUsable() throws Exception {
        final String checkedOutToken = "checked-out-token-12345678901234567890";
        jdbc.update("""
                insert into carts (token, state, created_at, updated_at)
                values (?, 'CHECKED_OUT', current_timestamp, current_timestamp)
                """, checkedOutToken);

        mvc.perform(get("/cart/" + checkedOutToken))
            .andExpect(status().isNotFound())
            .andExpect(content().string(containsString("Cart not found")))
            .andExpect(content().string(containsString("Back to products")));

        mvc.perform(post("/cart/" + checkedOutToken + "/items")
                .with(csrf())
                .param("productSlug", "sourdough-country-loaf"))
            .andExpect(status().isNotFound())
            .andExpect(content().string(containsString("Cart not found")))
            .andExpect(content().string(containsString("Back to products")));
    }

    private String startCart(final String productSlug) throws Exception {
        final MvcResult result = mvc.perform(post("/cart/start")
                .with(csrf())
                .param("productSlug", productSlug))
            .andExpect(status().isSeeOther())
            .andExpect(header().string("Location", matchesPattern(CART_PATH.pattern())))
            .andReturn();
        return result.getResponse().getHeader("Location");
    }

    private void setQuantity(final String cartPath, final String productSlug, final String quantity) throws Exception {
        mvc.perform(post(cartPath + "/items/" + productSlug)
                .with(csrf())
                .param("quantity", quantity))
            .andExpect(status().isSeeOther())
            .andExpect(header().string("Location", cartPath));
    }
}
