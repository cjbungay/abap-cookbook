REPORT zbook_demo_dyn_struc_single.

DATA gs_ticket    TYPE zbook_ticket.
DATA gr_dd_single TYPE REF TO zcl_book_dynamic_data_single.

START-OF-SELECTION.

  CREATE OBJECT gr_dd_single.

  gr_dd_single->prepare_struc( gs_ticket ).
  gr_dd_single->display_data( ).

  gr_dd_single->get_data_struc( IMPORTING struc = gs_ticket ).

  BREAK-POINT.
