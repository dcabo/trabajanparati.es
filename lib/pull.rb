require 'rubygems'
require 'mechanize'
require 'json'

class Parser

  # Crappy xpath code ahead...
  def parse_personal_data(t, s)
    first_family_name = t.search("tr:nth-child(2) .col5Cont:nth-child(1)").children.last.text
    second_family_name = t.search("tr:nth-child(2) .col5Cont:nth-child(2)").children.last.text
    first_name = t.search("tr:nth-child(2) .col5Cont:nth-child(3)").children.last.text
  
    s.name = "#{first_name} #{first_family_name} #{second_family_name}"
    s.position = t.search("tr:nth-child(3) .col5Cont:nth-child(1)").children.last.text
    s.entity = t.search("tr:nth-child(4) .col5Cont:nth-child(1)").children.last.text
  end

  def parse_statement_trigger(t, s)
    s.event = t.search("tr:nth-child(2) .col5Cont:nth-child(1)").children.last.text
    event_date = t.search("tr:nth-child(2) .col5Cont:nth-child(2)").children.last.text
    s.event_date = Date.strptime(event_date, fmt='%d/%m/%Y')
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


  def parse_assets(t, s)
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
          s.total_cash = parse_amount(line.text)
        else
          logger.warning "## #{line.text}"
        end      
      else
        if (line.node_name == 'table')
          values = extract_amounts_from_table(line)
          case expecting
          when :property_data 
            values.each { |value| logger.debug "  GOT PROPERTY #{value}" }
            s.total_property = values.inject(0) { |sum,x| sum+x }
          when :funds_data
            values.each { |value| logger.debug "  GOT FUNDS #{value}" }
            s.total_funds = values.inject(0) { |sum,x| sum+x }
          when :vehicle_data
            values.each { |value| logger.debug "  GOT VEHICLE #{value}" }
            s.total_vehicles = values.inject(0) { |sum,x| sum+x }
          when :insurance_data
            values.each { |value| logger.debug "  GOT INSURANCE #{value}" }
            s.total_insurance = values.inject(0) { |sum,x| sum+x }
          end
        else
          logger.warning "## WARNING #{line.text}"
        end
      end
    end  
  end

  def parse_liabilities(t, s)
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
          values.each { |value| logger.debug "  OWES #{value}" }
          s.total_liabilities = values.inject(0) { |sum,x| sum+x }
        else
          logger.warning "## #{line.text}"
        end
      end
    end  
  end

  def parse_financial_statement(t, s)
    t.search("table.info3").each do |section|
      logger.error "ERROR!! WTF is this? #{section}" if section.children.size != 2
    
      if ( section.children.first.text =~ /^ACTIVO/ )
        parse_assets(section, s) 
      elsif ( section.text =~ /^PASIVO/ )
        parse_liabilities(section, s) 
      else
        logger.error "ERROR!! WTF is this? #{section}"
      end
    end
  end

  def parse_statement_page(url)
    agent = Mechanize.new
    logger.info "Parsing #{BASE_URL+url}..."
    tables = agent.get(BASE_URL+url).search("form > table")

    s = Statement.new
    parse_personal_data(tables[0], s)
    parse_statement_trigger(tables[1], s)  
    financial_statement = ( tables[2].text =~ /^DECLARACIÓN DE ACTIVIDADES/ ) ? tables[3] : tables[2]
    parse_financial_statement(financial_statement, s)  
  
    # Delete the same statement, if exists
    Statement.delete_all(["name=? and event_date=?", s.name, s.event_date])
  
    s.save!
  end

  def parse_personal_page(person_id)
    agent = Mechanize.new
    page = agent.get( BASE_URL + 'listadodb.do?perId=' + person_id )
    page.links_with(:text => 'Ver declaración').each do |link|
      parse_statement_page(link.href)
    end
  end

  BASE_URL = 'https://ws037.juntadeandalucia.es/riibp/publica/'

  cattr_accessor :logger
  self.logger = RAILS_DEFAULT_LOGGER
end

p = Parser.new

url = 'detallesdb.do?accion=download&id=1729'
p.parse_statement_page(url)

#p.parse_personal_page("1")