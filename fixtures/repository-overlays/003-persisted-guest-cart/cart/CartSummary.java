package demo.supermarket.cart;

import java.math.BigDecimal;

public record CartSummary(Cart cart, BigDecimal subtotal) {
}
