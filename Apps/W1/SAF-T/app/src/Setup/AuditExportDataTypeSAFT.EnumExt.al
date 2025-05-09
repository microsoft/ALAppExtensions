// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

enumextension 5282 "Audit Export Data Type SAF-T" extends "Audit File Export Data Type"
{
    value(5280; GeneralLedgerAccounts) { Caption = 'General Ledger Accounts'; }
    value(5281; Customers) { Caption = 'Customers'; }
    value(5282; Suppliers) { Caption = 'Suppliers'; }
    value(5283; TaxTable) { Caption = 'Tax Table'; }
    value(5284; UOMTable) { Caption = 'UOM Table'; }
    value(5285; AnalysisTypeTable) { Caption = 'Analysis Type Table'; }
    value(5286; MovementTypeTable) { Caption = 'Movement Type Table'; }
    value(5287; Products) { Caption = 'Products'; }
    value(5288; PhysicalStock) { Caption = 'Physical Stock'; }
    value(5289; Assets) { Caption = 'Assets'; }
    value(5290; GeneralLedgerEntries) { Caption = 'General Ledger Entries'; }
    value(5291; SalesInvoices) { Caption = 'Sales Invoices'; }
    value(5292; PurchaseInvoices) { Caption = 'Purchase Invoices'; }
    value(5293; Payments) { Caption = 'Payments'; }
    value(5294; MovementOfGoods) { Caption = 'Movement Of Goods'; }
    value(5295; AssetTransactions) { Caption = 'Asset Transactions'; }
}
