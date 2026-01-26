// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST;

using Microsoft.Finance.GST.Application;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Distribution;
using Microsoft.Finance.GST.Payments;
using Microsoft.Finance.GST.Reconcilation;
using Microsoft.Finance.GST.ReturnSettlement;
using Microsoft.Finance.GST.ServicesTransfer;
using Microsoft.Finance.GST.StockTransfer;
using Microsoft.Finance.GST.Subcontracting;
using Microsoft.Finance.TaxBase;

permissionset 18360 "D365 Read Access - India GST"
{
    Access = Internal;
    Assignable = false;
    Caption = 'D365 Read Access - India GST';

    IncludedPermissionSets = "IN Advance Objects - India GST";

    Permissions = tabledata "Applied Delivery Challan Entry" = R,
                  tabledata "Applied Delivery Challan" = R,
                  tabledata "Bank Charge" = R,
                  tabledata "Bank Charge Deemed Value Setup" = R,
                  tabledata "Detailed Cr. Adjstmnt. Entry" = R,
                  tabledata "Detailed GST Dist. Entry" = R,
                  tabledata "Detailed GST Entry Buffer" = R,
                  tabledata "Detailed GST Ledger Entry" = R,
                  tabledata "Detailed GST Ledger Entry Info" = R,
                  tabledata "Dist. Component Amount" = R,
                  tabledata "Delivery Challan Header" = R,
                  tabledata "Delivery Challan Line" = R,
                  tabledata "E-Comm. Merchant" = R,
                  tabledata "GST Application Buffer" = R,
                  tabledata "GST Claim Setoff" = R,
                  tabledata "GST Component Distribution" = R,
                  tabledata "GST Credit Adjustment Journal" = R,
                  tabledata "GST Distribution Header" = R,
                  tabledata "GST Distribution Line" = R,
                  tabledata "GST Group" = R,
                  tabledata "GST Ledger Entry" = R,
                  tabledata "GST Liability Adjustment" = R,
                  tabledata "GST Liability Buffer" = R,
                  tabledata "GST Payment Buffer" = R,
                  tabledata "GST Payment Buffer Details" = R,
                  tabledata "GST Posting Buffer" = R,
                  tabledata "GST Posting Setup" = R,
                  tabledata "GST Recon. Mapping" = R,
                  tabledata "GST Reconcilation" = R,
                  tabledata "GST Reconcilation Line" = R,
                  tabledata "GST Registration Nos." = R,
                  tabledata "GST Setup" = R,
                  tabledata "GST TDS/TCS Entry" = R,
                  tabledata "GST Tracking Entry" = R,
                  tabledata "GST Journal Template" = R,
                  tabledata "GST Journal Batch" = R,
                  tabledata "GST Journal Line" = R,
                  tabledata "GST Adjustment Buffer" = R,
                  tabledata "GST Liability Line" = R,
                  tabledata "HSN/SAC" = R,
                  tabledata "ISD Ledger" = R,
                  tabledata "Journal Bank Charges" = R,
                  tabledata "Multiple Subcon. Order Details" = R,
                  tabledata "Periodic GSTR-2A Data" = R,
                  tabledata "Posted GST Distribution Header" = R,
                  tabledata "Posted GST Distribution Line" = R,
                  tabledata "Posted GST Liability Adj." = R,
                  tabledata "Posted GST Reconciliation" = R,
                  tabledata "Posted Jnl. Bank Charges" = R,
                  tabledata "Posted Settlement Entries" = R,
                  tabledata "Posting No. Series" = R,
                  tabledata "Posted Applied DeliveryChallan" = R,
                  tabledata "Posted GST Liability Line" = RMID,
                  tabledata "Reference Invoice No." = R,
                  tabledata "Retrun & Reco. Components" = R,
                  tabledata "Service Transfer Header" = R,
                  tabledata "Service Transfer Line" = R,
                  tabledata "Service Transfer Rcpt. Header" = R,
                  tabledata "Service Transfer Rcpt. Line" = R,
                  tabledata "Service Transfer Shpt. Header" = R,
                  tabledata "Service Transfer Shpt. Line" = R,
                  tabledata "Sub. Comp. Rcpt. Header" = R,
                  tabledata "Sub. Comp. Rcpt. Line" = R,
                  tabledata "Subcon. Delivery Challan Line" = R,
                  tabledata "Subcontractor Delivery Challan" = R,
                  tabledata "Sub Order Comp. List Vend" = R,
                  tabledata "Sub Order Component List" = R,
                  tabledata "Transfer Buffer" = R;
}
