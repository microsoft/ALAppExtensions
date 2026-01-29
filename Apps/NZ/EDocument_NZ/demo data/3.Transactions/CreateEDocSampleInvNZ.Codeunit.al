// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoData.Localization;

using Microsoft.DemoData.Common;
using Microsoft.DemoData.Finance;
using Microsoft.DemoData.Purchases;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.Purchases.Document;

codeunit 17214 "Create E-Doc Sample Inv. NZ"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        EDocSamplePurchaseInvoice: Codeunit "E-Doc Sample Purchase Invoice";
        CreateVendor: Codeunit "Create Vendor";
        CreateCommonUnitOfMeasure: Codeunit "Create Common Unit of Measure";
        CreateDemoEDocsNZ: Codeunit "Create Demo EDocs NZ";
        CreateAllocationAccountNZ: Codeunit "Create Allocation Account NZ";

    trigger OnRun()
    var
        YearlyLicenstCostLbl: Label 'Yearly license cost mapped to a G/L account';
        MonthlyLicenseCostLbl: Label 'Monthly license cost mapped to a G/L account';
    begin
        EDocSamplePurchaseInvoice.AddInvoice(CreateVendor.DomesticFirstUp(), '108244', MonthlyLicenseCostLbl, 216);
        EDocSamplePurchaseInvoice.AddLine(
            Enum::"Purchase Line Type"::"G/L Account", '', CreateDemoEDocsNZ.ITServicesDecember(), 12, 200, '', CreateCommonUnitOfMeasure.Piece());
        EDocSamplePurchaseInvoice.Generate();

        EDocSamplePurchaseInvoice.AddInvoice(CreateVendor.EUGraphicDesign(), '108240', YearlyLicenstCostLbl);
        EDocSamplePurchaseInvoice.AddLine(
            Enum::"Purchase Line Type"::" ", '', CreateAllocationAccountNZ.LicensesDescription(), 1, 5000, '', CreateCommonUnitOfMeasure.Piece());
        EDocSamplePurchaseInvoice.Generate();
    end;
}
