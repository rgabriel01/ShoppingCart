class ShoppingCart
  
  PRODUCTS= [
    {product_code: 'ult_small',name: 'Unlimited 1GB', price: 24.9},
    {product_code: 'ult_medium',name: 'Unlimited 2GB', price: 29.9},
    {product_code: 'ult_large',name: 'Unlimited 5GB', price: 44.9},
    {product_code: '1gb',name: '1 GB Data-pack', price: 9.9},
  ]

  attr_reader :pricing_rules
  attr_accessor :cart_items, :freebies

  def initialize(pricing_rules = [])
    @pricing_rules = pricing_rules
    @cart_items = []
    @freebies = []
  end

  def add(product_code, promo_code = '')
    product_profile = get_product_profile(product_code)
    price = promo_code.empty? ? product_profile[:price] : process_promo(promo_code, product_profile)
    @cart_items.push({product_code: product_profile[:product_code], price: price})
  end

  def total
    running_total = 0
    @pricing_rules.each do |pricing_rule|
      running_total += process_pricing_rule(pricing_rule)
    end
    running_total += process_normal_items
    running_total.round(2)
  end

  private

  def process_normal_items
    total = 0
    @cart_items.each do |cart_item|
      if !promo_item?(cart_item[:product_code])
        total += cart_item[:price]
      end
    end
    total
  end

  def promo_item?(product_code)
    product_code_from_pricing_rules.include? product_code
  end

  def product_code_from_pricing_rules
    pricing_rules.map{|rules| rules[:product_code]}
  end

  def process_cart
    total = 0
    @cart_items.each do |item|
      total += item[:price]
    end
    total
  end

  def process_promo(promo_code, product_profile)
    discounted_price = 0
    case promo_code
    when 'I<3AMAYSIM'
      discounted_price = i_love_amaysim_promo(product_profile)
    end
    discounted_price
  end

  def process_pricing_rule(pricing_rule)
    discounted_total = 0
    case pricing_rule[:rule]
    when 'buy_nquantity_for_nprice'
      discounted_total = buy_nquantity_for_nprice(pricing_rule)
    when 'bulk_price'
      discounted_total = bulk_discount(pricing_rule)
    when 'bundle'
      discounted_total = bundle(pricing_rule)
    end
    discounted_total
  end

  def buy_nquantity_for_nprice(pricing_rule)
    total = 0
    return 0 unless item_in_cart?(pricing_rule[:product_code])
    product_profile = get_product_profile(pricing_rule[:product_code])
    cart_products = group_cart_products_by_product_code(pricing_rule[:product_code])
    running_cart_quantity = cart_products.count

    n_quantity = pricing_rule[:nquantity] #buying condition
    n_price = pricing_rule[:nprice] #for the price of this
    rule_in_effect = false
    while running_cart_quantity >= n_quantity
      if running_cart_quantity < n_price
        total += product_profile[:price]
      else
        total += product_profile[:price] * n_price
      end
      running_cart_quantity -= n_quantity
    end

    #handle residue
    if (running_cart_quantity < n_quantity)
      total += product_profile[:price] * running_cart_quantity
    end
    total
  end

  def bulk_discount(pricing_rule)
    total = 0
    return 0 unless item_in_cart?(pricing_rule[:product_code])
    product_profile = get_product_profile(pricing_rule[:product_code])
    cart_products = group_cart_products_by_product_code(pricing_rule[:product_code])
    running_cart_quantity = cart_products.count

    bulk_price = pricing_rule[:bulk_price]
    quantity_trigger = pricing_rule[:quantity_trigger]
    
    if  running_cart_quantity > quantity_trigger
      total = bulk_price * running_cart_quantity
    else
      total = product_profile[:price] * running_cart_quantity
    end
    total
  end

  def bundle(pricing_rule)
    total = 0
    return 0 unless item_in_cart?(pricing_rule[:product_code])
    product_profile = get_product_profile(pricing_rule[:product_code])
    cart_products = group_cart_products_by_product_code(pricing_rule[:product_code])
    free_product_profile = get_product_profile(pricing_rule[:free_product_code])
    for_bundling_cart_products = group_cart_products_by_product_code(pricing_rule[:free_product_code])
    running_cart_quantity = cart_products.count

    quantity_trigger = pricing_rule[:quantity_trigger]

    bundled_freebies_count = running_cart_quantity / quantity_trigger
    @freebies = [{product_code: free_product_profile[:product_code], price: 0}] * bundled_freebies_count

    total += running_cart_quantity * product_profile[:price]
    total
  end

  def i_love_amaysim_promo(product_profile)
    discount_percent = 10.to_f
    price = product_profile[:price].to_f
    discount_amount = price.to_f * (discount_percent.to_f / 100)
    price - discount_amount
  end

  def get_product_profile(product_code)
    PRODUCTS.find{|product| product[:product_code] == product_code}
  end

  def item_in_cart?(product_code)
    @cart_items.map{|item| item[:product_code]}.include? product_code
  end

  def group_cart_products_by_product_code(product_code)
    @cart_items.select{|cart_item| cart_item[:product_code] == product_code}
  end
end
