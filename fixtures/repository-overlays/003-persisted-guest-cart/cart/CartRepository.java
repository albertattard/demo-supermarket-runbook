package demo.supermarket.cart;

import java.util.Optional;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

interface CartRepository extends JpaRepository<Cart, Long> {

    boolean existsByPublicToken(String publicToken);

    @EntityGraph(attributePaths = { "items", "items.product", "items.product.category" })
    Optional<Cart> findByPublicToken(String publicToken);
}
