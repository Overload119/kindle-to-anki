require 'nokogiri'

class KindleNoteReader
  class UnsupportedFileFormat < StandardError; end

  def initialize(path)
    @path = path
  end

  def notes
    @notes ||= begin
      ext_name = File.extname(@path)
      if ext_name === '.html'
        parse_html
      else
        raise UnsupportedFileFormat, ext_name
      end
    end
  end

  private

  def parse_html
    notes = []
    File.open(@path) do |file|
      html = Nokogiri::HTML(file)
      html.css('.noteText').each do |node|
        notes << node.inner_text.strip
      end
    end
    notes
  end
end
