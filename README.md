# rubycsv (gentoo foundation fork)

This fork has been heavily modified to support the extensive Paypal variations
as found in the Gentoo Foundation's Paypal history.

It makes use of balance assertions to verify the values in the conversion, so
works best if you have a full history dump.

Paypal has changed the CSVs numerous times, in all sorts of ways:
- inconsistency in field names
  - 'Balance' vs 'Available Balance'
- inconsistency in field values
  - bank transfers: 'Withdraw Funds to Bank Account', 'Transfer to Bank Initiated/Completed'
  - bank transfers: double-recording ''Transfer to Bank Initiated', ''Transfer to Bank Completed'
  - 'Type': changed over time
- inconsistency in fee handling on holds
  - The hold lists the fee, but so does the original transaction
- inconsistency in fee handling on refunds
  - Paypal only refunds the variable portion of the fee, they keep the flat $0.30!
  - This has changed slightly over time!

TODO:
- recognize more credit transactions and file to correct accounts
- review Type='Pending Balance Payment' for double-recording
- improve tablematch to include type for special handling of 'Payment Sent' to
  previously unknown expense destinations.
- Allow mix-in of external metadata based on transaction/reference IDs
- Handle currency conversions as an actual exchange!

# rubycsv (original README follows)

Convert CSV files to arbitrary formats via erb-style templates and lookups.

Basically, it reads in a CSV file, and then evaluates the ERB template on a per-line basis, using the header line to index the lines. 

This allows additional per-input file logic in the conversion, and regex-based lookup tables in the templates.

This was originally created to use with [ledger](http://ledger-cli.org) files, but can process any arbitrary CSV file into other formats.  It was inspired in part by [hledger](http://hledger.org)'s CSV conversion logic.

## Usage

`rubycsv.rb templatefile source_csv > outputfile`

## Example

There's a sample CSV and template file in examples folder - run it with:

`./rubycsv.rb examples/savings.tpl examples/savings.csv`
