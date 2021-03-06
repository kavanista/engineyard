require 'engineyard/error'

module EY
  module Collection
    class Abstract < Array
      COLLAB_MESSAGE = <<-MSG
\nThis error is due to having access to another account's resources via the collaboration feature.
Specify --account ACCOUNT_NAME to resolve this ambiguity.
      MSG

      def named(name, account_name=nil)
        candidates = find_all do |x|
          if account_name
            x.name.downcase == name.downcase && x.account.name.downcase == account_name.downcase
          else
            x.name.downcase == name.downcase
          end
        end
        if candidates.size > 1
          raise ambiguous_error(name, candidates.map {|e| e.name}, COLLAB_MESSAGE )
        end
        candidates.first
      end

      def match_one(name_part)
        named(name_part) || find_by_unambiguous_substring(name_part)
      end

      def match_one!(name_part)
        match_one(name_part) or raise invalid_error(name_part)
      end

    private

      def find_by_unambiguous_substring(name_part)
        candidates = find_all{|e| e.name.downcase[name_part.downcase] }
        if candidates.size > 1
          raise ambiguous_error(name_part, candidates.map {|e| e.name})
        end
        candidates.first
      end

      class << self
        attr_accessor :invalid_error, :ambiguous_error
      end

      def invalid_error(*args, &blk)
        self.class.invalid_error.new(*args, &blk)
      end

      def ambiguous_error(*args, &blk)
        self.class.ambiguous_error.new(*args, &blk)
      end

    end
  end
end
