// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Reports;

using Microsoft.Sales.Setup;

codeunit 148003 "Report Layout - Local"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        isInitialized: Boolean;

    [Test]
    [HandlerFunctions('RHFixedAssetProfessionalTax')]
    [Scope('OnPrem')]
    procedure TestFixedAssetProfessionalTax()
    begin
        Initialize();
        Report.Run(Report::"Fixed Asset-Professional TaxFR");
    end;

    local procedure Initialize()
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Report Layout - Local");
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Report Layout - Local");

        // Setup logo to be printed by default
        SalesSetup.Validate("Logo Position on Documents", SalesSetup."Logo Position on Documents"::Center);
        SalesSetup.Modify(true);

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Report Layout - Local");
    end;

    local procedure FomatFileName(ReportCaption: Text) ReportFileName: Text
    begin
        ReportFileName := DelChr(ReportCaption, '=', '/') + '.pdf'
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure RHFixedAssetProfessionalTax(var FixedAssetProfessionalTax: TestRequestPage "Fixed Asset-Professional TaxFR")
    begin
        FixedAssetProfessionalTax.StartingDate.SetValue(WorkDate());
        FixedAssetProfessionalTax.EndDate.SetValue(CalcDate('<+10Y>', WorkDate()));
        FixedAssetProfessionalTax.SaveAsPdf(FomatFileName(FixedAssetProfessionalTax.Caption));
    end;
}