package demo.supermarket;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class CatalogPageTests {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void homePageShowsSeededCatalogToAnonymousCustomers() throws Exception {
        mockMvc.perform(get("/"))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("Product catalog")))
            .andExpect(content().string(containsString("Bananas")))
            .andExpect(content().string(containsString("Fresh Produce")))
            .andExpect(content().string(containsString("each")))
            .andExpect(content().string(containsString("€0.35")))
            .andExpect(content().string(not(containsString("Archived Dish Soap"))));
    }

    @Test
    void productsPageSupportsCategoryFiltering() throws Exception {
        mockMvc.perform(get("/products").param("category", "2"))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("Whole Milk")))
            .andExpect(content().string(containsString("Greek Yogurt")))
            .andExpect(content().string(not(containsString("Bananas"))));
    }

    @Test
    void productsPageSupportsTextSearchByNameAndDescription() throws Exception {
        mockMvc.perform(get("/products").param("q", "smoothie"))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("Bananas")))
            .andExpect(content().string(not(containsString("Whole Milk"))));

        mockMvc.perform(get("/products").param("q", "sourdough"))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("Sourdough Loaf")))
            .andExpect(content().string(not(containsString("Orange Juice"))));
    }
}
