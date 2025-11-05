class YCL_PAY_SLIP definition
  public
  final
  create public .

*"* public components of class YCL_PAY_SLIP
*"* do not include other source files here!!!
public section.

  data ABONOS type /1PYXXFO/YSAP_PAYSLIP-STAR_PAY_GROSS .
  data DESCONTOS type /1PYXXFO/YSAP_PAYSLIP-STAR_PAY_DEDUCTIONS .
  data NOTICES type /1PYXXFO/YSAP_PAYSLIP-STAR_NOTICES .
  data TOTAL_ABONOS type MAXBT .
  data MONTANTE_BRUTO_TOTAL type MAXBT .
  data TOTAL_DESCONTOS type MAXBT .
  data EMP_ADDRESS type ADRS .
  data EMP_NIF type PPT_FINUM .
  data EMP_SSNUM type PPT_SSNUM .
  data EMP_HIRE_DATE type BEGDA .
  data EMP_FIRE_DATE type ENDDA .
  data EMP_CATEGORIA type PPT_PCATT .
  data EMPRESA type BUTXT .
  data NIF_EMPRESA type T5PFD-FDATA .
  data CENTRO_CUSTO type KLTXT .
  data NUM_PESSOAL type P_PERNR .
  data PAYROLL_AREA_TEXT type ABKTX .
  data FORMA_PAGAMENTO type TEXT1_042Z .
  data MONTANTE type MAXBT .
  data MOEDA type WAERS .
  data BANK_NAME type BANKA .
  data BASE_IRS type MAXBT .
  data IRS_RETIDO type MAXBT .
  data IRS_RETIDO_ACUMULADO type MAXBT .
  data MONTANTE_BRUTO_IRS type MAXBT .
  data APOLICE_SEGURO type VSNUM .
  data INSURANCE_COMPANY_TEXT type VTX .
  data EMP_NIB type CHAR21 .
  data:
    wagetype_97  TYPE  LINE OF /1pyxxfo/ysap_payslip-star_pay_deductions .

  methods CONSTRUCTOR
    importing
      !PS_HRDATA type /1PYXXFO/YSAP_PAYSLIP .
protected section.
*"* protected components of class YCL_PAY_SLIP
*"* do not include other source files here!!!
private section.
*"* private components of class YCL_PAY_SLIP
*"* do not include other source files here!!!

  data PAYROLL_AREA type ABKRS .
  data HRDATA type /1PYXXFO/YSAP_PAYSLIP .
  data:
    wa_result  TYPE  LINE OF /1pyxxfo/ysap_payslip-star_payresult .
  data:
    wa_gross TYPE  LINE OF /1pyxxfo/ysap_payslip-star_pay_gross .
  data:
    wa_c_gross TYPE  LINE OF /1pyxxfo/ysap_payslip-star_cum_gross .
  data:
    wa_dedu  TYPE  LINE OF /1pyxxfo/ysap_payslip-star_pay_deductions .
  data:
    wa_c_dedu  TYPE  LINE OF /1pyxxfo/ysap_payslip-star_cum_deductions .
  data:
    wa_employee  TYPE  LINE OF /1pyxxfo/ysap_payslip-dim_employee .
  data:
    wa_orgdata TYPE  LINE OF /1pyxxfo/ysap_payslip-star_org_corp .
  data:
    wa_forpayroll_area TYPE  LINE OF /1pyxxfo/ysap_payslip-dim_forpayroll_area .
  data:
    wa_payment_method  TYPE  LINE OF /1pyxxfo/ysap_payslip-dim_payment_method .
  data:
    wa_payment TYPE  LINE OF /1pyxxfo/ysap_payslip-star_payments .
  data:
    wa_bank  TYPE  LINE OF /1pyxxfo/ysap_payslip-dim_bank .
  data:
    wa_bank_account  TYPE  LINE OF /1pyxxfo/ysap_payslip-dim_bank_account .
  data:
    wa_notif TYPE  LINE OF /1pyxxfo/ysap_payslip-star_notices .
  data:
    wa_transfer TYPE  LINE OF /1pyxxfo/ysap_payslip-dim_transfer .

  methods INIT .
  methods PROCESS_RESULTS .
  methods PROCESS_EMPLOYEE_DATA .
  methods PROCESS_ORG_DATA .
  methods PROCESS_PAYROLL_AREA .
  methods PROCESS_INSURANCE_DATA .
  methods PROCESS_BANK_DATA .
  methods PROCESS_TAX_DATA .
  methods PROCESS_NOTICES .
  class-methods GET_NIB
    importing
      value(I_BANK_ACCOUNT) type KNBK_BF-BANKN
      value(I_BANK_CONTROL_KEY) type KNBK_BF-BKONT
      value(I_BANK_COUNTRY) type KNBK_BF-BANKS
      value(I_BANK_NUMBER) type KNBK_BF-BANKL
    exporting
      !E_NIB type CHAR21 .
  methods PROCESS_ORG_NIF .
