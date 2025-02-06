@EndUserText.label: 'GL Journal Entry Prjection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_JOURNAL_N 
provider contract transactional_query
as projection on ZR_JOURNAL_N

{
  key Plant,
 key Customerpricegroup,
 key Material,
 key Purchaseorderbyshiptoparty,
 @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_Customer_VH',
                     element: 'Customer' }
        }]
      // ]--GENERATED
  @ObjectModel.foreignKey.association: '_SoldToParty'
  @ObjectModel.text.element: [ 'CustomerName' ]
 key Soldtoparty,
 key Salesorder,
 key Item,
 @EndUserText.label: 'Study Id'
 key Yy1StudyidSdh,
 key bp_id,
 key transactioncurrency,

 Belnr,
 @EndUserText.label: 'From Date'
 Fdate,
 @EndUserText.label: 'To Date'
 Tdate,
 @EndUserText.label: 'Document Date'
 vdate,
 CustomerName,
 
 _SoldToParty
}
