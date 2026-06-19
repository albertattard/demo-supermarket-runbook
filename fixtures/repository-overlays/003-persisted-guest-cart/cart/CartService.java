package demo.supermarket.cart;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.util.Base64;

import demo.supermarket.catalog.ProductRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@Transactional
public class CartService {

    private static final SecureRandom RANDOM = new SecureRandom();

    private final CartRepository cartRepository;
    private final ProductRepository productRepository;

    CartService(CartRepository cartRepository, ProductRepository productRepository) {
        this.cartRepository = cartRepository;
        this.productRepository = productRepository;
    }

    public Cart startCart() {
        var token = newToken();
        while (cartRepository.existsByPublicToken(token)) {
            token = newToken();
        }
        return cartRepository.save(new Cart(token));
    }

    public Cart startCartWithProduct(Long productId) {
        var cart = startCart();
        addProduct(cart.getPublicToken(), productId);
        return cart;
    }

    @Transactional(readOnly = true)
    public CartSummary findCart(String token) {
        return toSummary(findActiveCart(token));
    }

    public CartSummary addProduct(String token, Long productId) {
        var cart = findActiveCart(token);
        var product = productRepository.findById(productId)
            .filter(productCandidate -> productCandidate.isActive())
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found"));

        cart.getItems().stream()
            .filter(item -> item.getProduct().getId().equals(productId))
            .findFirst()
            .ifPresentOrElse(CartItem::increment, () -> cart.addItem(new CartItem(product, 1)));
        cart.touch();

        return toSummary(cart);
    }

    public CartSummary updateQuantity(String token, Long itemId, int quantity) {
        var cart = findActiveCart(token);
        findItem(cart, itemId).changeQuantity(quantity);
        cart.touch();
        return toSummary(cart);
    }

    public CartSummary removeItem(String token, Long itemId) {
        var cart = findActiveCart(token);
        cart.removeItem(findItem(cart, itemId));
        return toSummary(cart);
    }

    private Cart findActiveCart(String token) {
        return cartRepository.findByPublicToken(token)
            .filter(cart -> cart.getState() == CartState.ACTIVE)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Cart not found"));
    }

    private CartItem findItem(Cart cart, Long itemId) {
        return cart.getItems().stream()
            .filter(item -> item.getId().equals(itemId))
            .findFirst()
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Cart item not found"));
    }

    private CartSummary toSummary(Cart cart) {
        var subtotal = cart.getItems().stream()
            .map(CartItem::getLineTotal)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        return new CartSummary(cart, subtotal);
    }

    private static String newToken() {
        var bytes = new byte[24];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}
