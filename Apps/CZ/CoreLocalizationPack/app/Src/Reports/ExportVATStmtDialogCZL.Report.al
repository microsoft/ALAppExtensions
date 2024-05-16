// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Company;
using Microsoft.Finance.GeneralLedger.Setup;
using System.Utilities;

report 31003 "Export VAT Stmt. Dialog CZL"
{
    Caption = 'Export VAT Statement';
    ProcessingOnly = true;

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(General)
                {
                    Caption = 'General';
                    field(VATStatementTemplateNameField; VATStatementTemplateName)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'VAT Statement Template Name';
                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the name of the VAT statement template.';
                    }
                    field(VATStatementNameField; VATStatementName)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'VAT Statement Name';
                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the name of VAT statement.';
                    }
                    field(XMLFormatField; XMLFormat)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'XML Format';
                        Editable = false;
                        ToolTip = 'Specifies XML format in which vat statement will be exported';
                    }
                    field(StartDateField; StartDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Starting Date';
                        TableRelation = "VAT Period CZL";
                        ToolTip = 'Specifies the first date in the period for which VAT statement were exported.';

                        trigger OnValidate()
                        begin
                            StartDateOnAfterValidate();
                        end;
                    }
                    field(EndDateField; EndDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Ending Date';
                        ToolTip = 'Specifies the last date in the period for which VAT statement were exported.';

                        trigger OnValidate()
                        begin
                            EndDateReqOnAfterValidate();
                        end;
                    }
                    field(MonthField; Month)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Month';
                        ToolTip = 'Specifies the month number for VAT statement reporting.';

                        trigger OnValidate()
                        begin
                            if Month <> 0 then
                                if Quarter <> 0 then
                                    Error(MonthZeroIfQuarterErr);
                        end;
                    }
                    field(QuarterField; Quarter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Quarter';
                        ToolTip = 'Specifies the quarter number for VAT statement reporting.';

                        trigger OnValidate()
                        begin
                            if Quarter <> 0 then
                                if Month <> 0 then
                                    Error(MonthDontEmptyIfQuarErr);
                        end;
                    }
                    field(YearField; Year)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Year';
                        ToolTip = 'Specifies year of vat statement';
                    }
                    field(SelectionField; Selection)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Entries Selection';
                        ToolTip = 'Specifies that VAT entries are included in the VAT Statement Preview window.';
                    }
                    field(PeriodSelectionField; PeriodSelection)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Period Selection';
                        ToolTip = 'Specifies the filtr of VAT entries.';
                    }
                    field(PrintInIntegersField; PrintInIntegers)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Round to Integer';
                        ToolTip = 'Specifies if the vat statement will be rounded to integer';

                        trigger OnValidate()
                        begin
                            PrintInIntegersOnAfterValidate();
                        end;
                    }
                    group(RoundingDirectionCtrl)
                    {
                        ShowCaption = false;
                        Visible = RoundingDirectionCtrlVisible;
                        field(RoundingDirectionField; RoundingDirection)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Rounding Direction';
                            OptionCaption = 'Nearest,Down,Up';
                            ToolTip = 'Specifies rounding direction';
                        }
                    }
                    field(DeclarationTypeField; DeclarationType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Declaration Type';
                        ToolTip = 'Specifies the declaration type (recapitulative, corrective, supplementary).';

                        trigger OnValidate()
                        begin
                            if DeclarationType <> DeclarationType::Supplementary then
                                ReasonsObservedOn := 0D;
                            DeclarationTypeOnAfterValidate();
                        end;
                    }
                    field(FilledByEmployeeNoField; FilledByEmployeeNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Filled By Employee No.';
                        TableRelation = "Company Official CZL";
                        ToolTip = 'Specifies the number of employee, who filled VAT statement.';
                        ShowMandatory = true;
                    }
                }
                group(Additional)
                {
                    Caption = 'Additional';
                    field(ReasonsObservedOnField; ReasonsObservedOn)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Reasons Find';
                        Editable = ReasonsObservedOnCtrlEditable;
                        ToolTip = 'Specifies the date of finding reasons of supplementary vat statement';
                    }
                    field(NextYearVATPeriodCodeField; NextYearVATPeriodCode)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Next Year VAT Period Code';
                        ToolTip = 'Specifies next year VAT period code to be filled only in the recapitulative VAT statement for the last VAT period of the calendar year. Do not fill when VAT period does not change.';
                    }
                    field(SettlementNoFilterField; SettlementNoFilter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Filter VAT Settlement No.';
                        ToolTip = 'Specifies the filter setup of document number which the VAT entries were closed.';
                    }
                    field(CommentsField; Comments)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Comments';
                        Editable = false;
                        ToolTip = 'Specifies cash document comments.';
                    }
                    field(AttachmentsField; Attachments)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Attachments';
                        Editable = false;
                        ToolTip = 'Specifies the number of attachments.';
                    }
                    field(NoTaxField; NoTax)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No Tax reliability or Right to deduction';
                        ToolTip = 'Specifies if it is no tax reliability or right to deduction.';
                    }
                    field(UseAmtsInAddCurrField; UseAmtsInAddCurr)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Amounts in Add. Reporting Currency';
                        ToolTip = 'Specifies whether to show the reported amounts in the additional reporting currency.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            GetStatementNameRec();
            RequestOptionsPage.Caption := StrSubstNo(PageCaptionLbl, RequestOptionsPage.Caption(), VATStatementTemplateName, VATStatementName);
            UpdateControls();
            UpdateDateParameters();
        end;
    }

    trigger OnInitReport()
    begin
        SetUseAmtsInAddCurr();
    end;

    var
        RecordVATStatementName: Record "VAT Statement Name";
        VATStatementTemplate: Record "VAT Statement Template";
        Comments: Integer;
        Attachments: Integer;
        Selection: Enum "VAT Statement Report Selection";
        PeriodSelection: Enum "VAT Statement Report Period Selection";
        DeclarationType: Enum "VAT Stmt. Declaration Type CZL";
        RoundingDirection: Option Nearest,Down,Up;
        XMLFormat: Enum "VAT Statement XML Format CZL";
        SettlementNoFilter: Text[50];
        MonthDontEmptyIfQuarErr: Label 'Quarter must be 0 if Month is filled in.';
        MonthZeroIfQuarterErr: Label 'Month must be 0 if Quarter is filled in.';
        PageCaptionLbl: Label '%1: %2, %3', Comment = '%1=report caption, %2=VAT statement template name, %3=VAT statement name', Locked = true;

    protected var
        FilledByEmployeeNo: Code[20];
        NextYearVATPeriodCode: Code[3];
        VATStatementTemplateName: Code[10];
        VATStatementName: Code[10];
        StartDate: Date;
        EndDate: Date;
        ReasonsObservedOn: Date;
        NoTax: Boolean;
        PrintInIntegers: Boolean;
        ReasonsObservedOnCtrlEditable: Boolean;
        RoundingDirectionCtrlVisible: Boolean;
        UseAmtsInAddCurr: Boolean;
        Month: Integer;
        Quarter: Integer;
        Year: Integer;

    local procedure GetStatementNameRec()
    begin
        RecordVATStatementName.Get(VATStatementTemplateName, VATStatementName);
        VATStatementTemplate.Get(VATStatementTemplateName);
        XMLFormat := VATStatementTemplate."XML Format CZL";

        RecordVATStatementName.CalcFields("Comments CZL", "Attachments CZL");
        Comments := RecordVATStatementName."Comments CZL";
        Attachments := RecordVATStatementName."Attachments CZL";
    end;

    local procedure UpdateControls()
    begin
        RoundingDirectionCtrlVisible := PrintInIntegers;
        ReasonsObservedOnCtrlEditable := DeclarationIsSupplementary();
    end;

    local procedure UpdateDateParameters()
    var
        RecordDate: Record Date;
    begin
        if (StartDate <> 0D) and (EndDate <> 0D) then begin
            if EndDate < StartDate then
                EndDate := StartDate;
            Year := Date2DMY(StartDate, 3);
            Month := Date2DMY(StartDate, 2);
            if (Month = Date2DMY(EndDate, 2)) and (Year = Date2DMY(EndDate, 3)) then
                Quarter := 0
            else begin
                Month := 0;
                RecordDate.SetRange("Period Type", RecordDate."Period Type"::Quarter);
                RecordDate.SetFilter("Period Start", '..%1', StartDate);
                if RecordDate.FindLast() then
                    Quarter := RecordDate."Period No.";
            end;
        end;
    end;

    local procedure DeclarationIsSupplementary(): Boolean
    begin
        exit(DeclarationType in [DeclarationType::Supplementary, DeclarationType::"Supplementary/Corrective"])
    end;

    local procedure DeclarationTypeOnAfterValidate()
    begin
        UpdateControls();
    end;

    local procedure PrintInIntegersOnAfterValidate()
    begin
        UpdateControls();
    end;

    local procedure EndDateReqOnAfterValidate()
    begin
        UpdateDateParameters();
    end;

    local procedure StartDateOnAfterValidate()
    var
        VATPeriodCZL: Record "VAT Period CZL";
    begin
        VATPeriodCZL.SetFilter("Starting Date", '%1..', StartDate);
        VATPeriodCZL.FindSet();
        if VATPeriodCZL.Next() > 0 then
            EndDate := CalcDate('<-1D>', VATPeriodCZL."Starting Date");
        UpdateDateParameters();
    end;

    local procedure SetUseAmtsInAddCurr()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        UseAmtsInAddCurr := GeneralLedgerSetup."Additional Reporting Currency" <> '';
    end;
}
