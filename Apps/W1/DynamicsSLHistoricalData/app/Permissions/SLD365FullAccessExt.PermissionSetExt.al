// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

using System.Security.AccessControl;
using Microsoft.DataMigration.SL;

permissionsetextension 42801 "SL D365 Full Access Ext." extends "D365 FULL ACCESS"
{
    Permissions = tabledata "SL Hist. APAdjust" = RIMD,
#if not CLEAN28
#pragma warning disable AL0432
                  tabledata "SL Hist. APDoc" = RIMD,
                  tabledata "SL Hist. APTran" = RIMD,
#pragma warning restore AL0432
#endif
                  tabledata "SL Hist. APTran Archive" = RIMD,
                  tabledata "SL Hist. ARAdjust" = RIMD,
#if not CLEAN28
#pragma warning disable AL0432
                  tabledata "SL Hist. ARDoc" = RIMD,
                  tabledata "SL Hist. ARTran" = RIMD,
#pragma warning restore AL0432
#endif
                  tabledata "SL Hist. ARTran Archive" = RIMD,
                  tabledata "SL Hist. Batch" = RIMD,
                  tabledata "SL Hist. GLSetup" = RIMD,
#if not CLEAN28
#pragma warning disable AL0432
                  tabledata "SL Hist. GLTran" = RIMD,
                  tabledata "SL Hist. INTran" = RIMD,
                  tabledata "SL Hist. LotSerT" = RIMD,
#pragma warning restore AL0432
#endif
                  tabledata "SL Hist. GLTran Archive" = RIMD,
                  tabledata "SL Hist. INTran Archive" = RIMD,
                  tabledata "SL Hist. LotSerT Archive" = RIMD,
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
                  tabledata "SL Hist. SOType" = RIMD;
}