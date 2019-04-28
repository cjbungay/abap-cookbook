*&---------------------------------------------------------------------*
*& Report  ZBOOK_DEMO_DYN_STRUCTURE
*&---------------------------------------------------------------------*
REPORT zbook_demo_dyn_structure.

TABLES: zbook_ticket.


DATA: gr_t_data TYPE REF TO data,  " Output table
      go_salv   TYPE REF TO cl_salv_table.

*--------------------------------------------------------------------*
* Selektionsbild
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-bl1.
SELECT-OPTIONS: s_tiknr FOR zbook_ticket-tiknr.
SELECTION-SCREEN END OF BLOCK bl1.


START-OF-SELECTION.
  PERFORM read_static_ticket_data CHANGING gr_t_data.
  PERFORM add_dynamic_ticket_data CHANGING gr_t_data.


END-OF-SELECTION.
  PERFORM output_data CHANGING gr_t_data.
*&---------------------------------------------------------------------*
*&      Form  OUTPUT_DATA
*&---------------------------------------------------------------------*
FORM output_data  CHANGING  pr_t_data TYPE REF TO data.

  FIELD-SYMBOLS: <lt_data> TYPE STANDARD TABLE.

  DATA: lo_salv_columns_table         TYPE REF TO cl_salv_columns_table.

  ASSIGN pr_t_data->* TO <lt_data>.

  TRY.
      CALL METHOD cl_salv_table=>factory
        IMPORTING
          r_salv_table = go_salv
        CHANGING
          t_table      = <lt_data>.

*--------------------------------------------------------------------*
* SALV-Spalten:
*--------------------------------------------------------------------*
      lo_salv_columns_table = go_salv->get_columns( )      .
      lo_salv_columns_table->set_optimize( ).      " Spaltenbreite optimieren
      lo_salv_columns_table->set_exception_column( value = 'LIGHT' " extra angefügt worden
                                                   group = '1' ).  " LED (2) statt Ampel (1) geht nicht - SAP-Doku hier leider fehlerhaft


*--------------------------------------------------------------------*
* SALV-Anzeige
*--------------------------------------------------------------------*
      go_salv->display( ).

    CATCH cx_salv_msg .
      BREAK-POINT.  " Hier sinnvolle Fehlerbehandlung

    CATCH cx_salv_data_error.
      BREAK-POINT.  " Hier sinnvolle Fehlerbehandlung

  ENDTRY.


ENDFORM.                    " OUTPUT_DATA

*&---------------------------------------------------------------------*
*&      Form  READ_STATIC_TICKET_DATA
*&---------------------------------------------------------------------*
FORM read_static_ticket_data CHANGING pr_t_data TYPE REF TO data.

  FIELD-SYMBOLS: <lt_data> TYPE STANDARD TABLE.

  CREATE DATA pr_t_data TYPE STANDARD TABLE OF zbook_ticket.
  ASSIGN pr_t_data->* TO <lt_data>.
  SELECT *
    INTO TABLE <lt_data>
    FROM zbook_ticket
    WHERE tiknr IN s_tiknr.


ENDFORM.                    " READ_STATIC_TICKET_DATA


*&---------------------------------------------------------------------*
*&      Form  ADD_DYNAMIC_TICKET_DATA
*&---------------------------------------------------------------------*
* 1. Schritt - Lesen aller Ticketattribute
* 2. Schritt - Bestimmen welche Ticketattribute in der Selektion verwendet werden
* 3. Schritt - Neue Tabellenbeschreibung aufbauen inkl. der verwendeten Ticketattribute
* 4. Schritt - Neue erweiterte Tabelle aufbauen
* 5. Schritt - Daten von alter in neue Tabelle umschaufeln und mit dyn. Attributen erweitern
*&---------------------------------------------------------------------*
FORM add_dynamic_ticket_data CHANGING pr_t_data TYPE REF TO data.

  DATA: lt_zbook_ticketattr   TYPE SORTED TABLE OF zbook_ticketattr WITH NON-UNIQUE KEY tiknr,
        lt_used_attributes    TYPE SORTED TABLE OF zbook_ticketattr WITH UNIQUE KEY attribute_table attribute_field,  " Type sorted, damit ich einen nummerierten Index bekomme
        lo_datadescr           TYPE REF TO cl_abap_datadescr,
        lo_structdescr        TYPE REF TO cl_abap_structdescr,
        lo_tabledescr         TYPE REF TO cl_abap_tabledescr,
        lt_dyn_components     TYPE cl_abap_structdescr=>component_table, "Struktur von cl_abap_structdescr=>COMPONENT_TABLE
