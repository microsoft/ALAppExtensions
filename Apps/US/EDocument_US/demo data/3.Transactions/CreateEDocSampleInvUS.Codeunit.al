#if not CLEAN28
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

codeunit 11504 "Create E-Doc Sample Inv. US"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by Create E-Doc. Sample Invoices Codeunit';
    ObsoleteTag = '28.0';

    var
        EDocSamplePurchaseInvoice: Codeunit "E-Doc Sample Purchase Invoice";
        CreateVendor: Codeunit "Create Vendor";
        CreateEDocumentMasterData: Codeunit "Create E-Document Master Data";
        CreateJobItem: Codeunit "Create Job Item";
        CreateCommonUnitOfMeasure: Codeunit "Create Common Unit Of Measure";
        CreateDemoEDocsUS: Codeunit "Create Demo EDocs US";
        CreateAllocationAccount: Codeunit "Create Allocation Account";

    trigger OnRun()
    var
        YearlyLicenstCostLbl: Label 'Yearly license cost mapped to a G/L account';
        BasicCoffeeEquipmentLbl: Label 'Basic coffee equipment mapped to vendor''s Item References';
        CoffeeBeansAndPartsLbl: Label 'Coffee beans and parts with shipping cost that needs human intervention';
    begin
        EDocSamplePurchaseInvoice.AddInvoice(CreateVendor.ExportFabrikam(), '108925', CoffeeBeansAndPartsLbl);
        EDocSamplePurchaseInvoice.AddLine(
            Enum::"Purchase Line Type"::Item, CreateEDocumentMasterData.WholeDecafBeansColombia(), '', 50, 5, '', CreateCommonUnitOfMeasure.Piece());
        EDocSamplePurchaseInvoice.AddLine(
            Enum::"Purchase Line Type"::Item, CreateJobItem.ItemConsumable(), '', 50, 65, '', CreateCommonUnitOfMeasure.Piece());
        EDocSamplePurchaseInvoice.AddLine(
            Enum::"Purchase Line Type"::" ", '', CreateDemoEDocsUS.GetShipmentDHLInvoiceDescription(), 1, 60, '', CreateCommonUnitOfMeasure.Piece());
        EDocSamplePurchaseInvoice.Generate();

        EDocSamplePurchaseInvoice.AddInvoice(CreateVendor.DomesticWorldImporter(), '108426', BasicCoffeeEquipmentLbl);
        EDocSamplePurchaseInvoice.AddLine(
            Enum::"Purchase Line Type"::Item, CreateEDocumentMasterData.SmartGrindHome(), '', 100, 299, '', CreateCommonUnitOfMeasure.Piece());
        EDocSamplePurchaseInvoice.AddLine(
            Enum::"Purchase Line Type"::Item, CreateEDocumentMasterData.PrecisionGrindHome(), '', 50, 199, '', CreateCommonUnitOfMeasure.Piece());
        EDocSamplePurchaseInvoice.Generate();

        EDocSamplePurchaseInvoice.AddInvoice(CreateVendor.EUGraphicDesign(), '108427', YearlyLicenstCostLbl);
        EDocSamplePurchaseInvoice.AddLine(
            Enum::"Purchase Line Type"::" ", '', CreateAllocationAccount.LicensesDescription(), 6, 500, '', CreateCommonUnitOfMeasure.Piece());
        EDocSamplePurchaseInvoice.Generate();
    end;
}
#endif