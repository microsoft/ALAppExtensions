#if not CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoData.Localization;

using Microsoft.DemoData.Common;
using Microsoft.DemoData.Finance;
using Microsoft.DemoData.Purchases;
using Microsoft.eServices.EDocument.DemoData;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.Purchases.Document;

codeunit 17213 "Create Demo EDocs NZ"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by Create E-Doc. Sample Invoices Codeunit';
    ObsoleteTag = '28.0';

    var
        ContosoInboundEDocument: Codeunit "Contoso Inbound E-Document";

    trigger OnRun()
    begin
        GenerateContosoInboundEDocuments();
    end;

    procedure GetShipmentDHLInvoiceDescription(): Text[100]
    var
        ShipmentDHLLbl: Label 'Shipment', MaxLength = 100;
    begin
        exit(ShipmentDHLLbl);
    end;

    procedure ITServicesDecember(): Text[100]
    var
        ITServicesDecemberLbl: Label 'IT Services Support period: December', MaxLength = 100;
    begin
        exit(ITServicesDecemberLbl);
    end;

    local procedure GenerateContosoInboundEDocuments()
    var
        CreateVendor: Codeunit "Create Vendor";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateCommonUnitOfMeasure: Codeunit "Create Common Unit of Measure";
        CreateAllocationAccount: Codeunit "Create Allocation Account";
        CreateDeferralTemplate: Codeunit "Create Deferral Template";
        EDocSamplePurchaseInvoice: Codeunit "E-Doc Sample Purchase Invoice";
        ITServicesJanuaryLbl: Label 'IT Services Support period: January', MaxLength = 100;
        ITServicesFebruaryLbl: Label 'IT Services Support period: February', MaxLength = 100;
        ITServicesMarchLbl: Label 'IT Services Support period: March', MaxLength = 100;
        ITServicesAprilLbl: Label 'IT Services Support period: April', MaxLength = 100;
        ITServicesMayLbl: Label 'IT Services Support period: May', MaxLength = 100;
        SavedWorkDate, SampleInvoiceDate : Date;
    begin
        SavedWorkDate := WorkDate();
        SampleInvoiceDate := EDocSamplePurchaseInvoice.GetSampleInvoicePostingDate();
        WorkDate(SampleInvoiceDate);
        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.EUGraphicDesign(), SampleInvoiceDate, '245');
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"Allocation Account", CreateAllocationAccount.Licenses(), '',
            6, 500, CreateDeferralTemplate.DeferralCode1Y(), '');
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), SampleInvoiceDate, '1419', 108);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateGLAccount.ConsultantServices(),
            ITServicesJanuaryLbl, 6, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), SampleInvoiceDate, '1425', 378);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateGLAccount.ConsultantServices(),
            ITServicesFebruaryLbl, 21, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), SampleInvoiceDate, '1437', 144);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateGLAccount.ConsultantServices(),
            ITServicesMarchLbl, 8, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), SampleInvoiceDate, '1456', 216);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateGLAccount.ConsultantServices(),
            ITServicesAprilLbl, 12, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), SampleInvoiceDate, '1479', 324);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateGLAccount.ConsultantServices(),
            ITServicesMayLbl, 18, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();

        ContosoInboundEDocument.AddEDocPurchaseHeader(CreateVendor.DomesticFirstUp(), SampleInvoiceDate, '1484', 180);
        ContosoInboundEDocument.AddEDocPurchaseLine(
            Enum::"Purchase Line Type"::"G/L Account", CreateGLAccount.ConsultantServices(),
            ITServicesDecember(), 10, 200, '', CreateCommonUnitOfMeasure.Hour());
        ContosoInboundEDocument.Generate();
        WorkDate(SavedWorkDate);
    end;

}
#endif
