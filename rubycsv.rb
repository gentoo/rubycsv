#!/usr/bin/env ruby

require 'csv'
require 'erb'
require 'date'
require 'tzinfo'

# globals
$template_file = ARGV[0]
$csv_filename = ARGV[1]
$template_text = ""
$header_row = []
$line = 0

# evaluate the template in order to get the templates and other variables out
eval(File.read($template_file))
$template_text = $erb_template

# class to bind hash into erb template
class CSVRow
    attr_accessor :csvrow

    def initialize(row)
        @csvrow = Hash.new
        index = 0 
        $header_row.size.times do 
            @csvrow[$header_row[index]] = row[index]
            index +=1;
        end
    end

    def get_binding()
        return binding()
    end

	def [](key)
		@csvrow[key]
	end
end

# helper functions
def clean_date(text_date) # reformat date in to big endian format
    return Date.strptime(text_date, '%m/%d/%Y').strftime("%Y-%m-%d")
end

def clean_money(text_money) # nuke all but digits, negation, decimal place
    if text_money.nil?
        return ""
    end
    return text_money.gsub(/[^-\d\.]/,'')
end

def clean_num(text_num) # nuke all but digits, negation
    if text_num.nil?
        return ""
    end
    return text_num.gsub(/[^-\d]/,'')
end

def clean_text(text) # get rid of anything that's not a word or space, make multiple spaces single space
    if text.nil?
        return ""
    end
    return text.gsub(/[^\w \]\[\@\.\,\'\"]/,'').gsub(/[ ]+/,' ').strip;
end

def negate_num(text_money_or_num)
  replacement = text_money_or_num =~ /-/ ? '' : '-'
  return text_money_or_num.sub(/^-?(\d)/, replacement + '\1')
end

def positive_num(text_money_or_num)
  return text_money_or_num.sub(/^-?(\d)/, '\1')
end
def negative_num(text_money_or_num)
  return text_money_or_num.sub(/^-?(\d)/, '-\1')
end

# lookup values in arrays.  Table is a 2D array, 
# where the first value is the string returned, 
# and the following are substrings to attempt to match against the value

def tablematch(table, value)
    default = ""

    table.each do |row|
        rowfirst = row.first

        row.slice(1,row.length).each do |item|
            if item == "DEFAULT"  # set the default value
                default = rowfirst
            elsif value.match(/^#{item}/i)
                #print "  val: #{value} matches #{item}, returning #{rowfirst}\n"
                return rowfirst
            end
        end
    end
    return default
end

# parse CSV file

$data = {}
$header_data = {}
$seen_csv_header = false
known_paypal_headers = [
  'Address Line 1', 'Address Line 2/District', 
  'Address Line 2/District/Neighborhood', 'Address Status', 
  'Auction Site', 'Available Balance', 'Balance', 'Balance Impact', 
  'Buyer ID', 'Closing Date', 'Contact Phone Number',
  'Counterparty Status', 'Country', 'Currency', 'Custom Number',
  'Date', 'Fee', 'From Email Address', 'Gross', 'Insurance Amount',
  'Invoice Number', 'Item ID', 'Item Title', 'Item URL', 'Name',
  'Net', 'Note', 
  'Option 1 Name', 'Option 1 Value', 
  'Option 2 Name', 'Option 2 Value', 
  'Payment Type', 'Quantity', 'Receipt ID', 'Reference Txn ID',
  'Sales Tax', 'Shipping address', 'Shipping and Handling Amount',
  'State/Province',
  'State/Province/Region/County/Territory/Prefecture/Republic',
  'Status', 'Subject', 'Subscription Number',
  'Time', 'Time Zone', 'To Email Address',
  'Town/City', 'Transaction ID', 'Type',
  'Zip/Postal Code',
]

filemode = 'r:ISO-8859-1'
filemode = 'r:bom|utf-8'

CSV.foreach($csv_filename, filemode) do |row|
    $line += 1 
	#print "; ", row, "\n"
	row = row.collect{ |val| val.nil? ? '' : val.strip}
	if row.length == 2 && !$seen_csv_header then
		$header_data[row[0]] = row[1]
	elsif(!$seen_csv_header && (row & known_paypal_headers).length > 10) then
        $header_row = row
		$seen_csv_header = true
    else
        $data[$line] = CSVRow.new(row)
    end
end

def paypal_row_to_time(row)
	date = row['Date']
	# Sadly Paypal data precision sucks; if the seconds are missing, let's just add them as zero
	time = row['Time'].sub(/^(\d{2}:\d{2})$/,'\1:00')
	timezone = row['Time Zone'] || row['TimeZone']
	begin
		tz = TZInfo::Timezone.get(timezone)
		dt = DateTime.strptime([date, time].join(' '), '%m/%d/%Y %H:%M:%S')
		tz.local_to_utc(dt).strftime('%s')
	rescue TZInfo::InvalidTimezoneIdentifier
		#STDERR.puts [date, time, timezone]
		dt = DateTime.strptime([date, time, timezone].join(' '), '%m/%d/%Y %H:%M:%S %Z')
		dt.strftime('%s')
	end
end

def sorter_key(v)
	key, row = v
	key
end
def sorter_date_time_tz(v)
	#STDERR.print v, "\n"
	key, row = v
	# This last part is too hacky :-(
	# we need to know if the file is ascending or decending in the first place I think.
	sortkey = []
	#sortkey << paypal_row_to_time(row)
	sortkey << key * $file_direction
end

# This is needed because the paypal file order is NOT consistent!
# Early paypal data was newest-first
# New paypal data is oldest-first
_ = $data.sort
t1 = paypal_row_to_time(_.last[1])
t2 = paypal_row_to_time(_.first[1])
$file_direction = t1 <=> t2

# TODO: support more sort options!
#STDERR.print $data.methods.sort
#&method(:inc))
$data.sort_by(&method(:sorter_date_time_tz)).each do |tuple|
	key, row = tuple
    #row = $data[key]
    $line = key
    #print "line: #{thisrow.csvrow.inspect}\n"
    erbrender = ERB.new($erb_template, safe_level=nil, trim_mode='-')
    puts erbrender.result(row.get_binding).rstrip()
    puts "\n"
end