ENDCLASS.



CLASS YCL_PAY_SLIP IMPLEMENTATION.


method CONSTRUCTOR.
  hrdata = PS_HRDATA.

  init( ).


endmethod.


METHOD get_nib.

  DATA:  konto(11)      TYPE c,        " Kontonummer
         nib(21)        TYPE c,        " BLZ + KtoNr. + Kontr.Schl.
         refe(11)       TYPE p,        " Rechenfeld
         strln          TYPE i.        " Stringlänge

  IF NOT i_bank_number IS INITIAL.


    CHECK NOT i_bank_number CN '0123456789 '.
    CHECK NOT i_bank_account CN '0123456789 '.

    CHECK NOT i_bank_control_key = space.

    strln = STRLEN( i_bank_control_key ).
    CHECK NOT strln <> 2.

    CHECK NOT i_bank_control_key CN '0123456789'.

    TRANSLATE i_bank_number USING '. '.
    CONDENSE i_bank_number NO-GAPS.

    WRITE i_bank_account TO konto NO-ZERO RIGHT-JUSTIFIED.
    TRANSLATE konto USING ' 0'.

    nib    = i_bank_number.
    nib+8  = konto.
    nib+19 = i_bank_control_key.
    CONDENSE nib NO-GAPS.

*    refe = nib.
*    refe = refe MOD 97.
*
*    CHECK NOT refe <> 1.

    e_nib = nib.
  ENDIF.

ENDMETHOD.


method INIT.
  process_results( ).
  process_employee_data( ).
  process_org_data( ).
  process_payroll_area( ).
  process_org_nif( ).
  process_insurance_data( ).
  process_bank_data( ).
  process_tax_data( ).
  process_notices( ).
endmethod.


method PROCESS_BANK_DATA.
  data:
    lf_CONTROL_KEY  type BKONT,
    lf_BANK_NUMBER type BANKL,
    lf_COUNTRY type LAND1,
    lf_ACCOUNT_NUMBER type BANKN.

*INI-ROFFSAM-VP-SG-5000008914-7000027852-Colaborador 10005384 (/557).

*  LOOP AT HRDATA-STAR_PAYMENTS into WA_PAYMENT
*    where EMPLOYEE_KEY = WA_RESULT-EMPLOYEE_KEY and
*          INPERIOD_KEY = WA_RESULT-INPERIOD_KEY and
*          ( WAGETYPE_KEY-WAGETYPE = '/559' or
*            WAGETYPE_KEY-WAGETYPE = '/558' ) .

  LOOP AT HRDATA-STAR_PAYMENTS into WA_PAYMENT
    where EMPLOYEE_KEY = WA_RESULT-EMPLOYEE_KEY and
          INPERIOD_KEY = WA_RESULT-INPERIOD_KEY and
          ( WAGETYPE_KEY-WAGETYPE = '/559' or
            WAGETYPE_KEY-WAGETYPE = '/558' or
            WAGETYPE_KEY-WAGETYPE = '/557' ).

*FIM-ROFFSAM-VP-SG-5000008914-7000027852-Colaborador 10005384 (/557).

    add wa_payment-pay_amount to montante.
  ENDLOOP.
  moeda = wa_payment-amt_curr.

  LOOP AT HRDATA-DIM_BANK into WA_BANK
    where KEY	= WA_PAYMENT-BANK_KEY.

    bank_name = WA_BANK-BANK_NAME.
    lf_CONTROL_KEY = WA_BANK-key-CONTROL_KEY.
    lf_BANK_NUMBER = WA_BANK-key-BANK_NUMBER.
    lf_COUNTRY = WA_BANK-key-COUNTRY.

  ENDLOOP.

  LOOP AT HRDATA-DIM_BANK_account into WA_BANK_account
    where KEY	= WA_PAYMENT-BANK_account_KEY.

    lf_ACCOUNT_NUMBER = WA_BANK_account-key-ACCOUNT_NUMBER.

  ENDLOOP.

  CALL METHOD ycl_pay_slip=>get_nib
    EXPORTING
      i_bank_account     = lf_ACCOUNT_NUMBER
      i_bank_control_key = lf_CONTROL_KEY
      i_bank_country     = lf_COUNTRY
      i_bank_number      = lf_BANK_NUMBER
    IMPORTING
      e_nib              = emp_nib
      .


