pragma solidity ^0.5.1;

import "./Ownable.sol";


contract Library is Ownable{
   
    struct Book {
        bytes32 name;
        bytes32 author;
        bool isFrees;
        bool isExists;
    }

    struct Reader {
        bytes32 firstName;
        bytes32 lastName;
        bytes32 idBook;
        bytes32[] bookList;
        bool isExists;
    }

    mapping (bytes32 => Book) private books;
    mapping (address => Reader) private readers;

    string private READER_EXIST = "Reader alredy exist";
    string private BOOK_EXIST = "Book alredy exist";
    string private READER_NOT_EXIST = "Reader not exist";
    string private BOOK_NOT_EXIST = "Book not exist";


    event LogReader(address _readerAddress, bytes32 _firstName,  bytes32 _lastName);
    event LogBook(bytes32 _idBook, bytes32 _nameBook, bytes32 _author);
    event LogReadBook(address _readerAddress, bytes32 _idBook);
    event LogReturnBook(address _readerAddress, bytes32 _idBook, bool _isRead);

    /** 
     * Add new reader can anybody who want to use Library. 
     * Function check if user exists.
     */
    function addReader(
        bytes32 _firstName,
        bytes32 _lastName
        )
    external
    payable
    {
        require (!isExistsReader(msg.sender), READER_EXIST);
        Reader memory newReader;
        newReader.firstName = _firstName;
        newReader.lastName = _lastName;
        newReader.isExists = true;
        readers[msg.sender] = newReader;
        emit LogReader(msg.sender, _firstName, _lastName);
    }
    
    /**
     * Add book can only owner. Function ckeck if msg.sender is owner
     */
    function addBook(
        bytes32 _idBook,
        bytes32 _nameBook,
        bytes32 _author
        )
    external
    payable
    onlyOwner
    {
        require (!isExistsBook(_idBook), BOOK_EXIST);
        Book memory newBook;
        newBook.name = _nameBook;
        newBook.author = _author;
        newBook.isFrees = true;
        newBook.isExists = true;
        books[_idBook] = newBook;
        emit LogBook(_idBook, _nameBook, _author);
    }
    
    /**
     * Read book can only reader who exists in library 
     * and if book exists in library 
     * and if book has status "isFree" is true 
     * and if reader does not read another book now.
     * Book will be added to the reader and will be unavailable
     */
    function readBook(bytes32 _idBook)
    external
    payable
    {
        require (isExistsReader(msg.sender), READER_NOT_EXIST);
        require (isExistsBook(_idBook), BOOK_NOT_EXIST);
        require (books[_idBook].isFrees == true, "this book read another reader");
        require (readers[msg.sender].idBook == 0, "please return your curent book");
        books[_idBook].isFrees = false;
        readers[msg.sender].idBook = _idBook;
        emit LogReadBook(msg.sender, _idBook);
    }
    
    /**
     * Return can only reader who exists in library 
     * and if book exists in library 
     * and if reader read this book.
     * Reader in parameter indicates read or not this book
     * if read it is added to his list of read books
     * if not, it just becomes available to other readers
     */
    function returnBook(
        bytes32 _idBook,
        bool _isRead
        )
    external
    payable
    {
        require (isExistsReader(msg.sender), READER_NOT_EXIST);
        require (isExistsBook(_idBook), BOOK_NOT_EXIST);
        require (readers[msg.sender].idBook == _idBook, "you read another book");
        readers[msg.sender].idBook = bytes32(0);
        if (_isRead){
            readers[msg.sender].bookList.push(_idBook);
        }
        books[_idBook].isFrees = true;
        emit LogReturnBook(msg.sender, _idBook, _isRead);
    }
    
    /**
     * Only owner can view reader by address.
     */
    function getReader(address _readerAddress)
    public
    view
    onlyOwner
    returns (bytes32, bytes32, bytes32, bytes32[] memory)
    {
        return (readers[_readerAddress].firstName, readers[_readerAddress].lastName, readers[_readerAddress].idBook, readers[msg.sender].bookList) ;
    }
    
    /**
     * Only owner can view book by id book.
     */
    function getBook(bytes32 _idBook)
    public
    view
    onlyOwner
    returns (bytes32, bytes32, bool)
    {
        return (books[_idBook].name, books[_idBook].author, books[_idBook].isFrees) ;
    }

    function isExistsReader (address _readerAddress)
    private
    view
    returns (bool)
    {
        return readers[_readerAddress].isExists;
    }

    function isExistsBook (bytes32 _idBook)
    private
    view
    returns (bool)
    {
        return books[_idBook].isExists;
    }
}



