*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 12.07.2013 at 11:55:26 by user EWULFF
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZBOOK_AREAS.....................................*
DATA:  BEGIN OF STATUS_ZBOOK_AREAS                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBOOK_AREAS                   .
CONTROLS: TCTRL_ZBOOK_AREAS
            TYPE TABLEVIEW USING SCREEN '5580'.
*...processing: ZBOOK_AREASV....................................*
TABLES: ZBOOK_AREASV, *ZBOOK_AREASV. "view work areas
CONTROLS: TCTRL_ZBOOK_AREASV
TYPE TABLEVIEW USING SCREEN '9960'.
DATA: BEGIN OF STATUS_ZBOOK_AREASV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZBOOK_AREASV.
* Table for entries selected to show on screen
DATA: BEGIN OF ZBOOK_AREASV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZBOOK_AREASV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBOOK_AREASV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZBOOK_AREASV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZBOOK_AREASV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBOOK_AREASV_TOTAL.

*...processing: ZBOOK_AREAV.....................................*
TABLES: ZBOOK_AREAV, *ZBOOK_AREAV. "view work areas
CONTROLS: TCTRL_ZBOOK_AREAV
TYPE TABLEVIEW USING SCREEN '5000'.
DATA: BEGIN OF STATUS_ZBOOK_AREAV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZBOOK_AREAV.
* Table for entries selected to show on screen
DATA: BEGIN OF ZBOOK_AREAV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZBOOK_AREAV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBOOK_AREAV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZBOOK_AREAV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZBOOK_AREAV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBOOK_AREAV_TOTAL.

*...processing: ZBOOK_ATTR......................................*
DATA:  BEGIN OF STATUS_ZBOOK_ATTR                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBOOK_ATTR                    .
CONTROLS: TCTRL_ZBOOK_ATTR
            TYPE TABLEVIEW USING SCREEN '0080'.
*...processing: ZBOOK_CLASS.....................................*
DATA:  BEGIN OF STATUS_ZBOOK_CLASS                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBOOK_CLASS                   .
CONTROLS: TCTRL_ZBOOK_CLASS
            TYPE TABLEVIEW USING SCREEN '0850'.
*...processing: ZBOOK_CLASS_ATTR................................*
DATA:  BEGIN OF STATUS_ZBOOK_CLASS_ATTR              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBOOK_CLASS_ATTR              .
CONTROLS: TCTRL_ZBOOK_CLASS_ATTR
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: ZBOOK_CLASV.....................................*
TABLES: ZBOOK_CLASV, *ZBOOK_CLASV. "view work areas
CONTROLS: TCTRL_ZBOOK_CLASV
TYPE TABLEVIEW USING SCREEN '5010'.
DATA: BEGIN OF STATUS_ZBOOK_CLASV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZBOOK_CLASV.
* Table for entries selected to show on screen
DATA: BEGIN OF ZBOOK_CLASV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZBOOK_CLASV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBOOK_CLASV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZBOOK_CLASV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZBOOK_CLASV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBOOK_CLASV_TOTAL.

*...processing: ZBOOK_DATE......................................*
DATA:  BEGIN OF STATUS_ZBOOK_DATE                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBOOK_DATE                    .
CONTROLS: TCTRL_ZBOOK_DATE
            TYPE TABLEVIEW USING SCREEN '7400'.
*.........table declarations:.................................*
TABLES: *ZBOOK_AREAS                   .
TABLES: *ZBOOK_AREAT                   .
TABLES: *ZBOOK_ATTR                    .
TABLES: *ZBOOK_CLASS                   .
TABLES: *ZBOOK_CLASS_ATTR              .
TABLES: *ZBOOK_CLAST                   .
TABLES: *ZBOOK_DATE                    .
TABLES: ZBOOK_AREAS                    .
TABLES: ZBOOK_AREAT                    .
TABLES: ZBOOK_ATTR                     .
TABLES: ZBOOK_CLASS                    .
TABLES: ZBOOK_CLASS_ATTR               .
TABLES: ZBOOK_CLAST                    .
TABLES: ZBOOK_DATE                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