endmethod.


METHOD process_employee_data.
  DATA :
    p0331_tab TYPE TABLE OF p0331,
    wa_0331   TYPE p0331,
    p0332_tab TYPE TABLE OF p0332,
    wa_0332   TYPE p0332,
    p0337_tab TYPE TABLE OF p0337,
    wa_0337   TYPE p0337,
    p0000_tab TYPE TABLE OF p0000,
    wa_0000   TYPE p0000.

  CALL FUNCTION 'HR_READ_INFOTYPE'
    EXPORTING
*     TCLAS           = 'A'
      pernr           = wa_result-employee_key-personnel_number
      infty           = '0337'
      begda           = wa_result-inperiod_key-begin_date
      endda           = wa_result-inperiod_key-end_date
      bypass_buffer   = ' '
*      IMPORTING
*     SUBRC           =
    TABLES
      infty_tab       = p0337_tab
    EXCEPTIONS
      infty_not_found = 1
      OTHERS          = 2.

  READ TABLE p0337_tab INTO wa_0337 INDEX 1.

  IF sy-subrc = 0.
    SELECT SINGLE pcatt
      FROM t5ps2t
      INTO emp_categoria
      WHERE prcat = wa_0337-prcat AND
            sprsl = sy-langu.
  ENDIF.

  CALL FUNCTION 'HR_READ_INFOTYPE'
    EXPORTING
*     TCLAS           = 'A'
      pernr           = wa_result-employee_key-personnel_number
      infty           = '0331'
      begda           = wa_result-inperiod_key-begin_date
      endda           = wa_result-inperiod_key-end_date
      bypass_buffer   = ' '
*      IMPORTING
*     SUBRC           =
    TABLES
      infty_tab       = p0331_tab
    EXCEPTIONS
      infty_not_found = 1
      OTHERS          = 2.

  READ TABLE p0331_tab INTO wa_0331 INDEX 1.

  IF sy-subrc = 0.
    emp_nif = wa_0331-finum.
  ENDIF.


  CALL FUNCTION 'HR_READ_INFOTYPE'
    EXPORTING
*     TCLAS           = 'A'
      pernr           = wa_result-employee_key-personnel_number
      infty           = '0332'
      begda           = wa_result-inperiod_key-begin_date
      endda           = wa_result-inperiod_key-end_date
      bypass_buffer   = ' '
*      IMPORTING
*     SUBRC           =
    TABLES
      infty_tab       = p0332_tab
    EXCEPTIONS
      infty_not_found = 1
      OTHERS          = 2.

  READ TABLE p0332_tab INTO wa_0332 INDEX 1.

  IF sy-subrc = 0.
    emp_ssnum = wa_0332-ssnum.
  ENDIF.

  CALL FUNCTION 'HR_READ_INFOTYPE'
    EXPORTING
*     TCLAS           = 'A'
      pernr           = wa_result-employee_key-personnel_number
      infty           = '0000'
*     begda           = wa_result-inperiod_key-begin_date
*     endda           = wa_result-inperiod_key-end_date
      bypass_buffer   = ' '
*      IMPORTING
*     SUBRC           =
    TABLES
      infty_tab       = p0000_tab
    EXCEPTIONS
      infty_not_found = 1
      OTHERS          = 2.


*>>ROFF SAM HCN:EF/FC Msg 7000032375 22.12.2016-----*
*  read table p0000_tab into wa_0000 with key massn = 'Z4' .
*  if sy-subrc = 0.
*    EMP_FIRE_DATE = wa_0000-begda.
*  endif.
*<<ROFF SAM HCN:EF/FC Msg 7000032375 22.12.2016-----*


  LOOP AT hrdata-dim_employee INTO wa_employee
    WHERE key = wa_result-employee_key.
    emp_address   = wa_employee-address.
    emp_hire_date = wa_employee-hire_date.
*    EMP_FIRE_DATE = wa_employee-fire_date.
  ENDLOOP.

