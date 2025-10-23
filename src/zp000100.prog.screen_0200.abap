*
PROCESS BEFORE OUTPUT.
  MODULE modify_subscreen.
  MODULE module_pbo_0001.
  MODULE hidden_data_subscreen.
*
PROCESS AFTER INPUT.
*   This chain has to include all input-fields:
  CHAIN.
    FIELD p0001-cdope.
    MODULE input_status_subscreen ON CHAIN-REQUEST.
  ENDCHAIN.
*   infotype specific checks etc.:
  MODULE module_pai_0001.
