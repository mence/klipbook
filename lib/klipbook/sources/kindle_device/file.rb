module Klipbook::Sources
  module KindleDevice
    class File
      def initialize(infile, max_books, file_parser=FileParser.new)
        @file_text = infile.read.strip
        @file_parser = file_parser
        @max_books = max_books
      end

      # TODO Shift max books here
      def books
        @books ||= build_books.take(@max_books)
      end

    private

      def build_books
        sorted_entries = extract_sorted_entries_from_file_text
        build_sorted_book_list(sorted_entries)
      end

      def extract_sorted_entries_from_file_text
        entries = @file_parser.extract_entries(@file_text)
        entries.sort { |entry_a, entry_b| entry_a.title <=> entry_b.title }
      end

      def build_sorted_book_list(sorted_entries)
        books_from_entries(sorted_entries).sort do |book_a, book_b|
          book_b.last_update <=> book_a.last_update
        end
      end

      def books_from_entries(entries)
        entries.select { |entry| entry.type != :bookmark }
               .group_by(&:title)
               .map { |title, book_entries| book_from_entries(book_entries) }
      end

      def book_from_entries(entries)
        entries.sort! { |ea, eb| ea.location <=> eb.location }

        Klipbook::Book.new.tap do |b|
          b.title = entries.first.title
          b.author = entries.first.author
          b.last_update = entries.map(&:added_on).max
          b.clippings = entries.map do |e|
            Klipbook::Clipping.new.tap do |c|
              c.location = e.location
              c.page = e.page
              c.text = e.text
              c.type = e.type
            end
          end
        end
      end
    end
  end
end
