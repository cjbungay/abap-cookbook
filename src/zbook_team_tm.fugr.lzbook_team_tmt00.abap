*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 22.11.2012 at 18:14:05 by user DGOERKE
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZBOOK_TEAM......................................*
DATA:  BEGIN OF STATUS_ZBOOK_TEAM                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBOOK_TEAM                    .
CONTROLS: TCTRL_ZBOOK_TEAM
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZBOOK_TEAM                    .
TABLES: ZBOOK_TEAM                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
