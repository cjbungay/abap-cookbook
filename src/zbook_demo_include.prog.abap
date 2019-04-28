REPORT zbook_demo_include.


DATA gt_fcat           TYPE lvc_t_fcat.
FIELD-SYMBOLS <fcat>   TYPE lvc_s_fcat.

FIELD-SYMBOLS <t_demo> TYPE table.
FIELD-SYMBOLS <s_demo> TYPE ANY.
DATA gd_demo           TYPE REF TO data.
DATA gr_grid           TYPE REF TO cl_salv_table.

PARAMETERS p_sname TYPE c LENGTH 30 DEFAULT 'ZBOOK_STATUS_DEMO1'.
PARAMETERS p_fcat  TYPE c RADIOBUTTON GROUP type.
PARAMETERS p_salv  TYPE c RADIOBUTTON GROUP type.


START-OF-SELECTION.
  CASE 'X'.
    WHEN p_fcat.
      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name       = p_sname
        CHANGING
          ct_fieldcat            = gt_fcat
        EXCEPTIONS
          inconsistent_interface = 1
          program_error          = 2
          OTHERS                 = 3.
*    BREAK-POINT.

      LOOP AT gt_fcat ASSIGNING <fcat>.
        WRITE: / <fcat>-col_pos,
                 <fcat>-fieldname.
      ENDLOOP.

    WHEN p_salv.

      CREATE DATA gd_demo TYPE STANDARD TABLE OF (p_sname).

      ASSIGN gd_demo->* TO <t_demo>.

      DO 5 TIMES.
        APPEND INITIAL LINE TO <t_demo> ASSIGNING <s_demo>.
        CLEAR <s_demo> WITH sy-abcde+sy-index(1).
      ENDDO.

      TRY.
          cl_salv_table=>factory(
            IMPORTING
              r_salv_table = gr_grid
            CHANGING
              t_table      = <t_demo> ).
        CATCH cx_salv_msg.
      ENDTRY.
      gr_grid->display( ).
  ENDCASE.
