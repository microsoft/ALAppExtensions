// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

codeunit 47008 "SL Vendor 1099 Mapping Helpers"
{
    var
        APStringTxt: Label 'AP', Locked = true;
        StatusOpenTxt: Label 'O', Locked = true;

    procedure InsertSupportedTaxYear(TaxYear: Integer)
    var
        SLSupportedTaxYear: Record "SL Supported Tax Year";
    begin
        SLSupportedTaxYear."Tax Year" := TaxYear;
        SLSupportedTaxYear.Insert();
    end;

    procedure InsertMapping(TaxYear: Integer; SL1099DataValue: Text[2]; SL1099BoxNo: Text[3]; FormType: Text[4]; BCIRS1099Code: Code[10])
    var
        SL1099BoxMapping: Record "SL 1099 Box Mapping";
    begin
        SL1099BoxMapping."Tax Year" := TaxYear;
        SL1099BoxMapping."SL 1099 Box No." := SL1099BoxNo;
        SL1099BoxMapping."SL Data Value" := SL1099DataValue;
        SL1099BoxMapping."Form Type" := FormType;
        SL1099BoxMapping."BC IRS 1099 Code" := BCIRS1099Code;
        SL1099BoxMapping.Insert();
    end;

    procedure GetIRS1099BoxCode(TaxYear: Integer; SL1099DataValue: Text[2]): Code[10]
    var
        SL1099BoxMapping: Record "SL 1099 Box Mapping";
    begin
        if SL1099BoxMapping.Get(TaxYear, SL1099DataValue) then
            exit(SL1099BoxMapping."BC IRS 1099 Code");

        exit('');
    end;

    internal procedure GetCurrent1099YearFromSLAPSetup(): Integer
    var
        SLAPSetup: Record "SL APSetup";
        ReportingYear: Integer;
    begin
        if not SLAPSetup.Get(APStringTxt) then
            exit(0);

        if Evaluate(ReportingYear, SLAPSetup.Curr1099Yr) then
            exit(ReportingYear)
        else
            exit(0);
    end;

    internal procedure GetCurrent1099YearOpenStatus(): Boolean
    var
        SLAPSetup: Record "SL APSetup";
        CurrentYearStatus: Text[1];
    begin
        if not SLAPSetup.Get(APStringTxt) then
            exit(false);

        CurrentYearStatus := SLAPSetup.CY1099Stat;
        if CurrentYearStatus = StatusOpenTxt then
            exit(true)
        else
            exit(false);
    end;

    internal procedure GetNext1099YearFromSLAPSetup(): Integer
    var
        SLAPSetup: Record "SL APSetup";
        ReportingYear: Integer;
    begin
        if not SLAPSetup.Get(APStringTxt) then
            exit(0);

        if Evaluate(ReportingYear, SLAPSetup.Next1099Yr) then
            exit(ReportingYear)
        else
            exit(0);
    end;

    internal procedure GetNext1099YearOpenStatus(): Boolean
    var
        SLAPSetup: Record "SL APSetup";
        NextYearStatus: Text[1];
    begin
        if not SLAPSetup.Get(APStringTxt) then
            exit(false);

        NextYearStatus := SLAPSetup.NY1099Stat;
        if NextYearStatus = StatusOpenTxt then
            exit(true)
        else
            exit(false);
    end;
}