*                                                                              name       type string,
*                                                                              type       type ref to cl_abap_datadescr,
*                                                                              as_include type abap_bool,
*                                                                              suffix     type string,
        ls_dyn_component      LIKE LINE OF lt_dyn_components,
        lv_n3                 TYPE numc3,
        lv_fieldname          TYPE fieldname,

        BEGIN OF ls_excecption,
          light TYPE char1,
        END OF ls_excecption,

        lr_t_new_data         TYPE REF TO data,
        ls_zbook_ticket       TYPE zbook_ticket.

  FIELD-SYMBOLS: <ls_zbook_ticketattr> TYPE zbook_ticketattr,
                 <lt_old_data>         TYPE STANDARD TABLE,
                 <lt_new_data>         TYPE STANDARD TABLE,
                 <ls_old_data>         TYPE any,
                 <ls_new_data>         TYPE any,
                 <lv_field>            TYPE any.


*--------------------------------------------------------------------*
* 1. Schritt - Lesen aller Ticketattribute
* Bei komplexeren Bedingungen in routine READ_STATIC_TICKET_DATA alternativ via "for all entries" an dieser Stelle
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE lt_zbook_ticketattr
    FROM zbook_ticketattr
    WHERE tiknr IN s_tiknr.

*--------------------------------------------------------------------*
* 2. Schritt - Bestimmen welche Ticketattribute in der Selektion verwendet werden
*--------------------------------------------------------------------*
  LOOP AT lt_zbook_ticketattr ASSIGNING <ls_zbook_ticketattr>.
    INSERT <ls_zbook_ticketattr> INTO TABLE lt_used_attributes.
  ENDLOOP.

*--------------------------------------------------------------------*
* 3. Schritt - Neue Tabelle aufbauen inkl. der verwendeten Ticketattribute
*--------------------------------------------------------------------*
* Zunächst die Ausgangstabelle nehmen
* Da Ausgangstabelle momentan via Referenz angegeben wird, die Methode aufrufen, die für Datenreferenzen zuständig ist
  lo_tabledescr ?= cl_abap_typedescr=>describe_by_data_ref( pr_t_data ).  " Wir übergeben eine Tabellenreferenz
  lo_structdescr ?= lo_tabledescr->get_table_line_type( ).
  ls_dyn_component-name       = 'BASE_TABLE'.
  ls_dyn_component-type       = lo_structdescr.
  ls_dyn_component-as_include = 'X'.
  APPEND ls_dyn_component TO lt_dyn_components.

* Danach dann alle dyn. Attribute hinzufügen
  LOOP AT  lt_used_attributes ASSIGNING  <ls_zbook_ticketattr>.

    lv_n3 = sy-tabix.
    CONCATENATE 'DYN_FIELD_' lv_n3 INTO  ls_dyn_component-name.  " Feldname in neuer Struktur - damit kann ich später dann entscheiden welches Feld zu füllen ist

    CONCATENATE <ls_zbook_ticketattr>-attribute_table <ls_zbook_ticketattr>-attribute_field INTO lv_fieldname SEPARATED BY '-'.
    lo_datadescr ?= cl_abap_datadescr=>describe_by_name( lv_fieldname ).
    ls_dyn_component-type       = lo_datadescr.
    ls_dyn_component-as_include = ' '.
    APPEND ls_dyn_component TO lt_dyn_components.

  ENDLOOP.

