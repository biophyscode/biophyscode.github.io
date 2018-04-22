Jekyll::Hooks.register :site, :after_init do |site|
  # write test reports which show the proof of work for a test, with commit hashes
  #! cannot use site.data because it is not ready at :after_init so we get it manually
  #! this means that we only run once on build and not continuously on `jekyll serve`
  require 'yaml'
  site_data_reports = YAML.load_file('_data/reports.yaml')
  for report in site_data_reports
    File.open("_test_reports/#{report['when']}.md",'w') { |file| 
      out = {"layout"=>"test_report_raw","title"=>report['when'],"raw"=>{}}
      if report.key?('amx')
        report['amx'].each do |item|
          key = "experiment: #{item['name']}, "+\
            "kickstarter: #{item['kickstarter']}, docker: #{item['docker']}"
          out['raw'][key] = item['raw'].gsub!(/(https?:\/\/\S+)/,'[\1](\1)')
        end
      end
      if report.key?('validations')
        report['validations']['raw'].each do |key,val|
          out['raw'][key] = val.gsub!(/(https?:\/\/\S+)/,'[\1](\1)')
        end
      end
      file.write("#{out.to_yaml}\n---\n\n")
    }
  end
end
