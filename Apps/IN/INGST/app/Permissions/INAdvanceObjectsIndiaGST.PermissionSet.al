// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST;

using Microsoft.Finance.GST.Application;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Distribution;
using Microsoft.Finance.GST.Payments;
using Microsoft.Finance.GST.Purchase;
using Microsoft.Finance.GST.Reconcilation;
using Microsoft.Finance.GST.ReturnSettlement;
using Microsoft.Finance.GST.Sales;
using Microsoft.Finance.GST.Services;
using Microsoft.Finance.GST.ServicesTransfer;
using Microsoft.Finance.GST.StockTransfer;
using Microsoft.Finance.GST.Subcontracting;

permissionset 18358 "IN Advance Objects - India GST"
{
    Access = Public;
    Assignable = false;
    Caption = 'IN Advance Objects - India GST';

    Permissions = codeunit "GST Statistics" = X,
                  codeunit "GST Stats Management" = X,
                  codeunit "GST Application Handler" = X,
                  codeunit "GST Application Library" = X,
                  codeunit "GST Application Session Mgt." = X,
                  codeunit "GST Item Charge Subscribers" = X,
                  codeunit "GST Purchase Application Mgt." = X,
                  codeunit "GST Reverse Trans. Handler" = X,
                  codeunit "GST Reverse Trans. Session Mgt" = X,
                  codeunit "GST Sales Application Mgt." = X,
                  codeunit "Reference Invoice No. Mgt." = X,
                  codeunit "GST Base Validation" = X,
                  codeunit "GST Navigate" = X,
                  codeunit "GST Posting Management" = X,
                  codeunit "GST Preview Handler" = X,
                  codeunit "Migrate Ecom Merchant Data" = X,
                  codeunit "GST Distribution" = X,
                  codeunit "GST Distribution Subcsribers" = X,
                  codeunit "GST Bank Charge Session Mgt." = X,
                  codeunit "GST Journal Line Subscribers" = X,
                  codeunit "GST Journal Line Validations" = X,
                  codeunit "GST Journal Subscribers" = X,
                  codeunit "GST Journal Validations" = X,
                  codeunit "GST Non Availment Session Mgt" = X,
                  codeunit "GST Purchase Non Availment" = X,
                  codeunit "GST Purch CustomDuty Availment" = X,
                  codeunit "Validate Bank Charges Amount" = X,
                  codeunit "GST Canc Corr Purch Inv Credit" = X,
                  codeunit "GST Purchase Subscribers" = X,
                  codeunit "GST Purhase No. Series" = X,
                  codeunit "GST Vendor Ledger Entry" = X,
                  codeunit "GST Reconcilation Match" = X,
                  codeunit "GST Adj. Journal Subscribers" = X,
                  codeunit "GST Helpers" = X,
                  codeunit "GST Journal Management" = X,
                  codeunit "GST Journal Post" = X,
                  codeunit "GST Settlement" = X,
                  codeunit "e-Invoice Json Handler" = X,
                  codeunit "e-Invoice Management" = X,
                  codeunit "GST Canc Corr Sales Inv Credit" = X,
                  codeunit "GST Cust. Ledger Entry" = X,
                  codeunit "GST Fin Charge Memo Validation" = X,
                  codeunit "GST Sales Posting No. Series" = X,
                  codeunit "GST Sales Validation" = X,
                  codeunit "GST Ship To Address" = X,
                  codeunit "e-Invoice Json Handler for Ser" = X,
                  codeunit "e-Invoice Management for Ser." = X,
                  codeunit "GST Service Posting No. Series" = X,
                  codeunit "GST Service Ship To Address" = X,
                  codeunit "GST Service Validations" = X,
                  codeunit "Service Transfer Post" = X,
                  codeunit "Validate Service Trans. Price" = X,
                  codeunit "GST Transfer Order Receipt" = X,
                  codeunit "GST Transfer Order Shipment" = X,
                  codeunit "GST Transfer Subscribers" = X,
                  codeunit "Validate Transfer Price" = X,
                  codeunit "Apply Delivery Challan Mgt." = X,
                  codeunit "Subcontracting Confirm-Post" = X,
                  codeunit "Subcontracting Post" = X,
                  codeunit "Subcontracting Post Batch" = X,
                  codeunit "Subcontracting Post GST Liab." = X,
                  codeunit "Subcontracting Subscribers" = X,
                  codeunit "Subcontracting Validations" = X,
                  codeunit "Update Subcontract Details" = X;
}
