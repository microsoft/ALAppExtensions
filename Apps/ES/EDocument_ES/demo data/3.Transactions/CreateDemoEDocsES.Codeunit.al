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

codeunit 10886 "Create Demo EDocs ES"
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
        CreateESGLAccounts: Codeunit "Create ES GL Accounts";
        CreateCommonUnitOfMeasure: Codeunit "Create Common Unit Of Measure";
        CreateEDocumentMasterData: Codeunit "Create E-Document Master Data";
        CreateJobItem: Codeunit "Create Job Item";
        CreateAllocationAccountES: Codeunit "Create Allocation Account ES";
        CreateDeferralTemplate: Codeunit "Create Deferral Template";
        EDocSamplePurchaseInvoice: Codeunit "E-Doc Sample Purchase Invoice";
        AccountingServicesJanuaryLbl: Label 'Accounting support period: January', MaxLength = 100;
        AccountingServicesFebruaryLbl: Label 'Accounting support period: February', MaxLength = 100;
        AccountingServicesMarchLbl: Label 'Accounting support period: March', MaxLength = 100;
        AccountingServicesDecemberLbl: Label 'Accounting support period: December', MaxLength = 100;
        AccountingServicesMayLbl: Label 'Accounting support period: May', MaxLength = 100;
    begin
        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.EUGraphicDesign(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '245');
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"Allocation Account", CreateAllocationAccountES.Licenses(),
            CreateAllocationAccountES.LicensesDescription(), 6, 500, CreateDeferralTemplate.DeferralCode1Y(), '');
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '1419', 252);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateESGLAccounts.ProfessionalAdvisoryServices(),
            AccountingServicesJanuaryLbl, 6, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '1425', 798);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateESGLAccounts.ProfessionalAdvisoryServices(),
            AccountingServicesFebruaryLbl, 19, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '1437', 84);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateESGLAccounts.ProfessionalAdvisoryServices(),
            AccountingServicesMarchLbl, 2, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '1479', 672);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateESGLAccounts.ProfessionalAdvisoryServices(),
            AccountingServicesMayLbl, 16, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '1456', 294);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateESGLAccounts.ProfessionalAdvisoryServices(),
            AccountingServicesDecemberLbl, 7, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.ExportFabrikam(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), 'F12938');
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::Item, CreateEDocumentMasterData.WholeDecafBeansColombia(),
            '', 50, 5, '', CreateCommonUnitOfMeasure.Piece());
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::Item, CreateJobItem.ItemConsumable(),
            '', 50, 65, '', CreateCommonUnitOfMeasure.Piece());
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateESGLAccounts.Transportation(),
            GetShipmentDHLInvoiceDescription(), 1, 60, '', '');
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticWorldImporter(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '000982', 8368.5);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::Item, CreateEDocumentMasterData.SmartGrindHome(),
            '', 100, 299, '', CreateCommonUnitOfMeasure.Piece());
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::Item, CreateEDocumentMasterData.PrecisionGrindHome(),
            '', 50, 199, '', CreateCommonUnitOfMeasure.Piece());
        ContosoInboundEDocument.Generate();
    end;

}