* >>> INI Inetum SAM EMP/SM HR 7000232228 14.05.2025
* Comentado
** >>> INI Inetum SAM EMP/SM HR 7000217593 29.11.2024
** A data de admissão tem se a que estiver em vigor na
** data do processamento em que se estiver a extrair o recibo de vencimento.
** Por exemplo o PERNR 10006866 para 10.2020 tinha uma data de admissão errada
*
*  DATA: lt_p0000 TYPE TABLE OF p0000,
*        lt_p0001 TYPE TABLE OF p0001.
*
*  CLEAR emp_hire_date.
*
*  REFRESH: lt_p0000, lt_p0001.
*  CALL FUNCTION 'HR_READ_INFOTYPE'
*    EXPORTING
*      pernr           = wa_result-employee_key-personnel_number
*      infty           = '0000'
*      begda           = '19990101'
*      endda           = wa_result-inperiod_key-end_date
*      bypass_buffer   = ' '
*    TABLES
*      infty_tab       = lt_p0000
*    EXCEPTIONS
*      infty_not_found = 1
*      OTHERS          = 2.
*  CALL FUNCTION 'HR_READ_INFOTYPE'
*    EXPORTING
*      pernr           = wa_result-employee_key-personnel_number
*      infty           = '0001'
*      begda           = '19990101'
*      endda           = wa_result-inperiod_key-end_date
*      bypass_buffer   = ' '
*    TABLES
*      infty_tab       = lt_p0001
*    EXCEPTIONS
*      infty_not_found = 1
*      OTHERS          = 2.
*  CALL FUNCTION 'HR_PT_HIRE_FIRE'
*    IMPORTING
*      hire_date            = emp_hire_date
*    TABLES
*      pp0000               = lt_p0000
*      pp0001               = lt_p0001
*    EXCEPTIONS
*      entry_date_not_found = 1
*      feature_error        = 2
*      OTHERS               = 3.
*  IF sy-subrc <> 0.
*  ENDIF.
** <<< END Inetum SAM EMP/SM HR 7000217593 29.11.2024

* A data de admissão tem se a que estiver em vigor na
* data do processamento em que se estiver a extrair o recibo de vencimento.
* Por exemplo o PERNR 10006866 para 10.2020 tinha uma data de admissão errada

* Deve ser lido o IT0041. Vou ler pela seguinte ordem:
* P1, P2, P3, P4, P5

  DATA: lr_msg   TYPE REF TO if_hrpa_message_handler,
        lv_date  TYPE datar,
        lv_index TYPE numc1,
        aux_data TYPE begda.

  aux_data = emp_hire_date.
  CLEAR: emp_hire_date.

  CLEAR: lv_index.
  DO 5 TIMES.
    ADD 1 TO lv_index.
    CONCATENATE 'P' lv_index INTO lv_date.

    CALL FUNCTION 'HR_ECM_GET_DATETYP_FROM_IT0041'
      EXPORTING
        pernr           = wa_result-employee_key-personnel_number
        keydt           = wa_result-inperiod_key-end_date
        datar           = lv_date
        message_handler = lr_msg
      IMPORTING
        date            = emp_hire_date.
    IF emp_hire_date IS NOT INITIAL.
      EXIT.
    ENDIF.
  ENDDO.

  IF emp_hire_date IS INITIAL.
    emp_hire_date = aux_data.
  ENDIF.
* <<< END Inetum SAM EMP/SM HR 7000232228 14.05.2025

*>>ROFF SAM HCN:EF/FC Msg 7000032375 22.12.2016-----*
  CLEAR emp_fire_date.
  LOOP AT p0000_tab INTO wa_0000
    WHERE massn = 'Z4'
      AND begda GT emp_hire_date.
    emp_fire_date = wa_0000-begda.
  ENDLOOP.
*<<ROFF SAM HCN:EF/FC Msg 7000032375 22.12.2016-----*

ENDMETHOD.


method PROCESS_INSURANCE_DATA.
  data:
    p0037_tab type table of p0037,
    wa_0037   type p0037.

  call function 'HR_READ_INFOTYPE'
      exporting
*       TCLAS                 = 'A'
        pernr                 = wa_result-employee_key-personnel_number
        infty                 = '0037'
        begda                 = wa_result-inperiod_key-begin_date
        endda                 = wa_result-inperiod_key-end_date
        bypass_buffer         = ' '
*      IMPORTING
*        SUBRC                 =
      tables
        infty_tab             = p0037_tab
      exceptions
        infty_not_found       = 1
        others                = 2.

  read table p0037_tab into wa_0037 index 1.

  if sy-subrc = 0.
    apolice_seguro = wa_0037-vsnum.
