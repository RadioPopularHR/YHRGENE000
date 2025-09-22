DATA: lt_star_pay_deductions LIKE hrdata-star_pay_deductions.

lt_star_pay_deductions[] = hrdata-star_pay_deductions[].

READ TABLE lt_star_pay_deductions
   INTO DATA(ls_star_pay_deductions)
   WITH KEY employee_key = wa_result-employee_key
            inperiod_key = wa_result-inperiod_key
            wagetype_key = '19/552'.
IF sy-subrc = 0 AND ls_star_pay_deductions-pay_amount < 0.
  wa_dedu-wagetype_longtext = 'Valor a repor'.
ENDIF.

















