require 'yaml'
require 'digest'

class Program
  class << self
    def run
      get_same_files.each.with_index(1) do |(hash, paths), i|
        break if i > config['result']
        display_result(paths)
      end
    end

    def get_files
      Dir.glob(config['dir'] + '**/**/*').select { |f| File.file?(f) }
    end

    def file_digest(file_path)
      Digest::SHA256.file(file_path).hexdigest
    end

    # Group files and sort it
    def get_same_files
      result = Hash.new []

      get_files.each do |file_path|
        result[file_digest(file_path)] += [file_path]
      end

      result.sort_by { |key, value| value.size }.reverse!
    end

    # Display result by content and how many same files
    # If the files are large, I think it's better to use file hash
    def display_result(paths)
      content = File.read(paths.sample)

      begin
        content = truncate(content)
      rescue => e
        puts "[Warning] #{e}"
        content = truncate(to_utf8(content))
      end

      puts [content, paths.size].join(' - ')
    end

    def truncate(content)
      content[0..50].gsub(/[\r\n]+/, ' ')
    end

    # https://stackoverflow.com/a/18454435
    def to_utf8(str)
      str.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    end

    def config
      YAML.load_file('config.yml')
    end
  end
end

Program.run