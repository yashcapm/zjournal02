CLASS lhc_zr_journal_n DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.

    DATA : ls_final_purch LIKE LINE OF zbp_r_journal_n=>lt_journal,
           ls_dtl         LIKE LINE OF zbp_r_journal_n=>lt_dtl.



  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_journal_n RESULT result.

    METHODS post FOR DETERMINE ON SAVE
      IMPORTING keys FOR zr_journal_n~post.

ENDCLASS.

CLASS lhc_zr_journal_n IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD post.
    DATA: lt_entry     TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
          ls_entry     LIKE LINE OF lt_entry,
          ls_glitem    LIKE LINE OF ls_entry-%param-_glitems,
          ls_amount    LIKE LINE OF ls_glitem-_currencyamount,
          n            TYPE i,
          lt_temp_key  TYPE zgje_transaction_handler=>tt_temp_key,
          ls_temp_key  LIKE LINE OF lt_temp_key,
          update_lines TYPE TABLE FOR UPDATE zr_journal_n,
          update_line  TYPE STRUCTURE FOR UPDATE zr_journal_n.

    TYPES: BEGIN OF ty_final_key,
             cid   TYPE abp_behv_cid,
             bukrs TYPE bukrs,
             belnr TYPE belnr_d,
             gjahr TYPE gjahr,
           END OF ty_final_key,
           tt_final_key TYPE STANDARD TABLE OF ty_final_key WITH DEFAULT KEY.
    DATA : lt_docs   TYPE zgje_transaction_handler=>tt_final_key,
           lt_create TYPE zgje_transaction_handler=>tt_header,
           lt_delete TYPE zgje_transaction_handler=>tt_header.

    READ ENTITIES OF zr_journal_n IN LOCAL MODE
            ENTITY zr_journal_n ALL FIELDS WITH CORRESPONDING #( keys ) RESULT FINAL(data_read).

    READ TABLE data_read INTO DATA(wa_read) INDEX 1.
    DATA(fdate) = wa_read-fdate.
    DATA(tdate) = wa_read-tdate.
    DATA(vdate) = wa_read-vdate.



    SELECT * FROM zcm_journalitem
WHERE creationdate BETWEEN @fdate AND @tdate
INTO TABLE @DATA(it_so).

    DATA: it_temp  TYPE STANDARD TABLE OF zcm_journalitem,
          wa_temp  TYPE zcm_journalitem,
          it_final TYPE STANDARD TABLE OF ztt_journal02,
          wa_final TYPE ztt_journal02.

    LOOP AT it_so INTO DATA(wa_list).
      MOVE-CORRESPONDING wa_list TO ls_dtl.
      ls_dtl-fdate = vdate.
      APPEND ls_dtl TO zbp_r_journal_n=>lt_dtl.
    ENDLOOP.


    LOOP AT it_so INTO DATA(wa_so) GROUP BY ( key1 =  wa_so-plant
                                              key2 = wa_so-customerpricegroup
                                              key3 = wa_so-material
                                              key4 = wa_so-yy1_studyid_sdh
                                              key5 = wa_so-purchaseorderbyshiptoparty
                                              key6 = wa_so-soldtoparty
                                              key7 = wa_so-transactioncurrency ) .
      DATA(lv_salesorder) = wa_so-salesorder.
      DATA(lv_salesorderitem) = wa_so-salesorderitem.
      LOOP AT GROUP wa_so INTO DATA(ls).
        wa_temp-companycode        =   ls-companycode.
        wa_temp-material           =   ls-material.
        wa_temp-salesorder         =   lv_salesorder.
        wa_temp-salesorderitem     =   lv_salesorderitem.
        wa_temp-plant              =   ls-plant.
        wa_temp-customerpricegroup =   ls-customerpricegroup.
        wa_temp-yy1_studyid_sdh =   ls-yy1_studyid_sdh.
        wa_temp-purchaseorderbyshiptoparty = ls-purchaseorderbyshiptoparty.
        wa_temp-soldtoparty    = ls-soldtoparty.
        wa_temp-netamount      = ls-netamount.
        wa_temp-orderquantity  = ls-orderquantity.
        wa_temp-orderquantityunit  = ls-orderquantityunit.
        wa_temp-transactioncurrency = ls-transactioncurrency.
        COLLECT wa_temp INTO it_temp.
        CLEAR:wa_temp,wa_so.
      ENDLOOP.

    ENDLOOP.
    DATA(it_so_main) = it_so[].
    it_so[] = it_temp[].


    LOOP AT it_so ASSIGNING FIELD-SYMBOL(<fs_so>).
      CLEAR:lt_entry,ls_entry.
      n += 1.
      "purchase requisition
      DATA(cid) = 'My%CID' && '_' && n.


      ls_entry-%cid = cid.
      ls_entry-%param-companycode = <fs_so>-companycode."
      ls_entry-%param-businesstransactiontype = 'RFBU'.
      ls_entry-%param-documentreferenceid = 'BKPFF'.
      ls_entry-%param-accountingdocumenttype = 'SA'.
      ls_entry-%param-accountingdocumentheadertext = 'Test1'.
      ls_entry-%param-documentdate = vdate.
      ls_entry-%param-postingdate = vdate.
      ls_entry-%param-createdbyuser = sy-uname.
      ls_entry-%param-taxreportingdate = vdate.
      ls_entry-%param-taxdeterminationdate = vdate.

      CLEAR ls_glitem.

      ls_glitem-glaccountlineitem = '0010'.
      ls_glitem-glaccount         = '00483520'.
