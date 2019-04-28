*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZBOOK_TPD01
*   generation date: 11.05.2013 at 16:37:34 by user EWULFF
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZBOOK_TPD01        .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
