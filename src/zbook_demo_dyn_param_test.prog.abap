REPORT zbook_demo_dyn_param_test.

DATA gr_attr TYPE REF TO zcl_book_attr.

PARAMETERS p_tiknr TYPE zbook_ticket_nr MEMORY ID ztik.
PARAMETERS p_num   type i DEFAULT 1.
PARAMETERS p_show  AS CHECKBOX DEFAULT space.
PARAMETERS p_Save  AS CHECKBOX DEFAULT 'X'.

START-OF-SELECTION.
  CREATE OBJECT gr_attr
    EXPORTING
      tiknr = p_tiknr.

  IF p_show IS NOT INITIAL.
    gr_attr->show( p_num ).
  ELSE.
    gr_attr->edit( p_num ).
    if p_save is NOT INITIAL.
      gr_attr->save( ).
    endif.
  ENDIF.
