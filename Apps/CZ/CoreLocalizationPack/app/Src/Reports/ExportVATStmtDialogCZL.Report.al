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
                        Visible = ExportType = ExportType::VATStatement;
                        Enabled = ExportType = ExportType::VATStatement;

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
                        Visible = ExportType = ExportType::VATStatement;
                        Enabled = ExportType = ExportType::VATStatement;

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
                        Visible = ExportType = ExportType::VATStatement;
                        Enabled = ExportType = ExportType::VATStatement;

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
                        Visible = ExportType = ExportType::VATStatement;
                        Enabled = ExportType = ExportType::VATStatement;

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
                        Visible = ExportType = ExportType::VATStatement;
                        Enabled = ExportType = ExportType::VATStatement;
                    }
                    field(SelectionField; Selection)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Entries Selection';
                        ToolTip = 'Specifies that VAT entries are included in the VAT Statement Preview window.';
                        Visible = ExportType = ExportType::VATStatement;
                        Enabled = ExportType = ExportType::VATStatement;
                    }
                    field(PeriodSelectionField; PeriodSelection)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Period Selection';
                        ToolTip = 'Specifies the filtr of VAT entries.';
                        Visible = ExportType = ExportType::VATStatement;
                        Enabled = ExportType = ExportType::VATStatement;
                    }
                    field(PrintInIntegersField; PrintInIntegers)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Round to Integer';
                        ToolTip = 'Specifies if the vat statement will be rounded to integer';
                        Visible = ExportType = ExportType::VATStatement;
                        Enabled = ExportType = ExportType::VATStatement;

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
            XMLFormat := GetXmlFormat();
            Attachments := CalcAttachmentsCount();
            Comments := CalcCommentsCount();
            RequestOptionsPage.Caption := StrSubstNo(PageCaptionLbl, RequestOptionsPage.Caption(), VATStatementTemplateName, VATStatementName);
            UpdateControls();
            UpdateDateParameters();
            UpdateFilledByEmployeeNo();
        end;
    }

    trigger OnInitReport()
    begin
        SetUseAmtsInAddCurr();
    end;

    var
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
        ExportType: Option VATStatement,VATReport;
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

    local procedure GetXmlFormat(): Enum "VAT Statement XML Format CZL"
    begin
        VATStatementTemplate.Get(VATStatementTemplateName);
        exit(VATStatementTemplate."XML Format CZL");
    end;

    local procedure CalcAttachmentsCount(): Integer
    var
        VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL";
    begin
        VATStatementAttachmentCZL.SetRange("VAT Statement Template Name", VATStatementTemplateName);
        VATStatementAttachmentCZL.SetRange("VAT Statement Name", VATStatementName);
        VATStatementAttachmentCZL.SetRange("Date", StartDate, EndDate);
        exit(VATStatementAttachmentCZL.Count());
    end;

    local procedure CalcCommentsCount(): Integer
    var
        VATStatementCommentLineCZL: Record "VAT Statement Comment Line CZL";
    begin
        VATStatementCommentLineCZL.SetRange("VAT Statement Template Name", VATStatementTemplateName);
        VATStatementCommentLineCZL.SetRange("VAT Statement Name", VATStatementName);
        VATStatementCommentLineCZL.SetRange("Date", StartDate, EndDate);
        exit(VATStatementCommentLineCZL.Count());
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

    local procedure UpdateFilledByEmployeeNo()
    var
        StatutoryReportingSetup: Record "Statutory Reporting Setup CZL";
    begin
        StatutoryReportingSetup.Get();
        FilledByEmployeeNo := StatutoryReportingSetup."VAT Stat. Filled Employee No.";
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

    internal procedure Initialize(VATReportHeader: Record "VAT Report Header")
    begin
        VATStatementTemplateName := VATReportHeader."Statement Template Name";
        VATStatementName := VATReportHeader."Statement Name";
        StartDate := VATReportHeader."Start Date";
        EndDate := VATReportHeader."End Date";
        Month := VATReportHeader.GetMonth();
        Quarter := VATReportHeader.GetQuarter();
        Year := VATReportHeader."Period Year";
        UseAmtsInAddCurr := VATReportHeader."Amounts in Add. Rep. Currency";
        ExportType := ExportType::VATReport;
        DeclarationType := VATReportHeader.ConvertVATReportTypeToVATStmtDeclarationType();
        ReasonsObservedOn := 0D;
    end;
}
