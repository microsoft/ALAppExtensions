// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Finance.Currency;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Archive;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.History;
using Microsoft.Sales.Reminder;
using Microsoft.Sales.Setup;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Service.Setup;

codeunit 13623 "OIOUBL-MigrateToExtV2"
{
    Subtype = Install;

    trigger OnRun();
    begin
        if InitializeDone() then
            exit;

        MoveTablePaymentTerms();
        MoveTableCurrency();
        MoveTableCountryRegion();
        MoveTableCustomer();
        MoveTableSalesHeader();
        MoveTableSalesLine();
        MoveTableSalesInvoiceHeader();
        MoveTableSalesInvoiceLine();
        MoveTableSalesCrMemoHeader();
        MoveTableSalesCrMemoLine();
        MoveTableReminderHeader();
        MoveTableReminderLine();
        MoveTableIssuedReminderHeader();
        MoveTableIssuedReminderLine();
        MoveTableFinanceChargeMemoHeader();
        MoveTableFinanceChargeMemoLine();
        MoveTableIssuedFinanceChargeMemoHeader();
        MoveTableIssuedFinanceChargeMemoLine();
        MoveTableSalesAndReceivablesSetup();
        MoveTableSalesHeaderArchive();
        MoveTableSalesLineArchive();
        MoveTableItemCharge();
        MoveTableServiceHeader();
        MoveTableServiceLine();
        MoveTableServiceMgtSetup();
        MoveTableServiceCrMemoHeader();
        MoveTableServiceCrMemoLine();
        MoveTableOIOUBLProfile();
    end;

    local procedure InitializeDone(): boolean
    var
        OIOUBLProfile: Record "OIOUBL-Profile";
    begin
        exit(NOT OIOUBLProfile.IsEmpty());
    end;

    local procedure MoveTablePaymentTerms();
    var
        PaymentTerms: Record "Payment Terms";
    begin
        with PaymentTerms do
            if FindSet() then
                repeat
                    "OIOUBL-Code" := "OIOUBL Code";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableCurrency();
    var
        Currency: Record Currency;
    begin
        with Currency do
            if FindSet() then
                repeat
                    "OIOUBL-Currency Code" := "OIOUBL Currency Code";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableCountryRegion();
    var
        CountryRegion: Record "Country/Region";
    begin
        with CountryRegion do
            if FindSet() then
                repeat
                    "OIOUBL-Country/Region Code" := "OIOUBL Country/Region Code";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableCustomer();
    var
        Customer: Record Customer;
    begin
        with Customer do
            if FindSet() then
                repeat
                    "OIOUBL-Account Code" := "Account Code";
                    "OIOUBL-Profile Code" := "OIOUBL Profile Code";
                    "OIOUBL-Profile Code Required" := "OIOUBL Profile Code Required";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableSalesHeader();
    var
        SalesHeader: Record "Sales Header";
    begin
        with SalesHeader do
            if FindSet() then
                repeat
                    "OIOUBL-GLN" := "EAN No.";
                    "OIOUBL-Account Code" := "Account Code";
                    "OIOUBL-Profile Code" := "OIOUBL Profile Code";
                    "OIOUBL-Sell-to Contact Phone No." := "Sell-to Contact Phone No.";
                    "OIOUBL-Sell-to Contact Fax No." := "Sell-to Contact Fax No.";
                    "OIOUBL-Sell-to Contact E-Mail" := "Sell-to Contact E-Mail";
                    "OIOUBL-Sell-to Contact Role" := "Sell-to Contact Role";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableSalesLine();
    var
        SalesLine: Record "Sales Line";
    begin
        with SalesLine do
            if FindSet() then
                repeat
                    "OIOUBL-Account Code" := "Account Code";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableSalesInvoiceHeader();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        with SalesInvoiceHeader do
            if FindSet() then
                repeat
                    "OIOUBL-GLN" := "EAN No.";
                    "OIOUBL-Account Code" := "Account Code";
                    "OIOUBL-Profile Code" := "OIOUBL Profile Code";
                    "OIOUBL-Sell-to Contact Phone No." := "Sell-to Contact Phone No.";
                    "OIOUBL-Sell-to Contact Fax No." := "Sell-to Contact Fax No.";
                    "OIOUBL-Sell-to Contact E-Mail" := "Sell-to Contact E-Mail";
                    "OIOUBL-Sell-to Contact Role" := "Sell-to Contact Role";
                    "OIOUBL-Electronic Invoice Created" := "Electronic Invoice Created";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableSalesInvoiceLine();
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        with SalesInvoiceLine do
            if FindSet() then
                repeat
                    "OIOUBL-Account Code" := "Account Code";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableSalesCrMemoHeader();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        with SalesCrMemoHeader do
            if FindSet() then
                repeat
                    "OIOUBL-GLN" := "EAN No.";
                    "OIOUBL-Account Code" := "Account Code";
                    "OIOUBL-Profile Code" := "OIOUBL Profile Code";
                    "OIOUBL-Sell-to Contact Phone No." := "Sell-to Contact Phone No.";
                    "OIOUBL-Sell-to Contact Fax No." := "Sell-to Contact Fax No.";
                    "OIOUBL-Sell-to Contact E-Mail" := "Sell-to Contact E-Mail";
                    "OIOUBL-Sell-to Contact Role" := "Sell-to Contact Role";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableSalesCrMemoLine();
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        with SalesCrMemoLine do
            if FindSet() then
                repeat
                    "OIOUBL-Account Code" := "Account Code";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableReminderHeader();
    var
        ReminderHeader: Record "Reminder Header";
    begin
        with ReminderHeader do
            if FindSet() then
                repeat
                    "OIOUBL-GLN" := "EAN No.";
                    "OIOUBL-Account Code" := "Account Code";
                    "OIOUBL-Contact Phone No." := "Contact Phone No.";
                    "OIOUBL-Contact Fax No." := "Contact Fax No.";
                    "OIOUBL-Contact E-Mail" := "Contact E-Mail";
                    "OIOUBL-Contact Role" := "Contact Role";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableReminderLine();
    var
        ReminderLine: Record "Reminder Line";
    begin
        with ReminderLine do
            if FindSet() then
                repeat
                    "OIOUBL-Account Code" := "Account Code";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableIssuedReminderHeader();
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
    begin
        with IssuedReminderHeader do
            if FindSet() then
                repeat
                    "OIOUBL-GLN" := "EAN No.";
                    "OIOUBL-Account Code" := "Account Code";
                    "OIOUBL-Electronic Reminder Created" := "Electronic Reminder Created";
                    "OIOUBL-Contact Phone No." := "Contact Phone No.";
                    "OIOUBL-Contact Fax No." := "Contact Fax No.";
                    "OIOUBL-Contact E-Mail" := "Contact E-Mail";
                    "OIOUBL-Contact Role" := "Contact Role";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableIssuedReminderLine();
    var
        IssuedReminderLine: Record "Issued Reminder Line";
    begin
        with IssuedReminderLine do
            if FindSet() then
                repeat
                    "OIOUBL-Account Code" := "Account Code";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableFinanceChargeMemoHeader();
    var
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
    begin
        with FinanceChargeMemoHeader do
            if FindSet() then
                repeat
                    "OIOUBL-GLN" := "EAN No.";
                    "OIOUBL-Account Code" := "Account Code";
                    "OIOUBL-Contact Phone No." := "Contact Phone No.";
                    "OIOUBL-Contact Fax No." := "Contact Fax No.";
                    "OIOUBL-Contact E-Mail" := "Contact E-Mail";
                    "OIOUBL-Contact Role" := "Contact Role";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableFinanceChargeMemoLine();
    var
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
    begin
        with FinanceChargeMemoLine do
            if FindSet() then
                repeat
                    "OIOUBL-Account Code" := "Account Code";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableIssuedFinanceChargeMemoHeader();
    var
        IssuedFinanceChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
    begin
        with IssuedFinanceChargeMemoHeader do
            if FindSet() then
                repeat
                    "OIOUBL-GLN" := "EAN No.";
                    "OIOUBL-Account Code" := "Account Code";
                    "OIOUBL-Contact Phone No." := "Contact Phone No.";
                    "OIOUBL-Contact Fax No." := "Contact Fax No.";
                    "OIOUBL-Contact E-Mail" := "Contact E-Mail";
                    "OIOUBL-Contact Role" := "Contact Role";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableIssuedFinanceChargeMemoLine();
    var
        IssuedFinanceChargeMemoLine: Record "Issued Fin. Charge Memo Line";
    begin
        with IssuedFinanceChargeMemoLine do
            if FindSet() then
                repeat
                    "OIOUBL-Account Code" := "Account Code";
                    Modify(true);
                until Next() = 0;
    end;


    local procedure MoveTableSalesAndReceivablesSetup();
    var
        SalesAndReceivableSetup: Record "Sales & Receivables Setup";
    begin
        with SalesAndReceivableSetup do
            if FindSet() then
                repeat
                    "OIOUBL-Invoice Path" := "OIOUBL Invoice Path";
                    "OIOUBL-Cr. Memo Path" := "OIOUBL Cr. Memo Path";
                    "OIOUBL-Reminder Path" := "OIOUBL Reminder Path";
                    "OIOUBL-Fin. Chrg. Memo Path" := "OIOUBL Fin. Chrg. Memo Path";
                    "OIOUBL-Default Profile Code" := "Default OIOUBL Profile Code";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableSalesHeaderArchive();
    var
        SalesHeaderArchive: Record "Sales Header Archive";
    begin
        with SalesHeaderArchive do
            if FindSet() then
                repeat
                    "OIOUBL-GLN" := "EAN No.";
                    "OIOUBL-Account Code" := "Account Code";
                    "OIOUBL-Sell-to Contact Phone No." := "Sell-to Contact Phone No.";
                    "OIOUBL-Sell-to Contact Fax No." := "Sell-to Contact Fax No.";
                    "OIOUBL-Sell-to Contact E-Mail" := "Sell-to Contact E-Mail";
                    "OIOUBL-Sell-to Contact Role" := "Sell-to Contact Role";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableSalesLineArchive();
    var
        SalesLineArchive: Record "Sales Line Archive";
    begin
        with SalesLineArchive do
            if FindSet() then
                repeat
                    "OIOUBL-Account Code" := "Account Code";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableItemCharge();
    var
        ItemCharge: Record "Item Charge";
    begin
        with ItemCharge do
            if FindSet() then
                repeat
                    "OIOUBL-Charge Category" := "Charge Category";
                    Modify(true);
                until Next() = 0;
    end;


    local procedure MoveTableServiceHeader();
    var
        ServiceHeader: Record "Service Header";
    begin
        with ServiceHeader do
            if FindSet() then
                repeat
                    "OIOUBL-GLN" := "EAN No.";
                    "OIOUBL-Account Code" := "Account Code";
                    "OIOUBL-Contact Role" := "Contact Role";
                    "OIOUBL-Profile Code" := "OIOUBL Profile Code";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableServiceLine();
    var
        ServiceLine: Record "Service Line";
    begin
        with ServiceLine do
            if FindSet() then
                repeat
                    "OIOUBL-Account Code" := "Account Code";
                    Modify(false);
                until Next() = 0;
    end;

    local procedure MoveTableServiceMgtSetup();
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
    begin
        with ServiceMgtSetup do
            if FindSet() then
                repeat
                    "OIOUBL-Service Invoice Path" := "OIOUBL Service Invoice Path";
                    "OIOUBL-Service Cr. Memo Path" := "OIOUBL Service Cr. Memo Path";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableServiceCrMemoHeader();
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
    begin
        with ServiceCrMemoHeader do
            if FindSet() then
                repeat
                    "OIOUBL-GLN" := "EAN No.";
                    "OIOUBL-Account Code" := "Account Code";
                    "OIOUBL-Contact Role" := "Contact Role";
                    "OIOUBL-Electronic Credit Memo Created" := "Electronic Credit Memo Created";
                    "OIOUBL-Profile Code" := "OIOUBL Profile Code";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableServiceCrMemoLine();
    var
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
    begin
        with ServiceCrMemoLine do
            if FindSet() then
                repeat
                    "OIOUBL-Account Code" := "Account Code";
                    Modify(true);
                until Next() = 0;
    end;

    local procedure MoveTableOIOUBLProfile();
    var
        OIOUBLProfileNew: Record "OIOUBL-Profile";
        OIOUBLProfileOld: Record "OIOUBL Profile";
    begin
        if OIOUBLProfileOld.FindSet() then
            repeat
                OIOUBLProfileNew.Init();
                OIOUBLProfileNew.Validate("OIOUBL-Code", OIOUBLProfileOld.Code);
                OIOUBLProfileNew.Validate("OIOUBL-Profile ID", OIOUBLProfileOld."Profile ID");
                OIOUBLProfileNew.Insert(true);
            until OIOUBLProfileOld.Next() = 0;
    end;
}
