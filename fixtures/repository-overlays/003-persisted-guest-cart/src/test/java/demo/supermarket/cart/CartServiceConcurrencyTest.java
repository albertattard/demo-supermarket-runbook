package demo.supermarket.cart;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
class CartServiceConcurrencyTest {

    @Autowired
    private CartService cartService;

    @Test
    void concurrentAddsIncrementFromLatestPersistedQuantity() throws Exception {
        final CartView startedCart = cartService.startCart("sourdough-country-loaf");
        final ExecutorService executor = Executors.newFixedThreadPool(2);
        final CountDownLatch ready = new CountDownLatch(2);
        final CountDownLatch start = new CountDownLatch(1);
        try {
            final Future<?> first = executor.submit(() -> addProductWhenReleased(startedCart.token(), ready, start));
            final Future<?> second = executor.submit(() -> addProductWhenReleased(startedCart.token(), ready, start));

            ready.await();
            start.countDown();
            first.get();
            second.get();
        } finally {
            executor.shutdownNow();
        }

        final CartView cart = cartService.getActiveCart(startedCart.token());
        assertThat(cart.quantityFor("sourdough-country-loaf")).isEqualTo(3);
        assertThat(cart.subtotal()).isEqualByComparingTo("11.85");
    }

    private void addProductWhenReleased(
            final String cartToken,
            final CountDownLatch ready,
            final CountDownLatch start) {
        try {
            ready.countDown();
            start.await();
            cartService.addProduct(cartToken, "sourdough-country-loaf");
        } catch (final Exception ex) {
            throw new AssertionError(ex);
        }
    }
}
