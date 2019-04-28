REPORT zbook_call_maint_view_02.

*== data
DATA gs_zbook_areasv TYPE zbook_areasv.

*== selection screen
PARAMETERS p_area LIKE zbook_areas-area.

*== Start of program
START-OF-SELECTION.

  SELECT SINGLE *
    FROM zbook_areas
    INTO CORRESPONDING FIELDS OF gs_zbook_areasv
   WHERE area = p_area.
  CHECK sy-subrc = 0.

  CALL FUNCTION 'VIEW_MAINTENANCE_SINGLE_ENTRY'
    EXPORTING
      action    = 'UPD'
      view_name = 'ZBOOK_AREASV'
    CHANGING
      entry     = gs_zbook_areasv
    EXCEPTIONS
      OTHERS    = 15.
