class Utils::Phone

  def self.validate(phone_number, type="slim")
    phone_object = TelephoneNumber.parse(sanitize(phone_number), :US)
    result = {
      "valid" => phone_object.valid?,
      "raw_input" => phone_object.original_number,
      "national_number" => phone_object.national_number,
      "e164_number" => phone_object.e164_number,
      "country_code" => phone_object.country.country_code,
      "country_id" => phone_object.country.country_id,
      "location" => phone_object.location,
      "timezone" => phone_object.timezone
    }
    case type
    when "all"
      result
    when "slim"
      result.reject { |k,v| %w[country_code country_id location timezone].include? k }
    when "api"
      result.reject { |k,v| %w[national_number country_code country_id location timezone e164_number].include? k }
    else
      result
    end
  end

  def self.normalize(phone_number, type = "national_number")
    validated = validate(phone_number)
    result = validated["valid"] == true ? validated["national_number"] : validated["raw_input"]
    case type
    when "national_number"
      result
    when "e164_number"
      result = validated["valid"] == true ? validated["e164_number"] : validated["raw_input"]
    else
      result
    end
  end

  def self.sanitize(phone_number)
    TelephoneNumber.sanitize(phone_number)
  end

end