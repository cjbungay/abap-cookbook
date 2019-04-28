*&---------------------------------------------------------------------*
*& Report  ZBOOK_DEMO_DYN_STRUCTURE2
*&---------------------------------------------------------------------*
REPORT zbook_demo_dyn_structure2.

TABLES: zbook_ticket.


DATA: gr_t_data             TYPE REF TO data,  " Output table
      gts_used_planetypes   TYPE SORTED TABLE OF saplane-planetype WITH UNIQUE KEY table_line,
      go_salv               TYPE REF TO cl_salv_table.

*--------------------------------------------------------------------*
* Selektionsbild
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-bl1.
PARAMETERS: p_area  TYPE zbook_ticket-area  OBLIGATORY DEFAULT 'HARDWARE' MODIF ID ni.
PARAMETERS: p_clas TYPE zbook_ticket-clas OBLIGATORY DEFAULT 'MED'      MODIF ID ni.
SELECT-OPTIONS: s_tiknr FOR zbook_ticket-tiknr.
SELECTION-SCREEN END OF BLOCK bl1.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.

    IF screen-group1 = 'NI'.  "No Input
      screen-input = 0.
    ENDIF.

    MODIFY SCREEN.

  ENDLOOP.


START-OF-SELECTION.
  PERFORM read_dynamic_ticket_data CHANGING gr_t_data.


END-OF-SELECTION.
  PERFORM output_data CHANGING gr_t_data.


*&---------------------------------------------------------------------*
*&      Form  OUTPUT_DATA
*&---------------------------------------------------------------------*
FORM output_data  CHANGING  pr_t_data TYPE REF TO data.


  DATA: lo_salv_columns_table         TYPE REF TO cl_salv_columns_table,
        lt_salv_t_column_ref          TYPE salv_t_column_ref,
        lv_n3                         TYPE numc3,
        lv_scrtext_s                  TYPE scrtext_s,
        lv_scrtext_m                  TYPE scrtext_m,
        lv_scrtext_l                  TYPE scrtext_l.
  FIELD-SYMBOLS: <column_ref> LIKE LINE OF lt_salv_t_column_ref.
  FIELD-SYMBOLS: <lt_data>    TYPE STANDARD TABLE.
  FIELD-SYMBOLS: <planetype>  TYPE saplane-planetype.

  ASSIGN pr_t_data->* TO <lt_data>.

  TRY.
      cl_salv_table=>factory( "EXPORTING
*                            LIST_DISPLAY   = IF_SALV_C_BOOL_SAP=>FALSE
*                            R_CONTAINER    = R_CONTAINER
*                            CONTAINER_NAME = CONTAINER_NAME
                              IMPORTING
                                r_salv_table   = go_salv
                              CHANGING
                                t_table        = <lt_data> ).

*--------------------------------------------------------------------*
* SALV-Spalten:
*--------------------------------------------------------------------*
      lo_salv_columns_table = go_salv->get_columns( )      .
      lo_salv_columns_table->set_optimize( ).      " Spaltenbreite optimieren
