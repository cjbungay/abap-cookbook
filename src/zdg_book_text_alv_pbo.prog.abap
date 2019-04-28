*----------------------------------------------------------------------*
***INCLUDE ZDG_BOOK_TEXT_ALV_PBO .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '1'.

  if go_cust1 is not bound.
    CREATE OBJECT go_cust1
      EXPORTING
*        parent                      =
        container_name              = 'C1'.

CREATE OBJECT go_cust2
      EXPORTING
*        parent                      =
        container_name              = 'C2'.

    create object lo_event.

    CREATE OBJECT go_text
      EXPORTING
*        max_number_chars       =
*        style                  = 0
*        wordwrap_mode          = WORDWRAP_AT_WINDOWBORDER
*        wordwrap_position      = -1
*        wordwrap_to_linebreak_mode = FALSE
*        filedrop_mode          = DROPFILE_EVENT_OFF
        parent                 = go_cust1
*        lifetime               =
*        name                   =
*      EXCEPTIONS
*        error_cntl_create      = 1
*        error_cntl_init        = 2
*        error_cntl_link        = 3
*        error_dp_create        = 4
*        gui_type_not_supported = 5
*        others                 = 6
        .
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    set handler lo_event->handle_on_drop for go_text.


  endif.
ENDMODULE.                 " STATUS_0100  OUTPUT
