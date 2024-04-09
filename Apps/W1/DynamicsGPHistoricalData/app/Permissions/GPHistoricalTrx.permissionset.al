namespace Microsoft.DataMigration.GP.HistoricalData;

permissionset 40900 "GP Historical Trx."
{
    Assignable = true;
    Access = Public;
    Caption = 'GP Historical Transactions';

    Permissions = page "Hist. Gen. Journal Lines" = X,
                  page "Hist. G/L Account List" = X,
                  page "Hist. Inventory Trx." = X,
                  page "Hist. Inventory Trx. Headers" = X,
                  page "Hist. Inventory Trx. Lines" = X,
                  page "Hist. Payables Document" = X,
                  page "Hist. Payables Documents" = X,
                  page "Hist. Purchase Recv." = X,
                  page "Hist. Purchase Recv. Headers" = X,
                  page "Hist. Purchase Recv. Lines" = X,
                  page "Hist. Receivables Document" = X,
                  page "Hist. Receivables Documents" = X,
                  page "Hist. Sales Trx." = X,
                  page "Hist. Sales Trx. Headers" = X,
                  page "Hist. Sales Trx. Lines" = X,
                  page "Hist. Migration Step Status" = X,
                  page "Hist. Payables Apply" = X,
                  page "Hist. Payables Apply List" = X,
                  page "Hist. Payables Document List" = X,
                  page "Hist. Receivables Apply" = X,
                  page "Hist. Receivables Apply List" = X,
                  page "Hist. Recv. Document List" = X;
}