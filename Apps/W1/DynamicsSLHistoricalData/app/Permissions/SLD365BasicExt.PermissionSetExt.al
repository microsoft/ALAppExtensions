// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

using System.Security.AccessControl;

permissionsetextension 42800 "SL D365 Basic Ext." extends "D365 BASIC"
{
    Permissions = tabledata "SL Hist. APAdjust" = R,
                  tabledata "SL Hist. APDoc" = R,
                  tabledata "SL Hist. APTran" = R,
                  tabledata "SL Hist. ARAdjust" = R,
                  tabledata "SL Hist. ARDoc" = R,
                  tabledata "SL Hist. ARTran" = R,
                  tabledata "SL Hist. Batch" = R,
                  tabledata "SL Hist. GLTran" = R,
                  tabledata "SL Hist. INTran" = R,
                  tabledata "SL Hist. LotSerT" = R,
                  tabledata "SL Hist. Migration Cur. Status" = R,
                  tabledata "SL Hist. Migration Step Status" = R,
                  tabledata "SL Hist. POReceipt" = R,
                  tabledata "SL Hist. POTran" = R,
                  tabledata "SL Hist. PurchOrd" = R,
                  tabledata "SL Hist. PurOrdDet" = R,
                  tabledata "SL Hist. SOHeader" = R,
                  tabledata "SL Hist. SOLine" = R,
                  tabledata "SL Hist. SOShipHeader" = R,
                  tabledata "SL Hist. SOShipLine" = R,
                  tabledata "SL Hist. SOShipLot" = R,
                  tabledata "SL Hist. SOType" = R;

}