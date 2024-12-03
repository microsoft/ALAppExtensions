// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

permissionset 47004 "SL Migration - Edit"
{
    Assignable = true;
    Access = Public;
    Caption = 'SL Migration - Edit';

    Permissions = tabledata "SL AccountTransactions" = IMD,
                  tabledata "SL Account" = IMD,
                  tabledata "SL Account Staging" = IMD,
                  tabledata "SL Account Staging Setup" = IMD,
                  tabledata "SL AcctHist" = IMD,
                  tabledata "SL APAdjust" = IMD,
                  tabledata "SL APDoc" = IMD,
                  tabledata "SL APSetup" = IMD,
                  tabledata "SL APTran" = IMD,
                  tabledata "SL AP_Balances" = IMD,
                  tabledata "SL ARAdjust" = IMD,
                  tabledata "SL ARDoc" = IMD,
                  tabledata "SL ARSetup" = IMD,
                  tabledata "SL ARTran" = IMD,
                  tabledata "SL AR_Balances" = IMD,
                  tabledata "SL Batch" = IMD,
                  tabledata "SL Codes" = IMD,
                  tabledata "SL Company Additional Settings" = IMD,
                  tabledata "SL Company Migration Settings" = IMD,
                  tabledata "SL Customer" = IMD,
                  tabledata "SL Fiscal Periods" = IMD,
                  tabledata "SL FlexDef" = IMD,
                  tabledata "SL GLSetup" = IMD,
                  tabledata "SL GLTran" = IMD,
                  tabledata "SL Hist. Source Error" = IMD,
                  tabledata "SL Hist. Source Progress" = IMD,
                  tabledata "SL INSetup" = IMD,
                  tabledata "SL INTran" = IMD,
                  tabledata "SL Inventory" = IMD,
                  tabledata "SL InventoryADG" = IMD,
                  tabledata "SL ItemCost" = IMD,
                  tabledata "SL ItemSite" = IMD,
                  tabledata "SL LotSerMst" = IMD,
                  tabledata "SL LotSerT" = IMD,
                  tabledata "SL Migration Config" = IMD,
                  tabledata "SL Migration Error Overview" = IMD,
                  tabledata "SL Migration Errors" = IMD,
                  tabledata "SL Migration Warnings" = IMD,
                  tabledata "SL Payment Terms" = IMD,
                  tabledata "SL POAddress" = IMD,
                  tabledata "SL POReceipt" = IMD,
                  tabledata "SL POSetup" = IMD,
                  tabledata "SL POTran" = IMD,
                  tabledata "SL PurchOrd" = IMD,
                  tabledata "SL PurOrdDet" = IMD,
                  tabledata "SL SalesTax" = IMD,
                  tabledata "SL SegDef" = IMD,
                  tabledata "SL Segments" = IMD,
                  tabledata "SL Segment Name" = IMD,
                  tabledata "SL Site" = IMD,
                  tabledata "SL SOAddress" = IMD,
                  tabledata "SL SOHeader" = IMD,
                  tabledata "SL SOLine" = IMD,
                  tabledata "SL SOSetup" = IMD,
                  tabledata "SL SOShipHeader" = IMD,
                  tabledata "SL SOShipLine" = IMD,
                  tabledata "SL SOShipLot" = IMD,
                  tabledata "SL SOType" = IMD,
                  tabledata "SL Terms" = IMD,
                  tabledata "SL Upgrade Settings" = IMD,
                  tabledata "SL Vendor" = IMD,
                  tabledata SLGLAcctBalByPeriod = IMD,
                  tabledata "SL Period List Work Table" = IMD;
}