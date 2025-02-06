@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL Journal Entry Root View'
define root view entity ZR_JOURNAL_N
 as select from ZC_JOURNAL_TT_VIEW

{
 key Plant,
 key Customerpricegroup,
 key Material,
 key Purchaseorderbyshiptoparty,
 key Soldtoparty,
 key Salesorder,
 key Item,
 key Yy1StudyidSdh,
 key bp_id,
 key transactioncurrency,
 Belnr,
 Fdate,
 Tdate,
 vdate,
 CustomerName,
 
 _SoldToParty
} 