* preencher texto descritivo companhia seguros
    select single vtx
      into insurance_company_text
      from T564T
      where VSGES = wa_0037-VSGES and
            SPRAS = sy-langu.

  endif.

  LOOP AT HRDATA-DIM_PAYMENT_METHOD into WA_PAYMENT_METHOD.
    forma_pagamento = wa_payment_method-text.
  ENDLOOP.
endmethod.


method PROCESS_NOTICES.
  LOOP AT HRDATA-STAR_NOTICES into WA_NOTIF
    where DATE_RANGE_KEY-END_DATE >= WA_RESULT-INPERIOD_KEY-BEGIN_DATE and
          DATE_RANGE_KEY-BEGIN_DATE <= WA_RESULT-INPERIOD_KEY-END_DATE.

    append wa_notif to notices.

  ENDLOOP.
endmethod.


method PROCESS_ORG_DATA.


  LOOP AT HRDATA-STAR_ORG_CORP into WA_ORGDATA
    where EMPLOYEE_KEY = WA_RESULT-EMPLOYEE_KEY and
          INPERIOD_KEY =  WA_RESULT-INPERIOD_KEY.

    empresa = wa_orgdata-company_code_text.
    centro_custo = wa_orgdata-costcenter_key-catext.
    num_pessoal = wa_orgdata-employee_key-personnel_number.

  ENDLOOP.
endmethod.


METHOD process_org_nif.
  DATA: ltp_entty TYPE t5pfd-entty,
        ls_t5pfd TYPE t5pfd.


  CASE payroll_area.
    WHEN 'RP'.
      ltp_entty = 'RP'.
    WHEN 'CS'.
      ltp_entty = 'CRS'.
    WHEN 'OR'.
      ltp_entty = 'ORR'.
    WHEN OTHERS.
  ENDCASE.

  SELECT * INTO ls_t5pfd UP TO 1 ROWS
    FROM t5pfd
    WHERE entty = ltp_entty AND
          field = 'TAXNU'
    ORDER BY endda DESCENDING.
  ENDSELECT.
  CHECK sy-subrc = 0.
  MOVE ls_t5pfd-fdata TO nif_empresa.

ENDMETHOD.


method PROCESS_PAYROLL_AREA.
  LOOP AT HRDATA-DIM_FORPAYROLL_AREA into WA_FORPAYROLL_AREA.
    payroll_area_text = wa_FORPAYROLL_AREA-PAYR_AREA_TEXT.
    payroll_area = wa_FORPAYROLL_AREA-key-PAYROLL_AREA.
  ENDLOOP.
endmethod.


METHOD process_results.

*--- insert by jrf on 26 May 2009
  LOOP AT hrdata-star_pay_deductions INTO wa_dedu
      WHERE pay_amount   <> 0 AND
            evalclass02_key-wagetypegroup	= 08 AND
            forperiod_key-begin_date >= '20090501'.

      wa_dedu-pay_amount = wa_dedu-pay_amount * -1.
      MODIFY hrdata-star_pay_deductions INDEX sy-tabix from wa_dedu
                                        TRANSPORTING pay_amount.

  ENDLOOP.
*--- insert end

  LOOP AT hrdata-star_payresult INTO wa_result.

* processar remunerações brutas (Abonos)
    LOOP AT hrdata-star_pay_gross INTO wa_gross
      WHERE employee_key = wa_result-employee_key AND
            inperiod_key = wa_result-inperiod_key AND
            pay_amount <> 0 AND
            ( evalclass02_key-wagetypegroup	= 01 OR
              evalclass02_key-wagetypegroup	= 02 OR
              evalclass02_key-wagetypegroup	= 05 ).

      APPEND wa_gross TO abonos.
      ADD wa_gross-pay_amount TO total_abonos.

    ENDLOOP.

    LOOP AT hrdata-star_cum_gross INTO wa_c_gross
      WHERE employee_key = wa_result-employee_key AND
            inperiod_key = wa_result-inperiod_key AND
            pay_amount <> 0 AND
            RESULT_RETRO_KEY-RETRO = space AND
            ( wagetype_key-wagetype = '/101' "or
              "wagetype_key-wagetype = '/103' or
              "wagetype_key-wagetype = '/104'
                                              ).
      ADD wa_c_gross-pay_amount TO montante_bruto_total.

    ENDLOOP.

