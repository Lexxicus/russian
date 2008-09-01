$KCODE='u'

$:.push File.join(File.dirname(__FILE__), 'russian')
$:.push File.join(File.dirname(__FILE__), 'vendor', 'i18n', 'lib')

require 'i18n' unless defined?(I18n)

require 'backend/advanced'
require 'action_view_ext/helpers/date_helper'
require 'active_record_ext/custom_error_message'

module Russian
  module VERSION
    MAJOR = 0
    MINOR = 0
    TINY  = 1

    STRING = [MAJOR, MINOR, TINY].join('.')
  end
  
  # Russian locale
  LOCALE = :'ru-RU'

  class << self
    # Russian locale
    def locale
      LOCALE
    end
    
    # Returns custom backend class for usage with Russian library
    # 
    # See I18n::Backend
    def i18n_backend_class
      I18n::Backend::Advanced
    end
    
    # Init Russian i18n: set custom backend, set default locale to Russian locale, load all translations
    # shipped with library.
    def init_i18n
      I18n.backend = Russian.i18n_backend_class.new
      I18n.default_locale = LOCALE
      locale_files.each { |file| I18n.backend.load_translations(file) }
    end
  
    # See I18n::translate
    def translate(key, options = {})
      I18n.translate(key, options.merge({ :locale => LOCALE }))
    end        
    alias :t :translate
    
    # See I18n::localize
    def localize(object, options = {})
      I18n.localize(object, options.merge({ :locale => LOCALE }))
    end
    alias :l :localize
    
    # strftime() proxy with Russian localization
    def strftime(object, format = :default)
      localize(object, { :format => format })
    end
    
    # Simple pluralization proxy
    #
    # Usage: 
    #   Russian.pluralize(1, "вещь", "вещи", "вещей")
    def pluralize(n, *variants)
      variants_hash = pluralization_variants_to_hash(*variants)
      I18n.backend.send(:pluralize, LOCALE, variants_hash, n)
    end
    
    protected
      # Returns all locale files shipped with library
      def locale_files
        Dir[File.join(File.dirname(__FILE__), "russian", "locale", "**/*")]
      end
      
      # Converts an array of pluralization variants (3 entries) to a Hash that can be used
      # with I18n pluralization.
      def pluralization_variants_to_hash(*variants)
        raise ArgumentError, "Must have at least 3 variants for pluralization" if variants.size < 3
        {
          :one => variants[0],
          :few => variants[1],
          :many => variants[2],
          :other => variants[1]
        }
      end
  end
end

Russian.init_i18n