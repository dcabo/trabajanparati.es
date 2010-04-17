require 'rubygems'
require 'mechanize'
require 'json'

BASE_URL = 'https://ws037.juntadeandalucia.es/riibp/publica/'

# Crappy xpath code ahead...
def parse_personal_data(t, attrs)
  attrs[:first_family_name] = t.search("tr:nth-child(2) .col5Cont:nth-child(1)").children.last.text
  attrs[:second_family_name] = t.search("tr:nth-child(2) .col5Cont:nth-child(2)").children.last.text
  attrs[:first_name] = t.search("tr:nth-child(2) .col5Cont:nth-child(3)").children.last.text
  attrs[:position] = t.search("tr:nth-child(3) .col5Cont:nth-child(1)").children.last.text
  attrs[:entity] = t.search("tr:nth-child(4) .col5Cont:nth-child(1)").children.last.text
end

def parse_statement_trigger(t, attrs)
  attrs[:event] = t.search("tr:nth-child(2) .col5Cont:nth-child(1)").children.last.text
  attrs[:event_date] = t.search("tr:nth-child(2) .col5Cont:nth-child(2)").children.last.text
end

def parse_assets
end

def parse_liabilities
end

def parse_financial_statement(t, attrs)
  t.search("table.info3").each do |section|
    if ( section.text =~ /^ACTIVO/ )
      parse_assets(section) 
    elsif ( section.text =~ /^PASIVO/ )
      parse_liabilities(section) 
    else
      puts "ERROR!! WTF is this? #{section}"
    end
  end
end

def parse_statement_page(url)
  agent = Mechanize.new
  tables = agent.get(url).search("form > table")

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

url = 'https://ws037.juntadeandalucia.es/riibp/publica/detallesdb.do?accion=download&id=1671' # no activities
url = 'https://ws037.juntadeandalucia.es/riibp/publica/detallesdb.do?accion=download&id=2409' # all

parse_statement_page(url)