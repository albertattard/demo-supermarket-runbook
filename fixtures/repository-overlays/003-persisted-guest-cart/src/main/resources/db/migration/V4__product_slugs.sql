alter table products add column slug varchar(120);

update products set slug = 'sourdough-country-loaf' where name = 'Sourdough Country Loaf';
update products set slug = 'wholegrain-bread-rolls' where name = 'Wholegrain Bread Rolls';
update products set slug = 'butter-croissants' where name = 'Butter Croissants';
update products set slug = 'organic-whole-milk' where name = 'Organic Whole Milk';
update products set slug = 'greek-style-yogurt' where name = 'Greek Style Yogurt';
update products set slug = 'mature-cheddar' where name = 'Mature Cheddar';
update products set slug = 'bananas' where name = 'Bananas';
update products set slug = 'cherry-tomatoes' where name = 'Cherry Tomatoes';
update products set slug = 'baby-spinach' where name = 'Baby Spinach';
update products set slug = 'italian-chopped-tomatoes' where name = 'Italian Chopped Tomatoes';
update products set slug = 'extra-virgin-olive-oil' where name = 'Extra Virgin Olive Oil';
update products set slug = 'basmati-rice' where name = 'Basmati Rice';
update products set slug = 'recycled-kitchen-towels' where name = 'Recycled Kitchen Towels';
update products set slug = 'lemon-dish-soap' where name = 'Lemon Dish Soap';
update products set slug = 'compostable-bin-liners' where name = 'Compostable Bin Liners';
update products set slug = 'plain-cotton-tote-bag' where name = 'Plain Cotton Tote Bag';
update products set slug = 'mulled-apple-punch' where name = 'Mulled Apple Punch';
update products set slug = 'discontinued-breakfast-cereal' where name = 'Discontinued Breakfast Cereal';

alter table products alter column slug set not null;
alter table products add constraint chk_products_slug_not_blank check (length(trim(slug)) > 0);
alter table products add constraint uq_products_slug unique (slug);
