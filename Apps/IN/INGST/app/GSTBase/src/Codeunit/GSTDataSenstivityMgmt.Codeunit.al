// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Application;
using Microsoft.Finance.GST.Distribution;
using Microsoft.Finance.GST.Payments;
using Microsoft.Finance.GST.Reconcilation;
using Microsoft.Finance.GST.ReturnSettlement;
using Microsoft.Finance.GST.ServicesTransfer;
using Microsoft.Finance.GST.StockTransfer;
using Microsoft.Finance.GST.Subcontracting;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.TaxBase;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Shipping;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Setup;
using Microsoft.Inventory.Transfer;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Purchases.Archive;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Archive;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
#if not CLEAN25
using Microsoft.Sales.Pricing;
#endif
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Setup;
using Microsoft.Service.Contract;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Service.Pricing;
using Microsoft.Service.Setup;
using Microsoft.Utilities;
using System.Privacy;

codeunit 18020 "GST Data Senstivity Mgmt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure OnAfterClassifyScriptSpecificTables()
    begin
        ClassifyTablesToNormal();
    end;

    local procedure ClassifyTablesToNormal()
    begin
        SetTableFieldsToNormal(Database::"GST Setup");
        SetTableFieldsToNormal(Database::"GST Application Buffer");
        SetTableFieldsToNormal(Database::"Detailed GST Entry Buffer");
        SetTableFieldsToNormal(Database::"Detailed GST Ledger Entry");
        SetTableFieldsToNormal(Database::"Detailed GST Ledger Entry Info");
        SetTableFieldsToNormal(Database::"E-Comm. Merchant");
        SetTableFieldsToNormal(Database::"GST Claim Setoff");
        SetTableFieldsToNormal(Database::"GST Group");
        SetTableFieldsToNormal(Database::"GST Ledger Entry");
        SetTableFieldsToNormal(Database::"GST Posting Buffer");
        SetTableFieldsToNormal(Database::"GST Posting Setup");
        SetTableFieldsToNormal(Database::"GST Registration Nos.");
        SetTableFieldsToNormal(Database::"HSN/SAC");
        SetTableFieldsToNormal(Database::"Reference Invoice No.");
        SetTableFieldsToNormal(Database::"Retrun & Reco. Components");
        SetTableFieldsToNormal(Database::"Transfer Buffer");
        SetTableFieldsToNormal(Database::"Bank Account");
        SetTableFieldsToNormal(Database::"Company Information");
        SetTableFieldsToNormal(Database::Customer);
        SetTableFieldsToNormal(Database::"Fixed Asset");
        SetTableFieldsToNormal(Database::"General Ledger Setup");
        SetTableFieldsToNormal(Database::"Gen. Journal Line");
        SetTableFieldsToNormal(Database::"G/L Account");
        SetTableFieldsToNormal(Database::"Inventory Setup");
        SetTableFieldsToNormal(Database::"Item Charge");
        SetTableFieldsToNormal(Database::"Item Templ.");
        SetTableFieldsToNormal(Database::Item);
        SetTableFieldsToNormal(Database::Location);
        SetTableFieldsToNormal(Database::"Sales & Receivables Setup");
        SetTableFieldsToNormal(Database::Resource);
        SetTableFieldsToNormal(Database::"Service Cost");
        SetTableFieldsToNormal(Database::"Source Code Setup");
        SetTableFieldsToNormal(Database::State);
        SetTableFieldsToNormal(Database::"Tax Accounting Period");
        SetTableFieldsToNormal(Database::"Detailed GST Dist. Entry");
        SetTableFieldsToNormal(Database::"Dist. Component Amount");
        SetTableFieldsToNormal(Database::"GST Component Distribution");
        SetTableFieldsToNormal(Database::"GST Distribution Header");
        SetTableFieldsToNormal(Database::"GST Distribution Line");
        SetTableFieldsToNormal(Database::"GST Payment Buffer");
        SetTableFieldsToNormal(Database::"ISD Ledger");
        SetTableFieldsToNormal(Database::"Posted GST Distribution Header");
        SetTableFieldsToNormal(Database::"Posted GST Distribution Line");
        SetTableFieldsToNormal(Database::"Posted Settlement Entries");
        SetTableFieldsToNormal(Database::"Bank Charge");
        SetTableFieldsToNormal(Database::"Bank Charge Deemed Value Setup");
        SetTableFieldsToNormal(Database::"GST TDS/TCS Entry");
        SetTableFieldsToNormal(Database::"Journal Bank Charges");
        SetTableFieldsToNormal(Database::"Posted Jnl. Bank Charges");
        SetTableFieldsToNormal(Database::"Bank Account Posting Group");
        SetTableFieldsToNormal(Database::"Order Address");
        SetTableFieldsToNormal(Database::Party);
        SetTableFieldsToNormal(Database::"Purchase Header");
        SetTableFieldsToNormal(Database::"Purchase Line");
        SetTableFieldsToNormal(Database::"Purchases & Payables Setup");
        SetTableFieldsToNormal(Database::"Purch. Cr. Memo Hdr.");
        SetTableFieldsToNormal(Database::"Purch. Cr. Memo Line");
        SetTableFieldsToNormal(Database::"Purchase Header Archive");
        SetTableFieldsToNormal(Database::"Purch. Inv. Header");
        SetTableFieldsToNormal(Database::"Purch. Inv. Line");
        SetTableFieldsToNormal(Database::"Purch. Rcpt. Header");
        SetTableFieldsToNormal(Database::"Purch. Rcpt. Line");
        SetTableFieldsToNormal(Database::Vendor);
        SetTableFieldsToNormal(Database::"Vendor Ledger Entry");
        SetTableFieldsToNormal(Database::"GST Reconcilation");
        SetTableFieldsToNormal(Database::"GST Reconcilation Line");
        SetTableFieldsToNormal(Database::"GST Recon. Mapping");
        SetTableFieldsToNormal(Database::"Periodic GSTR-2A Data");
        SetTableFieldsToNormal(Database::"Posted GST Reconciliation");
        SetTableFieldsToNormal(Database::"Detailed Cr. Adjstmnt. Entry");
        SetTableFieldsToNormal(Database::"GST Credit Adjustment Journal");
        SetTableFieldsToNormal(Database::"GST Liability Adjustment");
        SetTableFieldsToNormal(Database::"GST Liability Buffer");
        SetTableFieldsToNormal(Database::"GST Payment Buffer Details");
        SetTableFieldsToNormal(Database::"Posted GST Liability Adj.");
        SetTableFieldsToNormal(Database::"Cust. Ledger Entry");
        SetTableFieldsToNormal(Database::"Sales Cr.Memo Header");
        SetTableFieldsToNormal(Database::"Sales Cr.Memo Line");
        SetTableFieldsToNormal(Database::"Sales Header Archive");
        SetTableFieldsToNormal(Database::"Sales Line Archive");
        SetTableFieldsToNormal(Database::"Sales Header");
        SetTableFieldsToNormal(Database::"Sales Invoice Line");
        SetTableFieldsToNormal(Database::"Sales Line");
