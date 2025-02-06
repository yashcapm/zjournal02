@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL Journal Entry'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_JOURNAL_N as select from I_JournalEntryItem
association [0..1] to I_JournalEntry as _JournalEntry on $projection.CompanyCode = _JournalEntry.CompanyCode
                                                    and  $projection.FiscalYear  = _JournalEntry.FiscalYear   
                                                    and  $projection.AccountingDocument = _JournalEntry.AccountingDocument
association [0..1] to I_SalesOrder     as _SalesOrder on $projection.SalesDocument =  _SalesOrder.SalesOrder
association [0..1] to I_SalesOrderItem as _SalesOrderItem on $projection.SalesDocument     =  _SalesOrderItem.SalesOrder                                                 
                                                        and  $projection.SalesDocumentItem = _SalesOrderItem.SalesOrderItem
association [0..1] to ztt_journal02 as  _Journal  on $projection.AccountingDocument =  _Journal.belnr   
                                                 and $projection.LedgerGLLineItem = '000001'                                                     
{
   key SourceLedger,
   key CompanyCode,
   key FiscalYear,
   key AccountingDocument,
   key LedgerGLLineItem,
   key Ledger,
   LedgerFiscalYear,
   PartnerCostCenter,
   PartnerProfitCenter,
   GLAccount,
   ProfitCenter,
   CostCenter,
   BalanceTransactionCurrency,
   @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
   AmountInBalanceTransacCrcy,
   CompanyCodeCurrency,
   @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
   AmountInCompanyCodeCurrency,
   GlobalCurrency,
   @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
   AmountInGlobalCurrency,
   TransactionCurrency,
   @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
   AmountInTransactionCurrency,
   
   SalesOrder as SalesDocument,
   SalesOrderItem as SalesDocumentItem,
   _JournalEntry.DocumentDate , 
   _JournalEntry.DocumentDate as Fdate,
   _JournalEntry.DocumentDate as Tdate,
   _SalesOrder.CreationDate,
   _SalesOrder.SoldToParty,
   _SalesOrderItem.OrderQuantityUnit,
   @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
   _SalesOrderItem.OrderQuantity,
   _SalesOrderItem.Material,
   _Journal.salesorder as So,
   _Journal.salesorderitem as soitem,
   _SalesOrder.YY1_StudyID_SDH,
   
   
//   
   _JournalEntry,
   _SalesOrder,
   _SalesOrderItem,
   _Journal
   
    
    
} where $projection.sourceledger = '0L'
