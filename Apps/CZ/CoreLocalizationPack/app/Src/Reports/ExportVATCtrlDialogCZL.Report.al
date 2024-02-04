// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Company;

report 31104 "Export VAT Ctrl. Dialog CZL"
{
    Caption = 'Export VAT Control Report';
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

                    field(VATControlReportNoField; VATControlReportNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'VAT Control Report No.';
                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the number of VAT Control Report.';
                    }
                    field(XMLFormatField; XMLFormat)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'XML Format';
                        Editable = false;
                        ToolTip = 'Specifies XML format of exported file.';
                    }
                    field(ReportPeriodField; ReportPeriod)
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        Caption = 'Report Period';
                        OptionCaption = 'Month,Quarter';
                        ToolTip = 'Specifies the VAT period (month or quarter) of the VAT Control Report.';
                    }
                    field(PeriodNoField; PeriodNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        Caption = 'Period No.';
                        ToolTip = 'Specifies the VAT period number of the VAT Control Report.';
                    }
                    field(YearField; Year)
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        Caption = 'Year';
                        ToolTip = 'Specifies the year number of the VAT Control Report.';
                    }
                    field(SelectionField; Selection)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Entries Selection';
                        ToolTip = 'Specifies that VAT entries are included in the VAT Control Report.';
                    }
                    field(PrintInIntegersField; PrintInIntegers)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Round to Integer';
                        ToolTip = 'Specifies if the vat control report will be rounded to integer';
                    }
                    field(DeclarationTypeField; DeclarationType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Declaration Type';
                        ToolTip = 'Specifies the declaration type.';

                        trigger OnValidate()
                        begin
                            if DeclarationType <> DeclarationType::Supplementary then begin
                                ReasonsObservedOn := 0D;
                                AppelDocumentNo := '';
                            end;
                            DeclarationTypeOnAfterValidate();
                        end;
                    }
                    field(FilledByEmployeeNoField; FilledByEmployeeNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Filled By Employee No.';
                        TableRelation = "Company Official CZL";
                        ToolTip = 'Specifies the number of employee, who filled VAT statement.';
                    }
                    field(ReasonsObservedOnField; ReasonsObservedOn)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Reasons Observed On Date';
                        Editable = ReasonsObservedOnCtrlEditable;
                        ToolTip = 'Specifies the date of finding reasons of supplementary VAT Control Report';
                    }
                    field(FastAppelReactionField; FastAppelReaction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Fast reaction to appel';
                        OptionCaption = ' ,B,P';
                        ToolTip = 'Specifies the quick answer for appel of financial office. B = I''m not obliged to submit a VAT control report, P = I confirm the accuracy of the submitted VAT control report.';
                    }
                    field(AppelDocumentNoField; AppelDocumentNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Appel Document No.';
                        ToolTip = 'Specifies the number of appel document.';
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            GetStatementNameRec();
            RequestOptionsPage.Caption := StrSubstNo(PageCaptionLbl, RequestOptionsPage.Caption(), VATCtrlReportHeaderCZL."No.", VATCtrlReportHeaderCZL.Description);
            UpdateControls();
        end;
    }
    var
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATControlReportNo: Code[20];
        ReportPeriod: Option Month,Quarter;
        PeriodNo: Integer;
        Year: Integer;
        Selection: Enum "VAT Statement Report Selection";
        DeclarationType: Enum "VAT Ctrl. Report Decl Type CZL";
        FilledByEmployeeNo: Code[20];
        PrintInIntegers: Boolean;
        ReasonsObservedOnCtrlEditable: Boolean;
        ReasonsObservedOn: Date;
        XMLFormat: Enum "VAT Ctrl. Report Format CZL";
        FastAppelReaction: Option " ",B,P;
        AppelDocumentNo: Text;
        PageCaptionLbl: Label '%1: %2, %3', Comment = '%1=report caption, %2=VAT control report number, %3=VAT control report description', Locked = true;

    local procedure GetStatementNameRec()
    begin
        VATCtrlReportHeaderCZL.Get(VATControlReportNo);
        XMLFormat := VATCtrlReportHeaderCZL."VAT Control Report XML Format";
        ReportPeriod := VATCtrlReportHeaderCZL."Report Period";
        PeriodNo := VATCtrlReportHeaderCZL."Period No.";
        Year := VATCtrlReportHeaderCZL.Year;
    end;

    local procedure DeclarationTypeOnAfterValidate()
    begin
        UpdateControls();
    end;

    local procedure UpdateControls()
    begin
        ReasonsObservedOnCtrlEditable := DeclarationIsSupplementary();
    end;

    local procedure DeclarationIsSupplementary(): Boolean
    begin
        exit(DeclarationType in [DeclarationType::Supplementary, DeclarationType::"Supplementary-Corrective"]);
    end;
}