* Spaltennamen mit Flugzeugtypen ersetzen
      lt_salv_t_column_ref = lo_salv_columns_table->get( ).
      LOOP AT lt_salv_t_column_ref ASSIGNING <column_ref>.

        FIND REGEX '^PLANETYPE_(\d{3})' IN <column_ref>-columnname SUBMATCHES lv_n3.
        CHECK sy-subrc = 0.
        READ TABLE gts_used_planetypes ASSIGNING <planetype> INDEX lv_n3.
        CHECK sy-subrc = 0.

        lv_scrtext_l = <planetype>.
        <column_ref>-r_column->set_short_text( lv_scrtext_s ).
        <column_ref>-r_column->set_medium_text( lv_scrtext_m ).
        <column_ref>-r_column->set_long_text( lv_scrtext_l ).

        <column_ref>-r_column->SET_ZERO( <column_ref>-r_column->false ).
      ENDLOOP.

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
*&      Form  read_dynamic_ticket_data
*&---------------------------------------------------------------------*
* 1. Schritt - Lesen aller Ticketattribute
* 2. Schritt - Bestimmen welche Planetypes verwendet werden
* 3. Schritt - Ausgabellenbeschreibung aufbauen
* 4. Schritt - Neue erweiterte Tabelle aufbauen
* 5. Schritt - Daten einfüllen
*----------------------------------------------------------------------*
* Area HARDWARE, class MED will be used to demonstrate
* Dynamic attributes here:  SYST-DATUM and SAPLANE-PLANETYP
*&---------------------------------------------------------------------*
FORM read_dynamic_ticket_data CHANGING pr_t_data TYPE REF TO data.

  TYPES: BEGIN OF lty_data,
           tiknr           TYPE zbook_ticketattr-tiknr,
           attribute_table TYPE zbook_ticketattr-attribute_table,
           attribute_field TYPE zbook_ticketattr-attribute_field,
           valuation_char  TYPE zbook_ticketattr-valuation_char,
         END OF lty_data.

  DATA: lts_zbook_ticketattr  TYPE SORTED TABLE OF lty_data WITH UNIQUE KEY tiknr attribute_table attribute_field,
        lv_planetype          LIKE LINE OF gts_used_planetypes,
        lo_datadescr          TYPE REF TO cl_abap_datadescr,
        lo_structdescr        TYPE REF TO cl_abap_structdescr,
        lo_tabledescr         TYPE REF TO cl_abap_tabledescr,
        lt_dyn_components     TYPE cl_abap_structdescr=>component_table, "Struktur von cl_abap_structdescr=>COMPONENT_TABLE
        ls_dyn_component      LIKE LINE OF lt_dyn_components,
        lv_datum              TYPE syst-datum,
        lv_n3                 TYPE numc3,
        lv_fieldname          TYPE fieldname,
        BEGIN OF ls_static,
          datum               TYPE sydatum,
        END OF ls_static,
        lr_tmp_struct         TYPE REF TO data,
        lr_t_new_data         TYPE REF TO data.

  FIELD-SYMBOLS: <ls_zbook_ticketattr>  TYPE lty_data,
                 <ls_zbook_ticketattr2> TYPE lty_data,
                 <ls_new_line>          TYPE any,
                 <ls_new_data>          TYPE any,
                 <lt_new_data>          TYPE STANDARD TABLE,
                 <planetype_count>      TYPE i.

*--------------------------------------------------------------------*
* 1. Schritt - Lesen aller Ticketattribute
* Bei komplexeren Bedingungen in routine READ_STATIC_TICKET_DATA alternativ via "for all entries" an dieser Stelle
*--------------------------------------------------------------------*
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE lts_zbook_ticketattr
    FROM zbook_ticket JOIN zbook_ticketattr ON zbook_ticket~tiknr = zbook_ticketattr~tiknr
    WHERE zbook_ticket~tiknr IN s_tiknr.

*--------------------------------------------------------------------*
* 2. Schritt - Bestimmen welche Ticketattribute in der Selektion verwendet werden
*--------------------------------------------------------------------*
  LOOP AT lts_zbook_ticketattr ASSIGNING <ls_zbook_ticketattr> WHERE attribute_table = 'SAPLANE'
                                                                 AND attribute_field = 'PLANETYPE'.

    lv_planetype = <ls_zbook_ticketattr>-valuation_char.
    INSERT lv_planetype  INTO TABLE gts_used_planetypes.

  ENDLOOP.

