// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Text;

page 31135 "VAT Statement Preview CZL"
{
    Caption = 'VAT Statement Preview';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    SaveValues = true;
    SourceTable = "VAT Statement Name";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(VATPeriodStartDate; VATPeriodStartDate)
                {
                    ApplicationArea = VAT;
                    Caption = 'VAT Period Start Date';
                    LookupPageId = "VAT Periods CZL";
                    TableRelation = "VAT Period CZL";
                    ToolTip = 'Specifies the starting date for the VAT period.';

                    trigger OnValidate()
                    begin
                        if VATPeriodStartDate <> 0D then begin
                            VATPeriodCZL.Get(VATPeriodStartDate);
                            if VATPeriodCZL.Next() > 0 then
                                VATPeriodEndDate := CalcDate('<-1D>', VATPeriodCZL."Starting Date");
                        end;
                        Rec.SetRange("Date Filter", VATPeriodStartDate, VATPeriodEndDate);
                        DateFilter := Rec.GetFilter("Date Filter");
                        UpdateSubForm();
                    end;
                }
                field(VATPeriodEndDate; VATPeriodEndDate)
                {
                    ApplicationArea = VAT;
                    Caption = 'VAT Period End Date';
                    ToolTip = 'Specifies the ending date for the VAT period.';

                    trigger OnValidate()
                    begin
                        Rec.SetRange("Date Filter", VATPeriodStartDate, VATPeriodEndDate);
                        DateFilter := Rec.GetFilter("Date Filter");
                        UpdateSubForm();
                    end;
                }
                field(DateFilter; DateFilter)
                {
                    ApplicationArea = VAT;
                    Caption = 'Date Filter';
                    ToolTip = 'Specifies the dates that will be used to filter the amounts in the window.';

                    trigger OnValidate()
                    var
                        FilterTokens: Codeunit "Filter Tokens";
                    begin
                        FilterTokens.MakeDateFilter(DateFilter);
                        Rec.SetFilter("Date Filter", DateFilter);
                        CurrPage.Update();
                        if DateFilter <> '' then begin
                            VATPeriodStartDate := 0D;
                            VATPeriodEndDate := 0D;
                        end;
                        UpdateSubForm();
                    end;
                }
                field(SettlementNoFilter; SettlementNoFilter)
                {
                    ApplicationArea = VAT;
                    Caption = 'Filter VAT Settlement No.';
                    ToolTip = 'Specifies the filter setup of document number which the VAT entries were closed.';

                    trigger OnValidate()
                    begin
                        UpdateSubForm();
                    end;
                }
                field(Selection; VATStatementReportSelection)
                {
                    ApplicationArea = VAT;
                    Caption = 'Include VAT entries';
                    ToolTip = 'Specifies that VAT entries are included in the VAT Statement Preview window. This only works for lines of type VAT Entry Totaling. It does not work for lines of type Account Totaling.';

                    trigger OnValidate()
                    begin
                        if VATStatementReportSelection = VATStatementReportSelection::"Open and Closed" then
                            OpenandClosedSelectionOnValida();
                        if VATStatementReportSelection = VATStatementReportSelection::Closed then
                            ClosedSelectionOnValidate();
                        if VATStatementReportSelection = VATStatementReportSelection::Open then
                            OpenSelectionOnValidate();
                    end;
                }
                field(PeriodSelection; VATStatementReportPeriodSelection)
                {
                    ApplicationArea = VAT;
                    Caption = 'Include VAT entries';
                    ToolTip = 'Specifies that VAT entries are included in the VAT Statement Preview window. This only works for lines of type VAT Entry Totaling. It does not work for lines of type Account Totaling.';

                    trigger OnValidate()
                    begin
                        if VATStatementReportPeriodSelection = VATStatementReportPeriodSelection::"Before and Within Period" then
                            BeforeandWithinPeriodSelection();
                        if VATStatementReportPeriodSelection = VATStatementReportPeriodSelection::"Within Period" then
                            WithinPeriodPeriodSelectionOnV();
                    end;
                }
                field(UseAmtsInAddCurr; UseAmtsInAddCurr)
                {
                    ApplicationArea = Suite;
                    Caption = 'Show Amounts in Add. Reporting Currency';
                    MultiLine = true;
                    ToolTip = 'Specifies that the VAT Statement Preview window shows amounts in the additional reporting currency.';

                    trigger OnValidate()
                    begin
                        UseAmtsInAddCurrOnPush();
                    end;
                }
            }
            part(VATStatementLineSubForm; "VAT Statement Preview Line CZL")
            {
                ApplicationArea = VAT;
                SubPageLink = "Statement Template Name" = field("Statement Template Name"),
                              "Statement Name" = field(Name);
                SubPageView = sorting("Statement Template Name", "Statement Name", "Line No.");
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        UpdateSubForm();
    end;

    trigger OnOpenPage()
    begin
        if (VATPeriodStartDate <> 0D) or (VATPeriodEndDate <> 0D) then begin
            Rec.SetRange("Date Filter", VATPeriodStartDate, VATPeriodEndDate);
            DateFilter := Rec.GetFilter("Date Filter");
        end else
            DateFilter := '';
        UpdateSubForm();
    end;

    protected var
        VATPeriodCZL: Record "VAT Period CZL";
        VATStatementReportSelection: Enum "VAT Statement Report Selection";
        VATStatementReportPeriodSelection: Enum "VAT Statement Report Period Selection";
        UseAmtsInAddCurr: Boolean;
        DateFilter: Text;
        VATPeriodStartDate: Date;
        VATPeriodEndDate: Date;
        SettlementNoFilter: Text[50];

    procedure UpdateSubForm()
    begin
        CurrPage.VATStatementLineSubForm.PAGE.UpdateForm(Rec, VATStatementReportSelection, VATStatementReportPeriodSelection, UseAmtsInAddCurr, SettlementNoFilter);
    end;

    procedure GetParameters(var NewSelection: Enum "VAT Statement Report Selection"; var NewPeriodSelection: Enum "VAT Statement Report Period Selection"; var NewUseAmtsInAddCurr: Boolean)
    begin
        NewSelection := VATStatementReportSelection;
        NewPeriodSelection := VATStatementReportPeriodSelection;
        NewUseAmtsInAddCurr := UseAmtsInAddCurr;
    end;

    local procedure OpenandClosedSelectionOnPush()
    begin
        UpdateSubForm();
    end;

    local procedure ClosedSelectionOnPush()
    begin
        UpdateSubForm();
    end;

    local procedure OpenSelectionOnPush()
    begin
        UpdateSubForm();
    end;

    local procedure BeforeandWithinPeriodSelOnPush()
    begin
        UpdateSubForm();
    end;

    local procedure WithinPeriodPeriodSelectOnPush()
    begin
        UpdateSubForm();
    end;

    local procedure UseAmtsInAddCurrOnPush()
    begin
        UpdateSubForm();
    end;

    local procedure OpenSelectionOnValidate()
    begin
        OpenSelectionOnPush();
    end;

    local procedure ClosedSelectionOnValidate()
    begin
        ClosedSelectionOnPush();
    end;

    local procedure OpenandClosedSelectionOnValida()
    begin
        OpenandClosedSelectionOnPush();
    end;

    local procedure WithinPeriodPeriodSelectionOnV()
    begin
        WithinPeriodPeriodSelectOnPush();
    end;

    local procedure BeforeandWithinPeriodSelection()
    begin
        BeforeandWithinPeriodSelOnPush();
    end;
}