#if not CLEAN25
        SetTableFieldsToNormal(Database::"Sales Price");
#endif
        SetTableFieldsToNormal(Database::"Sales Shipment Header");
        SetTableFieldsToNormal(Database::"Sales Shipment Line");
        SetTableFieldsToNormal(Database::"Shipping Agent");
        SetTableFieldsToNormal(Database::"Ship-to Address");
        SetTableFieldsToNormal(Database::"Service Contract Header");
        SetTableFieldsToNormal(Database::"Service Cr.Memo Header");
        SetTableFieldsToNormal(Database::"Service Cr.Memo Line");
        SetTableFieldsToNormal(Database::"Service Header");
        SetTableFieldsToNormal(Database::"Service Invoice Header");
        SetTableFieldsToNormal(Database::"Service Invoice Line");
        SetTableFieldsToNormal(Database::"Service Line");
        SetTableFieldsToNormal(Database::"Service Mgt. Setup");
        SetTableFieldsToNormal(Database::"Service Shipment Header");
        SetTableFieldsToNormal(Database::"Service Shipment Line");
        SetTableFieldsToNormal(Database::"Service Transfer Header");
        SetTableFieldsToNormal(Database::"Service Transfer Line");
        SetTableFieldsToNormal(Database::"Service Transfer Rcpt. Header");
        SetTableFieldsToNormal(Database::"Service Transfer Rcpt. Line");
        SetTableFieldsToNormal(Database::"Service Transfer Shpt. Header");
        SetTableFieldsToNormal(Database::"Service Transfer Shpt. Line");
        SetTableFieldsToNormal(Database::"GST Tracking Entry");
        SetTableFieldsToNormal(Database::"Inventory Posting Setup");
        SetTableFieldsToNormal(Database::"Transfer Header");
        SetTableFieldsToNormal(Database::"Transfer Shipment Header");
        SetTableFieldsToNormal(Database::"Transfer Receipt Line");
        SetTableFieldsToNormal(Database::"Transfer Line");
        SetTableFieldsToNormal(Database::"Transfer Shipment Line");
        SetTableFieldsToNormal(Database::"Transfer Receipt Header");
        SetTableFieldsToNormal(Database::"Applied Delivery Challan Entry");
        SetTableFieldsToNormal(Database::"Delivery Challan Header");
        SetTableFieldsToNormal(Database::"Applied Delivery Challan");
        SetTableFieldsToNormal(Database::"Delivery Challan Line");
        SetTableFieldsToNormal(Database::"GST Liability Line");
        SetTableFieldsToNormal(Database::"Posted GST Liability Line");
        SetTableFieldsToNormal(Database::"Sub. Comp. Rcpt. Header");
        SetTableFieldsToNormal(Database::"Sub. Comp. Rcpt. Line");
        SetTableFieldsToNormal(Database::"Dist. Component Amount");
        SetTableFieldsToNormal(Database::"ISD Ledger");
        SetTableFieldsToNormal(Database::"Posted GST Distribution Header");
        SetTableFieldsToNormal(Database::"Posted GST Distribution Line");
        SetTableFieldsToNormal(Database::"Posted Settlement Entries");
        SetTableFieldsToNormal(Database::"GST TDS/TCS Entry");
        SetTableFieldsToNormal(Database::"Posted Jnl. Bank Charges");
        SetTableFieldsToNormal(Database::"Detailed GST Ledger Entry Info");
        SetTableFieldsToNormal(Database::"General Ledger Setup");
        SetTableFieldsToNormal(Database::"Sales Cr.Memo Header");
        SetTableFieldsToNormal(Database::"Sales Invoice Header");
        SetTableFieldsToNormal(Database::"Purchase Line Archive");
        SetTableFieldsToNormal(Database::"GST Journal Template");
        SetTableFieldsToNormal(Database::"GST Journal Batch");
        SetTableFieldsToNormal(Database::"GST Journal Line");
        SetTableFieldsToNormal(Database::"GST Adjustment Buffer");
        SetTableFieldsToNormal(Database::"Invoice Posting Buffer");
    end;

    local procedure SetTableFieldsToNormal(TableNo: Integer)
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);
    end;
}
