*&---------------------------------------------------------------------*
*& Report  ZDG_BOOK_TEXT_ALV
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zdg_book_text_alv.

class lcl_handler definition deferred.

DATA: go_text TYPE REF TO cl_gui_textedit,
      go_cust1 TYPE REF TO cl_gui_custom_container,
      go_cust2 TYPE REF TO cl_gui_custom_container,
      lo_event type ref to lcl_handler,
      ok_code TYPE sy-ucomm.

*----------------------------------------------------------------------*
*       CLASS lcl_handler DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_handler DEFINITION.
  PUBLIC SECTION.
    METHODS: handle_on_drop FOR EVENT on_drop OF cl_gui_textedit
               IMPORTING
                 index
                  line
                  pos
                  dragdrop_object.

ENDCLASS.                    "lcl_handler DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_handler IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_handler IMPLEMENTATION.
  METHOD: handle_on_drop.
    break-point.

  ENDMETHOD.                    "handle_on_drop
ENDCLASS.                    "lcl_handler IMPLEMENTATION

start-of-selection.

CALL SCREEN 0100.

INCLUDE zdg_book_text_alv_pbo.

INCLUDE zdg_book_text_alv_pai.
