// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

using Microsoft.Finance.Analysis.StatisticalAccount;
using Microsoft.Finance.FinancialReports;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.HumanResources.Employee;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Scorecard;

codeunit 6260 "Sust. ESG Reporting Helper Mgt"
{
    var
        AccSchedManagement: Codeunit AccSchedManagement;
        Amount: Decimal;
        EndDate: Date;
        StartDate: Date;
        EndDateReq: Date;
        CountryRegionFilter: Text;
        DivisionError: Boolean;
        NonExistentRowNoErr: Label 'You have entered an illegal value or a nonexistent row number %1.', Comment = '%1 = Row No.';

    procedure InitializeRequest(var ESGReportingName: Record "Sust. ESG Reporting Name"; var NewESGReportingLine: Record "Sust. ESG Reporting Line"; NewCountryRegionFilter: Text)
    begin
        if NewESGReportingLine.GetFilter("Date Filter") <> '' then begin
            StartDate := NewESGReportingLine.GetRangeMin("Date Filter");
            EndDateReq := NewESGReportingLine.GetRangeMax("Date Filter");
            EndDate := EndDateReq;
        end else begin
            StartDate := 0D;
            EndDateReq := 0D;
            EndDate := DMY2Date(31, 12, 9999);
        end;
        CountryRegionFilter := NewCountryRegionFilter;
    end;

    procedure CalcLineTotal(ESGReportingLine: Record "Sust. ESG Reporting Line"; var TotalAmount: Decimal; Level: Integer): Boolean
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        if Level = 0 then
            TotalAmount := 0;

        case ESGReportingLine."Field Type" of
            ESGReportingLine."Field Type"::"Table Field":
                begin
                    Amount := 0;
                    SetSourceFilters(RecRef, ESGReportingLine);

                    case ESGReportingLine."Value Settings" of
                        ESGReportingLine."Value Settings"::Sum:
                            begin
                                FieldRef := RecRef.Field(ESGReportingLine."Field No.");
                                FieldRef.CalcSum();
                                Amount := RoundAmount(FieldRef.Value, ESGReportingLine.Rounding);
                            end;
                        ESGReportingLine."Value Settings"::Count:
                            Amount := RecRef.Count();
                    end;
                    CalcTotalAmount(ESGReportingLine, TotalAmount);
                end;
            ESGReportingLine."Field Type"::Formula:
                begin
                    Level := Level + 1;
                    Amount := EvaluateExpression(ESGReportingLine."Row Totaling", ESGReportingLine);
                    CalcTotalAmount(ESGReportingLine, TotalAmount);
                end;
        end;

        exit(true);
    end;

    procedure DrillDown(ESGReportingLine: Record "Sust. ESG Reporting Line")
    begin
        case ESGReportingLine."Table No." of
            Database::"Sustainability Ledger Entry":
                DrillDownOnSustainabilityLedgerEntry(ESGReportingLine);
            Database::"Sustainability Goal":
                DrillDownOnSustainabilityGoal(ESGReportingLine);
            Database::"Statistical Ledger Entry":
                DrillDownOnStatisticalLedgerEntry(ESGReportingLine);
            Database::"G/L Entry":
                DrillDownOnGLEntry(ESGReportingLine);
            Database::Employee:
                DrillDownOnEmployee(ESGReportingLine);
            Database::Customer:
                DrillDownOnCustomer(ESGReportingLine);
            Database::Vendor:
                DrillDownOnVendor(ESGReportingLine);
            else
                OnDrillDownElseCase(ESGReportingLine);
        end;
    end;

    local procedure SetSourceFilters(var RecRef: RecordRef; ESGReportingLine: Record "Sust. ESG Reporting Line")
    var
        GLEntry: Record "G/L Entry";
        Employee: Record Employee;
        Customer: Record Customer;
        Vendor: Record Vendor;
        SustainabilityGoal: Record "Sustainability Goal";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        StatisticalLedgerEntry: Record "Statistical Ledger Entry";
    begin
        case ESGReportingLine."Table No." of
            Database::"Sustainability Ledger Entry":
                begin
                    SetSustainabilityLedgerEntryFilters(SustainabilityLedgerEntry, ESGReportingLine);

                    RecRef.GetTable(SustainabilityLedgerEntry);
                end;
            Database::"Sustainability Goal":
                begin
                    SetSustainabilityGoalFilters(SustainabilityGoal, ESGReportingLine);

                    RecRef.GetTable(SustainabilityGoal);
                end;
            Database::"Statistical Ledger Entry":
                begin
                    SetStatisticalLedgerEntryFilters(StatisticalLedgerEntry, ESGReportingLine);

                    RecRef.GetTable(StatisticalLedgerEntry);
                end;
            Database::"G/L Entry":
                begin
                    SetGLEntryFilters(GLEntry, ESGReportingLine);

                    RecRef.GetTable(GLEntry);
                end;
            Database::Employee:
                begin
                    SetEmployeeFilters(Employee, ESGReportingLine);

                    RecRef.GetTable(Employee);
                end;
            Database::Customer:
                begin
                    SetCustomerFilters(Customer, ESGReportingLine);

                    RecRef.GetTable(Customer);
                end;
            Database::Vendor:
                begin
                    SetVendorFilters(Vendor, ESGReportingLine);

                    RecRef.GetTable(Vendor);
                end;
            else
                OnSetSourceFiltersOnElseTableNo(RecRef, ESGReportingLine);
        end;
    end;


    local procedure DrillDownOnSustainabilityLedgerEntry(ESGReportingLine: Record "Sust. ESG Reporting Line")
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
    begin
        SetSustainabilityLedgerEntryFilters(SustainabilityLedgerEntry, ESGReportingLine);

        Page.Run(Page::"Sustainability Ledger Entries", SustainabilityLedgerEntry);
    end;

    local procedure DrillDownOnSustainabilityGoal(ESGReportingLine: Record "Sust. ESG Reporting Line")
    var
        SustainabilityGoal: Record "Sustainability Goal";
    begin
        SetSustainabilityGoalFilters(SustainabilityGoal, ESGReportingLine);

        Page.Run(Page::"Sustainability Goals", SustainabilityGoal);
    end;

    local procedure DrillDownOnStatisticalLedgerEntry(ESGReportingLine: Record "Sust. ESG Reporting Line")
    var
        StatisticalLedgerEntry: Record "Statistical Ledger Entry";
    begin
        SetStatisticalLedgerEntryFilters(StatisticalLedgerEntry, ESGReportingLine);

        Page.Run(Page::"Statistical Ledger Entry List", StatisticalLedgerEntry);
    end;

    local procedure DrillDownOnGLEntry(ESGReportingLine: Record "Sust. ESG Reporting Line")
    var
        GLEntry: Record "G/L Entry";
    begin
        SetGLEntryFilters(GLEntry, ESGReportingLine);

        Page.Run(Page::"General Ledger Entries", GLEntry);
    end;

    local procedure DrillDownOnEmployee(ESGReportingLine: Record "Sust. ESG Reporting Line")
    var
        Employee: Record Employee;
    begin
        SetEmployeeFilters(Employee, ESGReportingLine);

        Page.Run(Page::"Employee List", Employee);
    end;

    local procedure DrillDownOnCustomer(ESGReportingLine: Record "Sust. ESG Reporting Line")
    var
        Customer: Record Customer;
    begin
        SetCustomerFilters(Customer, ESGReportingLine);

        Page.Run(Page::"Customer List", Customer);
    end;

    local procedure DrillDownOnVendor(ESGReportingLine: Record "Sust. ESG Reporting Line")
    var
        Vendor: Record Vendor;
    begin
        SetVendorFilters(Vendor, ESGReportingLine);

        Page.Run(Page::"Vendor List", Vendor);
    end;

    local procedure SetSustainabilityLedgerEntryFilters(var SustainabilityLedgerEntry: Record "Sustainability Ledger Entry"; ESGReportingLine: Record "Sust. ESG Reporting Line")
    begin
        case ESGReportingLine."Row Type" of
            ESGReportingLine."Row Type"::"Net Change":
                SustainabilityLedgerEntry.SetRange("Posting Date", StartDate, EndDate);
            ESGReportingLine."Row Type"::"Balance at Date":
                SustainabilityLedgerEntry.SetRange("Posting Date", 0D, EndDate);
            ESGReportingLine."Row Type"::"Beginning Balance":
                SustainabilityLedgerEntry.SetFilter("Posting Date", '..%1', ClosingDate(StartDate - 1));
            ESGReportingLine."Row Type"::"Year to Date":
                SustainabilityLedgerEntry.SetRange("Posting Date", CalcDate('<-CY>', Today), Today);
        end;

        if CountryRegionFilter <> '' then
            SustainabilityLedgerEntry.SetFilter("Country/Region Code", CountryRegionFilter);

        if ESGReportingLine."Account Filter" <> '' then
            SustainabilityLedgerEntry.SetFilter("Account No.", ESGReportingLine."Account Filter");
    end;

    local procedure SetSustainabilityGoalFilters(var SustainabilityGoal: Record "Sustainability Goal"; ESGReportingLine: Record "Sust. ESG Reporting Line")
    begin
        if not IsNullGuid(ESGReportingLine."Goal SystemID") then
            SustainabilityGoal.SetFilter(SystemId, ESGReportingLine."Goal SystemID");
    end;

    local procedure SetStatisticalLedgerEntryFilters(var StatisticalLedgerEntry: Record "Statistical Ledger Entry"; ESGReportingLine: Record "Sust. ESG Reporting Line")
    begin
        case ESGReportingLine."Row Type" of
            ESGReportingLine."Row Type"::"Net Change":
                StatisticalLedgerEntry.SetRange("Posting Date", StartDate, EndDate);
            ESGReportingLine."Row Type"::"Balance at Date":
                StatisticalLedgerEntry.SetRange("Posting Date", 0D, EndDate);
            ESGReportingLine."Row Type"::"Beginning Balance":
                StatisticalLedgerEntry.SetFilter("Posting Date", '..%1', ClosingDate(StartDate - 1));
            ESGReportingLine."Row Type"::"Year to Date":
                StatisticalLedgerEntry.SetRange("Posting Date", CalcDate('<-CY>', Today), Today);
        end;

        if ESGReportingLine."Account Filter" <> '' then
            StatisticalLedgerEntry.SetFilter("Statistical Account No.", ESGReportingLine."Account Filter");
    end;

    local procedure SetGLEntryFilters(var GLEntry: Record "G/L Entry"; ESGReportingLine: Record "Sust. ESG Reporting Line")
    begin
        case ESGReportingLine."Row Type" of
            ESGReportingLine."Row Type"::"Net Change":
                GLEntry.SetRange("Posting Date", StartDate, EndDate);
            ESGReportingLine."Row Type"::"Balance at Date":
                GLEntry.SetRange("Posting Date", 0D, EndDate);
            ESGReportingLine."Row Type"::"Beginning Balance":
                GLEntry.SetFilter("Posting Date", '..%1', ClosingDate(StartDate - 1));
            ESGReportingLine."Row Type"::"Year to Date":
                GLEntry.SetRange("Posting Date", CalcDate('<-CY>', Today), Today);
        end;

        if ESGReportingLine."Account Filter" <> '' then
            GLEntry.SetFilter("G/L Account No.", ESGReportingLine."Account Filter");
    end;

    local procedure SetEmployeeFilters(var Employee: Record Employee; ESGReportingLine: Record "Sust. ESG Reporting Line")
    begin
        case ESGReportingLine."Row Type" of
            ESGReportingLine."Row Type"::"Net Change":
                Employee.SetRange("Date Filter", StartDate, EndDate);
            ESGReportingLine."Row Type"::"Balance at Date":
                Employee.SetRange("Date Filter", 0D, EndDate);
            ESGReportingLine."Row Type"::"Beginning Balance":
                Employee.SetFilter("Date Filter", '..%1', ClosingDate(StartDate - 1));
            ESGReportingLine."Row Type"::"Year to Date":
                Employee.SetRange("Date Filter", CalcDate('<-CY>', Today), Today);
        end;

        if CountryRegionFilter <> '' then
            Employee.SetFilter("Country/Region Code", CountryRegionFilter);

        if ESGReportingLine."Account Filter" <> '' then
            Employee.SetFilter("No.", ESGReportingLine."Account Filter");
    end;

    local procedure SetCustomerFilters(var Customer: Record Customer; ESGReportingLine: Record "Sust. ESG Reporting Line")
    begin
        case ESGReportingLine."Row Type" of
            ESGReportingLine."Row Type"::"Net Change":
                Customer.SetRange("Date Filter", StartDate, EndDate);
            ESGReportingLine."Row Type"::"Balance at Date":
                Customer.SetRange("Date Filter", 0D, EndDate);
            ESGReportingLine."Row Type"::"Beginning Balance":
                Customer.SetFilter("Date Filter", '..%1', ClosingDate(StartDate - 1));
            ESGReportingLine."Row Type"::"Year to Date":
                Customer.SetRange("Date Filter", CalcDate('<-CY>', Today), Today);
        end;

        if CountryRegionFilter <> '' then
            Customer.SetFilter("Country/Region Code", CountryRegionFilter);

        if ESGReportingLine."Account Filter" <> '' then
            Customer.SetFilter("No.", ESGReportingLine."Account Filter");
    end;

    local procedure SetVendorFilters(var Vendor: Record Vendor; ESGReportingLine: Record "Sust. ESG Reporting Line")
    begin
        case ESGReportingLine."Row Type" of
            ESGReportingLine."Row Type"::"Net Change":
                Vendor.SetRange("Date Filter", StartDate, EndDate);
            ESGReportingLine."Row Type"::"Balance at Date":
                Vendor.SetRange("Date Filter", 0D, EndDate);
            ESGReportingLine."Row Type"::"Beginning Balance":
                Vendor.SetFilter("Date Filter", '..%1', ClosingDate(StartDate - 1));
            ESGReportingLine."Row Type"::"Year to Date":
                Vendor.SetRange("Date Filter", CalcDate('<-CY>', Today), Today);
        end;

        if CountryRegionFilter <> '' then
            Vendor.SetFilter("Country/Region Code", CountryRegionFilter);

        if ESGReportingLine."Account Filter" <> '' then
            Vendor.SetFilter("No.", ESGReportingLine."Account Filter");
    end;

    local procedure CalcTotalAmount(ESGReportingLine: Record "Sust. ESG Reporting Line"; var TotalAmount: Decimal)
    begin
        if ESGReportingLine."Calculate With" = ESGReportingLine."Calculate With"::"Opposite Sign" then
            Amount := -Amount;

        TotalAmount := TotalAmount + Amount;
    end;

    local procedure EvaluateExpression(Expression: Text; ESGReportingLine: Record "Sust. ESG Reporting Line"): Decimal
    var
        Result: Decimal;
        Operator: Char;
        LeftOperand: Text;
        RightOperand: Text;
        LeftResult: Decimal;
        RightResult: Decimal;
        i: Integer;
        IsExpression: Boolean;
        IsFilter: Boolean;
    begin
        Result := 0;

        Expression := DelChr(Expression, '<>', ' ');
        if StrLen(Expression) > 0 then begin
            IsExpression := AccSchedManagement.ParseExpression(Expression, i);
            if IsExpression then begin
                if i > 1 then
                    LeftOperand := CopyStr(Expression, 1, i - 1)
                else
                    LeftOperand := '';
                if i < StrLen(Expression) then
                    RightOperand := CopyStr(Expression, i + 1)
                else
                    RightOperand := '';
                Operator := Expression[i];
                LeftResult := EvaluateExpression(LeftOperand, ESGReportingLine);
                RightResult := EvaluateExpression(RightOperand, ESGReportingLine);
                Result := AccSchedManagement.ApplyOperator(LeftResult, RightResult, Operator, DivisionError);
            end else
                if (Expression[1] = '(') and (Expression[StrLen(Expression)] = ')') then
                    Result := EvaluateExpression(CopyStr(Expression, 2, StrLen(Expression) - 2), ESGReportingLine)
                else begin
                    IsFilter := AccSchedManagement.IsExpressionFilter(Expression);
                    if (StrLen(Expression) > 10) and (not IsFilter) then
                        Evaluate(Result, Expression)
                    else
                        Result := CalcCellValueInESGReportingLine(ESGReportingLine, Expression, IsFilter);
                end;
        end;
        exit(Result);
    end;

    local procedure CalcCellValueInESGReportingLine(SourceESGReportingLine: Record "Sust. ESG Reporting Line"; Expression: Text; IsFilter: Boolean) Result: Decimal
    var
        ESGReportingLine: Record "Sust. ESG Reporting Line";
    begin
        ESGReportingLine.SetRange("ESG Reporting Template Name", SourceESGReportingLine."ESG Reporting Template Name");
        ESGReportingLine.SetRange("ESG Reporting Name", SourceESGReportingLine."ESG Reporting Name");
        ESGReportingLine.SetFilter("Row No.", Expression);
        if ESGReportingLine.FindSet() then
            repeat
                if ESGReportingLine."Line No." <> SourceESGReportingLine."Line No." then
                    CalcLineTotal(ESGReportingLine, Result, 0);
            until ESGReportingLine.Next() = 0
        else
            if IsFilter or (not Evaluate(Result, Expression)) then
                Error(NonExistentRowNoErr, SourceESGReportingLine."Row No.");
    end;

    local procedure RoundAmount(RoundAmt: Decimal; RoundingFactor: Enum "Sust. ESG Rounding Factor"): Decimal
    begin
        if RoundAmt = 0 then
            exit(0);

        if RoundingFactor = RoundingFactor::"1" then
            exit(Round(RoundAmt, 1));

        exit(RoundAmt);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnDrillDownElseCase(ESGReportingLine: Record "Sust. ESG Reporting Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnSetSourceFiltersOnElseTableNo(var RecRef: RecordRef; ESGReportingLine: Record "Sust. ESG Reporting Line")
    begin
    end;
}