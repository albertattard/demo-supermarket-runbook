package demo.supermarket.cart;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.server.ResponseStatusException;

@Controller
public class CartController {

    private final CartService cartService;

    CartController(CartService cartService) {
        this.cartService = cartService;
    }

    @PostMapping("/cart/start")
    String startCart(@RequestParam(name = "productId", required = false) Long productId) {
        var cart = productId == null ? cartService.startCart() : cartService.startCartWithProduct(productId);
        return "redirect:/cart/" + cart.getPublicToken();
    }

    @GetMapping("/cart/{cartToken}")
    String cart(@PathVariable String cartToken, Model model) {
        addCartModel(model, cartService.findCart(cartToken));
        return "cart";
    }

    @PostMapping("/cart/{cartToken}/items")
    String addItem(@PathVariable String cartToken, @RequestParam Long productId, Model model) {
        try {
            cartService.addProduct(cartToken, productId);
        } catch (InvalidCartQuantityException ex) {
            addCartModel(model, cartService.findCart(cartToken));
            model.addAttribute("cartError", "Quantity must be between 1 and 99.");
            return "cart";
        }
        return "redirect:/cart/" + cartToken;
    }

    @PostMapping("/cart/{cartToken}/items/{itemId}")
    String updateItem(
        @PathVariable String cartToken,
        @PathVariable Long itemId,
        @RequestParam int quantity,
        Model model
    ) {
        try {
            cartService.updateQuantity(cartToken, itemId, quantity);
        } catch (InvalidCartQuantityException ex) {
            addCartModel(model, cartService.findCart(cartToken));
            model.addAttribute("cartError", "Quantity must be between 1 and 99.");
            return "cart";
        }
        return "redirect:/cart/" + cartToken;
    }

    @PostMapping("/cart/{cartToken}/items/{itemId}/remove")
    String removeItem(@PathVariable String cartToken, @PathVariable Long itemId) {
        cartService.removeItem(cartToken, itemId);
        return "redirect:/cart/" + cartToken;
    }

    @ExceptionHandler(ResponseStatusException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    String unavailableCart(ResponseStatusException ex, Model model) {
        if (ex.getStatusCode() != HttpStatus.NOT_FOUND) {
            throw ex;
        }
        model.addAttribute("message", "This cart is not available.");
        return "cart-unavailable";
    }

    private void addCartModel(Model model, CartSummary summary) {
        model.addAttribute("cart", summary.cart());
        model.addAttribute("subtotal", summary.subtotal());
    }
}
