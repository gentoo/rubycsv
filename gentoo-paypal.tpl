# vim:ft=eruby:
$erb_template = <<END
<%
$currency = [["Unknown", "DEFAULT"],
    ["CAD", "CAN", "CDN", "CAD"],
    ["EUR", "€", "EUR"],
    ["$", "$", "USD", "US"],
    ["DKK", "DKK", ],
    ["GBP", "GBP", ],
    ["CZK", "CZK", ],
]

$categories = [["Income:Donations:Cash", "DEFAULT"],
    #[ "Assets:Paypal",
    #    "(To|From) U.S. Dollar", "(To|From) Euro", "(To|From) British Pound", "(To|From) Danish Krone"],
    [ "Assets:Supplies",
      ".*dealextreme.com"],
    [ "Expenses:Hosting:Hetzner",
	  ".*Hetzner Online"], # Hetzner has changed the suffix a few times!
	[ "Assets:Clearing:Paypal-Exchange",
      ".*Currency Conversion"],
    [ "Income:Commission",
	  ".*CafePress.com"],
	[ "Expenses:Hosting:Amazon",
      ".*Amazon Web Services"],
	[ "Expenses:Mail",
      ".*Traveling Mailbox"],
	[ "Expenses:Phone",
      # voip.ms, legal company name is '9171-5573 Quebec' d/b/a SwiftVox/Voip.MS
      ".*(payments@swiftvox.com|9171-5573 Quebec)"],
    [ "Expenses:Accounting",
	  # This is the HMAC-SHA1 for the accountant's lowercase name & email, for 2017 July-Dec.
      ".*(934e2cd08d9fcb1d5ada5ed18a531296f934d553|72adf2611a3676994464fc4156fc3a6c29e2f974)"],
    #[ "Expenses:Accounting",
    #  ".*Accounting"],
    [ "Expenses:Unspecified:Paypal",
	  ".*General PayPal Debit Card Transaction"],

]

def paypal_transfer_acct
	'Assets:Clearing:Paypal-Holding'
end

def bank_transfer_acct(row)
	dt = DateTime.strptime(row['Date'], '%m/%d/%Y')
	if dt.year >= 2009
		'Assets:Clearing:Paypal-CapOneMoneyMarket'
	else
		'Assets:Clearing:Paypal-NetBank'
	end
end

def cleantext(txt)
	txt.gsub(/\n/, ' ').gsub(/^[[:space:]]+|[[:space:]]+$/,'')
end
def cleanprefix(txt)
	txt = cleantext(txt)
	return ' ' + txt if(txt.length > 0)
	return ''
end

# This does the meat of work
# - Try to match against one of the CSV fields directly
# - Try to match against a salted hash of lowercase(Email) or lowercase(Name)
def categorize(cats, row)
	candidates_columns = [
		'Name',
		'To Email Address',
		'From Email Address',
		'Subject',
		'Note',
	]
	candidate_text = candidates_columns.map { |x|
		row[x]
	}.map { |x|
		clean_text(x.strip)
	}.reject{ |x|
		# Ditch empty cols
		x.length == 0
	}.compact.join(' ')
	# We might not want to expose the email or name of the person here, but we
	# DO still want to match it!
	# Use HMAC-SHA1 with a static key 'gentoofoundation'
	# This means if somebody wants to attack the hashes, they are going to have
	# to bruteforce it, no rainbow tables.
	require 'openssl'
	hmac_hash = 'sha1'
	hmac_key = 'gentoofoundation'
	candidate_text_salthashed = [
		'Name',
		'To Email Address',
		'From Email Address',
	]
	candidate_hashed = candidates_columns.map { |x|
		row[x]
	}.map { |x|
		clean_text(x.strip.downcase)
	}.reject{ |x|
		x.length == 0
	}.compact.map { |x|
		OpenSSL::HMAC.hexdigest(hmac_hash, hmac_key, x)
	}.join(' ')
	return tablematch(cats, candidate_text + ' ' + candidate_hashed)
end

