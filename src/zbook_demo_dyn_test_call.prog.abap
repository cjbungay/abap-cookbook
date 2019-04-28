REPORT zbook_demo_dyn_test_call.

DATA gt_attributes TYPE zbook_class_attr_tt.

PARAMETERS p_area TYPE zbook_area DEFAULT 'HARDWARE'.
PARAMETERS p_clas TYPE zbook_clas DEFAULT 'PC'.

DATA gv_type01 TYPE c LENGTH 80.
DATA gv_type02 TYPE c LENGTH 80.
DATA gv_type03 TYPE c LENGTH 80.
DATA gv_type04 TYPE c LENGTH 80.
DATA gv_type05 TYPE c LENGTH 80.

DATA gv_data01 TYPE c LENGTH 20.
DATA gv_data02 TYPE c LENGTH 20.
DATA gv_data03 TYPE c LENGTH 20.
DATA gv_data04 TYPE c LENGTH 20.
DATA gv_data05 TYPE c LENGTH 20.


START-OF-SELECTION.

  PERFORM assign_attributes.

  CHECK gt_attributes IS NOT INITIAL.

  SUBMIT zbook_demo_dyn_data
          WITH p_data01 = gv_data01
          WITH p_data02 = gv_data02
          WITH p_data03 = gv_data03
          WITH p_data04 = gv_data04
          WITH p_data05 = gv_data05
          WITH p_type01 = gv_type01
          WITH p_type02 = gv_type02
          WITH p_type03 = gv_type03
          WITH p_type04 = gv_type04
          WITH p_type05 = gv_type05
           AND RETURN.

  PERFORM import_data.


*&---------------------------------------------------------------------*
*&      Form  assign_attributes
*&---------------------------------------------------------------------*
FORM assign_attributes.

  DATA lv_count             TYPE n LENGTH 2.
  DATA lv_type              TYPE c LENGTH 80.
  FIELD-SYMBOLS <type>      TYPE any.
  FIELD-SYMBOLS <attribute> TYPE zbook_class_attr.

  SELECT * FROM zbook_class_attr
    INTO TABLE gt_attributes
   WHERE ( area = p_area AND clas = p_clas )
      OR ( area = p_area AND clas = space ).

  CHECK sy-subrc = 0.

  SORT gt_attributes BY clas sort_order.

  LOOP AT gt_attributes ASSIGNING <attribute>.
    lv_count = sy-tabix.
    CONCATENATE 'GV_TYPE' lv_count INTO lv_type.
    ASSIGN (lv_type) TO <type>.
    IF sy-subrc = 0.
      CONCATENATE <attribute>-attribute_table <attribute>-attribute_field INTO <type> SEPARATED BY '-'.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "assign_attributes

*&---------------------------------------------------------------------*
*&      Form  import_data
*&---------------------------------------------------------------------*
FORM import_data.
  TYPES: BEGIN OF ty_param,
           field TYPE c LENGTH 80,
           value TYPE c LENGTH 80,
         END OF ty_param.
  DATA lt_params TYPE STANDARD TABLE OF ty_param.
  FIELD-SYMBOLS <param> TYPE ty_param.
  FIELD-SYMBOLS <value> TYPE any.

  DATA lv_count     TYPE n LENGTH 2.
  DATA lv_pname     TYPE c LENGTH 80.


  DO 5 TIMES.
    lv_count = sy-index.
    APPEND INITIAL LINE TO lt_params ASSIGNING <param>.
    <param>-field = lv_count.
    CONCATENATE 'GV_DATA' lv_count INTO <param>-value.
  ENDDO.


  IMPORT (lt_params) FROM MEMORY ID '$DYN$'.
  LOOP AT lt_params ASSIGNING <param>.
    ASSIGN (<param>-value) TO <value>.
    WRITE: / <param>-value, <value> COLOR COL_TOTAL.
  ENDLOOP.

  DO 5 TIMES.
    lv_count = sy-index.
    CONCATENATE 'P_DATA' lv_count INTO lv_pname.
    ASSIGN (lv_pname) TO <value>.
    IMPORT value TO <value> FROM MEMORY ID lv_pname.
    CHECK sy-subrc = 0.
    WRITE: / lv_pname, <value> COLOR COL_POSITIVE.
  ENDDO.

  PERFORM convert_fields_to_structure.