*        ls_glitem-costcenter       = '0191731601'.
*        ls_glitem-profitcenter     = '0000731601'.
      ls_glitem-documentitemtext  = 'TEST1'.
      ls_glitem-salesorder          = <fs_so>-salesorder.
      ls_glitem-salesorderitem      = <fs_so>-salesorderitem.
      ls_glitem-yy1_lmiordertypegroup_cob     = <fs_so>-customerpricegroup.
      ls_glitem-yy1_studyid_cob               = <fs_so>-yy1_studyid_sdh.


*      ls_glitem-Material          =  <fs_so>-Material.
*      ls_glitem-Quantity          = <fs_so>-OrderQuantity.
*      ls_glitem-BaseUnit          = <fs_so>-OrderQuantityUnit.

      SELECT SINGLE * FROM ztt_lmimapping
    WHERE CompanyCode = @<fs_so>-CompanyCode
    and   Plant       = @<fs_so>-Plant
      INTO @DATA(wa_prct) .

*      DATA(lo_data_retrieval) = cl_cbo_developer_access=>business_object( '$YY1_LMIMAPPING$'
*    )->root_node(
*    )->data_retrieval( ).



      <fs_so>-netamount = <fs_so>-netamount * -1.
      CLEAR ls_amount.
      ls_amount-currencyrole = '00'.
      ls_amount-currency = <fs_so>-transactioncurrency.
      ls_amount-journalentryitemamount = <fs_so>-netamount.
      APPEND ls_amount TO ls_glitem-_currencyamount.
      ls_glitem-_profitabilitysupplement-profitcenter = wa_prct-profitcenter."'0000731601'.
      ls_glitem-_profitabilitysupplement-salesorder = <fs_so>-salesorder.
      ls_glitem-_profitabilitysupplement-salesorderitem = <fs_so>-salesorderitem.

*      ls_glitem-_profitabilitysupplement-Customer       = <fs_so>-SoldToParty.
      APPEND ls_glitem TO ls_entry-%param-_glitems.
*  <<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      CLEAR ls_glitem.
      ls_glitem-glaccountlineitem = '0020'.
      ls_glitem-glaccount         = '00171150'.
*        ls_glitem-costcenter        = '0191731601'.
*        ls_glitem-profitcenter      = '0000731601'.
      ls_glitem-documentitemtext  = 'TEST2'.
      ls_glitem-salesorder          = <fs_so>-salesorder.
      ls_glitem-salesorderitem      = <fs_so>-salesorderitem.
      ls_glitem-yy1_lmiordertypegroup_cob     = <fs_so>-customerpricegroup.
      ls_glitem-yy1_studyid_cob               = <fs_so>-yy1_studyid_sdh.


*      ls_glitem-Material          =  <fs_so>-Material.
*      ls_glitem-Quantity          = <fs_so>-OrderQuantity.
*      ls_glitem-BaseUnit          = <fs_so>-OrderQuantityUnit.

      <fs_so>-netamount = <fs_so>-netamount * -1.
      CLEAR ls_amount.
      ls_amount-currencyrole = '00'.
      ls_amount-currency = <fs_so>-transactioncurrency.
      ls_amount-journalentryitemamount = <fs_so>-netamount.
      APPEND ls_amount TO ls_glitem-_currencyamount.
      ls_glitem-_profitabilitysupplement-profitcenter = wa_prct-profitcenter."'0000731601'.
      ls_glitem-_profitabilitysupplement-salesorder = <fs_so>-salesorder.
      ls_glitem-_profitabilitysupplement-salesorderitem = <fs_so>-salesorderitem.

*      ls_glitem-_profitabilitysupplement-Customer       = <fs_so>-SoldToParty.
      APPEND ls_glitem TO ls_entry-%param-_glitems.