*--------------------------------------------------------------------*
* 3. Schritt - Ausgabellenbeschreibung aufbauen
*--------------------------------------------------------------------*
* Augabetabelle:  1. Feld:  Datum
* Dann für jeden Planetype 1 Feld vom Typ integer ( Zählen wie viele Tickets erfasst wurden )
  lo_datadescr ?= cl_abap_datadescr=>describe_by_name( 'SYST-DATUM' ).
  ls_dyn_component-name       = 'DATUM'.
  ls_dyn_component-type       = lo_datadescr.
  ls_dyn_component-as_include = ' '.
  APPEND ls_dyn_component TO lt_dyn_components.


  lo_datadescr ?= cl_abap_datadescr=>describe_by_data( sy-tabix ). " Sy-Tbix ist vom Typ Integer
  ls_dyn_component-type       = lo_datadescr.
  ls_dyn_component-as_include = ' '.

  LOOP AT gts_used_planetypes INTO lv_planetype.

    lv_n3 = sy-tabix.
    CONCATENATE 'PLANETYPE_' lv_n3 INTO  ls_dyn_component-name.  " Feldname in neuer Struktur - damit kann ich später dann entscheiden welches Feld zu füllen ist
    APPEND ls_dyn_component TO lt_dyn_components.

  ENDLOOP.

*--------------------------------------------------------------------*
* 4. Schritt - Neue erweiterte Tabelle aufbauen
*--------------------------------------------------------------------*
* Zunächst eine Strukturbeschreibung erzeugen aus den einzelnen Komponenten
  TRY.
      lo_structdescr = cl_abap_structdescr=>create(  p_components = lt_dyn_components ).
      CREATE DATA lr_tmp_struct TYPE HANDLE lo_structdescr.
      ASSIGN lr_tmp_struct->* TO <ls_new_data>.
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

  ASSIGN lr_t_new_data->* TO <lt_new_data>.

* Zunächst die möglichen Datümer in Tabelle schieben
  LOOP AT lts_zbook_ticketattr ASSIGNING <ls_zbook_ticketattr> WHERE attribute_table = 'SYST'
                                                                 AND attribute_field = 'DATUM'.

    ls_static-datum = <ls_zbook_ticketattr>-valuation_char.
    CLEAR <ls_new_data>.
    MOVE-CORRESPONDING ls_static TO <ls_new_data>.
    APPEND <ls_new_data> TO <lt_new_data>.

  ENDLOOP.
  SORT <lt_new_data>.
  DELETE ADJACENT DUPLICATES FROM <lt_new_data>.

* Und jetzt zu jedem Datum die Planetypes die hier gemeldet wurden eintragen
  LOOP AT lts_zbook_ticketattr ASSIGNING <ls_zbook_ticketattr> WHERE attribute_table = 'SAPLANE'
                                                                 AND attribute_field = 'PLANETYPE'.

* Feldnamen aufbauen
    lv_planetype = <ls_zbook_ticketattr>-valuation_char.
    READ TABLE gts_used_planetypes TRANSPORTING NO FIELDS WITH TABLE KEY table_line = lv_planetype.
    CHECK sy-subrc = 0.

    lv_n3 = sy-tabix.
    CONCATENATE 'PLANETYPE_' lv_n3 INTO  lv_fieldname.  " Feldname in neuer Struktur

* Welches DAtum muss angepasst werden?
    READ TABLE lts_zbook_ticketattr ASSIGNING <ls_zbook_ticketattr2> WITH TABLE KEY tiknr           = <ls_zbook_ticketattr>-tiknr
                                                                                    attribute_table = 'SYST'
                                                                                    attribute_field = 'DATUM'.
    CHECK sy-subrc = 0.
* Lesen korrekte Zeile
    READ TABLE <lt_new_data> ASSIGNING <ls_new_data> WITH KEY ('DATUM') = <ls_zbook_ticketattr2>-valuation_char.
    CHECK sy-subrc = 0.
* Zuweisen korrektes Feld
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_new_data> TO <planetype_count>.
    CHECK sy-subrc = 0.
    ADD 1 TO <planetype_count>.

  ENDLOOP.

  pr_t_data = lr_t_new_data.

ENDFORM.                    "read_dynamic_ticket_data
