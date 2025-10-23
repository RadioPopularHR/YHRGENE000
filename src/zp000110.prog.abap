*----------------------------------------------------------------------*
*   INCLUDE ZP000100                                                   *
*----------------------------------------------------------------------*

PROGRAM ZP000100 MESSAGE-ID RP.
TABLES: P0001.

*tables: ZPLISmmmm

FIELD-SYMBOLS: <PNNNN> STRUCTURE P0001 DEFAULT P0001.

DATA: PSAVE LIKE P0001.
