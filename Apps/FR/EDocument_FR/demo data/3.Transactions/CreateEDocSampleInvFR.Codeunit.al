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

codeunit 10912 "Create E-Doc Sample Inv. FR"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        EDocSamplePurchaseInvoice: Codeunit "E-Doc Sample Purchase Invoice";
        CreateVendor: Codeunit "Create Vendor";
        CreateEDocumentMasterData: Codeunit "Create E-Document Master Data";
        CreateJobItem: Codeunit "Create Job Item";
        CreateCommonUnitOfMeasure: Codeunit "Create Common Unit Of Measure";
        CreateDemoEDocsFR: Codeunit "Create Demo EDocs FR";
        CreateAllocationAccountFR: Codeunit "Create Allocation Account FR";

    trigger OnRun()
    var
        YearlyLicenstCostLbl: Label 'Yearly license cost mapped to a G/L account';
        BasicCoffeeEquipmentLbl: Label 'Basic coffee equipment mapped to vendor''s Item References';
        CoffeeBeansAndPartsLbl: Label 'Coffee beans and parts with shipping cost that needs human intervention';
    begin
        EDocSamplePurchaseInvoice.AddInvoice(CreateVendor.ExportFabrikam(), '108239', CoffeeBeansAndPartsLbl);
        EDocSamplePurchaseInvoice.AddLine(
            Enum::"Purchase Line Type"::Item, CreateEDocumentMasterData.WholeDecafBeansColombia(), '', 50, 180, '', CreateCommonUnitOfMeasure.Piece());
        EDocSamplePurchaseInvoice.AddLine(
            Enum::"Purchase Line Type"::Item, CreateJobItem.ItemConsumable(), '', 50, 65, '', CreateCommonUnitOfMeasure.Piece());
        EDocSamplePurchaseInvoice.AddLine(
            Enum::"Purchase Line Type"::" ", '', CreateDemoEDocsFR.GetShipmentDHLInvoiceDescription(), 1, 60, '', CreateCommonUnitOfMeasure.Piece());
        EDocSamplePurchaseInvoice.Generate();

        EDocSamplePurchaseInvoice.AddInvoice(CreateVendor.DomesticWorldImporter(), '108240', BasicCoffeeEquipmentLbl, 7970);
        EDocSamplePurchaseInvoice.AddLine(
            Enum::"Purchase Line Type"::Item, CreateEDocumentMasterData.SmartGrindHome(), '', 100, 299, '', CreateCommonUnitOfMeasure.Piece());
        EDocSamplePurchaseInvoice.AddLine(
            Enum::"Purchase Line Type"::Item, CreateEDocumentMasterData.PrecisionGrindHome(), '', 50, 199, '', CreateCommonUnitOfMeasure.Piece());
        EDocSamplePurchaseInvoice.Generate();

        EDocSamplePurchaseInvoice.AddInvoice(CreateVendor.EUGraphicDesign(), '108426', YearlyLicenstCostLbl);
        EDocSamplePurchaseInvoice.AddLine(
            Enum::"Purchase Line Type"::" ", '', CreateAllocationAccountFR.LicensesDescription(), 1, 5000, '', CreateCommonUnitOfMeasure.Piece());
        EDocSamplePurchaseInvoice.Generate();
    end;
}
