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

codeunit 10558 "Create Demo EDocs GB"
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
        CreateGBGLAccounts: Codeunit "Create GB GL Accounts";
        CreateCommonUnitOfMeasure: Codeunit "Create Common Unit Of Measure";
        CreateEDocumentMasterData: Codeunit "Create E-Document Master Data";
        CreateJobItem: Codeunit "Create Job Item";
        CreateAllocationAccountGB: Codeunit "Create Allocation Account GB";
        CreateDeferralTemplate: Codeunit "Create Deferral Template";
        EDocSamplePurchaseInvoice: Codeunit "E-Doc Sample Purchase Invoice";
        ITServicesJanuaryLbl: Label 'IT support Support period: January', MaxLength = 100;
        ITServicesFebruaryLbl: Label 'IT support Support period: February', MaxLength = 100;
        ITServicesMarchLbl: Label 'IT support Support period: March', MaxLength = 100;
        ITServicesDecemberLbl: Label 'IT support Support period: December', MaxLength = 100;
        ITServicesMayLbl: Label 'IT support Support period: May', MaxLength = 100;
    begin
        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.EUGraphicDesign(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '245');
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"Allocation Account", CreateAllocationAccountGB.Licenses(), '',
            6, 500, CreateDeferralTemplate.DeferralCode1Y(), '');
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '1419', 60);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateGBGLAccounts.ITServices(),
            ITServicesJanuaryLbl, 6, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '1425', 190);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateGBGLAccounts.ITServices(),
            ITServicesFebruaryLbl, 19, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '1437', 20);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateGBGLAccounts.ITServices(),
            ITServicesMarchLbl, 2, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '1479', 90);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateGBGLAccounts.ITServices(),
            ITServicesMayLbl, 9, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '1456', 70);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateGBGLAccounts.ITServices(),
            ITServicesDecemberLbl, 7, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.ExportFabrikam(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), 'F12938');
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::Item, CreateEDocumentMasterData.WholeDecafBeansColombia(),
            '', 50, 5, '', CreateCommonUnitOfMeasure.Piece());
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::Item, CreateJobItem.ItemConsumable(),
            '', 50, 65, '', CreateCommonUnitOfMeasure.Piece());
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateGBGLAccounts.FreightFeesForGoods(),
            GetShipmentDHLInvoiceDescription(), 1, 60, '', '');
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticWorldImporter(), EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate(), '000982', 7970);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::Item, CreateEDocumentMasterData.SmartGrindHome(),
            '', 100, 299, '', CreateCommonUnitOfMeasure.Piece());
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::Item, CreateEDocumentMasterData.PrecisionGrindHome(),
            '', 50, 199, '', CreateCommonUnitOfMeasure.Piece());
        ContosoInboundEDocument.Generate();
    end;

}
