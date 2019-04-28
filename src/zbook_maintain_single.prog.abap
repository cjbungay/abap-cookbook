*"---------------------------------------------------------------------*
REPORT zbook_maintain_single.

PARAMETERS p_call RADIOBUTTON GROUP x DEFAULT 'X'.
PARAMETERS p_sgle RADIOBUTTON GROUP x.
*"* Init
INITIALIZATION.

*"* Start of program
START-OF-SELECTION.


  CASE 'X'.
    WHEN p_call.

      DATA lt_sellist TYPE STANDARD TABLE OF vimsellist.
      DATA ls_sellist TYPE vimsellist.

      DATA lt_exclude TYPE STANDARD TABLE OF vimexclfun.
      DATA ls_exclude TYPE vimexclfun.

      ls_sellist-viewfield = 'AREA'.
*ls_sellist-NEGATION
*ls_sellist-LEFTPAR
      ls_sellist-operator = 'CP'.
      ls_sellist-value    = 'S*'.
*ls_sellist-RIGHTPAR
      APPEND ls_sellist TO lt_sellist.

      ls_exclude-function = 'AEND'.
      APPEND ls_exclude TO lt_exclude.

      CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
        EXPORTING
          action                               = 'S'
*   CORR_NUMBER                          = '          '
*   GENERATE_MAINT_TOOL_IF_MISSING       = ' '
       show_selection_popup                 = ' '
          view_name                            = 'ZBOOK_AREAS'
*   NO_WARNING_FOR_CLIENTINDEP           = ' '
*   RFC_DESTINATION_FOR_UPGRADE          = ' '
*   CLIENT_FOR_UPGRADE                   = ' '
*   VARIANT_FOR_SELECTION                = ' '
*   COMPLEX_SELCONDS_USED                = ' '
*   CHECK_DDIC_MAINFLAG                  = ' '
*   SUPPRESS_WA_POPUP                    = ' '
      TABLES
        dba_sellist                          = lt_sellist
        excl_cua_funct                       = lt_exclude
* EXCEPTIONS
*   CLIENT_REFERENCE                     = 1
*   FOREIGN_LOCK                         = 2
*   INVALID_ACTION                       = 3
*   NO_CLIENTINDEPENDENT_AUTH            = 4
*   NO_DATABASE_FUNCTION                 = 5
*   NO_EDITOR_FUNCTION                   = 6
*   NO_SHOW_AUTH                         = 7
*   NO_TVDIR_ENTRY                       = 8
*   NO_UPD_AUTH                          = 9
*   ONLY_SHOW_ALLOWED                    = 10
*   SYSTEM_FAILURE                       = 11
*   UNKNOWN_FIELD_IN_DBA_SELLIST         = 12
*   VIEW_NOT_FOUND                       = 13
*   MAINTENANCE_PROHIBITED               = 14
*   OTHERS                               = 15
                .
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    WHEN p_sgle.

      DATA ls_area TYPE zbook_areas.

      SELECT * FROM zbook_areas INTO ls_area.
        EXIT.
      ENDSELECT.
      CALL FUNCTION 'VIEW_MAINTENANCE_SINGLE_ENTRY'
        EXPORTING
          action                             = 'SHOW'
*   CORR_NUMBER                        = '          '
          view_name                          = 'ZBOOK_AREAS'
*   NO_WARNING_FOR_CLIENTINDEP         = ' '
*   RFC_DESTINATION_FOR_UPGRADE        = ' '
*   CLIENT_FOR_UPGRADE                 = ' '
*   VARIANT_FOR_SELECTION              = ' '
*   NO_TRANSPORT                       = ' '
*   SUPPRESSDIALOG                     = ' '
*   INSERT_KEY_NOT_FIXED               = ' '
*   COMPLEX_SELCONDS_USED              = ' '
* IMPORTING
*   CORR_NUMBER                        =
* TABLES
*   DBA_SELLIST                        =
*   EXCL_CUA_FUNCT                     =
        CHANGING
          entry                              = ls_area
* EXCEPTIONS
*   ENTRY_ALREADY_EXISTS               = 1
*   ENTRY_NOT_FOUND                    = 2
*   CLIENT_REFERENCE                   = 3
*   FOREIGN_LOCK                       = 4
*   INVALID_ACTION                     = 5
*   NO_CLIENTINDEPENDENT_AUTH          = 6
*   NO_DATABASE_FUNCTION               = 7
*   NO_EDITOR_FUNCTION                 = 8
*   NO_SHOW_AUTH                       = 9
*   NO_TVDIR_ENTRY                     = 10
*   NO_UPD_AUTH                        = 11
*   SYSTEM_FAILURE                     = 12
*   UNKNOWN_FIELD_IN_DBA_SELLIST       = 13
*   VIEW_NOT_FOUND                     = 14
*   OTHERS                             = 15
                .
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
  ENDCASE.

END-OF-SELECTION.
