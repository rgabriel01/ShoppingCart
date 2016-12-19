pricing_rules = [{
  rule: 'bulk_price',
  product_code: 'ult_large',
  bulk_price: 39.9,
  quantity_trigger: 3
},
{
  rule: 'buy_nquantity_for_nprice',
  product_code: 'ult_small',
  nquantity: 3,
  nprice: 2
},
{
  rule: 'bundle',
  product_code: 'ult_medium',
  free_product_code: '1gb',
  quantity_trigger: 1
}]

#scenario 1
s1 = ShoppingCart.new(pricing_rules)
s1.add('ult_small')
s1.add('ult_small')
s1.add('ult_small')
s1.add('ult_large')
puts "total is #{s1.total}"
puts s1.cart_items

#scenario 2
s2 = ShoppingCart.new(pricing_rules)
s2.add('ult_small')
s2.add('ult_small')
s2.add('ult_large')
s2.add('ult_large')
s2.add('ult_large')
s2.add('ult_large')
puts "total is #{s2.total}"
puts s2.cart_items

#scenario 3
s3 = ShoppingCart.new(pricing_rules)
s3.add('ult_small')
s3.add('ult_medium')
s3.add('ult_medium')
puts "total is #{s3.total}"
puts s3.cart_items
puts s3.freebies

#scenario 4
s4 = ShoppingCart.new(pricing_rules)
s4.add('ult_small')
s4.add('1gb', 'I<3AMAYSIM')
puts "total is #{s4.total}"
puts s4.cart_items


