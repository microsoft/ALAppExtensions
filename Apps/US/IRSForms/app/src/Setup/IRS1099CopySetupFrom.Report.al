// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Environment;

report 10037 "IRS 1099 Copy Setup From"
{
    Caption = 'IRS 1099 Copy Setup';
    ProcessingOnly = true;
    ApplicationArea = BasicUS;

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(FromPeriod; FromPeriodNo)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'From Period';
                        ToolTip = 'Specifies the period to copy from';
                        TableRelation = "IRS Reporting Period";
                        ShowMandatory = true;

                        trigger OnValidate()
                        begin
                            ValidateReportingPeriodFrom();
                        end;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            IRSReportingPeriod: Record "IRS Reporting Period";
                            IRSReportingPeriods: Page "IRS Reporting Periods";
                        begin
                            IRSReportingPeriod.SetFilter("No.", '<>%1', ToPeriodNo);
                            IRSReportingPeriods.SetTableView(IRSReportingPeriod);
                            IRSReportingPeriods.LookupMode := true;
                            if IRSReportingPeriods.RunModal() = Action::LookupOK then begin
                                IRSReportingPeriods.GetRecord(IRSReportingPeriod);
                                FromPeriodNo := IRSReportingPeriod."No.";
                            end;
                        end;
                    }
                    field(ToPeriod; ToPeriodNo)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'To Period';
                        ToolTip = 'Specifies the period to copy to.';
                        TableRelation = "IRS Reporting Period";
                        ShowMandatory = true;

                        trigger OnValidate()
                        var
                            IRS1099Form: Record "IRS 1099 Form";
                            ReportingPeriodAlreadyHasSetupMsg: Label 'The reporting period already has setup.';
                        begin
                            IRS1099Form.SetRange("Period No.", ToPeriodNo);
                            if not IRS1099Form.IsEmpty() then
                                error(ReportingPeriodAlreadyHasSetupMsg);
                        end;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            IRSReportingPeriod: Record "IRS Reporting Period";
                            IRSReportingPeriods: Page "IRS Reporting Periods";
                        begin
                            IRSReportingPeriod.SetFilter("No.", '<>%1', FromPeriodNo);
                            IRSReportingPeriods.SetTableView(IRSReportingPeriod);
                            IRSReportingPeriods.LookupMode := true;
                            if IRSReportingPeriods.RunModal() = Action::LookupOK then begin
                                IRSReportingPeriods.GetRecord(IRSReportingPeriod);
                                ToPeriodNo := IRSReportingPeriod."No.";
                            end;
                        end;
                    }
                    field(CompaniesSelectionOption; CompaniesSelection)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Companies';
                        ToolTip = 'Specifies the companies to copy the setup for.';
                        Editable = false;

                        trigger OnAssistEdit()
                        var
                            IRSFormsCompanySelector: Page "IRS Forms Company Selector";
                            AtLeastOneCompanyMustBeSelectedErr: Label 'At least one company must be selected.';
                        begin
                            IRSFormsCompanySelector.SetSelectedCompanies(TempSelectedCompany);
                            if IRSFormsCompanySelector.RunModal() = Action::Cancel then
                                exit;
                            IRSFormsCompanySelector.GetSelectedCompanies(TempSelectedCompany);
                            if TempSelectedCompany.IsEmpty() then
                                Error(AtLeastOneCompanyMustBeSelectedErr);
                            UpdateCompanySelectionOption();
                        end;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            TempSelectedCompany.Name := CopyStr(CompanyName(), 1, MaxStrLen(TempSelectedCompany.Name));
            TempSelectedCompany.Insert();
            UpdateCompanySelectionOption();
        end;
    }

    var
        TempSelectedCompany: Record Company temporary;

    protected var
        ToPeriodNo: Code[20];
        FromPeriodNo: Code[20];
        CompaniesSelection: Text;

    trigger OnPostReport()
    var
        IRSReportingPeriod: Codeunit "IRS Reporting Period";
    begin
        IRSReportingPeriod.CopyReportingPeriodSetup(FromPeriodNo, ToPeriodNo, TempSelectedCompany);
        IRSReportingPeriod.UpdateDataForNewTaxYear(FromPeriodNo, ToPeriodNo, TempSelectedCompany, false);
    end;

#if not CLEAN28
    [Obsolete('Use SetCopyPeriodFrom instead.', '28.0')]
    procedure InitializeRequest(NewToPeriodNo: Code[20]);
    begin
        ToPeriodNo := NewToPeriodNo;
    end;
#endif

    procedure SetCopyPeriodFrom(NewFromPeriodNo: Code[20]);
    begin
        FromPeriodNo := NewFromPeriodNo;
        ValidateReportingPeriodFrom();
    end;

    local procedure UpdateCompanySelectionOption()
    var
        MultipleCompaniesSelectedTok: Label '(%1 companies)', Comment = '%1 = Number of companies selected';
    begin
        if TempSelectedCompany.Count() = 1 then
            CompaniesSelection := TempSelectedCompany.Name
        else
            CompaniesSelection := StrSubstNo(MultipleCompaniesSelectedTok, TempSelectedCompany.Count());
    end;

    local procedure ValidateReportingPeriodFrom()
    var
        IRS1099Form: Record "IRS 1099 Form";
        ReportingPeriodDoesNotHaveSetupMsg: Label 'The reporting period does not have a setup to copy from.';
    begin
        IRS1099Form.SetRange("Period No.", FromPeriodNo);
        if IRS1099Form.IsEmpty() then
            error(ReportingPeriodDoesNotHaveSetupMsg);
    end;
}
