// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoData.Localization;

using Microsoft.DemoData.Common;
using Microsoft.DemoData.Finance;
using Microsoft.DemoData.Jobs;
using Microsoft.DemoData.Purchases;
using Microsoft.eServices.EDocument.DemoData;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.Purchases.Document;

codeunit 11370 "Create Demo EDocs DE"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        ContosoInboundEDocument: Codeunit "Contoso Inbound E-Document";

    trigger OnRun()
    begin
        GenerateContosoInboundEDocuments();
    end;

    procedure GetShipmentDHLInvoiceDescription(): Text[100]
    var
        ShipmentDHLLbl: Label 'Shipment, DHL', MaxLength = 100;
    begin
        exit(ShipmentDHLLbl);
    end;

    local procedure GenerateContosoInboundEDocuments()
    var
        CreateVendor: Codeunit "Create Vendor";
        CreateGLAccDE: Codeunit "Create DE GL Acc.";
        CreateCommonUnitOfMeasure: Codeunit "Create Common Unit Of Measure";
        CreateEDocumentMasterData: Codeunit "Create E-Document Master Data";
        CreateJobItem: Codeunit "Create Job Item";
        CreateAllocationAccountDE: Codeunit "Create Allocation Account DE";
        CreateDeferralTemplate: Codeunit "Create Deferral Template";
        EDocSamplePurchaseInvoice: Codeunit "E-Doc Sample Purchase Invoice";
        AccountingServicesJanuaryLbl: Label 'Accounting support period: January', MaxLength = 100;
        AccountingServicesFebruaryLbl: Label 'Accounting support period: February', MaxLength = 100;
        AccountingServicesMarchLbl: Label 'Accounting support period: March', MaxLength = 100;
        AccountingServicesDecemberLbl: Label 'Accounting support period: December', MaxLength = 100;
        AccountingServicesMayLbl: Label 'Accounting support period: May', MaxLength = 100;
    begin
        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.EUGraphicDesign(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '245', 0);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"Allocation Account", CreateAllocationAccountDE.Licenses(),
            CreateAllocationAccountDE.LicensesDescription(), 6, 500, CreateDeferralTemplate.DeferralCode1Y(), '');
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '1419', 84);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateGLAccDE.LegalFeesandAttorneyServices(),
            AccountingServicesJanuaryLbl, 6, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '1425', 266);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateGLAccDE.LegalFeesandAttorneyServices(),
            AccountingServicesFebruaryLbl, 19, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '1437', 28);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateGLAccDE.LegalFeesandAttorneyServices(),
            AccountingServicesMarchLbl, 2, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '1479', 224);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateGLAccDE.LegalFeesandAttorneyServices(),
            AccountingServicesMayLbl, 16, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '1456', 98);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateGLAccDE.LegalFeesandAttorneyServices(),
            AccountingServicesDecemberLbl, 7, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.ExportFabrikam(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), 'F12938', 0);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::Item, CreateEDocumentMasterData.WholeDecafBeansColombia(),
            '', 50, 5, '', CreateCommonUnitOfMeasure.Piece());
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::Item, CreateJobItem.ItemConsumable(),
            '', 50, 65, '', CreateCommonUnitOfMeasure.Piece());
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateGLAccDE.Freightfeesforgoods(),
            GetShipmentDHLInvoiceDescription(), 1, 60, '', '');
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticWorldImporter(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '000982', 7571.5);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::Item, CreateEDocumentMasterData.SmartGrindHome(),
            '', 100, 299, '', CreateCommonUnitOfMeasure.Piece());
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::Item, CreateEDocumentMasterData.PrecisionGrindHome(),
            '', 50, 199, '', CreateCommonUnitOfMeasure.Piece());
        ContosoInboundEDocument.Generate();
    end;

}
