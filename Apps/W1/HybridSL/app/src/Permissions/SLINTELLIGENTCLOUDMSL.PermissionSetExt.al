// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using System.Security.AccessControl;

permissionsetextension 47000 "SLINTELLIGENT CLOUD - MSL" extends "INTELLIGENT CLOUD"
{
    Permissions = tabledata "SL AccountTransactions" = RIMD,
                  tabledata "SL Account" = RIMD,
                  tabledata "SL Account Staging" = RIMD,
                  tabledata "SL Account Staging Setup" = RIMD,
                  tabledata "SL AcctHist" = RIMD,
                  tabledata "SL APAdjust" = RIMD,
                  tabledata "SL APDoc Buffer" = RIMD,
                  tabledata "SL APSetup" = RIMD,
#if not CLEAN28
#pragma warning disable AL0432
                  tabledata "SL APDoc" = RIMD,
                  tabledata "SL APTran" = RIMD,
#pragma warning restore AL0432
#endif
                  tabledata "SL APTran Buffer" = RIMD,
                  tabledata "SL AP_Balances" = RIMD,
                  tabledata "SL ARAdjust" = RIMD,
#if not CLEAN28
#pragma warning disable AL0432
                  tabledata "SL ARDoc" = RIMD,
#pragma warning restore AL0432
#endif
                  tabledata "SL ARDoc Buffer" = RIMD,
                  tabledata "SL ARSetup" = RIMD,
#if not CLEAN28
#pragma warning disable AL0432
                  tabledata "SL ARTran" = RIMD,
#pragma warning restore AL0432
#endif
                  tabledata "SL ARTran Buffer" = RIMD,
                  tabledata "SL AR_Balances" = RIMD,
                  tabledata "SL Batch" = RIMD,
                  tabledata "SL Codes" = RIMD,
                  tabledata "SL Company Additional Settings" = RIMD,
                  tabledata "SL Company Migration Settings" = RIMD,
                  tabledata "SL CustClass" = RIMD,
                  tabledata "SL Customer" = RIMD,
                  tabledata "SL Fiscal Periods" = RIMD,
                  tabledata "SL FlexDef" = RIMD,
                  tabledata "SL GLSetup" = RIMD,
#if not CLEAN28
#pragma warning disable AL0432
                  tabledata "SL GLTran" = RIMD,
#pragma warning restore AL0432
#endif
                  tabledata "SL GLTran Buffer" = RIMD,
                  tabledata "SL Hist. Source Error" = RIMD,
                  tabledata "SL Hist. Source Progress" = RIMD,
                  tabledata "SL INSetup" = RIMD,
                  tabledata "SL INTran Buffer" = RIMD,
                  tabledata "SL Inventory Buffer" = RIMD,
                  tabledata "SL InventoryADG" = RIMD,
                  tabledata "SL ItemCost Buffer" = RIMD,
                  tabledata "SL ItemSite Buffer" = RIMD,
                  tabledata "SL LotSerMst Buffer" = RIMD,
                  tabledata "SL LotSerT Buffer" = RIMD,
#if not CLEAN28
#pragma warning disable AL0432
                  tabledata "SL INTran" = RIMD,
                  tabledata "SL Inventory" = RIMD,
                  tabledata "SL ItemCost" = RIMD,
                  tabledata "SL ItemSite" = RIMD,
                  tabledata "SL LotSerMst" = RIMD,
                  tabledata "SL LotSerT" = RIMD,
#pragma warning restore AL0432
#endif
                  tabledata "SL Migration Config" = RIMD,
                  tabledata "SL Migration Error Overview" = RIMD,
                  tabledata "SL Migration Errors" = RIMD,
                  tabledata "SL Migration Warnings" = RIMD,
                  tabledata "SL Payment Terms" = RIMD,
                  tabledata "SL PJAddr" = RIMD,
                  tabledata "SL PJCode" = RIMD,
                  tabledata "SL PJEmploy Buffer" = RIMD,
                  tabledata "SL PJEmpPjt Buffer" = RIMD,
                  tabledata "SL PJEQRate Buffer" = RIMD,
                  tabledata "SL PJEquip Buffer" = RIMD,
                  tabledata "SL PJPent Buffer" = RIMD,
                  tabledata "SL PJProj Buffer" = RIMD,
#if not CLEAN28
#pragma warning disable AL0432
                  tabledata "SL PJEmploy" = RIMD,
                  tabledata "SL PJEmpPjt" = RIMD,
                  tabledata "SL PJEQRate" = RIMD,
                  tabledata "SL PJEquip" = RIMD,
                  tabledata "SL PJPent" = RIMD,
                  tabledata "SL PJProj" = RIMD,
#pragma warning restore AL0432
#endif                  
                  tabledata "SL POAddress" = RIMD,
                  tabledata "SL POReceipt" = RIMD,
                  tabledata "SL POSetup" = RIMD,
                  tabledata "SL POTran" = RIMD,
                  tabledata "SL ProductClass" = RIMD,
                  tabledata "SL PurchOrd" = RIMD,
                  tabledata "SL PurOrdDet" = RIMD,
                  tabledata "SL SalesTax" = RIMD,
                  tabledata "SL SegDef" = RIMD,
                  tabledata "SL Segments" = RIMD,
                  tabledata "SL Segment Name" = RIMD,
                  tabledata "SL Site" = RIMD,
                  tabledata "SL SOAddress" = RIMD,
                  tabledata "SL SOHeader" = RIMD,
                  tabledata "SL SOLine" = RIMD,
                  tabledata "SL SOSetup" = RIMD,
                  tabledata "SL SOShipHeader" = RIMD,
                  tabledata "SL SOShipLine" = RIMD,
                  tabledata "SL SOShipLot" = RIMD,
                  tabledata "SL SOType" = RIMD,
                  tabledata "SL Terms" = RIMD,
                  tabledata "SL Upgrade Settings" = RIMD,
                  tabledata "SL VendClass" = RIMD,
                  tabledata "SL Vendor" = RIMD,
                  tabledata SLGLAcctBalByPeriod = RIMD,
                  tabledata "SL Period List Work Table" = RIMD;
}