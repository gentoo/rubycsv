# vim:ft=eruby:
$erb_template = <<END
<%
$currency = [
    ["Unknown", "DEFAULT"],
    ["$", "$", "USD", "US"],
    ["CAD", "CAN", "CDN", "CAD"],
    ["CZK", "CZK", ],
    ["NOK", "NOK", ],
    ["DKK", "DKK", ],
    ["EUR", "€", "EUR"],
    ["GBP", "GBP", ],
    ["JPY", "JPY", ],
]

$categories = [["Unknown", "DEFAULT"],
    #[ "Assets:Paypal",
    #    "(To|From) U.S. Dollar", "(To|From) Euro", "(To|From) British Pound", "(To|From) Danish Krone"],
    [ "Income:Donations:Cash",
      ".*Gentoo Linux [sS]upport"],
    [ "Income:Donations:Cash",
      ".*Gentoo Sponsorship"],
    [ "Income:Donations:Cash",
      ".*Donate to Gentoo"],
    [ "Income:Donations:Cash",
      ".*paypal@mikedoty.name.*amd64"], # Special donations by Mike Doty for AMD64
    # TODO: this might need to be reported as different income if audited,
    # check with a CPA
    [ "Income:Donations:Cash",
      ".*Developer Conference 2005"],
    # Unknown why this string appears, but it's used for a few legit donations
    [ "Income:Donations:Cash",
      ".*Turtles asked me to.*"],
    #[ "Assets:Supplies",
    #  ".*dealextreme.com.*"],
    [ "Expenses:Hosting:Hetzner",
	  ".*Hetzner Online.*"], # Hetzner has changed the suffix a few times!
    [ "Expenses:Hosting:Hetzner",
	  ".*HETZNER.*"], # Hetzner has changed the suffix a few times!
	[ "Assets:Clearing:Paypal-Exchange",
      ".*Currency Conversion.*"],
    [ "Income:Commission",
	  ".*CafePress.com.*"],
	[ "Expenses:Donations",
      ".*OSU FOUNDATION.*"],
	[ "Assets:Capital:Computers:Infra",
      ".*AMFELTEC.*20171002-06.*"],
	[ "Assets:Capital:Computers:Infra",
      ".*NewEgg.*"],
	[ "Expenses:Hosting:Amazon",
      ".*Amazon Web Services.*"],
	[ "Expenses:Hosting:Amazon",
      ".*aws.amazon.*"],
	[ "Expenses:Hosting:Amazon",
      ".*AWS.AMAZON.*"],
	[ "Expenses:Hosting:Rackspace",
      ".*RACKSPACE CLOUD.*"],
	[ "Expenses:Hosting:OVH",
      ".*paypal@ovh.net.*"],
	[ "Assets:Capital:Computers:Infra",
      ".*Amazon.*Payments.*"],
	[ "Assets:Capital:Computers:Infra",
      ".*Amazon.com.*"],
	[ "Assets:Capital:Computers:Infra",
      ".*OPEN ?GEAR.*"],
	[ "Expenses:Mail",
      ".*Traveling ?Mail(box)?.*"],
    # Antispam
	[ "Expenses:Services",
      ".*malwarepatrol.*"],
	[ "Expenses:Services",
      ".*ppsales.2checkout.com.*"],
	[ "Expenses:Services",
      ".*2Checkout.com.*"],
	[ "Expenses:Services",
      ".*(35A12063HE9515104|1VY55057LW612912E|6UT15274HL558444C|0X0697041H1405258|92J157367U561180X).*"],
    # Phone
	[ "Expenses:Phone",
      # voip.ms, legal company name is '9171-5573 Quebec' d/b/a SwiftVox/Voip.MS
      ".*(payments@swiftvox.com|9171-5573 Quebec|VOIP.MS).*"],
    [ "Expenses:Accounting",
      # This is the HMAC-SHA1 for the accountant's lowercase name & email, for 2017 July-Dec.
      # It was specifically used in place of the name/email to protect the
      # identity of the accountant.
      ".*(934e2cd08d9fcb1d5ada5ed18a531296f934d553|72adf2611a3676994464fc4156fc3a6c29e2f974)"],
    #[ "Expenses:Accounting",
    #  ".*Accounting"],
    [ "Expenses:Accounting",
      ".*CORPORATE CAPITAL"],
    [ "Expenses:Accounting",
      ".*CORPORATE CAPITA"], # Paypal truncates their name sometimes!
    [ "Expenses:Events",
      ".*(9D0425387F676360E|0XX376078W200444L|2SP58554T93029521|108573749C2322059)"],
    [ "Expenses:Project:Nitrokey", ".*nitrokey.com.*"],
    [ "Assets:Capital:Computers:Infra:Purchased_GDS5_201206",
      ".*@dell.com.*7DY965318L922281C" ],
    [ "Assets:Capital:Banners:Purchased_GDS7_201811",
      ".*alice.*7RH17973D71151334"],
    [ "Income:Donations:Cash",
      ".*(1V72559214700303D|4DV724475R802903V|1UK96365EK8061355|5JV62057G77109143|1CF08775U3863904J).*Refund" ],
    [ "Assets:Capital:Computers:Dev:Purchased_GDS5_201106",
      ".*mattst88.*(4JX09116V5200501C|49S75814H86810608|70U02994SC989423E)" ],
    [ "Assets:Capital:Computers:Dev:Purchased_GDS5_201107",
      ".*mattst88.*(6GC40575DU592321S)" ],
    [ "Assets:Capital:Computers:Infra:Purchased_GDS5_201911", ".*(0TL83255MC162162M|631750465G2367318)"],
    [ "Assets:Capital:Computers:Infra:Purchased_GDS5_201907", ".*(9D469133EF7019638)"],
    [ "Expenses:Infra:Parts", ".*(21K67528SF984330G|6H167528BN380453S)" ], # tech for less
    [ "Expenses:Infra:Parts", ".*(81376595W2242272D|4K110430ND5570122)" ], # CDW: serial cable parts for OSUOSL
    [ "Expenses:Fees:Legal",
      ".*OFFICE OF THE NM SOS"],
    [ "Expenses:Fees:Legal",
      ".*US PATENT TRADEMARK.*6H108086SY709645J"],
    [ "Expenses:Fees:Legal",
      ".*8EE53557TT6255427"],
    [ "Expenses:Donations",
      ".*billing@yapc.org.*18380511HB907902B"],
    [ "Expenses:GSOC:Mentor-Travel-Reimbursement",
      ".*(1CR38323CY8432902|4KP10148XA437243W|87N49081CL3000742|8XX66840L62895546|25T96197D6407310R|35A20655SN352982E|0K4406155H379924V|62106544S9576952X|95K44436CC206273Y|9G410934RY513593K).*"],
    [ "Expenses:Services", ".*44M47848WL891505S.*" ],
	[ "Expenses:Shipping", ".*(1WV28590181169742|4W705354M59480838).*"],
    [ "Income:Donations:Cash", ".*88F402144B854453W"],
    [ "Income:Donations:Cash", ".*(9SP30539DD333753R|6BB79733GL4773515).*"], # whatbox.ca special donation
    [ "Assets:Capital:Computers:Infra:Purchased_GDS5_202206", ".*(35M001159N645891H).*"],
    # Generic stuff after this!
    [ "Expenses:Unspecified:Paypal", ".*General PayPal Debit Card Transaction"],
    [ "Expenses:Unspecified:Paypal", ".*General Payment"],
    [ "Income:Donations:Cash", ".*(Update to eCheck Received\|Update to Bank Transfer Received\|Update to Payment Received\|Payment Received\|Payment Processed\|Donation Received|Chargeback Settlement|Website Payment)"],
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
    #$stderr.puts "DEBUG:",row
	candidates_columns = [
		'Name',
		'To Email Address',
		'From Email Address',
		'Subject',
        'Note',
        'Item Title',
        'Transaction ID',
        'Type',
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

def category_to_program(cat)
  return 'Foundation' if cat =~ /Expenses:(Fees:)?(Legal|Accounting|Mail|Phone)/
  return 'PR' if cat =~ /Expenses:Events/
  return 'GSOC' if cat =~ /GSOC/
  return 'Nitrokey' if cat =~ /Nitrokey/
  return 'Infra' if cat =~ /Expenses:Hosting:(Amazon|Hetzner)/
  return 'Infra' if cat =~ /Expenses:Infra:Parts/
  return 'Infra' if cat =~ /Expenses:Shipping/
  return 'Infra' if cat =~ /Expenses:Services/ # AntiSpam: TODO should have had a better category
  return nil
  #; Foundation
  #; GSOC
  #; Infra
  #; Nitrokey
  #; PR
  # These Program categories are wrong and should be corrected
  #; General -- FIXME
  #; Dev -- FIXME
  #; Legal -- FIXME
  #; Releng -- FIXME
end
def category_to_metadata(cat)
  md = {}
  program = category_to_program(cat)
  md['Program'] = program if program
  md['Reference'] = 'TODO' if program or cat =~ /Expense/
  md['TaxImplication'] = 'TODO' if program or cat =~ /Expense/
  md['TaxImplication'] = 'Reimbursement' if cat =~ /Expense.*Reimbursement/
  md['Entity'] = 'TODO' if cat =~ /Expense/
  return md
end

# The trailing spaces on each line are important!
$validstatus = [ 'Canceled', 'Cancelled', 'Cleared', 'Completed', 'Paid', 'Pending', 'Placed', 'Refunded', 'Removed', 'Returned', 'Reversed', 'Updated' ]
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
<% elsif csvrow['Type'] =~ /(Debit Card )?Cash Back Bonus/ -%>
<%= memo %>    Expenses:Fees:Paypal  <%= transcur + positive_num(clean_money(csvrow['Fee'])) %>
<%= memo %>    Assets:Paypal  <%= transcur + clean_money(csvrow['Net']) %> <%= balance %>
<%= memo %>    Income:Rebate  <%= transcur + negate_num(clean_money(csvrow['Net'])) %>
<% elsif csvrow['Type'] =~ /Funds.*Bank Account/ or csvrow['Type'] =~ /Transfer.*Bank/ then -%>
<%= memo %>    Expenses:Fees:Paypal  <%= transcur + positive_num(clean_money(csvrow['Fee'])) %>
<%= memo %>    Assets:Paypal  <%= transcur + clean_money(csvrow['Net']) %> <%= balance %>
<%= memo %>    <%= bank_transfer_acct(csvrow) %>  <%= transcur + negate_num(clean_money(csvrow['Net'])) %>
<% -%>
<% elsif [/Temporary Hold/, /Pending Balance Payment/, /Update to Reversal/, /Account Hold for Open Authorization/, /Reversal of General Account Hold/, /General Authorization/, /Void of Authorization/].any? { |r| csvrow['Type'] =~ r } then -%>
<% # There we must IGNORE the Fee on the temporary hold, because it is ALSO included in the referenced transaction -%>
<%= memo %>    Assets:Paypal  <%= transcur + clean_money(csvrow['Net']) %> <%= balance %>
<%= memo %>    ; SKIP <%= categorize($categories, csvrow) %>  <%= transcur + negate_num(clean_money(csvrow['Net'])) %>
<%= memo %>    <%= paypal_transfer_acct() %>
<% -%>
<% elsif csvrow['Type'] =~ /Refund/i then
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
<%= memo %>    <%= $category = categorize($categories, csvrow); $category %>  <%= transcur + negate_num(clean_money(csvrow['Gross'])) %>
<% -%>
<% elsif csvrow['Type'] =~ /Payment Sent/ or csvrow['Type'] =~ /Cancell?ed Payment/ then -%>
<% # TODO: improve this code, we override the DEFAULT in a dumb way -%>
<%= memo %>    Expenses:Fees:Paypal  <%= transcur + positive_num(clean_money(csvrow['Fee'])) %>
<%= memo %>    Assets:Paypal  <%= transcur + clean_money(csvrow['Net']) %> <%= balance %>
<%= memo %>    <%= $category = categorize($categories+[['Expenses:Unspecified:Paypal','DEFAULT']], csvrow); $category %>  <%= transcur + negate_num(clean_money(csvrow['Gross'])) %>
<% -%>
<% else -%>
<%= memo %>    Expenses:Fees:Paypal  <%= transcur + positive_num(clean_money(csvrow['Fee'])) %>
<%= memo %>    Assets:Paypal  <%= transcur + clean_money(csvrow['Net']) %> <%= balance %>
<%= memo %>    <%= $category = categorize($categories, csvrow); $category %>  <%= transcur + negate_num(clean_money(csvrow['Gross'])) %>
<% -%>
<% end -%>
<% $md = category_to_metadata($category) -%>
<% $md.each_pair do |tag,value| -%>
<%= memo %>    ; <%= tag %>: <%= value %>
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

