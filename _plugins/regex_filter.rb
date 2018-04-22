
module Jekyll
  module RegexFilter
    def regex_subs(input, reg_str, repl_str)
      re = Regexp.new reg_str
      input.gsub re, repl_str
    end
  end
end

Liquid::Template.register_filter(Jekyll::RegexFilter)

