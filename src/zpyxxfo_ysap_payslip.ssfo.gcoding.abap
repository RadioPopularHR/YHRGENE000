
*INI - ROFF: SAM: BM/RS/SM Oc. 3890920 04.10.2012
DELETE hrdata-star_pay_deductions WHERE pay_number = 0 AND
                                        pay_rate   = 0 AND
                                        pay_amount = 0.

DELETE hrdata-star_pay_gross WHERE pay_number = 0 AND
                                   pay_rate   = 0 AND
                                   pay_amount = 0.

DELETE hrdata-star_pay_net WHERE pay_number = 0 AND
                                 pay_rate   = 0 AND
                                 pay_amount = 0.
*FIM - ROFF: SAM: BM/RS/SM Oc. 3890920 04.10.2012

*** ROFF RS/SMatos oc 3890920
*** as tres estruturas principais nao podem estar vazias
IF hrdata-star_pay_deductions[] IS INITIAL AND
   hrdata-star_pay_gross[] IS INITIAL AND
   hrdata-star_pay_net[] IS INITIAL.
  RAISE no_data.
ENDIF.
*** ROFF RS/SMatos oc 3890920

CREATE OBJECT recibo
  EXPORTING
    ps_hrdata = hrdata.