# The trailing spaces on each line are important!
$validstatus = [ 'Canceled', 'Cancelled', 'Cleared', 'Completed', 'Paid', 'Pending', 'Placed', 'Refunded', 'Removed', 'Returned', 'Reversed' ]
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
<% if (($validstatus.include? csvrow['Status']) && (csvrow['Type'] != "Shopping Cart Item") && (csvrow['Type'] != 'Transfer to Bank Initiated')) -%>
; CSV "<%= $csv_filename %>", line: <%= $line %>
<%= memo %><%= clean_date(csvrow['Date'], '%m/%d/%Y') %> Paypal <%= clean_text(csvrow['Name'] + ' ' + csvrow['To Email Address'] + ' ' + csvrow['Item Title']) %> ID: <%= csvrow['Transaction ID'] %><%= refid %>, <%= csvrow['Type'] %>
<% -%>
<% if false then -%>
<% elsif csvrow['Type'] =~ /Currency Conversion/ -%>
<%= memo %>    Expenses:Fees:Paypal  <%= transcur + positive_num(clean_money(csvrow['Fee'])) %>
<%= memo %>    Assets:Paypal  <%= transcur + clean_money(csvrow['Net']) %> <%= balance %>
<%= memo %>    Assets:Clearing:Paypal-Exchange  <%= transcur + negate_num(clean_money(csvrow['Net'])) %>
<% elsif csvrow['Type'] =~ /Debit Card Cash Back Bonus/ -%>
<%= memo %>    Expenses:Fees:Paypal  <%= transcur + positive_num(clean_money(csvrow['Fee'])) %>
<%= memo %>    Assets:Paypal  <%= transcur + clean_money(csvrow['Net']) %> <%= balance %>
<%= memo %>    Income:Rebate  <%= transcur + negate_num(clean_money(csvrow['Net'])) %>
<% elsif csvrow['Type'] =~ /Funds.*Bank Account/ or csvrow['Type'] =~ /Transfer.*Bank/ then -%>
<%= memo %>    Expenses:Fees:Paypal  <%= transcur + positive_num(clean_money(csvrow['Fee'])) %>
<%= memo %>    Assets:Paypal  <%= transcur + clean_money(csvrow['Net']) %> <%= balance %>
<%= memo %>    <%= bank_transfer_acct(csvrow) %>  <%= transcur + negate_num(clean_money(csvrow['Net'])) %>
<% -%>
<% elsif [/Temporary Hold/, /Pending Balance Payment/, /Update to Reversal/].any? { |r| csvrow['Type'] =~ r } then -%>
<% # There we must IGNORE the Fee on the temporary hold, because it is ALSO included in the referenced transaction -%>
<%= memo %>    Assets:Paypal  <%= transcur + clean_money(csvrow['Net']) %> <%= balance %>
<%= memo %>    ; SKIP <%= categorize($categories, csvrow) %>  <%= transcur + negate_num(clean_money(csvrow['Net'])) %>
<%= memo %>    <%= paypal_transfer_acct() %>
<% -%>
<% elsif csvrow['Type'] =~ /Refund/ then
# The signs of some of the refunds are wrong, so they need special handling
# The Fee is refunded, and needs flipping manually
# (alternatively, we ignore the fee on the refund, and change the fee refund special transaction AWAY from being a memo)
# The Net & Gross amounts are already reversed, but this means we need to flip the sign on the Income entry
# TODO: should Income:Paypal be the reverse account for the default case?
# This is problematic as a type, because the Refund transaction is NOT clear if
# it's refunding money we have recieved, or if we recieved a refund for a
# payment sent.
# Our date has examples of both:
# PaymentSent/Refund: 49S75814H86810608, 4JX09116V5200501C
# Web Accept Payment Received/Refund: 3TV525461B3251548, 1V72559214700303D
-%>
<%= memo %>    Expenses:Fees:Paypal  <%= transcur + negative_num(clean_money(csvrow['Fee'])) %>
<%= memo %>    Assets:Paypal  <%= transcur + clean_money(csvrow['Net']) %> <%= balance %>
<%= memo %>    <%= categorize(csvrow) %>  <%= transcur + negate_num(clean_money(csvrow['Gross'])) %>
<% -%>
<% elsif csvrow['Type'] =~ /Payment Sent/ or csvrow['Type'] =~ /Cancell?ed Payment/ then -%>
<% # TODO: improve this code, we override the DEFAULT in a dumb way -%>
<%= memo %>    Expenses:Fees:Paypal  <%= transcur + positive_num(clean_money(csvrow['Fee'])) %>
<%= memo %>    Assets:Paypal  <%= transcur + clean_money(csvrow['Net']) %> <%= balance %>
<%= memo %>    <%= categorize($categories+[['Expenses:Unspecified:Paypal','DEFAULT']], csvrow) %>  <%= transcur + negate_num(clean_money(csvrow['Gross'])) %>
<% -%>
<% else -%>
<%= memo %>    Expenses:Fees:Paypal  <%= transcur + positive_num(clean_money(csvrow['Fee'])) %>
<%= memo %>    Assets:Paypal  <%= transcur + clean_money(csvrow['Net']) %> <%= balance %>
<%= memo %>    <%= categorize($categories, csvrow) %>  <%= transcur + negate_num(clean_money(csvrow['Gross'])) %>
<% -%>
<% end -%>
<%= memo %>    ; Name:<%= cleanprefix(csvrow['Name']) %>
<%= memo %>    ; To.email:<%= cleanprefix(csvrow['To Email Address']) %>
<%= memo %>    ; From.email:<%= cleanprefix(csvrow['From Email Address']) %>
<%= memo %>    ; Subject:<%= cleanprefix(csvrow['Subject']) %>
<%= memo %>    ; Note:<%= cleanprefix(csvrow['Note']) %>
<%= memo %>    ; Balance: <%= clean_money(balval) %>
<%= memo %>    ; Gross: <%= clean_money(csvrow['Gross']) %>
<%= memo %>    ; Net: <%= clean_money(csvrow['Net']) %>
<% end -%>

END

