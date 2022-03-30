# frozen_string_literal: true

class Utils::Phone
  def self.validate(phone_number, validate_type = "slim")
    if TelephoneNumber.parse(sanitize(phone_number)).country.nil?
      phone_object = TelephoneNumber.parse(sanitize(phone_number), :PR).valid? ? TelephoneNumber.parse(sanitize(phone_number), :PR) : TelephoneNumber.parse(sanitize(phone_number), :US)
    else
      phone_object = TelephoneNumber.parse(sanitize(phone_number))
    end
    result = {
      "valid" => phone_object.valid?,
      "raw_input" => phone_object.original_number,
      "national_number" => phone_object.national_number,
      "international_number" => phone_object.international_number,
      "e164_number" => phone_object.e164_number,
      "country_code" => phone_object.country.country_code,
      "country_id" => phone_object.country.country_id,
      "location" => phone_object.location,
      "timezone" => phone_object.timezone
    }
    case validate_type
    when "all"
      result
    when "slim"
      result.reject { |k, v| %w[country_code location timezone].include? k }
    when "api"
      result.reject { |k, v| %w[national_number international_number country_id country_code location timezone e164_number].include? k }
    else
      result
    end
  end

  def self.normalize(phone_number, normalize_type = "national_number")
    validated = validate(phone_number)
    if ["US", "PR"].include? validated["country_id"]
      result = validated["valid"] == true ? validated["national_number"] : validated["raw_input"]
    else
      result = validated["valid"] == true ? validated["international_number"] : validated["raw_input"]
    end
    case normalize_type
    when "national_number"
      result
    when "e164_number"
      validated["valid"] == true ? validated["e164_number"] : validated["raw_input"]
    else
      result
    end
  end

  def self.sanitize(phone_number)
    TelephoneNumber.sanitize(phone_number)
  end
end
