*&--------------------------------------------------------------------*
*&      Form  get_next_entry
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->VALUE($INFOtext)
*      -->VALUE($WA) text
*      -->$NEXT      text
*---------------------------------------------------------------------*
FORM get_next_entry
USING value($infostar) TYPE INDEX TABLE
value($wa)       TYPE any
$next      TYPE any.
* Get the table entry which follows the current entry
* If nothing is found, $NEXT is cleared
DATA:
index TYPE syindex.

READ TABLE $infostar FROM $wa TRANSPORTING NO FIELDS.
IF sy-subrc EQ 0.
index = sy-tabix + 1.
READ TABLE $infostar INTO $next INDEX index.
IF sy-subrc <> 0.
CLEAR $next.
ENDIF.
ELSE.
CLEAR $next.
ENDIF.
ENDFORM.                    "get_next_entry

























