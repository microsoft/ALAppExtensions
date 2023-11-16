// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.Period;
using Microsoft.Inventory.Ledger;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

codeunit 31326 "Acc. Sched. Extension Mgt. CZL"
{
    var
        AccScheduleLine: Record "Acc. Schedule Line";
        ColumnLayout: Record "Column Layout";
        AccScheduleExtensionCZL: Record "Acc. Schedule Extension CZL";
        AccScheduleResultHdrCZL: Record "Acc. Schedule Result Hdr. CZL";
        GeneralLedgerSetup: Record "General Ledger Setup";
        AccSchedManagement: Codeunit AccSchedManagement;
        AccountingPeriodMgt: Codeunit "Accounting Period Mgt.";
        StartDate: Date;
        EndDate: Date;
        FiscalStartDate: Date;
        PeriodError: Boolean;
        GLSetupRead: Boolean;
        BDDateFormulaTxt: Label 'BD';
        EDDateFormulaTxt: Label 'ED';
        MonthDateFormulaTxt: Label 'M';
        QuarterDataFormulaTxt: Label 'Q';
        YearDateFormulaTxt: Label 'Y';
        FromToFilterTok: Label '%1..%2', locked = true;
        ToFilterTok: Label '..%1', locked = true;
        SmallerThanFilterTok: Label '<%1', locked = true;
        InvalidDateFilterErr: Label 'Invalid value for Date Filter = %1.', Comment = '%1 = Date Filter';

    procedure CalcCustomFunc(var NewAccScheduleLine: Record "Acc. Schedule Line"; NewColumnLayout: Record "Column Layout"; NewStartDate: Date; NewEndDate: Date) Value: Decimal
    begin
        AccScheduleLine.Copy(NewAccScheduleLine);
        ColumnLayout := NewColumnLayout;
        StartDate := NewStartDate;
        EndDate := NewEndDate;
        Value := 0;
        AccSchedManagement.SetStartDateEndDate(StartDate, EndDate);
        AccScheduleExtensionCZL.SetFilter(Code, NewAccScheduleLine.Totaling);
        if AccScheduleExtensionCZL.FindFirst() then
            case AccScheduleExtensionCZL."Source Table" of
                AccScheduleExtensionCZL."Source Table"::"VAT Entry":
                    Value := GetVATEntryValue();
                AccScheduleExtensionCZL."Source Table"::"Value Entry":
                    Value := GetValueEntry();
                AccScheduleExtensionCZL."Source Table"::"Customer Entry":
                    Value := GetCustEntryValue();
                AccScheduleExtensionCZL."Source Table"::"Vendor Entry":
                    Value := GetVendEntryValue();
            end;
    end;

    procedure GetVATEntryValue() Result: Decimal
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.Reset();
        VATEntry.SetCurrentKey(Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "Posting Date");
        SetVATLedgEntryFilters(VATEntry);

        case AccScheduleExtensionCZL."VAT Amount Type" of
            AccScheduleExtensionCZL."VAT Amount Type"::Base:
                begin
                    VATEntry.CalcSums(Base);
                    Result := VATEntry.Base;
                end;
            AccScheduleExtensionCZL."VAT Amount Type"::Amount:
                begin
                    VATEntry.CalcSums(Amount);
                    Result := VATEntry.Amount;
                end;
        end;
        if AccScheduleExtensionCZL."Reverse Sign" then
            Result := -1 * Result;
    end;

    procedure GetValueEntry() Result: Decimal
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.Reset();
        ValueEntry.SetCurrentKey("Item No.", "Posting Date", "Item Ledger Entry Type", "Entry Type",
          "Variance Type", "Item Charge No.", "Location Code", "Variant Code",
          "Global Dimension 1 Code", "Global Dimension 2 Code");
        SetValueLedgEntryFilters(ValueEntry);
        ValueEntry.CalcSums("Cost Posted to G/L");
        Result := ValueEntry."Cost Posted to G/L";
        if AccScheduleExtensionCZL."Reverse Sign" then
            Result := -1 * Result;
    end;

    procedure CalcDateFormula(DateFormula: Text[250]): Date
    begin
        if DateFormula = '' then
            exit(0D);

        case CopyStr(DateFormula, 1, 2) of
            BDDateFormulaTxt:
                exit(CalcDate(CopyStr(DateFormula, 3), StartDate));
            EDDateFormulaTxt:
                exit(CalcDate(CopyStr(DateFormula, 3), EndDate));
        end;

        Error(InvalidDateFilterErr, DateFormula);
    end;

    procedure GetDateFilter(DateFilter: Text[250]): Text[250]
    var
        Position: Integer;
        LeftFormula: Text[250];
        RightFormula: Text[250];
    begin
        if DateFilter = '' then
            exit(DateFilter);

        Position := StrPos(DateFilter, '..');
        if Position > 0 then begin
            LeftFormula := CopyStr(CopyStr(DateFilter, 1, Position - 1), 1, MaxStrLen(LeftFormula));
            RightFormula := CopyStr(CopyStr(DateFilter, Position + 2), 1, MaxStrLen(RightFormula));
            exit(Format(CalcDateFormula(LeftFormula)) + '..' + Format(CalcDateFormula(RightFormula)));
        end;

        case DateFilter of
            BDDateFormulaTxt:
                exit(Format(StartDate));
            EDDateFormulaTxt:
                exit(Format(EndDate));
        end;

        exit(DateFilter);
    end;

    procedure SetCustLedgEntryFilters(var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        if AccScheduleExtensionCZL."Posting Date Filter" <> '' then
            CustLedgerEntry.SetFilter("Posting Date",
              GetDateFilter(AccScheduleExtensionCZL."Posting Date Filter"))
        else
            CustLedgerEntry.SetFilter("Posting Date", GetPostingDateFilter(AccScheduleLine, ColumnLayout));
        CustLedgerEntry.CopyFilter("Posting Date", CustLedgerEntry."Date Filter");
        CustLedgerEntry.SetFilter("Global Dimension 1 Code", AccScheduleLine.GetFilter("Dimension 1 Filter"));
        CustLedgerEntry.SetFilter("Global Dimension 2 Code", AccScheduleLine.GetFilter("Dimension 2 Filter"));

        if AccScheduleExtensionCZL."Document Type Filter" <> '' then
            CustLedgerEntry.SetFilter("Document Type", AccScheduleExtensionCZL."Document Type Filter");
        if AccScheduleExtensionCZL."Posting Group Filter" <> '' then
            CustLedgerEntry.SetFilter("Customer Posting Group", AccScheduleExtensionCZL."Posting Group Filter");
        OnAfterSetCustLedgEntryFilters(AccScheduleExtensionCZL, CustLedgerEntry);
    end;

    procedure SetVendLedgEntryFilters(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        if AccScheduleExtensionCZL."Posting Date Filter" <> '' then
            VendorLedgerEntry.SetFilter("Posting Date",
              GetDateFilter(AccScheduleExtensionCZL."Posting Date Filter"))
        else
            VendorLedgerEntry.SetFilter("Posting Date", GetPostingDateFilter(AccScheduleLine, ColumnLayout));
        VendorLedgerEntry.CopyFilter("Posting Date", VendorLedgerEntry."Date Filter");
        VendorLedgerEntry.SetFilter("Global Dimension 1 Code", AccScheduleLine.GetFilter("Dimension 1 Filter"));
        VendorLedgerEntry.SetFilter("Global Dimension 2 Code", AccScheduleLine.GetFilter("Dimension 2 Filter"));

        if AccScheduleExtensionCZL."Document Type Filter" <> '' then
            VendorLedgerEntry.SetFilter("Document Type", AccScheduleExtensionCZL."Document Type Filter");
        if AccScheduleExtensionCZL."Posting Group Filter" <> '' then
            VendorLedgerEntry.SetFilter("Vendor Posting Group", AccScheduleExtensionCZL."Posting Group Filter");
        OnAfterSetVendLedgEntryFilters(AccScheduleExtensionCZL, VendorLedgerEntry);
    end;

    procedure SetVATLedgEntryFilters(var VATEntry: Record "VAT Entry")
    begin
        case AccScheduleExtensionCZL."Entry Type" of
            AccScheduleExtensionCZL."Entry Type"::Purchase:
                VATEntry.SetRange(Type, VATEntry.Type::Purchase);
            AccScheduleExtensionCZL."Entry Type"::Sale:
                VATEntry.SetRange(Type, VATEntry.Type::Sale);
        end;
        VATEntry.SetFilter("Posting Date", GetPostingDateFilter(AccScheduleLine, ColumnLayout));
        VATEntry.SetFilter("VAT Bus. Posting Group", AccScheduleExtensionCZL."VAT Bus. Post. Group Filter");
        VATEntry.SetFilter("VAT Prod. Posting Group", AccScheduleExtensionCZL."VAT Prod. Post. Group Filter");
    end;

    procedure SetValueLedgEntryFilters(var ValueEntry: Record "Value Entry")
    begin
        ValueEntry.SetFilter("Global Dimension 1 Code", AccScheduleLine.GetFilter("Dimension 1 Filter"));
        ValueEntry.SetFilter("Global Dimension 2 Code", AccScheduleLine.GetFilter("Dimension 2 Filter"));
        ValueEntry.SetFilter("Location Code", AccScheduleExtensionCZL."Location Filter");
        ValueEntry.SetFilter("Posting Date", GetPostingDateFilter(AccScheduleLine, ColumnLayout));
    end;

    procedure GetCustEntryValue() Amount: Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetCurrentKey("Document Type", "Customer No.", "Posting Date", "Currency Code");
        SetCustLedgEntryFilters(CustLedgerEntry);
        if CustLedgerEntry.FindSet() then
            repeat
                CustLedgerEntry.CalcFields("Remaining Amt. (LCY)");
                case AccScheduleExtensionCZL."Amount Sign" of
                    AccScheduleExtensionCZL."Amount Sign"::" ":
                        Amount += CustLedgerEntry."Remaining Amt. (LCY)";
                    AccScheduleExtensionCZL."Amount Sign"::Positive:
                        if CustLedgerEntry."Remaining Amt. (LCY)" > 0 then
                            Amount += CustLedgerEntry."Remaining Amt. (LCY)";
                    AccScheduleExtensionCZL."Amount Sign"::Negative:
                        if CustLedgerEntry."Remaining Amt. (LCY)" < 0 then
                            Amount += CustLedgerEntry."Remaining Amt. (LCY)";
                end;
            until CustLedgerEntry.Next() = 0;

        if AccScheduleExtensionCZL."Reverse Sign" then
            Amount := -Amount;
    end;

    procedure GetVendEntryValue() Amount: Decimal
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetCurrentKey("Document Type", "Vendor No.", "Posting Date", "Currency Code");
        SetVendLedgEntryFilters(VendorLedgerEntry);
        if VendorLedgerEntry.FindSet() then
            repeat
                VendorLedgerEntry.CalcFields("Remaining Amt. (LCY)");
                case AccScheduleExtensionCZL."Amount Sign" of
                    AccScheduleExtensionCZL."Amount Sign"::" ":
                        Amount += VendorLedgerEntry."Remaining Amt. (LCY)";
                    AccScheduleExtensionCZL."Amount Sign"::Positive:
                        if VendorLedgerEntry."Remaining Amt. (LCY)" > 0 then
                            Amount += VendorLedgerEntry."Remaining Amt. (LCY)";
                    AccScheduleExtensionCZL."Amount Sign"::Negative:
                        if VendorLedgerEntry."Remaining Amt. (LCY)" < 0 then
                            Amount += VendorLedgerEntry."Remaining Amt. (LCY)";
                end;
            until VendorLedgerEntry.Next() = 0;

        if AccScheduleExtensionCZL."Reverse Sign" then
            Amount := -Amount;
    end;

    procedure DrillDownAmount(var NewAccScheduleLine: Record "Acc. Schedule Line"; NewColumnLayout: Record "Column Layout"; ExtensionCode: Code[20]; NewStartDate: Date; NewEndDate: Date)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VATEntry: Record "VAT Entry";
        ValueEntry: Record "Value Entry";
    begin
        AccScheduleLine.Copy(NewAccScheduleLine);
        ColumnLayout := NewColumnLayout;
        AccScheduleExtensionCZL.Get(ExtensionCode);
        StartDate := NewStartDate;
        EndDate := NewEndDate;
        AccSchedManagement.SetStartDateEndDate(StartDate, EndDate);
        case AccScheduleExtensionCZL."Source Table" of
            AccScheduleExtensionCZL."Source Table"::"VAT Entry":
                begin
                    SetVATLedgEntryFilters(VATEntry);
                    Page.Run(0, VATEntry);
                end;
            AccScheduleExtensionCZL."Source Table"::"Customer Entry":
                begin
                    SetCustLedgEntryFilters(CustLedgerEntry);
                    Page.Run(0, CustLedgerEntry);
                end;
            AccScheduleExtensionCZL."Source Table"::"Vendor Entry":
                begin
                    SetVendLedgEntryFilters(VendorLedgerEntry);
                    Page.Run(0, VendorLedgerEntry);
                end;
            AccScheduleExtensionCZL."Source Table"::"Value Entry":
                begin
                    SetValueLedgEntryFilters(ValueEntry);
                    Page.Run(0, ValueEntry);
                end;
        end;
    end;

    procedure GetPostingDateFilter(AccScheduleLine2: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"): Text[100]
    var
        FromDate: Date;
        ToDate: Date;
        FiscalStartDate2: Date;
    begin
        if (Format(ColumnLayout."Comparison Date Formula") <> '0') and (Format(ColumnLayout."Comparison Date Formula") <> '') then begin
            FromDate := CalcDate(ColumnLayout."Comparison Date Formula", StartDate);
            if (EndDate = CalcDate('<CM>', EndDate)) and
               ((StrPos(Format(ColumnLayout."Comparison Date Formula"), MonthDateFormulaTxt) > 0) or
                (StrPos(Format(ColumnLayout."Comparison Date Formula"), QuarterDataFormulaTxt) > 0) or
                (StrPos(Format(ColumnLayout."Comparison Date Formula"), YearDateFormulaTxt) > 0))
            then
                ToDate := CalcDate('<CM>', CalcDate(ColumnLayout."Comparison Date Formula", EndDate))
            else
                ToDate := CalcDate(ColumnLayout."Comparison Date Formula", EndDate);
            FiscalStartDate2 := AccountingPeriodMgt.FindFiscalYear(ToDate);
        end else
            if ColumnLayout."Comparison Period Formula" <> '' then begin
                AccPeriodStartEnd(ColumnLayout, StartDate, FromDate, ToDate);
                FiscalStartDate2 := AccountingPeriodMgt.FindFiscalYear(ToDate);
            end else begin
                FromDate := StartDate;
                ToDate := EndDate;
                FiscalStartDate := AccountingPeriodMgt.FindFiscalYear(EndDate);
                FiscalStartDate2 := FiscalStartDate;
            end;
        case ColumnLayout."Column Type" of
            ColumnLayout."Column Type"::"Net Change":
                case AccScheduleLine2."Row Type" of
                    AccScheduleLine2."Row Type"::"Net Change":
                        exit(StrSubstNo(FromToFilterTok, FromDate, ToDate));
                    AccScheduleLine2."Row Type"::"Beginning Balance":
                        exit(StrSubstNo(SmallerThanFilterTok, FromDate));
                    AccScheduleLine2."Row Type"::"Balance at Date":
                        exit(StrSubstNo(ToFilterTok, ToDate));
                end;
            ColumnLayout."Column Type"::"Balance at Date":
                if AccScheduleLine2."Row Type" = AccScheduleLine2."Row Type"::"Beginning Balance" then
                    exit('''''')
                else
                    exit(StrSubstNo(ToFilterTok, ToDate));
            ColumnLayout."Column Type"::"Beginning Balance":
                if AccScheduleLine2."Row Type" = AccScheduleLine2."Row Type"::"Balance at Date" then
                    exit('''''')
                else
                    exit(StrSubstNo(ToFilterTok, ClosingDate(FromDate - 1)));
            ColumnLayout."Column Type"::"Year to Date":
                case AccScheduleLine2."Row Type" of
                    AccScheduleLine2."Row Type"::"Net Change":
                        exit(StrSubstNo(FromToFilterTok, FiscalStartDate2, ToDate));
                    AccScheduleLine2."Row Type"::"Beginning Balance":
                        exit(StrSubstNo(SmallerThanFilterTok, FiscalStartDate2));
                    AccScheduleLine2."Row Type"::"Balance at Date":
                        exit(StrSubstNo(ToFilterTok, ToDate));
                end;
            ColumnLayout."Column Type"::"Rest of Fiscal Year":
                case AccScheduleLine2."Row Type" of
                    AccScheduleLine2."Row Type"::"Net Change":
                        exit(StrSubstNo(FromToFilterTok, CalcDate('<+1D>', ToDate), AccountingPeriodMgt.FindEndOfFiscalYear(FiscalStartDate2)));
                    AccScheduleLine2."Row Type"::"Beginning Balance":
                        exit(StrSubstNo(ToFilterTok, ToDate));
                    AccScheduleLine2."Row Type"::"Balance at Date":
                        exit(StrSubstNo(ToFilterTok, AccountingPeriodMgt.FindEndOfFiscalYear(ToDate)));
                end;
            ColumnLayout."Column Type"::"Entire Fiscal Year":
                case AccScheduleLine2."Row Type" of
                    AccScheduleLine2."Row Type"::"Net Change":
                        exit(StrSubstNo(FromToFilterTok, FiscalStartDate2, AccountingPeriodMgt.FindEndOfFiscalYear(FiscalStartDate2)));
                    AccScheduleLine2."Row Type"::"Beginning Balance":
                        exit(StrSubstNo(SmallerThanFilterTok, FiscalStartDate2));
                    AccScheduleLine2."Row Type"::"Balance at Date":
                        exit(StrSubstNo(ToFilterTok, AccountingPeriodMgt.FindEndOfFiscalYear(ToDate)));
                end;
        end;
    end;

    procedure ValidateFormula(AccScheduleLine: Record "Acc. Schedule Line")
    var
        AccScheduleName: Record "Acc. Schedule Name";
        ColumnLayoutType: Record "Column Layout";
        SavedAccScheduleLine: Record "Acc. Schedule Line";
    begin
        AccScheduleName.Get(AccScheduleLine."Schedule Name");
        ColumnLayoutType."Column Type" := ColumnLayoutType."Column Type"::"Net Change";
        AccScheduleLine.SetRange("Date Filter", Today);
        SavedAccScheduleLine := AccScheduleLine;
        AccSchedManagement.CalcCell(AccScheduleLine, ColumnLayoutType, false);
        AccScheduleLine := SavedAccScheduleLine;
    end;

    procedure PrepareToSaveResults(AccScheduleName: Code[10]; ColumnLayoutName: Code[10]; DateFilter: Text; Dim1Filter: Text[250]; Dim2Filter: Text[250]; Dim3Filter: Text[250]; Dim4Filter: Text[250]; Description: Text[50])
    var
        ColumnLayoutSave: Record "Column Layout";
        AccScheduleLineSave: Record "Acc. Schedule Line";
        AccScheduleResultLineCZL: Record "Acc. Schedule Result Line CZL";
        AccScheduleResultColCZL: Record "Acc. Schedule Result Col. CZL";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        GetGLSetup();
        GeneralLedgerSetup.TestField("Acc. Schedule Results Nos. CZL");

        AccScheduleResultHdrCZL.Init();
        AccScheduleResultHdrCZL."Result Code" :=
          NoSeriesManagement.GetNextNo(GeneralLedgerSetup."Acc. Schedule Results Nos. CZL", Today, true);
        AccScheduleResultHdrCZL."Acc. Schedule Name" := AccScheduleName;
        AccScheduleResultHdrCZL."Column Layout Name" := ColumnLayoutName;
        AccScheduleResultHdrCZL."Date Filter" := CopyStr(DateFilter, 1, MaxStrLen(AccScheduleResultHdrCZL."Date Filter"));
        AccScheduleResultHdrCZL."User ID" := CopyStr(UserId, 1, MaxStrLen(AccScheduleResultHdrCZL."User ID"));
        AccScheduleResultHdrCZL."Result Date" := Today;
        AccScheduleResultHdrCZL."Result Time" := Time;
        AccScheduleResultHdrCZL."Dimension 1 Filter" := Dim1Filter;
        AccScheduleResultHdrCZL."Dimension 2 Filter" := Dim2Filter;
        AccScheduleResultHdrCZL."Dimension 3 Filter" := Dim3Filter;
        AccScheduleResultHdrCZL."Dimension 4 Filter" := Dim4Filter;
        AccScheduleResultHdrCZL.Description := Description;
        AccScheduleResultHdrCZL.Insert();

        AccScheduleLineSave.SetRange("Schedule Name", AccScheduleName);
        if AccScheduleLineSave.FindSet() then
            repeat
                AccScheduleResultLineCZL.TransferFields(AccScheduleLineSave);
                AccScheduleResultLineCZL."Result Code" := AccScheduleResultHdrCZL."Result Code";
                AccScheduleResultLineCZL.Insert();
            until AccScheduleLineSave.Next() = 0;

        ColumnLayoutSave.SetRange("Column Layout Name", ColumnLayoutName);
        if ColumnLayoutSave.FindSet() then
            repeat
                AccScheduleResultColCZL.TransferFields(ColumnLayoutSave);
                AccScheduleResultColCZL."Result Code" := AccScheduleResultHdrCZL."Result Code";
                AccScheduleResultColCZL.Insert();
            until ColumnLayoutSave.Next() = 0;
    end;

    procedure CreateResults(var SourceAccScheduleLine: Record "Acc. Schedule Line"; ColumnLayoutName: Code[10]; UseAmtsInAddCurr: Boolean)
    var
        ColumnLayoutCreate: Record "Column Layout";
        AccScheduleResultValueCZL: Record "Acc. Schedule Result Value CZL";
        SaveAccScheduleResultCZL: Page "Save Acc. Schedule Result CZL";
        AccSchedName: Code[10];
        DimFilter: array[4] of Text[250];
        DateFilter: Text;
        Result: Decimal;
        Description: Text[50];
        ScheduleNameErr: Label 'You must specify acc. schedule name.';
        ColumnLayoutNameErr: Label 'You must specify column layout name.';
        DateFilterErr: Label 'You must specify date filter.';
    begin
        AccSchedName := SourceAccScheduleLine."Schedule Name";
        DateFilter := SourceAccScheduleLine.GetFilter("Date Filter");
        DimFilter[1] := CopyStr(SourceAccScheduleLine.GetFilter("Dimension 1 Filter"), 1, MaxStrlen(DimFilter[1]));
        DimFilter[2] := CopyStr(SourceAccScheduleLine.GetFilter("Dimension 2 Filter"), 1, MaxStrlen(DimFilter[2]));
        DimFilter[3] := CopyStr(SourceAccScheduleLine.GetFilter("Dimension 3 Filter"), 1, MaxStrlen(DimFilter[3]));
        DimFilter[4] := CopyStr(SourceAccScheduleLine.GetFilter("Dimension 4 Filter"), 1, MaxStrlen(DimFilter[4]));

        SaveAccScheduleResultCZL.SetParameters(AccSchedName, ColumnLayoutName, DateFilter, UseAmtsInAddCurr);
        SaveAccScheduleResultCZL.LookupMode(true);
        if SaveAccScheduleResultCZL.RunModal() = Action::LookupOK then begin
            SaveAccScheduleResultCZL.GetParameters(AccSchedName, ColumnLayoutName, DateFilter, Description, UseAmtsInAddCurr);

            if AccSchedName = '' then
                Error(ScheduleNameErr);
            if ColumnLayoutName = '' then
                Error(ColumnLayoutNameErr);
            if DateFilter = '' then
                Error(DateFilterErr);

            PrepareToSaveResults(AccSchedName, ColumnLayoutName, DateFilter, DimFilter[1], DimFilter[2], DimFilter[3], DimFilter[4], Description);

            AccScheduleLine.CopyFilters(SourceAccScheduleLine);
            AccScheduleLine.SetRange("Schedule Name", AccSchedName);
            AccScheduleLine.SetFilter("Date Filter", DateFilter);
            ColumnLayoutCreate.SetRange("Column Layout Name", ColumnLayoutName);
            if AccScheduleLine.FindSet() then
                repeat
                    if ColumnLayoutCreate.FindSet() then
                        repeat
                            Result := AccSchedManagement.CalcCell(AccScheduleLine, ColumnLayoutCreate, UseAmtsInAddCurr);
                            AccScheduleResultValueCZL."Result Code" := AccScheduleResultHdrCZL."Result Code";
                            AccScheduleResultValueCZL."Row No." := AccScheduleLine."Line No.";
                            AccScheduleResultValueCZL."Column No." := ColumnLayoutCreate."Line No.";
                            AccScheduleResultValueCZL.Value := Result;
                            AccScheduleResultValueCZL.Insert();
                        until ColumnLayoutCreate.Next() = 0;
                until AccScheduleLine.Next() = 0;
        end;
    end;

    procedure FindSharedAccountSchedule(SourceAccScheduleLine: Record "Acc. Schedule Line"; var AccScheduleLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; CalcAddCurr: Boolean; var CellValue: Decimal; StartDate: Date; EndDate: Date; var Result: Decimal): Boolean
    var
        SharedAccountScheduleFind: Boolean;
        IsHandled: Boolean;
    begin
        GetGLSetup();
        SharedAccountScheduleFind := false;
        AccScheduleLine.SetRange("Schedule Name", GeneralLedgerSetup."Shared Account Schedule CZL");
        if AccScheduleLine.FindSet() then begin
            SharedAccountScheduleFind := true;
            repeat
                IsHandled := false;
                OnFindSharedAccountScheduleOnBeforeCalcAccSchedLineCellValue(
                    SourceAccScheduleLine, AccScheduleLine, ColumnLayout, CalcAddCurr, CellValue, IsHandled);
                if IsHandled then
                    Result += CellValue
                else begin
                    AccSchedManagement.SetStartDateEndDate(StartDate, EndDate);
                    Result := Result + AccSchedManagement.CalcCellValue(AccScheduleLine, ColumnLayout, CalcAddCurr);
                end;
            until AccScheduleLine.Next() = 0
        end;
        exit(SharedAccountScheduleFind);
    end;

    local procedure AccPeriodStartEnd(ColumnLayout: Record "Column Layout"; Date: Date; var StartDate: Date; var EndDate: Date)
    var
        Steps: Integer;
        Type: Option " ",Period,"Fiscal Year";
        RangeFromType: Option Int,CP,LP;
        RangeToType: Option Int,CP,LP;
        RangeFromInt: Integer;
        RangeToInt: Integer;
    begin
        if ColumnLayout."Comparison Period Formula" = '' then
            exit;

        ColumnLayout.ParsePeriodFormula(
          ColumnLayout."Comparison Period Formula", Steps, Type, RangeFromType, RangeToType, RangeFromInt, RangeToInt);

        AccountingPeriodMgt.AccPeriodStartEnd(
          Date, StartDate, EndDate, PeriodError, Steps, Type, RangeFromType, RangeToType, RangeFromInt, RangeToInt);
    end;

    local procedure GetGLSetup()
    begin
        if not GLSetupRead then
            GeneralLedgerSetup.Get();
        GLSetupRead := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindSharedAccountScheduleOnBeforeCalcAccSchedLineCellValue(SourceAccScheduleLine: Record "Acc. Schedule Line"; var "; var AccScheduleLine: Record ": Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; CalcAddCurr: Boolean; var CellValue: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetCustLedgEntryFilters(AccScheduleExtensionCZL: Record "Acc. Schedule Extension CZL"; var CustLedgerEntry: Record "Cust. Ledger Entry");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetVendLedgEntryFilters(AccScheduleExtensionCZL: Record "Acc. Schedule Extension CZL"; var VendorLedgerEntry: Record "Vendor Ledger Entry");
    begin
    end;
}
