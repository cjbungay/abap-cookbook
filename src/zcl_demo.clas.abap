class ZCL_DEMO definition
  public
  create public .

public section.

  types:
    BEGIN OF ty_item,
             pos      TYPE n LENGTH 4,
             object   TYPE c LENGTH 10,
             quantity TYPE p LENGTH 10 DECIMALS 3,
           END OF ty_item .
  types:
    BEGIN OF ty_head,
             doc  TYPE c LENGTH 5,
             date TYPE d,
             name TYPE syuname,
             item_table TYPE STANDARD TABLE OF ty_item WITH KEY pos,
           END OF ty_head .

  class-data GS_DOCUMENT type TY_HEAD .
  class-data:
    gt_documents TYPE STANDARD TABLE OF ty_head WITH KEY doc .
  class-data GS_ITEM type TY_ITEM .

  class-methods FILL .
  class-methods READ .
protected section.
private section.
ENDCLASS.



CLASS ZCL_DEMO IMPLEMENTATION.


method FILL.

    gs_document-doc  = '12345'.
    gs_document-date = sy-datum.
    gs_document-name = sy-uname.
    gs_item-pos      = 10.
    gs_item-object   = 'ABC'.
    gs_item-quantity = 100.
    APPEND gs_item TO gs_document-item_table.
    gs_item-pos      = 20.
    gs_item-object   = 'DEF'.
    gs_item-quantity = 200.
    APPEND gs_item TO gs_document-item_table.

    APPEND gs_document TO gt_documents.

endmethod.


method READ.

    CLEAR gs_document.
    CLEAR gs_item.

    FIELD-SYMBOLS <document> TYPE ty_head.
    FIELD-SYMBOLS <item>     TYPE ty_item.
    READ TABLE gt_documents ASSIGNING <document> WITH TABLE KEY doc = '12345'.
    IF sy-subrc = 0.
      LOOP AT <document>-item_table ASSIGNING <item>.
        WRITE: / <item>-pos, <item>-object, <item>-quantity.
      ENDLOOP.
    ENDIF.

endmethod.
ENDCLASS.
