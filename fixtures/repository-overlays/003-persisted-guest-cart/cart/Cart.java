package demo.supermarket.cart;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

@Entity
@Table(name = "carts")
public class Cart {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "public_token", nullable = false, unique = true, length = 64)
    private String publicToken;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private CartState state = CartState.ACTIVE;

    @Column(nullable = false)
    private Instant createdAt = Instant.now();

    @Column(nullable = false)
    private Instant updatedAt = Instant.now();

    @OneToMany(mappedBy = "cart", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<CartItem> items = new ArrayList<>();

    protected Cart() {
    }

    Cart(String publicToken) {
        this.publicToken = publicToken;
    }

    public Long getId() {
        return id;
    }

    public String getPublicToken() {
        return publicToken;
    }

    public CartState getState() {
        return state;
    }

    public List<CartItem> getItems() {
        return items;
    }

    void addItem(CartItem item) {
        items.add(item);
        item.assignTo(this);
        touch();
    }

    void removeItem(CartItem item) {
        items.remove(item);
        touch();
    }

    void touch() {
        updatedAt = Instant.now();
    }
}