ENDFORM.                    "import_data

*&---------------------------------------------------------------------*
*&      Form  convert_fields_to_structure
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM convert_fields_to_structure.


  FIELD-SYMBOLS <attribute> TYPE zbook_class_attr.
  DATA lv_fieldname         TYPE string.
  DATA lr_datadescr         TYPE REF TO cl_abap_datadescr.
  DATA lr_structdescr       TYPE REF TO cl_abap_structdescr.
  DATA lr_tabledescr        TYPE REF TO cl_abap_tabledescr.
  DATA lt_dyn_components    TYPE cl_abap_structdescr=>component_table. "Struktur von cl_abap_structdescr=>COMPONENT_TABLE
  DATA ls_dyn_component     LIKE LINE OF lt_dyn_components.
  DATA ld_dynamic_data      TYPE REF TO data.
  FIELD-SYMBOLS <dd_table>  TYPE STANDARD TABLE.
  FIELD-SYMBOLS <dd_warea>  TYPE any.

  FIELD-SYMBOLS <dd_value>  TYPE any.
  FIELD-SYMBOLS <data>      TYPE any.

  DATA lv_count             TYPE n LENGTH 2.
  DATA lv_pname             TYPE c LENGTH 80.

  DATA lv_xml_string        TYPE string.

  LOOP AT  gt_attributes ASSIGNING  <attribute>.

    ls_dyn_component-name = <attribute>-attribute_field.

    CONCATENATE <attribute>-attribute_table <attribute>-attribute_field INTO lv_fieldname SEPARATED BY '-'.
    lr_datadescr ?= cl_abap_datadescr=>describe_by_name( lv_fieldname ).
    ls_dyn_component-type       = lr_datadescr.
    ls_dyn_component-as_include = ' '.
    ls_dyn_component-name       = <attribute>-attribute_field.
    APPEND ls_dyn_component TO lt_dyn_components.

  ENDLOOP.


* Zunächst eine Strukturbeschreibung erzeugen aus den einzelnen Komponenten
  TRY.
      lr_structdescr = cl_abap_structdescr=>create(  p_components = lt_dyn_components ).
    CATCH cx_sy_struct_creation .
      BREAK-POINT.  " Hier sinnvolle Fehlerbehandlung
  ENDTRY.

* Aus der Strukturbeschreibung eine Tabellenbeschreibung erzeugen und daraus dann eine Referenz auf zugehörige Tabelle
  TRY.
      lr_tabledescr = cl_abap_tabledescr=>create( p_line_type  = lr_structdescr ).
      CREATE DATA ld_dynamic_data TYPE HANDLE lr_tabledescr.
    CATCH cx_sy_table_creation .
      BREAK-POINT.  " Hier sinnvolle Fehlerbehandlung
  ENDTRY.

  ASSIGN ld_dynamic_data->* TO <dd_table>.




  APPEND INITIAL LINE TO <dd_table> ASSIGNING <dd_warea>.
  DO.
    lv_count = sy-index.
    ASSIGN  COMPONENT sy-index OF STRUCTURE <dd_warea> TO <dd_value>.
    IF sy-subrc = 0.
      CONCATENATE 'GV_DATA' lv_count INTO lv_pname.
      ASSIGN (lv_pname) TO <data>.
      IF sy-subrc = 0.
        <dd_value> = <data>.
      ENDIF.
    ELSE.
      EXIT. "from do
    ENDIF.
  ENDDO.

  CALL TRANSFORMATION id SOURCE data = <dd_table>
                       RESULT XML lv_xml_string.


ENDFORM.                    "convert_fields_to_structure
