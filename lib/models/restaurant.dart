class Review {
  final String reviewer;
  final int rating;
  final String comment;

  Review({required this.reviewer, required this.rating, required this.comment});
}

class Item {
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Item({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Item &&
            other.name == name &&
            other.description == description &&
            other.price == price &&
            other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => Object.hash(name, description, price, imageUrl);
}

class Restaurant {
  String id;
  String name;
  String address;
  String attributes;
  String imageUrl;
  String imageCredits;
  double distance;
  double rating;
  List<Item> items;
  List<Review> reviews;

  Restaurant(
    this.id,
    this.name,
    this.address,
    this.attributes,
    this.imageUrl,
    this.imageCredits,
    this.distance,
    this.rating,
    this.items, {
    List<Review>? reviews,
  }) : reviews = reviews ?? [];

  String getRatingAndDistance() {
    return '''Rating: ${rating.toStringAsFixed(1)} ★ | Distance: ${distance.toStringAsFixed(1)} miles''';
  }
}

List<Restaurant> restaurants = [
  Restaurant(
    '0',
    'The Blue Prawn',
    '676 Cedar St, New York, PA 19113',
    'Seafood, Healthy, Organic',
    'assets/restaurants/TheBluePrawn.webp',
    'assets/restaurant_credits/TheBluePrawn_credit.jpg',
    2.1,
    4.5,
    [
      Item(
        name: 'Ocean Bounty Salad',
        description:
            '''A fresh mix of organic greens, cherry tomatoes, avocados, topped with succulent prawns and a lemon vinaigrette.''',
        price: 14.99,
        imageUrl: 'assets/item_images/ocean_bounty_salad.jpg',
      ),
      Item(
        name: 'Grilled Prawn Tacos',
        description:
            '''Soft organic tortillas filled with seasoned grilled prawns, fresh cabbage slaw, and a zesty avocado salsa.''',
        price: 16.99,
        imageUrl: 'assets/item_images/grilled_prawn_tacos.jpg',
      ),
      Item(
        name: 'Blue Prawn Risotto',
        description:
            '''Creamy organic Arborio rice cooked with white wine and garlic, enriched with blue prawns and sprinkled with parmesan.''',
        price: 19.99,
        imageUrl: 'assets/item_images/blue_prawn_risotto.jpg',
      ),
      Item(
        name: 'Seaweed-Wrapped Salmon',
        description:
            '''Organic salmon fillet wrapped in seaweed, steamed to perfection, served with quinoa and a side of roasted veggies.''',
        price: 21.99,
        imageUrl: 'assets/item_images/seaweed_wrapped_salmon.jpg',
      ),
      Item(
        name: 'Lobster & Prawn Soup',
        description:
            '''A rich and hearty soup made from fresh organic lobster and prawns, complemented with seasonal herbs and a touch of coconut milk.''',
        price: 17.99,
        imageUrl: 'assets/item_images/lobster_prawn_soup.jpg',
      ),
    ],
  ),
  Restaurant(
    '1',
    "Mama Rosa's Pizza",
    '603 Cedar St, Chicago, AZ 92294',
    'Pizza, Italian, Comfort Food',
    'assets/restaurants/MamaRosasPizza.webp',
    'assets/restaurant_credits/MamaRosasPizza_credit.jpg',
    0.7,
    4.7,
    [
      Item(
        name: 'Margherita Classic',
        description:
            '''Timeless blend of ripe tomatoes, fresh basil, mozzarella cheese, and a touch of olive oil on a thin crust.''',
        price: 12.99,
        imageUrl: 'assets/item_images/margherita_classic.jpg',
      ),
      Item(
        name: 'Pepperoni Passion',
        description:
            '''Generous layers of spicy pepperoni on a bed of mozzarella and marinara sauce.''',
        price: 14.99,
        imageUrl: 'assets/item_images/pepperoni_passion.jpg',
      ),
      Item(
        name: 'Mamas Veggie Supreme',
        description:
            '''A delightful array of bell peppers, olives, red onions, mushrooms, and spinach with feta and mozzarella cheese.''',
        price: 13.99,
        imageUrl: 'assets/item_images/mamas_veggie_supreme.jpg',
      ),
      Item(
        name: 'Spaghetti Carbonara',
        description:
            '''Creamy pasta cooked with crisp pancetta, eggs, and parmesan cheese, sprinkled with parsley.''',
        price: 15.99,
        imageUrl: 'assets/item_images/spaghetti_carbonara.jpg',
      ),
      Item(
        name: 'Chicken Parmesan',
        description:
            '''Tender breaded chicken breast topped with marinara sauce, mozzarella, and parmesan cheese, served with spaghetti.''',
        price: 17.99,
        imageUrl: 'assets/item_images/chicken_parmesan.jpg',
      ),
      Item(
        name: 'Tiramisu Delight',
        description:
            '''Classic Italian dessert made with layers of coffee-soaked ladyfingers and rich mascarpone cream, dusted with cocoa.''',
        price: 7.99,
        imageUrl: 'assets/item_images/tiramisu_delight.jpg',
      ),
    ],
  ),
  Restaurant(
    '2',
    'Bistro De Paris',
    '810 Main St, San Jose, NY 19113',
    'French, Fine Dining, Wine',
    'assets/restaurants/BistroDeParis.jpg',
    'assets/restaurant_credits/BistroDeParis_credit.jpg',
    3.3,
    4.8,
    [
      Item(
        name: 'Coq au Vin',
        description:
            '''Tender chicken slow-cooked in a rich red wine sauce with mushrooms, pearl onions, and lardons.''',
        price: 26.99,
        imageUrl: 'assets/item_images/coq_au_vin.jpg',
      ),
      Item(
        name: 'Bouillabaisse',
        description:
            '''Provencal fish stew made with a blend of fish, shellfish, leeks, onions, tomatoes, and served with a side of rouille sauce.''',
        price: 29.99,
        imageUrl: 'assets/item_images/bouillabaisse.jpg',
      ),
      Item(
        name: 'Duck à lOrange',
        description:
            '''Roast duck served with a sweet and tangy orange sauce, complemented by seasonal vegetables.''',
        price: 28.99,
        imageUrl: 'assets/item_images/duck_lorange.jpg',
      ),
      Item(
        name: 'Ratatouille Niçoise',
        description:
            '''A flavorful stew of eggplant, bell peppers, zucchini, and tomatoes, seasoned with fresh herbs from Provence.''',
        price: 22.99,
        imageUrl: 'assets/item_images/ratatouille_ni_oise.jpg',
      ),
      Item(
        name: 'Crème Brûlée',
        description:
            '''Creamy vanilla custard topped with a layer of hardened caramelized sugar.''',
        price: 9.99,
        imageUrl: 'assets/item_images/cr_me_br_l_e.jpg',
      ),
      Item(
        name: 'Chateau Bordeaux',
        description:
            '''Fine-aged red wine from the Bordeaux region, boasting deep flavors of plum, black currant, and hints of cedar.''',
        price: 49.99,
        imageUrl: 'assets/item_images/chateau_bordeaux.jpg',
      ),
    ],
  ),
  Restaurant(
    '3',
    'Green Zenphony',
    '810 Main St, San Jose, NY 19113',
    'Vegan, Vegetarian, Healthy',
    'assets/restaurants/GreenZenphony.jpg',
    'assets/restaurant_credits/GreenZenphony_credit.jpg',
    1.5,
    4.4,
    [
      Item(
        name: 'Mystical Mushroom Ramen',
        description:
            '''Hearty broth infused with shiitake and maitake mushrooms, served with whole grain noodles, tofu, and seasonal greens.''',
        price: 14.99,
        imageUrl: 'assets/item_images/mystical_mushroom_ramen.jpg',
      ),
      Item(
        name: 'Golden Turmeric Bowl',
        description:
            '''A vibrant blend of quinoa, roasted vegetables, chickpeas, and drizzled with a turmeric-tahini dressing.''',
        price: 12.99,
        imageUrl: 'assets/item_images/golden_turmeric_bowl.jpg',
      ),
      Item(
        name: 'Zen Buddha Wrap',
        description:
            '''A hearty wrap filled with hummus, avocado, shredded beets, carrots, and sprouts. Served with a side of kale chips.''',
        price: 10.99,
        imageUrl: 'assets/item_images/zen_buddha_wrap.jpg',
      ),
      Item(
        name: 'Green Harmony Smoothie',
        description:
            '''A refreshing blend of spinach, cucumber, green apple, chia seeds, and coconut water.''',
        price: 6.99,
        imageUrl: 'assets/item_images/green_harmony_smoothie.jpg',
      ),
      Item(
        name: 'Avocado Chocolate Mousse',
        description:
            '''A creamy and rich mousse made from ripe avocados, cacao, and sweetened with agave nectar.''',
        price: 7.99,
        imageUrl: 'assets/item_images/avocado_chocolate_mousse.jpg',
      ),
      Item(
        name: 'Serenity Herbal Tea',
        description:
            '''A soothing blend of chamomile, lavender, and rose petals. Perfect for relaxation.''',
        price: 4.99,
        imageUrl: 'assets/item_images/serenity_herbal_tea.jpg',
      ),
    ],
  ),
  Restaurant(
    '4',
    'Tandoori Flame',
    '810 Main St, San Jose, NY 19113',
    'Indian, Spicy, Vegan Options',
    'assets/restaurants/TandooriFlame.jpg',
    'assets/restaurant_credits/TandooriFlame_credit.jpg',
    2.8,
    4.2,
    [
      Item(
        name: 'Butter Chicken',
        description:
            '''Tender chicken pieces marinated in yogurt and spices, cooked in a rich tomato-based gravy with a touch of cream.''',
        price: 15.99,
        imageUrl: 'assets/item_images/butter_chicken.jpg',
      ),
      Item(
        name: 'Paneer Tikka Masala',
        description:
            '''Soft paneer cubes cooked in a spicy and creamy tomato gravy, infused with aromatic herbs.''',
        price: 14.99,
        imageUrl: 'assets/item_images/paneer_tikka_masala.jpg',
      ),
      Item(
        name: 'Chana Masala',
        description:
            '''Hearty chickpeas simmered in a tangy and spicy tomato gravy, garnished with fresh cilantro.''',
        price: 12.99,
        imageUrl: 'assets/item_images/chana_masala.jpg',
      ),
      Item(
        name: 'Tandoori Broccoli',
        description:
            '''Broccoli florets marinated in a blend of yogurt and spices, then roasted in the tandoor to perfection.''',
        price: 11.99,
        imageUrl: 'assets/item_images/tandoori_broccoli.jpg',
      ),
      Item(
        name: 'Lamb Rogan Josh',
        description:
            '''Slow-cooked lamb chunks in a rich and aromatic gravy, made from onions, yogurt, and a blend of spices.''',
        price: 18.99,
        imageUrl: 'assets/item_images/lamb_rogan_josh.jpg',
      ),
      Item(
        name: 'Vegan Biryani',
        description:
            '''Flavorful rice dish cooked with a medley of vegetables and aromatic spices, served with a side of vegan raita.''',
        price: 14.99,
        imageUrl: 'assets/item_images/vegan_biryani.jpg',
      ),
    ],
  ),
  Restaurant(
    '5',
    'El Toro Loco',
    '810 Main St, San Jose, NY 19113',
    'Mexican, Tacos, Margaritas',
    'assets/restaurants/ElToroLoco.jpg',
    'assets/restaurant_credits/ElToroLoco_credit.jpg',
    0.9,
    4.3,
    [
      Item(
        name: 'Carne Asada Tacos',
        description:
            '''Grilled steak tacos served with fresh cilantro, diced onions, and a squeeze of lime.''',
        price: 13.99,
        imageUrl: 'assets/item_images/carne_asada_tacos.jpg',
      ),
      Item(
        name: 'Pescado Tacos',
        description:
            '''Lightly breaded fish tacos topped with cabbage slaw, pico de gallo, and tangy chipotle mayo.''',
        price: 14.99,
        imageUrl: 'assets/item_images/pescado_tacos.jpg',
      ),
      Item(
        name: 'Enchiladas',
        description:
            '''Soft tortillas filled with sautéed vegetables, smothered in red enchilada sauce and melted cheese.''',
        price: 12.99,
        imageUrl: 'assets/item_images/enchiladas.jpg',
      ),
      Item(
        name: 'Guacamole & Chips',
        description:
            'Freshly made guacamole served with crispy tortilla chips.',
        price: 6.99,
        imageUrl: 'assets/item_images/guacamole_chips.jpg',
      ),
      Item(
        name: 'Classic Margarita',
        description:
            '''A refreshing blend of tequila, lime juice, triple sec, served on the rocks with a salted rim.''',
        price: 8.99,
        imageUrl: 'assets/item_images/classic_margarita.jpg',
      ),
      Item(
        name: 'Churros with Chocolate Sauce',
        description:
            '''Crispy golden churros dusted with cinnamon sugar, served with a side of rich chocolate dipping sauce.''',
        price: 7.99,
        imageUrl: 'assets/item_images/churros_with_chocolate_sauce.jpg',
      ),
    ],
  ),
  Restaurant(
    '6',
    'Sushi Delight',
    '810 Main St, San Jose, NY 19113',
    'Japanese, Sushi, Seafood',
    'assets/restaurants/OldKyotoSushi.jpg',
    'assets/restaurant_credits/OldKyotoSushi_credit.jpg',
    4.2,
    4.6,
    [
      Item(
        name: 'Salmon Nigiri',
        description:
            '''Fresh, raw salmon slices served atop hand-pressed vinegar-seasoned rice.''',
        price: 13.99,
        imageUrl: 'assets/item_images/salmon_nigiri.jpg',
      ),
      Item(
        name: 'Tuna Maki Roll',
        description:
            '''Sushi roll filled with fresh tuna, cucumber, and avocado, wrapped in seaweed and sushi rice.''',
        price: 14.99,
        imageUrl: 'assets/item_images/tuna_maki_roll.jpg',
      ),
      Item(
        name: 'Vegetable Tempura',
        description:
            '''Assorted vegetables lightly battered and deep-fried until crispy, served with tempura dipping sauce.''',
        price: 12.99,
        imageUrl: 'assets/item_images/vegetable_tempura.jpg',
      ),
      Item(
        name: 'Miso Soup',
        description:
            '''Traditional Japanese soup made with soybean paste, tofu, and seaweed.''',
        price: 6.99,
        imageUrl: 'assets/item_images/miso_soup.jpg',
      ),
      Item(
        name: 'Green Tea Ice Cream',
        description: 'Refreshing and creamy green tea-flavored ice cream.',
        price: 8.99,
        imageUrl: 'assets/item_images/green_tea_ice_cream.jpg',
      ),
      Item(
        name: 'Tempura Banana with Sesame Seeds',
        description:
            '''Ripe banana slices dipped in tempura batter, deep-fried until golden, and sprinkled with sesame seeds.''',
        price: 7.99,
        imageUrl: 'assets/item_images/tempura_banana_with_sesame_seeds.jpg',
      ),
    ],
  ),
  Restaurant(
    '7',
    'Tuscan Olive',
    '810 Main St, San Jose, NY 19113',
    'Italian, Pasta, Wine',
    'assets/restaurants/TuscanOlive.jpg',
    'assets/restaurant_credits/TuscanOlive_credit.jpg',
    3.5,
    4.7,
    [
      Item(
        name: 'Fettuccine Alfredo',
        description:
            '''Creamy pasta dish made with butter, heavy cream, and Parmesan cheese, topped with freshly chopped parsley.''',
        price: 14.99,
        imageUrl: 'assets/item_images/fettuccine_alfredo.jpg',
      ),
      Item(
        name: 'Spaghetti Carbonara',
        description:
            '''Classic Roman dish with spaghetti, eggs, Pecorino Romano, guanciale, and pepper.''',
        price: 13.99,
        imageUrl: 'assets/item_images/spaghetti_carbonara.jpg',
      ),
      Item(
        name: 'Eggplant Parmigiana',
        description:
            '''Layers of thinly sliced eggplant, marinara sauce, and mozzarella, baked to perfection.''',
        price: 15.99,
        imageUrl: 'assets/item_images/eggplant_parmigiana.jpg',
      ),
      Item(
        name: 'Osso Buco',
        description:
            '''Slow-cooked veal shanks in a white wine and tomato sauce, served with risotto alla Milanese.''',
        price: 24.99,
        imageUrl: 'assets/item_images/osso_buco.jpg',
      ),
      Item(
        name: 'Tiramisu',
        description:
            '''Delicate layers of coffee-soaked ladyfingers and mascarpone cheese, dusted with cocoa powder.''',
        price: 8.99,
        imageUrl: 'assets/item_images/tiramisu.jpg',
      ),
      Item(
        name: 'Chianti Classico',
        description:
            '''A robust red wine with flavors of dark cherry and spice, perfect for pairing with hearty Italian dishes.''',
        price: 12.99,
        imageUrl: 'assets/item_images/chianti_classico.jpg',
      ),
    ],
  ),
  Restaurant(
    '8',
    'The Breakfast Club',
    '810 Main St, San Jose, NY 19113',
    'Breakfast, Brunch, Coffee',
    'assets/restaurants/TheBreakfastClub.jpg',
    'assets/restaurant_credits/TheBreakfastClub_credit.jpg',
    0.5,
    4.5,
    [
      Item(
        name: 'Classic Pancake Stack',
        description:
            '''Fluffy buttermilk pancakes served with butter, maple syrup, and a side of fresh berries.''',
        price: 9.99,
        imageUrl: 'assets/item_images/classic_pancake_stack.jpg',
      ),
      Item(
        name: 'Eggs Benedict',
        description:
            '''Toasted English muffins topped with ham, poached eggs, and creamy hollandaise sauce.''',
        price: 12.99,
        imageUrl: 'assets/item_images/eggs_benedict.jpg',
      ),
      Item(
        name: 'Avocado Toast',
        description:
            '''Whole grain toast spread with ripe avocado, cherry tomatoes, radish slices, and a sprinkle of feta.''',
        price: 8.99,
        imageUrl: 'assets/item_images/avocado_toast.jpg',
      ),
      Item(
        name: 'French Toast Casserole',
        description:
            '''Sweet and savory bread pudding style French toast served with a side of crispy bacon.''',
        price: 11.99,
        imageUrl: 'assets/item_images/french_toast_casserole.jpg',
      ),
      Item(
        name: 'Cappuccino',
        description:
            '''A perfect blend of espresso, steamed milk, and a frothy top, dusted with cocoa or cinnamon.''',
        price: 3.99,
        imageUrl: 'assets/item_images/cappuccino.jpg',
      ),
      Item(
        name: 'Vegan Breakfast Burrito',
        description:
            '''A hearty wrap filled with scrambled tofu, sautéed vegetables, black beans, and avocado. Served with salsa on the side.''',
        price: 10.99,
        imageUrl: 'assets/item_images/vegan_breakfast_burrito.jpg',
      ),
    ],
  ),
];