* Und zu guter letzt noch ein zusätzliches Feld für eine Ausnahmespalte im SALV
  ls_dyn_component-name       = 'LIGHT'.
  lo_datadescr ?= cl_abap_datadescr=>describe_by_data( ls_excecption-light ).  " Der einfachste Weg - ein Feld vom korrekten Typ definieren und beschreiben lassen
  ls_dyn_component-type       = lo_datadescr.
  ls_dyn_component-as_include = ' '.
  APPEND ls_dyn_component TO lt_dyn_components.


*--------------------------------------------------------------------*
* 4. Schritt - Neue erweiterte Tabelle aufbauen
*--------------------------------------------------------------------*
* Zunächst eine Strukturbeschreibung erzeugen aus den einzelnen Komponenten
  TRY.
      lo_structdescr = cl_abap_structdescr=>create(  p_components = lt_dyn_components ).
    CATCH cx_sy_struct_creation .
      BREAK-POINT.  " Hier sinnvolle Fehlerbehandlung
  ENDTRY.
* Aus der Strukturbeschreibung eine Tabellenbeschreibung erzeugen und daraus dann eine Referenz auf zugehörige Tabelle
  TRY.
      lo_tabledescr = cl_abap_tabledescr=>create( p_line_type  = lo_structdescr ).
      CREATE DATA lr_t_new_data TYPE HANDLE lo_tabledescr.
    CATCH cx_sy_table_creation .
      BREAK-POINT.  " Hier sinnvolle Fehlerbehandlung
  ENDTRY.

*--------------------------------------------------------------------*
* 5. Schritt - Daten von alter in neue Tabelle umschaufeln und mit dyn. Attributen erweitern
* Für bekannte (nicht dynamische) Felder am einfachsten stets mit move-corresponding
*--------------------------------------------------------------------*
  ASSIGN pr_t_data->*     TO <lt_old_data>.
  ASSIGN lr_t_new_data->* TO <lt_new_data>.

  LOOP AT <lt_old_data> ASSIGNING <ls_old_data>.

    MOVE-CORRESPONDING <ls_old_data> TO ls_zbook_ticket.

* Zunächst die alten Felder einfach kopieren.
    APPEND INITIAL LINE TO <lt_new_data> ASSIGNING <ls_new_data>.
    MOVE-CORRESPONDING <ls_old_data> TO <ls_new_data>.

* Jetzt die zugehörigen dynamischen Felder
    LOOP AT lt_zbook_ticketattr ASSIGNING <ls_zbook_ticketattr> WHERE tiknr =  ls_zbook_ticket-tiknr.
* Welches Feld in der dyn. Tabelle ist es?
      READ TABLE lt_used_attributes TRANSPORTING NO FIELDS WITH TABLE KEY attribute_table = <ls_zbook_ticketattr>-attribute_table
                                                                          attribute_field = <ls_zbook_ticketattr>-attribute_field.
      CHECK sy-subrc = 0.
      lv_n3 = sy-tabix.
      CONCATENATE 'DYN_FIELD_' lv_n3 INTO  lv_fieldname.  " Feldname in neuer Struktur
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_new_data> TO <lv_field>.
      CHECK sy-subrc = 0.
      <lv_field> = <ls_zbook_ticketattr>-valuation_char.  " Momentan nur das verwendet


    ENDLOOP.

* Und am Ende die Ampel setzen 0 = grau, 1 = rot, 2 = gelb, 3 = grün
    CASE ls_zbook_ticket-location.
      WHEN 'HB'.    ls_excecption-light = 3.
      WHEN 'HH'.    ls_excecption-light = 2.
      WHEN 'M'.     ls_excecption-light = 1.
      WHEN OTHERS.  ls_excecption-light = 0.
    ENDCASE.
    MOVE-CORRESPONDING ls_excecption TO <ls_new_data>.

  ENDLOOP.

* Am Ende die übergebene REferenz auf die neue Tabelle ändern
  pr_t_data = lr_t_new_data.
ENDFORM.                    " ADD_DYNAMIC_TICKET_DATA
