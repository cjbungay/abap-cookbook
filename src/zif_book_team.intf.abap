*"* components of interface ZIF_BOOK_TEAM
interface ZIF_BOOK_TEAM
  public .


  class-methods GET_TEAM
    importing
      !IDENTIFIER type CLIKE optional
    preferred parameter IDENTIFIER
    returning
      value(NODES) type SVMCRT_TREE_NODE_TAB .
endinterface.
