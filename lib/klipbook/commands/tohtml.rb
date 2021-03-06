module Klipbook::Commands
  class ToHtml
    def initialize(books, pretty_printer=Klipbook::ToHtml::HtmlPrinter.new)
      @books = books
      @pretty_printer = pretty_printer
    end

    def call(output_dir, force, message_stream=$stdout)
      message_stream.puts "Using output directory: #{output_dir}"

      @books.each do |book|
        @pretty_printer.print_to_file(book, output_dir, force)
      end
    end
  end
end

