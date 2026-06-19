package demo.supermarket.cart;

class InvalidCartQuantityException extends IllegalArgumentException {

    InvalidCartQuantityException(int quantity) {
        super("Cart quantity must be between 1 and 99: " + quantity);
    }
}
