REPORT zbook_demo_include4.


DATA gt_fcat    TYPE lvc_t_fcat.
FIELD-SYMBOLS <demo> TYPE ANY.
DATA gd_demo TYPE REF TO data.


PARAMETERS p_sname TYPE c LENGTH 30 DEFAULT 'ZBOOK_STATUS_DEMO1'.

CREATE DATA gd_demo TYPE (p_sname).

ASSIGN gd_demo->* TO <demo>.

CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
  EXPORTING
    i_structure_name       = p_sname
  CHANGING
    ct_fieldcat            = gt_fcat
  EXCEPTIONS
    inconsistent_interface = 1
    program_error          = 2
    OTHERS                 = 3.


BREAK-POINT.
