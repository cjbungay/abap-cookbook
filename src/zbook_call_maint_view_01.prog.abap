REPORT zbook_call_maint_view_01.

*== data
DATA gt_sellist TYPE STANDARD TABLE OF vimsellist.
FIELD-SYMBOLS <sellist> TYPE vimsellist.

*== selection screen
PARAMETERS p_area LIKE zbook_areasv-area.

*== Start of program
START-OF-SELECTION.

*== define select options
  APPEND INITIAL LINE TO gt_sellist ASSIGNING <sellist>.
  <sellist>-viewfield = 'AREA'.
  <sellist>-operator  = 'EQ'.
  <sellist>-value     = p_area.

*== call maintenance view (SM30)
  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action      = 'S'
      view_name   = 'ZBOOK_AREASV'
    TABLES
      dba_sellist = gt_sellist
    EXCEPTIONS
      OTHERS      = 15.
