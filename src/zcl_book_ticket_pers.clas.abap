class ZCL_BOOK_TICKET_PERS definition
  public
  inheriting from CL_SUPER_PERS_ACCESS
  final
  create public .

public section.

  methods CONSTRUCTOR .
protected section.
private section.
ENDCLASS.



CLASS ZCL_BOOK_TICKET_PERS IMPLEMENTATION.


METHOD constructor.

  super->constructor( ).

  table_user = 'ZBOOK_PERS'.
  field_user = 'UNAME'.
  table_role = space.
  field_role = space.
  table_system = space.


  CREATE DATA buffer_table_user TYPE STANDARD TABLE OF (table_user).
  CREATE DATA buffer_line_user TYPE (table_user).

ENDMETHOD.
ENDCLASS.
