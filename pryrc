require 'awesome_print'
AwesomePrint.pry!

def formatted_env
  case Rails.env
  when 'production'
    bold_upcased_env = Pry::Helpers::Text.bold(Rails.env.upcase)
    Pry::Helpers::Text.red(bold_upcased_env)
  when 'staging'
    Pry::Helpers::Text.yellow(Rails.env)
  when 'development'
    Pry::Helpers::Text.green(Rails.env)
  else
    Rails.env
  end
end

def app_name
  File.basename(Rails.root)
end

if defined?(Rails)
  Pry.config.prompt = proc { |obj, nest_level, _| "[#{app_name}][#{formatted_env}] #{obj}:#{nest_level}> " }
end
