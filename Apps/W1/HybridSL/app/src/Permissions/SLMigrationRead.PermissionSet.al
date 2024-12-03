// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

permissionset 47006 "SL Migration - Read"
{
    Assignable = true;
    Access = Public;
    Caption = 'SL Migration - Read';

    Permissions = tabledata "SL AccountTransactions" = R,
                  tabledata "SL Account" = R,
                  tabledata "SL Account Staging" = R,
                  tabledata "SL Account Staging Setup" = R,
                  tabledata "SL AcctHist" = R,
                  tabledata "SL APAdjust" = R,
                  tabledata "SL APDoc" = R,
                  tabledata "SL APSetup" = R,
                  tabledata "SL APTran" = R,
                  tabledata "SL AP_Balances" = R,
                  tabledata "SL ARAdjust" = R,
                  tabledata "SL ARDoc" = R,
                  tabledata "SL ARSetup" = R,
                  tabledata "SL ARTran" = R,
                  tabledata "SL AR_Balances" = R,
                  tabledata "SL Batch" = R,
                  tabledata "SL Codes" = R,
                  tabledata "SL Company Additional Settings" = R,
                  tabledata "SL Company Migration Settings" = R,
                  tabledata "SL Customer" = R,
                  tabledata "SL Fiscal Periods" = R,
                  tabledata "SL FlexDef" = R,
                  tabledata "SL GLSetup" = R,
                  tabledata "SL GLTran" = R,
                  tabledata "SL Hist. Source Error" = R,
                  tabledata "SL Hist. Source Progress" = R,
                  tabledata "SL INSetup" = R,
                  tabledata "SL INTran" = R,
                  tabledata "SL Inventory" = R,
                  tabledata "SL InventoryADG" = R,
                  tabledata "SL ItemCost" = R,
                  tabledata "SL ItemSite" = R,
                  tabledata "SL LotSerMst" = R,
                  tabledata "SL LotSerT" = R,
                  tabledata "SL Migration Config" = R,
                  tabledata "SL Migration Error Overview" = R,
                  tabledata "SL Migration Errors" = R,
                  tabledata "SL Migration Warnings" = R,
                  tabledata "SL Payment Terms" = R,
                  tabledata "SL Period List Work Table" = R,
                  tabledata "SL POAddress" = R,
                  tabledata "SL POReceipt" = R,
                  tabledata "SL POSetup" = R,
                  tabledata "SL POTran" = R,
                  tabledata "SL PurchOrd" = R,
                  tabledata "SL PurOrdDet" = R,
                  tabledata "SL SalesTax" = R,
                  tabledata "SL SegDef" = R,
                  tabledata "SL Segments" = R,
                  tabledata "SL Segment Name" = R,
                  tabledata "SL Site" = R,
                  tabledata "SL SOAddress" = R,
                  tabledata "SL SOHeader" = R,
                  tabledata "SL SOLine" = R,
                  tabledata "SL SOSetup" = R,
                  tabledata "SL SOShipHeader" = R,
                  tabledata "SL SOShipLine" = R,
                  tabledata "SL SOShipLot" = R,
                  tabledata "SL SOType" = R,
                  tabledata "SL Terms" = R,
                  tabledata "SL Upgrade Settings" = R,
                  tabledata "SL Vendor" = R,
                  tabledata SLGLAcctBalByPeriod = R;
}