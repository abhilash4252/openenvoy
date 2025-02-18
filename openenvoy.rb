class CodeLineCounter
    attr_reader :blank_lines, :comment_lines, :code_lines, :import_lines, :total_lines
  
    LANGUAGE_RULES = {
      "java" => { single: "//", multi_start: "/*", multi_end: "*/", import: "import " },
      "c" => { single: "//", multi_start: "/*", multi_end: "*/", import: "#include" },
      "javascript" => { single: "//", multi_start: "/*", multi_end: "*/", import: "import " },
      "python" => { single: "#", multi_start: '"""', multi_end: '"""', import: "import " },
      "ruby" => { single: "#", multi_start: "=begin", multi_end: "=end", import: "require " }
    }
  
    def initialize(language)
      @language = language.downcase
      @rules = LANGUAGE_RULES[@language]
      raise "Unsupported language: #{@language}" unless @rules
  
      @blank_lines = 0
      @comment_lines = 0
      @code_lines = 0
      @import_lines = 0
      @total_lines = 0
      @inside_multiline_comment = false
    end
  
    def count_lines(file_path)
      File.foreach(file_path) do |line|
        @total_lines += 1
        stripped_line = line.strip
  
        if stripped_line.empty?
          @blank_lines += 1
        elsif check_multiline_comment(stripped_line) || stripped_line.start_with?(@rules[:single])
          @comment_lines += 1
        elsif stripped_line.start_with?(@rules[:import])
          @import_lines += 1
        else
          @code_lines += 1
        end
      end
    end
  
    def check_multiline_comment(line)
      if @inside_multiline_comment
        @inside_multiline_comment = false if line.include?(@rules[:multi_end])
        return true
      elsif line.start_with?(@rules[:multi_start])
        @inside_multiline_comment = true unless line.include?(@rules[:multi_end])
        return true
      end
      false
    end
  
    def print_results
      puts "Blank: #{@blank_lines}"
      puts "Comments: #{@comment_lines}"
      puts "Imports: #{@import_lines}"
      puts "Code: #{@code_lines}"
      puts "\nTotal: #{@total_lines}"
    end
  end
  
  def process_directory(directory, language)
    counter = CodeLineCounter.new(language)
    
    Dir.glob("#{directory}/*").each do |file|
      next unless File.file?(file)
      puts "\nProcessing file: #{file}"
      counter.count_lines(file)
    end
  

    counter.print_results
  end

  if __FILE__ == $0
    directory = "test_files"  # Change this to your directory path
    language = "ruby"         # Change this based on file type (java, python, ruby, etc.)
  
    process_directory(directory, language)
  end
  