#include "Library.hpp"


namespace Library{

    /** 
     * Add new reader can anybody who want to use Library. 
     * Function check if user exists.
     */
    void Library::addreader(name reader_account){
        require_auth(reader_account);
        readerIndex readertable(_self, _self.value);
        auto iterator = readertable.find(reader_account.value);
        eosio_assert(iterator == readertable.end(), "address for reader alrady exist");
        readertable.emplace( _self, [&]( auto& reader ) {
            reader.reader_account = reader_account;
        });
    }

    /**
     * Add book can only owner. Function ckeck if msg.sender is owner
     */
    void Library::addbook(uint32_t book_id, string name_book, string author){
        require_auth(_self);
        bookIndex booktable(_self, _self.value);
        auto iterator = booktable.find(book_id);
        eosio_assert(iterator == booktable.end(), "book alrady exist");
        booktable.emplace( _self, [&]( auto& book ) {
            book.book_id = book_id;
            book.name = name_book;
            book.author = author;
            book.exist = true;
        });
    }

    /**
     * Read book can only reader who exists in library 
     * and if book exists in library 
     * and if book has status "isFree" is true 
     * and if reader does not read another book now.
     * Book will be added to the reader and will be unavailable
     */
    void Library::readbook(name reader_account, uint32_t book_id) {
        require_auth(reader_account);

        readerIndex readertable(_self, _self.value);
        auto iterator_reader = readertable.find(reader_account.value);
        eosio_assert(iterator_reader != readertable.end(),  "address for reader not found");

        bookIndex booktable(_self, _self.value);
        auto iterator_book = booktable.find(book_id);
        eosio_assert(iterator_book != booktable.end(), "book not found");

        booktable.modify(iterator_book, reader_account, [&](auto& book) {
            eosio_assert(book.exist != false, "this book read another reader");
            book.exist = false;
        });

        readertable.modify(iterator_reader, reader_account, [&](auto& reader) {
            eosio_assert(reader.book_id == 0, "please return your curent book");
            reader.book_id = book_id;
        }); 
    }

    /**
     * Return can only reader who exists in library 
     * and if book exists in library 
     * and if reader read this book.
     * Reader in parameter indicates read or not this book
     * if read it is added to his list of read books
     * if not, it just becomes available to other readers
     */
    void Library:: returnbook(name reader_account, uint32_t book_id, bool read){
        require_auth(reader_account);

        readerIndex readertable(_self, _self.value);
        auto iterator_reader = readertable.find(reader_account.value);
        eosio_assert(iterator_reader != readertable.end(),  "address for reader not found");

        bookIndex booktable(_self, _self.value);
        auto iterator_book = booktable.find(book_id);
        eosio_assert(iterator_book != booktable.end(), "book not found");

        readertable.modify(iterator_reader, reader_account, [&](auto& reader) {
            eosio_assert(reader.book_id == book_id, "you read another book");
            reader.book_id = 0;
            if(read){
                reader.books.push_back(book_id);
            }
        });
        
        booktable.modify(iterator_book, reader_account, [&](auto& book) {
            book.exist = true;
        });
    }

    EOSIO_DISPATCH( Library, (addreader)(addbook)(readbook)(returnbook))
};


