namespace Microsoft.DataMigration.GP.HistoricalData;

using System.Security.AccessControl;

permissionsetextension 40900 "D365 Basic Ext." extends "D365 BASIC"
{
    Permissions = tabledata "Hist. Gen. Journal Line" = R,
                  tabledata "Hist. G/L Account" = R,
                  tabledata "Hist. Sales Trx. Header" = R,
                  tabledata "Hist. Sales Trx. Line" = R,
                  tabledata "Hist. Receivables Document" = R,
                  tabledata "Hist. Payables Document" = R,
                  tabledata "Hist. Inventory Trx. Header" = R,
                  tabledata "Hist. Inventory Trx. Line" = R,
                  tabledata "Hist. Purchase Recv. Header" = R,
                  tabledata "Hist. Purchase Recv. Line" = R,
                  tabledata "Hist. Migration Step Status" = R,
                  tabledata "Hist. Migration Current Status" = R,
                  tabledata "Hist. Payables Apply" = R,
                  tabledata "Hist. Receivables Apply" = R;
}