// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

permissionset 42801 "SL Historical Querys"
{
    Assignable = true;
    Access = Public;
    Caption = 'SL Historical Transactions';

    Permissions = query "SL Hist. Shippers" = X,
                  query "SL Hist. APTransactions" = X,
                  query "SL Hist. ARTransactions" = X,
                  query "SL Hist. Batch" = X,
                  query "SL Hist. GLTransactions" = X,
                  query "SL Hist. InventoryTransactions" = X,
                  query "SL Hist. OpenARDocuments" = X,
                  query "SL Hist. APDocuments" = X,
                  query "SL Hist. ARDocuments" = X,
                  query "SL Hist. POReceiptDocuments" = X,
                  query "SL Hist. ARInvoiceDocuments" = X,
                  query "SL Hist. SalesOrders" = X,
                  query "SL Hist. SalesOrderQuotes" = X,
                  query "SL Hist. SalesOrderReturns" = X,
                  query "SL Hist. SalesOrderLineItems" = X,
                  query "SL Hist. ShipperLineItems" = X,
                  query "SL Hist. POReceiptLineItems" = X,
                  tabledata "SL Hist. APAdjust" = RIMD,
                  tabledata "SL Hist. APDoc" = RIMD,
                  tabledata "SL Hist. APTran" = RIMD,
                  tabledata "SL Hist. ARAdjust" = RIMD,
                  tabledata "SL Hist. ARDoc" = RIMD,
                  tabledata "SL Hist. ARTran" = RIMD,
                  tabledata "SL Hist. Batch" = RIMD,
                  tabledata "SL Hist. GLTran" = RIMD,
                  tabledata "SL Hist. INTran" = RIMD,
                  tabledata "SL Hist. LotSerT" = RIMD,
                  tabledata "SL Hist. Migration Cur. Status" = RIMD,
                  tabledata "SL Hist. Migration Step Status" = RIMD,
                  tabledata "SL Hist. POReceipt" = RIMD,
                  tabledata "SL Hist. POTran" = RIMD,
                  tabledata "SL Hist. PurchOrd" = RIMD,
                  tabledata "SL Hist. PurOrdDet" = RIMD,
                  tabledata "SL Hist. SOHeader" = RIMD,
                  tabledata "SL Hist. SOLine" = RIMD,
                  tabledata "SL Hist. SOShipHeader" = RIMD,
                  tabledata "SL Hist. SOShipLine" = RIMD,
                  tabledata "SL Hist. SOShipLot" = RIMD,
                  tabledata "SL Hist. SOType" = RIMD,
                  table "SL Hist. APAdjust" = X,
                  table "SL Hist. APDoc" = X,
                  table "SL Hist. APTran" = X,
                  table "SL Hist. ARAdjust" = X,
                  table "SL Hist. ARDoc" = X,
                  table "SL Hist. ARTran" = X,
                  table "SL Hist. Batch" = X,
                  table "SL Hist. GLTran" = X,
                  table "SL Hist. INTran" = X,
                  table "SL Hist. LotSerT" = X,
                  table "SL Hist. Migration Cur. Status" = X,
                  table "SL Hist. Migration Step Status" = X,
                  table "SL Hist. POReceipt" = X,
                  table "SL Hist. POTran" = X,
                  table "SL Hist. PurchOrd" = X,
                  table "SL Hist. PurOrdDet" = X,
                  table "SL Hist. SOHeader" = X,
                  table "SL Hist. SOLine" = X,
                  table "SL Hist. SOShipHeader" = X,
                  table "SL Hist. SOShipLine" = X,
                  table "SL Hist. SOShipLot" = X,
                  table "SL Hist. SOType" = X;
}