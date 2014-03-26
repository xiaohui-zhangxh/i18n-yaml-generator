module I18nYaml
  module Generators #:nodoc:
    class ModelGenerator < Rails::Generators::NamedBase #:nodoc:
      class_option :orm, :required => true
      class_option :commented, :default => Rails.application.config.i18n_yaml_generator.commented
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      include Rails::Generators::ResourceHelpers
      include I18nYamlGenerator::Helpers

      SUPPORTED_ORMS = {
        "active_record" => "activerecord",
        "active_model" => "activemodel",
        "mongoid"=> "mongoid"
      }

      def model_i18n_yaml_file
        current_orm = options.orm.to_s

        unless SUPPORTED_ORMS.keys.include? current_orm
          say "Not creating translation file - '#{current_orm}' not supported"
          return
        end

        orm_i18n_key = SUPPORTED_ORMS[current_orm]

        I18n.available_locales.each do |locale|
          hash_for_yaml = {}

          # Model name
          hash_for_yaml.deep_merge! wrap_hash(human_name, [orm_i18n_key, 'models', i18n_scope.gsub('.', '/')])

          # Attributes
          hash_for_yaml.deep_merge! wrap_hash(attributes_hash, [orm_i18n_key, 'attributes', i18n_scope.gsub('.', '/')])

          # Errors
          hash_for_yaml.deep_merge! wrap_hash({ singular_name => nil }, [orm_i18n_key, 'errors', 'models'])

          # Helpers
          hash_for_yaml.deep_merge! wrap_hash({ singular_name => nil }, ['helpers'])

          yaml_content = { locale.to_s => hash_for_yaml }.to_yaml

          destination_path = File.join('config/locales/models', "#{file_path}.#{locale}.yml")

          create_file destination_path, options.commented ? comment_yaml_body(yaml_content) : yaml_content
        end
      end

      protected

      def attributes_hash
        attributes.inject({}) { |hsh, a| hsh.merge(a.name => a.human_name) }
      end

    end
  end
end


