@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Basic View for Journal'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_JOURNAL_TT_VIEW
  as select from ztmapp_journal_n
  association [0..1] to I_Customer     as _SoldToParty on $projection.Soldtoparty = _SoldToParty.Customer
  
{
  key plant                      as Plant,
  key customerpricegroup         as Customerpricegroup,
  key material                   as Material,
  key purchaseorderbyshiptoparty as Purchaseorderbyshiptoparty,
  key soldtoparty                as Soldtoparty,
  key salesorder                 as Salesorder,
  key item                       as Item,
  key yy1_studyid_sdh            as Yy1StudyidSdh,
  key bp_id,
  key transactioncurrency,
      belnr                      as Belnr,
      fdate                      as Fdate,
      fdate                      as Tdate,
      fdate                      as vdate,
      _SoldToParty.CustomerName,

      _SoldToParty

}
