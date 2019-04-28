*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZBOOK_TEAM_TM
*   generation date: 26.11.2012 at 22:26:33 by user DGOERKE
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZBOOK_TEAM_TM      .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
