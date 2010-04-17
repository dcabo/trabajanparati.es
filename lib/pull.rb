require 'rubygems'
require 'mechanize'
require 'json'

BASE_URL = 'https://ws037.juntadeandalucia.es/riibp/publica/'

# Crappy xpath code ahead...
def parse_personal_data(t, attrs)
  first_family_name = t.search("tr:nth-child(2) .col5Cont:nth-child(1)").children.last.text
  second_family_name = t.search("tr:nth-child(2) .col5Cont:nth-child(2)").children.last.text
  first_name = t.search("tr:nth-child(2) .col5Cont:nth-child(3)").children.last.text
  
  attrs[:name] = "#{first_name} #{first_family_name} #{second_family_name}"
  attrs[:position] = t.search("tr:nth-child(3) .col5Cont:nth-child(1)").children.last.text
  attrs[:entity] = t.search("tr:nth-child(4) .col5Cont:nth-child(1)").children.last.text
end

def parse_statement_trigger(t, attrs)
  attrs[:event] = t.search("tr:nth-child(2) .col5Cont:nth-child(1)").children.last.text
  attrs[:event_date] = t.search("tr:nth-child(2) .col5Cont:nth-child(2)").children.last.text
end

def parse_amount(s)
  s.strip.gsub(/[^0-9,]+/i, '').to_i  # We ignore cents
end

def extract_amounts_from_table(t)
  # The HTML is broken, so we can't fetch the <tr>. use TD instead, brute force...
  amounts = []
  t.search("td").each do |td|
    amounts.push(parse_amount(td.text)) if td.text =~ /\d/
  end
  amounts
end


def parse_assets(t, attrs)
  assets = t.children.last.children # TD inside the second TR  
  # Parse the actual financial data, which comes as text + embedded tables
  expecting = ''
  assets.children.each do |line|
    case line.text.strip
    when "":
      # Do nothing
    when /^Bienes/:
      expecting = :property_data
    when /^CARACTERÍSTICAS/:
      # Do nothing? part of case above always?
    when /^Acciones y participaciones/:
      expecting = :funds_data
    when /^ENTIDADVALOR EUROS/:
      # Do nothing? part of case above always?
    when /^Automóviles/:
      expecting = :vehicle_data
    when /VALOR EUROS/:
      # Do nothing? part of case above always?
    when /^Seguros de vida/:
      expecting = :insurance_data
    when /^Saldo total de cuentas bancarias/:
      expecting = :bank_account_data
    when /^\302/:
      if ( expecting == :bank_account_data )
        attrs[:total_cash] = parse_amount(line.text)
      else
        puts "## WARNING #{line.text}"
      end      
    else
      if (line.node_name == 'table')
        values = extract_amounts_from_table(line)
        case expecting
        when :property_data 
          values.each { |value| puts "  GOT PROPERTY #{value}" }
          attrs[:total_property] = values.inject(0) { |sum,x| sum+x }
        when :funds_data
          values.each { |value| puts "  GOT FUNDS #{value}" }
          attrs[:total_funds] = values.inject(0) { |sum,x| sum+x }
        when :vehicle_data
          values.each { |value| puts "  GOT VEHICLE #{value}" }
          attrs[:total_vehicle] = values.inject(0) { |sum,x| sum+x }
        when :insurance_data
          values.each { |value| puts "  GOT INSURANCE #{value}" }
          attrs[:total_insurance] = values.inject(0) { |sum,x| sum+x }
        end
      else
        puts "## WARNING #{line.text}"
      end
    end
  end  
end

def parse_liabilities(t, attrs)
  liabilities = t.children.last.children
  # Parse the actual financial data, which comes as text + embedded tables
  liabilities.children.each do |line|
    case line.text.strip
    when "":
      # Do nothing
    when /VALOR EUROS/:
      # Nothing to do
    else
      if (line.node_name == 'table')
        values = extract_amounts_from_table(line)
        values.each { |value| puts "  OWES #{value}" }
        attrs[:total_liabilities] = values.inject(0) { |sum,x| sum+x }
      else
        puts "## WARNING #{line.text}"
      end
    end
  end  
end

def parse_financial_statement(t, attrs)
  t.search("table.info3").each do |section|
    puts "ERROR!! WTF is this? #{section}" if section.children.size != 2
    
    if ( section.children.first.text =~ /^ACTIVO/ )
      parse_assets(section, attrs) 
    elsif ( section.text =~ /^PASIVO/ )
      parse_liabilities(section, attrs) 
    else
      puts "ERROR!! WTF is this? #{section}"
    end
  end
end

def parse_statement_page(url)
  agent = Mechanize.new
  puts "Parsing #{BASE_URL+url}..."
  tables = agent.get(BASE_URL+url).search("form > table")

  attrs = {}
  parse_personal_data(tables[0], attrs)
  parse_statement_trigger(tables[1], attrs)  
  financial_statement = ( tables[2].text =~ /^DECLARACIÓN DE ACTIVIDADES/ ) ? tables[3] : tables[2]
  parse_financial_statement(financial_statement, attrs)  
  
  p attrs
end

def parse_personal_page(person_id)
  agent = Mechanize.new
  page = agent.get( BASE_URL + 'listadodb.do?perId=' + person_id )
  page.links_with(:text => 'Ver declaración').each do |link|
    parse_statement_page(link.href)
  end
end

url = 'detallesdb.do?accion=download&id=1729'
parse_statement_page(url)

#parse_personal_page("1")