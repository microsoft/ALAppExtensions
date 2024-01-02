// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Finance.Currency;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Reporting;
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
using System.Environment;
using System.IO;
using System.Privacy;

codeunit 13624 "OIOUBL-Initialize"
{
    Subtype = Install;

    var
        OIOUBLTxt: Label 'OIOUBL', Locked = true;
        OIOUBLFormatDescriptionTxt: Label 'OIOUBL Format (Offentlig Information Online Universal Business Language)', Locked = true;
        OIOUBLProfileDescriptionTxt: Label 'OIOUBL Document Sending Profile', Locked = true;
        OIOUBLProfileCodeTxt: Label 'BILSIM', Locked = true;
        OIOUBLProfileIDTxt: Label 'Procurement-OrdSimR-BilSim-1.0', Locked = true;

    trigger OnInstallAppPerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if AppInfo.DataVersion() = Version.Create('0.0.0.0') then
            CODEUNIT.Run(CODEUNIT::"OIOUBL-MigrateToExtV2");

        CompanyInitialize();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    begin
        CreateElectronicProfiles();
        CreateProfileCode();
        CreateRegionCode('DK');
        ApplyEvaluationClassificationsForPrivacy();
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        IssuedFinChargeMemoLine: Record "Issued Fin. Charge Memo Line";
        ReminderHeader: Record "Reminder Header";
        ReminderLine: Record "Reminder Line";
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedReminderLine: Record "Issued Reminder Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        SalesHeaderArchive: Record "Sales Header Archive";
        SalesLineArchive: Record "Sales Line Archive";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceMgtSetup: Record "Service Mgt. Setup";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceInvoiceLine: Record "Service Invoice Line";
        PaymentTerms: Record "Payment Terms";
        Currency: Record Currency;
        CountryRegion: Record "Country/Region";
        Customer: Record Customer;
        ItemCharge: Record "Item Charge";
        Company: Record Company;
        RecordExportBuffer: Record "Record Export Buffer";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetFieldToPersonal(Database::"Finance Charge Memo Header", FinanceChargeMemoHeader.FieldNo("OIOUBL-Contact Phone No."));
        DataClassificationMgt.SetFieldToPersonal(Database::"Finance Charge Memo Header", FinanceChargeMemoHeader.FieldNo("OIOUBL-Contact Fax No."));
        DataClassificationMgt.SetFieldToPersonal(Database::"Finance Charge Memo Header", FinanceChargeMemoHeader.FieldNo("OIOUBL-Contact E-Mail"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Finance Charge Memo Header", FinanceChargeMemoHeader.FieldNo("OIOUBL-Contact Role"));
        DataClassificationMgt.SetFieldToNormal(Database::"Finance Charge Memo Header", FinanceChargeMemoHeader.FieldNo("OIOUBL-Account Code"));
        DataClassificationMgt.SetFieldToNormal(Database::"Finance Charge Memo Header", FinanceChargeMemoHeader.FieldNo("OIOUBL-GLN"));

        DataClassificationMgt.SetFieldToNormal(Database::"Finance Charge Memo Line", FinanceChargeMemoLine.FieldNo("OIOUBL-Account Code"));

        DataClassificationMgt.SetFieldToNormal(Database::"Issued Fin. Charge Memo Header", IssuedFinChargeMemoHeader.FieldNo("OIOUBL-GLN"));
        DataClassificationMgt.SetFieldToNormal(Database::"Issued Fin. Charge Memo Header", IssuedFinChargeMemoHeader.FieldNo("OIOUBL-Account Code"));
        DataClassificationMgt.SetFieldToNormal(Database::"Issued Fin. Charge Memo Header", IssuedFinChargeMemoHeader.FieldNo("OIOUBL-Elec. Fin. Charge Memo Created"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Issued Fin. Charge Memo Header", IssuedFinChargeMemoHeader.FieldNo("OIOUBL-Contact Phone No."));
        DataClassificationMgt.SetFieldToPersonal(Database::"Issued Fin. Charge Memo Header", IssuedFinChargeMemoHeader.FieldNo("OIOUBL-Contact Fax No."));
        DataClassificationMgt.SetFieldToPersonal(Database::"Issued Fin. Charge Memo Header", IssuedFinChargeMemoHeader.FieldNo("OIOUBL-Contact E-Mail"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Issued Fin. Charge Memo Header", IssuedFinChargeMemoHeader.FieldNo("OIOUBL-Contact Role"));

        DataClassificationMgt.SetFieldToNormal(Database::"Issued Fin. Charge Memo Line", IssuedFinChargeMemoLine.FieldNo("OIOUBL-Account Code"));

        DataClassificationMgt.SetFieldToNormal(Database::"Reminder Header", ReminderHeader.FieldNo("OIOUBL-GLN"));
        DataClassificationMgt.SetFieldToNormal(Database::"Reminder Header", ReminderHeader.FieldNo("OIOUBL-Account Code"));

        DataClassificationMgt.SetFieldToNormal(Database::"Reminder Line", ReminderLine.FieldNo("OIOUBL-Account Code"));

        DataClassificationMgt.SetFieldToNormal(Database::"Issued Reminder Header", IssuedReminderHeader.FieldNo("OIOUBL-GLN"));
        DataClassificationMgt.SetFieldToNormal(Database::"Issued Reminder Header", IssuedReminderHeader.FieldNo("OIOUBL-Account Code"));
        DataClassificationMgt.SetFieldToNormal(Database::"Issued Reminder Header", IssuedReminderHeader.FieldNo("OIOUBL-Electronic Reminder Created"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Issued Reminder Header", IssuedReminderHeader.FieldNo("OIOUBL-Contact Phone No."));
        DataClassificationMgt.SetFieldToPersonal(Database::"Issued Reminder Header", IssuedReminderHeader.FieldNo("OIOUBL-Contact Fax No."));
        DataClassificationMgt.SetFieldToPersonal(Database::"Issued Reminder Header", IssuedReminderHeader.FieldNo("OIOUBL-Contact E-Mail"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Issued Reminder Header", IssuedReminderHeader.FieldNo("OIOUBL-Contact Role"));

        DataClassificationMgt.SetFieldToNormal(Database::"Issued Reminder Line", IssuedReminderLine.FieldNo("OIOUBL-Account Code"));

        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.FieldNo("OIOUBL-GLN"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.FieldNo("OIOUBL-Account Code"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.FieldNo("OIOUBL-Electronic Credit Memo Created"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.FieldNo("OIOUBL-Sell-to Contact Phone No."));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.FieldNo("OIOUBL-Sell-to Contact Fax No."));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.FieldNo("OIOUBL-Sell-to Contact E-Mail"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.FieldNo("OIOUBL-Sell-to Contact Role"));

        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Line", SalesCrMemoLine.FieldNo("OIOUBL-Account Code"));

        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header", SalesHeader.FieldNo("OIOUBL-GLN"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header", SalesHeader.FieldNo("OIOUBL-Account Code"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header", SalesHeader.FieldNo("OIOUBL-Profile Code"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales Header", SalesHeader.FieldNo("OIOUBL-Sell-to Contact Phone No."));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales Header", SalesHeader.FieldNo("OIOUBL-Sell-to Contact Fax No."));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales Header", SalesHeader.FieldNo("OIOUBL-Sell-to Contact E-Mail"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales Header", SalesHeader.FieldNo("OIOUBL-Sell-to Contact Role"));

        DataClassificationMgt.SetFieldToNormal(Database::"Sales Line", SalesLine.FieldNo("OIOUBL-Account Code"));

        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("OIOUBL-GLN"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("OIOUBL-Account Code"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("OIOUBL-Profile Code"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("OIOUBL-Electronic Invoice Created"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("OIOUBL-Sell-to Contact Phone No."));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("OIOUBL-Sell-to Contact Fax No."));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("OIOUBL-Sell-to Contact E-Mail"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("OIOUBL-Sell-to Contact Role"));

        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Line", SalesInvoiceLine.FieldNo("OIOUBL-Account Code"));

        DataClassificationMgt.SetFieldToPersonal(Database::"Sales & Receivables Setup", SalesReceivablesSetup.FieldNo("OIOUBL-Invoice Path"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales & Receivables Setup", SalesReceivablesSetup.FieldNo("OIOUBL-Cr. Memo Path"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales & Receivables Setup", SalesReceivablesSetup.FieldNo("OIOUBL-Reminder Path"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales & Receivables Setup", SalesReceivablesSetup.FieldNo("OIOUBL-Fin. Chrg. Memo Path"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales & Receivables Setup", SalesReceivablesSetup.FieldNo("OIOUBL-Default Profile Code"));

        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header Archive", SalesHeaderArchive.FieldNo("OIOUBL-GLN"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header Archive", SalesHeaderArchive.FieldNo("OIOUBL-Account Code"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales Header Archive", SalesHeaderArchive.FieldNo("OIOUBL-Sell-to Contact Phone No."));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales Header Archive", SalesHeaderArchive.FieldNo("OIOUBL-Sell-to Contact Fax No."));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales Header Archive", SalesHeaderArchive.FieldNo("OIOUBL-Sell-to Contact E-Mail"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales Header Archive", SalesHeaderArchive.FieldNo("OIOUBL-Sell-to Contact Role"));

        DataClassificationMgt.SetFieldToNormal(Database::"Sales Line Archive", SalesLineArchive.FieldNo("OIOUBL-Account Code"));

        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Header", ServiceCrMemoHeader.FieldNo("OIOUBL-GLN"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Header", ServiceCrMemoHeader.FieldNo("OIOUBL-Account Code"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Header", ServiceCrMemoHeader.FieldNo("OIOUBL-Electronic Credit Memo Created"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Header", ServiceCrMemoHeader.FieldNo("OIOUBL-Profile Code"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Service Cr.Memo Header", ServiceCrMemoHeader.FieldNo("OIOUBL-Contact Role"));

        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Line", ServiceCrMemoLine.FieldNo("OIOUBL-Account Code"));

        DataClassificationMgt.SetFieldToNormal(Database::"Service Header", ServiceHeader.FieldNo("OIOUBL-GLN"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Header", ServiceHeader.FieldNo("OIOUBL-Account Code"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Header", ServiceHeader.FieldNo("OIOUBL-Profile Code"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Service Header", ServiceHeader.FieldNo("OIOUBL-Contact Role"));

        DataClassificationMgt.SetFieldToNormal(Database::"Service Line", ServiceLine.FieldNo("OIOUBL-Account Code"));

        DataClassificationMgt.SetFieldToPersonal(Database::"Service Mgt. Setup", ServiceMgtSetup.FieldNo("OIOUBL-Service Invoice Path"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Service Mgt. Setup", ServiceMgtSetup.FieldNo("OIOUBL-Service Cr. Memo Path"));

        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Header", ServiceInvoiceHeader.FieldNo("OIOUBL-GLN"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Header", ServiceInvoiceHeader.FieldNo("OIOUBL-Account Code"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Header", ServiceInvoiceHeader.FieldNo("OIOUBL-Profile Code"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Header", ServiceInvoiceHeader.FieldNo("OIOUBL-Electronic Invoice Created"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Service Invoice Header", ServiceInvoiceHeader.FieldNo("OIOUBL-Contact Role"));

        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Line", ServiceInvoiceLine.FieldNo("OIOUBL-Account Code"));

        DataClassificationMgt.SetFieldToNormal(Database::"Payment Terms", PaymentTerms.FieldNo("OIOUBL-Code"));

        DataClassificationMgt.SetFieldToNormal(Database::Currency, Currency.FieldNo("OIOUBL-Currency Code"));

        DataClassificationMgt.SetFieldToNormal(Database::"Country/Region", CountryRegion.FieldNo("OIOUBL-Country/Region Code"));

        DataClassificationMgt.SetFieldToNormal(Database::Customer, Customer.FieldNo("OIOUBL-Account Code"));
        DataClassificationMgt.SetFieldToNormal(Database::Customer, Customer.FieldNo("OIOUBL-Profile Code"));
        DataClassificationMgt.SetFieldToNormal(Database::Customer, Customer.FieldNo("OIOUBL-Profile Code Required"));

        DataClassificationMgt.SetFieldToNormal(Database::"Item Charge", ItemCharge.FieldNo("OIOUBL-Charge Category"));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"OIOUBL-Profile");

        DataClassificationMgt.SetFieldToPersonal(Database::"Record Export Buffer", RecordExportBuffer.FieldNo("OIOUBL-User ID"));
    end;

    local procedure CreateElectronicProfiles();
    var
        ElectronicDocumentFormat: Record "Electronic Document Format";
    begin
        ElectronicDocumentFormat.InsertElectronicFormat(
            OIOUBLTxt, OIOUBLFormatDescriptionTxt,
            CODEUNIT::"OIOUBL-Export Sales Invoice", 0, ElectronicDocumentFormat.Usage::"Sales Invoice");

        ElectronicDocumentFormat.InsertElectronicFormat(
            OIOUBLTxt, OIOUBLFormatDescriptionTxt,
            CODEUNIT::"OIOUBL-Export Sales Cr. Memo", 0, ElectronicDocumentFormat.Usage::"Sales Credit Memo");

        ElectronicDocumentFormat.InsertElectronicFormat(
            OIOUBLTxt, OIOUBLFormatDescriptionTxt,
            CODEUNIT::"OIOUBL-Check Sales Header", 0, ElectronicDocumentFormat.Usage::"Sales Validation");
    end;

    local procedure CreateDocumentSendingProfile();
    var
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        if DocumentSendingProfile.GET(OIOUBLTxt) then
            exit;

        DocumentSendingProfile.Validate(Code, OIOUBLTxt);
        DocumentSendingProfile.Validate(Description, OIOUBLProfileDescriptionTxt);
        DocumentSendingProfile.Validate(Disk, DocumentSendingProfile.Disk::"Electronic Document");
        DocumentSendingProfile.Validate("Disk Format", OIOUBLTxt);
        DocumentSendingProfile.Insert(true);
    end;

    local procedure CreateProfileCode()
    var
        OIOUBLProfile: Record "OIOUBL-Profile";
        SalesNReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        if OIOUBLProfile.Get(OIOUBLProfileCodeTxt) then
            exit;

        OIOUBLProfile.Init();
        OIOUBLProfile.Validate("OIOUBL-Code", OIOUBLProfileCodeTxt);
        OIOUBLProfile.Validate("OIOUBL-Profile ID", OIOUBLProfileIDTxt);
        OIOUBLProfile.Insert(true);

        if NOT SalesNReceivablesSetup.GET() then
            exit;
        SalesNReceivablesSetup.Validate("OIOUBL-Default Profile Code", OIOUBLProfileCodeTxt);
        SalesNReceivablesSetup.Modify();
    end;

    local procedure CreateRegionCode(Code: Code[10])
    var
        CountryRegion: Record "Country/Region";
    begin
        if not CountryRegion.GET(Code) then
            exit;

        if CountryRegion."OIOUBL-Country/Region Code" = Code then
            exit;

        CountryRegion.VALIDATE("OIOUBL-Country/Region Code", Code);
        CountryRegion.MODIFY();
    end;
}