* processar pagamentos/deduções pessoais (descontos)
    LOOP AT hrdata-star_pay_deductions INTO wa_dedu
      WHERE employee_key = wa_result-employee_key AND
            inperiod_key = wa_result-inperiod_key AND
            pay_amount   <> 0 AND
            ( evalclass02_key-wagetypegroup	= 06 OR
              evalclass02_key-wagetypegroup	= 03 OR
              evalclass02_key-wagetypegroup	= 98 OR
              evalclass02_key-wagetypegroup	= 08 ).

      APPEND wa_dedu TO descontos.
      ADD wa_dedu-pay_amount TO total_descontos.

    ENDLOOP.

    LOOP AT hrdata-star_pay_deductions INTO wa_dedu
      WHERE employee_key = wa_result-employee_key AND
            inperiod_key = wa_result-inperiod_key AND
            pay_amount   <> 0 AND
            ( evalclass02_key-wagetypegroup	= 97 ).

      IF wagetype_97 is INITIAL.
        wagetype_97 = wa_dedu.
        clear wagetype_97-pay_amount.
      ENDIF.

      ADD wa_dedu-pay_amount TO wagetype_97-pay_amount.

    ENDLOOP.
  ENDLOOP.
* ordenar tabelas
  SORT abonos BY inperiod_key evalclass02_sort-wagetypegroup forperiod_key-begin_date.
  SORT descontos BY inperiod_key evalclass02_sort-wagetypegroup forperiod_key-begin_date.

ENDMETHOD.


METHOD process_tax_data.
  LOOP AT hrdata-star_pay_deductions INTO wa_dedu
    WHERE employee_key = wa_result-employee_key AND
          inperiod_key = wa_result-inperiod_key AND
          pay_amount <> 0 AND
          evalclass02_key-wagetypegroup = 99 AND

          ( wagetype_key-wagetype	= '/103' OR
            wagetype_key-wagetype	= '/104' OR
            wagetype_key-wagetype	= '/106' OR
            wagetype_key-wagetype	= '/113' OR
            wagetype_key-wagetype	= '/114' OR
            wagetype_key-wagetype	= '/115' ).

    ADD wa_dedu-pay_amount TO base_irs.

  ENDLOOP.

  LOOP AT hrdata-star_pay_deductions INTO wa_dedu
    WHERE employee_key = wa_result-employee_key AND
          inperiod_key = wa_result-inperiod_key AND
          pay_amount <> 0 AND
          evalclass02_key-wagetypegroup = 03 AND

          ( wagetype_key-wagetype	= '/401' OR
            wagetype_key-wagetype	= '/403' OR
            wagetype_key-wagetype	= '/404' OR
            wagetype_key-wagetype	= '/413' OR
            wagetype_key-wagetype	= '/414' OR
            wagetype_key-wagetype	= '/415' OR
            wagetype_key-wagetype	= '/405' OR
            wagetype_key-wagetype	= '/406' OR
            wagetype_key-wagetype	= '/407' OR
            wagetype_key-wagetype	= '/417').

    ADD wa_dedu-pay_amount TO irs_retido.

  ENDLOOP.

  LOOP AT hrdata-star_cum_deductions INTO wa_c_dedu
    WHERE employee_key = wa_result-employee_key AND
          inperiod_key = wa_result-inperiod_key AND
          pay_amount <> 0                       AND
          evalclass02_key-wagetypegroup = 03    AND

          ( wagetype_key-wagetype	= '/401' OR
            wagetype_key-wagetype	= '/403' OR
            wagetype_key-wagetype	= '/404' OR
            wagetype_key-wagetype	= '/413' OR
            wagetype_key-wagetype	= '/414' OR
            wagetype_key-wagetype	= '/415' OR
            wagetype_key-wagetype	= '/405' OR
            wagetype_key-wagetype	= '/406' OR
            wagetype_key-wagetype	= '/407' OR
            wagetype_key-wagetype	= '/417').

    ADD wa_c_dedu-pay_amount TO irs_retido_acumulado.

  ENDLOOP.

  LOOP AT hrdata-star_cum_gross INTO wa_c_gross
    WHERE employee_key = wa_result-employee_key AND
          inperiod_key = wa_result-inperiod_key AND
          pay_amount <> 0                       AND
          evalclass02_key-wagetypegroup = 99    AND

          ( wagetype_key-wagetype	= '/103' OR
            wagetype_key-wagetype	= '/104' OR
            wagetype_key-wagetype	= '/106' OR
            wagetype_key-wagetype	= '/113' OR
            wagetype_key-wagetype	= '/114' OR
            wagetype_key-wagetype	= '/115' ).

    ADD wa_c_gross-pay_amount TO montante_bruto_irs.

  ENDLOOP.
ENDMETHOD.
ENDCLASS.
