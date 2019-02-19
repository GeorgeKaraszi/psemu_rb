# frozen_string_literal: true

module HexByte
  DEFAULT  = 0
  READABLE = 1
  ARRAY    = 2

  BIG_ENDIAN     = "H*"
  LITTLE_ENDIAN  = "h*"
  @endian        = BIG_ENDIAN

  class << self
    attr_reader :endian

    def endian=(value)
      if [BIG_ENDIAN, LITTLE_ENDIAN].include?(value)
        @endian = value
      else
        raise "Value must be HexByte::BIG_ENDIAN or HexByte::LITTLE_ENDIAN"
      end
    end

    def system_big_endian?
      @system_endian ||= [1].pack("I") == [1].pack("N")
    end

    def system_little_endian?
      !system_big_endian?
    end
  end

  module String
    def to_base16
      to_i(16)
    end

    def to_byte_string(endian: HexByte.endian)
      stripped = gsub(/,*\s*/, "")

      if (stripped.size % 2).positive?
        raise "Can't translate a string unless it has an even number of digits"
      elsif (index = stripped =~ /\H/)
        raise "Can't translate non-hex characters: [striped_index: #{index}] '...#{stripped[index..index + 2]}'"
      else
        [stripped].pack(endian).force_encoding(Encoding::BINARY)
      end
    end

    def to_hex(format = HexByte::DEFAULT, endian: HexByte.endian)
      unpacked = gsub(/,*\s*/, "")
      unpacked = (unpacked.match?(/\H/) ? unpacked.unpack1(endian) : unpacked).translate_endian(endian)

      case format
      when HexByte::ARRAY
        unpacked.to_hex_array
      when HexByte::READABLE
        unpacked.as_hex_readable
      else
        unpacked.as_hex_readable('\1')
      end
    end

    def as_hex_readable(delimiter = '\1 ')
      gsub(/(..)/, delimiter).rstrip
    end

    def as_hex_array
      scan(/..?/)
    end

    protected

    def translate_endian(_endian)
      padding_size  = size + (size % 2)
      rjust(padding_size, "0")
      # is_big_endian = endian == HexByte::BIG_ENDIAN
      # translated    = rjust(padding_size, "0")

      # if (HexByte.system_big_endian? && !is_big_endian) || (HexByte.system_little_endian? && is_big_endian)
      #   translated.as_hex_array.reverse.join
      # else
      #   translated
      # end
    end
  end

  module Array
    def to_byte_string(endian: HexByte.endian)
      to_hex(HexByte::ARRAY, endian: endian).pack(endian * size).force_encoding(Encoding::BINARY)
    end

    # Convert bytes into hex string
    def to_hex(format = HexByte::DEFAULT, endian: HexByte.endian)
      hex_string = map { |elm| elm.to_hex(endian: endian) }

      case format
      when HexByte::ARRAY
        hex_string
      when HexByte::READABLE
        hex_string.join.as_hex_readable
      else
        hex_string.join
      end
    end
  end

  module Integer
    def to_byte_string(endian: HexByte.endian)
      to_hex(HexByte::ARRAY, endian: endian).to_byte_string
    end

    def to_hex(format = HexByte::DEFAULT, endian: HexByte.endian)
      hex = to_s(16).to_hex(endian: endian)

      case format
      when HexByte::READABLE
        hex.as_hex_readable
      when HexByte::ARRAY
        hex.as_hex_array
      else
        hex
      end
    end
  end
end

class String
  include HexByte::String
end

class Array
  include HexByte::Array
end

class Integer
  include HexByte::Integer
end