*  <<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*       ls_taxitem-TaxCode = 'A0'.
*       ls_taxitem-TaxDeterminationDate = SY-datum.
*
*       ls_taxamt-CurrencyRole = '00'.
*       ls_taxamt-Currency     = 'GBP'.
*       ls_taxamt-JournalEntryItemAmount = '0.00'.
*       APPEND ls_taxamt TO ls_taxitem-_currencyamount.
*       APPEND ls_taxitem TO ls_entry-%param-_taxitems.
*  <<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      APPEND ls_entry TO lt_entry.


      MODIFY ENTITIES OF i_journalentrytp
        ENTITY journalentry
      EXECUTE post FROM  lt_entry
      MAPPED FINAL(ls_post_mapped)
      FAILED FINAL(ls_post_failed)
      REPORTED FINAL(ls_post_reported).
*      FAILED DATA(ls_failed_deep)
*          REPORTED DATA(ls_reported_deep)
*          MAPPED DATA(ls_mapped_deep).
      IF ls_post_failed IS NOT INITIAL.
        LOOP AT ls_post_reported-journalentry INTO DATA(ls_report).
          APPEND VALUE #( %create = if_abap_behv=>mk-on
                          %msg = ls_report-%msg ) TO reported-zr_journal_n.
        ENDLOOP.
      ENDIF.

*      LOOP AT ls_post_mapped-journalentry INTO DATA(ls_je_mapped).
*        ls_temp_key-cid = ls_je_mapped-%cid.
*        ls_temp_key-pid = ls_je_mapped-%pid.
*        APPEND ls_temp_key TO lt_temp_key.
*      ENDLOOP.

      zbp_r_journal_n=>mapped_journalentrytp-journalentry =  ls_post_mapped-journalentry.

*      LOOP AT keys INTO DATA(key).
*
*        update_line-%tky                   = key-%tky.
*        update_line-belnr     = 'X'.
*        APPEND update_line TO update_lines.
*      ENDLOOP.

      MOVE-CORRESPONDING <fs_so> TO ls_final_purch.
      APPEND ls_final_purch TO zbp_r_journal_n=>lt_journal.


    ENDLOOP.


  ENDMETHOD.



ENDCLASS.

CLASS lsc_zr_journal_n DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zr_journal_n IMPLEMENTATION.

  METHOD save_modified.
    "unmanaged save for table ZGJE_HEADER


    DATA:it_main TYPE STANDARD TABLE OF ztmapp_journal_n,
         wa_main TYPE ztmapp_journal_n.
    CLEAR:wa_main,it_main.
    DELETE ztmapp_journal_n FROM @wa_main.

    DATA(lt_list) = zbp_r_journal_n=>lt_journal.
    DATA(lt_final) = zbp_r_journal_n=>lt_dtl.
    DATA:counter TYPE i.
    CLEAR:counter.
    LOOP AT zbp_r_journal_n=>mapped_journalentrytp-journalentry ASSIGNING FIELD-SYMBOL(<fs_pr_mapped>).
      CONVERT KEY OF i_journalentrytp FROM <fs_pr_mapped>-%pid TO DATA(ls_pr_key).
      <fs_pr_mapped>-accountingdocument = ls_pr_key-accountingdocument.
*        <<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      counter += 1.
      READ TABLE lt_list INTO DATA(wa_list) INDEX counter.
      wa_list-belnr =  <fs_pr_mapped>-accountingdocument.
      MOVE-CORRESPONDING wa_list TO wa_main.
      APPEND wa_main TO  it_main.
*      MODIFY ztt_mapp_journal FROM @wa_list.
      CLEAR:<fs_pr_mapped>,wa_list,wa_main.
    ENDLOOP.

    LOOP AT lt_final INTO DATA(wa_final).
      READ TABLE it_main INTO DATA(w_main) WITH KEY plant = wa_final-plant
                                                      customerpricegroup = wa_final-customerpricegroup
                                                      material  = wa_final-material
                                                      yy1_studyid_sdh = wa_final-yy1_studyid_sdh
                                                      purchaseorderbyshiptoparty = wa_final-purchaseorderbyshiptoparty
                                                      soldtoparty = wa_final-soldtoparty
                                                      transactioncurrency = wa_final-transactioncurrency.
      IF sy-subrc EQ 0.
        wa_final-belnr =   w_main-belnr.
        TRY.
            wa_final-bp_id =   cl_uuid_factory=>create_system_uuid( )->create_uuid_c32( ).
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
        MODIFY ztmapp_journal_n FROM @wa_final.
      ENDIF.
      CLEAR:wa_final,w_main.
    ENDLOOP.




  ENDMETHOD.



  METHOD cleanup_finalize.

  ENDMETHOD.

ENDCLASS.
