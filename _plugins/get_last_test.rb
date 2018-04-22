
=begin
Previously used this in the validation_report.html to get the latest test
however github pages disallows plugins so now we have a hook to write yaml for it
  {% if report.testing_note %}
  <strong>Note:</strong> {{ report.testing_note }}
  {% else %}
  {{ report.short | get_last_test: site.data.reports }}
  {% endif %}
=end

module Jekyll
  module TestLookups
    #! we send the reports from the site in the template 
    #! ... because we are not sure how to get site here?
    def get_last_test(input,reports)
      matches = []
      for entry in reports
        if entry.key?('validations')
          for subtype in ['automatic','interface']
            if entry['validations'].key?(subtype)
              for item in entry['validations'][subtype]
                if item['tag']==input
                  matches << entry['when']
                end
              end
            end
          end
        end
      end
      if matches.any?
        report_code = matches.sort.last
        out = "<a class=\"bubble_light\" href=\"/reports/#"+
          report_code+"\">tested "+report_code+"</a>"
        return out
      else
        return "<span class=\"bubble_light\">pending test</span>"
      end
    end
  end
end
Liquid::Template.register_filter(Jekyll::TestLookups)

Jekyll::Hooks.register :site, :after_init do |site|
  # note the most recent completed test in a new file
  require 'yaml'
  reports = YAML.load_file('_data/reports.yaml')
  validations  = YAML.load_file('_data/validations.yaml')
  mapping = {}
  for validation in validations
    puts validation
    matches = []
    for entry in reports
      if entry.key?('validations')
        for subtype in ['automatic','interface']
          if entry['validations'].key?(subtype)
            for item in entry['validations'][subtype]
              if item['tag']==validation["short"]
                matches << entry['when']
              end
            end
          end
        end
      end
    end
    if matches.any?
      report_code = matches.sort.last
      mapping[validation["short"]] = report_code
    end
  end
  File.open("_data/validations_times.yaml",'w') { |file| 
    file.write(mapping.to_yaml)
  }
end
