CLASS zcl_journal_new DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_JOURNAL_NEW IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    SELECT  a~sourceledger,
            a~companycode,
            a~fiscalyear,
            a~accountingdocument,
            a~ledgergllineitem,
            a~ledger,
            a~ledgerfiscalyear,
            a~partnercostcenter,
            a~partnerprofitcenter,
            a~SalesOrder,
            a~SalesOrderItem,
            b~CreationDate,
            c~material,
            c~plant,
            c~customerpricegroup,
            c~materialbycustomer,
            c~purchaseorderbyshiptoparty,
            b~soldtoparty,
            d~AccountingDocumentType

             from I_JournalEntryItem as a
             INNER JOIN I_SalesOrder as b on a~SalesOrder = b~SalesOrder
             left outer join I_SalesOrderitem as c on a~SalesOrder = c~SalesOrder
             inner join I_JournalEntry as d on a~accountingdocument = d~accountingdocument
             WHERE salesdocument <> @space
             and   d~AccountingDocumentType = 'SA'
            INTO TABLE @data(it_je).

            if it_je[] is NOT INITIAL.
              select SalesOrder
              from I_SalesOrder
              FOR ALL ENTRIES IN @it_je
              WHERE CreationDate = @it_je-CreationDate
              and   OverallSDProcessStatus <> 'C'
              INTO TABLE @data(it_so).

            if it_je[] is NOT INITIAL.
                select  a~SalesOrder,
                        a~SalesOrderItem,
                        a~material,
                        a~plant,
                        a~CUSTOMERPRICEGROUP,
                        a~MATERIALBYCUSTOMER,
                        a~PURCHASEORDERBYSHIPTOPARTY,
                        b~SOLDTOPARTY
               FROM I_SalesOrderItem as  a
               left outer join I_SalesOrder as b on a~SalesOrder = b~SalesOrder
               FOR ALL ENTRIES IN @it_so
               WHERE a~SalesOrder = @it_so-SalesOrder
               INTO TABLE  @data(it_main).
             endif.
            endif.

   data:it_temp TYPE STANDARD TABLE OF ztt_journal02,
        wa_temp type ztt_journal02.

 delete ztt_journal02 FROM @wa_temp.
        loop at it_main INTO data(wa_main).
          READ TABLE it_je INTO data(wa_je) WITH KEY material           = wa_main-material
                                                     plant              = wa_main-plant
                                                     CUSTOMERPRICEGROUP = wa_main-CUSTOMERPRICEGROUP
                                                     MATERIALBYCUSTOMER = wa_main-MATERIALBYCUSTOMER
                                                     PURCHASEORDERBYSHIPTOPARTY = wa_main-PURCHASEORDERBYSHIPTOPARTY
                                                     SOLDTOPARTY = wa_main-SOLDTOPARTY.
           if sy-subrc eq 0.
             wa_temp-salesorder           = wa_main-salesorder.
             wa_temp-salesorderitem       = wa_main-salesorderitem.
             wa_temp-belnr                = wa_je-AccountingDocument.
             wa_temp-material             = wa_main-Material.
             wa_temp-plant                = wa_main-Plant.
          MODIFY   ztt_journal02 FROM  @wa_temp.

           endif.

         clear:wa_temp,wa_je.
        endloop.





    endmethod.
ENDCLASS.
