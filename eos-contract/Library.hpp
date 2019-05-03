#include <eosiolib/eosio.hpp>
#include <eosiolib/print.hpp>
#include <string>

namespace Library{
    using namespace eosio;
    using std::string;

    class [[eosio::contract("Library")]] Library : public contract {
        using contract::contract;

        public:   

        [[eosio::action]]
        void addreader(name reader_name);

        [[eosio::action]]
        void addbook(uint32_t book_id, string name_book, string author);

        [[eosio::action]]
        void readbook(name reader_name, uint32_t book_id);

        [[eosio::action]]
        void returnbook(name reader_name, uint32_t book_id, bool read);

        private:

        struct [[eosio::table]] book {
            uint32_t book_id;
            string name;
            string author;
            bool exist;

            uint64_t primary_key()const { return book_id; }
         };

        struct [[eosio::table]] reader{
            name reader_account;
            uint32_t book_id;
            std::vector<uint32_t> books;

            uint64_t primary_key() const { return reader_account.value; }
        };

        typedef multi_index<"book"_n, book> bookIndex;
        typedef multi_index<"reader"_n,reader> readerIndex;
    };
};
