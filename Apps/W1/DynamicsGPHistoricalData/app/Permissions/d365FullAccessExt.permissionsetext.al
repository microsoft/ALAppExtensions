namespace Microsoft.DataMigration.GP.HistoricalData;

using System.Security.AccessControl;

permissionsetextension 40901 "D365 Full Access Ext." extends "D365 FULL ACCESS"
{
    Permissions = tabledata "Hist. Gen. Journal Line" = RIMD,
                  tabledata "Hist. G/L Account" = RIMD,
                  tabledata "Hist. Sales Trx. Header" = RIMD,
                  tabledata "Hist. Sales Trx. Line" = RIMD,
                  tabledata "Hist. Receivables Document" = RIMD,
                  tabledata "Hist. Payables Document" = RIMD,
                  tabledata "Hist. Inventory Trx. Header" = RIMD,
                  tabledata "Hist. Inventory Trx. Line" = RIMD,
                  tabledata "Hist. Purchase Recv. Header" = RIMD,
                  tabledata "Hist. Purchase Recv. Line" = RIMD,
                  tabledata "Hist. Migration Step Status" = RIMD,
                  tabledata "Hist. Migration Current Status" = RIMD,
                  tabledata "Hist. Payables Apply" = RIMD,
                  tabledata "Hist. Receivables Apply" = RIMD,
                  tabledata "Hist. Invt. Trx. SerialLot" = RIMD,
                  tabledata "Hist. Recv. Trx. SerialLot" = RIMD;
}