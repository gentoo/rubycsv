# vim:ft=eruby:
$erb_template = <<END
<%
$currency = [["Unknown", "DEFAULT"],
    ["CAD", "CAN", "CDN", "CAD"],
    ["EUR", "€", "EUR"],
    ["$", "$", "USD", "US"],
    ["DKK", "DKK", ],
    ["GBP", "GBP", ],
]

$categories = [["Income:Paypal", "DEFAULT"],
    #[ "Assets:Paypal",
    #    "(To|From) U.S. Dollar", "(To|From) Euro", "(To|From) British Pound", "(To|From) Danish Krone"],
    [ "Assets:Supplies",
      "dealextreme.com"],
    [ "Expenses:Hosting:Hetzner",
      "Hetzner Online AG"],
]

# The trailing spaces on each line are important!
$validtypes = [ 'Canceled', 'Cancelled', 'Cleared', 'Completed', 'Paid', 'Pending', 'Placed', 'Refunded', 'Removed', 'Returned', 'Reversed' ]
$memoprefix = ';MEMO '
transcur = tablematch($currency,csvrow['Currency']) + " "
memo = csvrow["Balance Impact"] == 'Memo' ? $memoprefix : ''
refid = csvrow["Reference Txn ID"]
if refid.length() > 0 then
  refid = ' Reference: ' + refid + ' '
end
# Depending on the version of the CSV data, the Balance MIGHT be in:
# Balanace
# Available Balance
# Or just missing!
balval = csvrow.select { |k,v| ['Balance', 'Available Balance'].include? k }.values[0]
balance = ''
if transcur == '$ ' then
  balance = '= ' + transcur + clean_money(balval)
end
-%>
<% if (($validtypes.include? csvrow['Status']) && (csvrow['Type'] != "Shopping Cart Item") && (csvrow['Type'] != 'Transfer to Bank Initiated')) -%>
; CSV "<%= $csv_filename %>", line: <%= $line %>
<%= memo %><%= clean_date(csvrow['Date']) %> Paypal <%= clean_text(csvrow['Name'] + ' ' + csvrow['To Email Address'] + ' ' + csvrow['Item Title']) %> ID: <%= csvrow['Transaction ID'] %><%= refid %>, <%= csvrow['Type'] %>
<% -%>
<% if csvrow['Type'] =~ /Funds.*Bank Account/ or csvrow['Type'] =~ /Transfer.*Bank/ then -%>
<%= memo %>    Expenses:Fees:Paypal  <%= transcur + positive_num(clean_money(csvrow['Fee'])) %>
<%= memo %>    Assets:Paypal  <%= transcur + clean_money(csvrow['Net']) %> <%= balance %>
<%= memo %>    Assets:Bank    <%= transcur + negate_num(clean_money(csvrow['Net'])) %>
<% -%>
<% elsif csvrow['Type'] =~ /Temporary Hold/ then -%>
<% # There we must IGNORE the Fee on the temporary hold, because it is ALSO included in the referenced transaction -%>
<%= memo %>    Assets:Paypal  <%= transcur + clean_money(csvrow['Net']) %> <%= balance %>
<%= memo %>    <%= tablematch($categories, clean_text(csvrow['Name'] + ' ' + csvrow['To Email Address'] + ' ' + csvrow['From Email Address'])) %>  <%= transcur + negate_num(clean_money(csvrow['Net'])) %>
<% -%>
<% elsif csvrow['Type'] =~ /Refund/ then
# The signs of some of the refunds are wrong, so they need special handling
# The Fee is refunded, and needs flipping manually
# (alternatively, we ignore the fee on the refund, and change the fee refund special transaction AWAY from being a memo)
# The Net & Gross amounts are already reversed, but this means we need to flip the sign on the Income entry
-%>
<%= memo %>    Expenses:Fees:Paypal  <%= transcur + negative_num(clean_money(csvrow['Fee'])) %>
<%= memo %>    Assets:Paypal  <%= transcur + clean_money(csvrow['Net']) %> <%= balance %>
<%= memo %>    <%= tablematch($categories, clean_text(csvrow['Name'] + ' ' + csvrow['To Email Address'] + ' ' + csvrow['From Email Address'])) %>  <%= transcur + negate_num(clean_money(csvrow['Gross'])) %>
<% -%>
<% else -%>
<%= memo %>    Expenses:Fees:Paypal  <%= transcur + positive_num(clean_money(csvrow['Fee'])) %>
<%= memo %>    Assets:Paypal  <%= transcur + clean_money(csvrow['Net']) %> <%= balance %>
<%= memo %>    <%= tablematch($categories, clean_text(csvrow['Name'] + ' ' + csvrow['To Email Address'] + ' ' + csvrow['From Email Address'])) %>  <%= transcur + negate_num(clean_money(csvrow['Gross'])) %>
<% -%>
<% end -%>
<%= memo %>    ; Balance: <%= clean_money(balval) %>
<%= memo %>    ; Gross: <%= clean_money(csvrow['Gross']) %>
<%= memo %>    ; Net: <%= clean_money(csvrow['Net']) %>
<% end -%>

END

