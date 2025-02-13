// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

report 11745 "VAT Report Request Page CZL"
{
    Caption = 'VAT Report Request Page CZ';
    ProcessingOnly = true;

    dataset
    {
        dataitem("VAT Report Header"; "VAT Report Header")
        {

            trigger OnPostDataItem()
            begin
                "Created Date-Time" := CurrentDateTime();
                "Round to Integer CZL" := RoundToInteger;
                "Rounding Direction CZL" := RoundingDirection;
                Modify();
            end;

            trigger OnPreDataItem()
            var
                TempVATStatementReportLine: Record "VAT Statement Report Line" temporary;
                TempVATStmtReportLineDataCZL: Record "VAT Stmt. Report Line Data CZL" temporary;
                VATAttributeCodeCZL: Record "VAT Attribute Code CZL";
                VATStatementLine: Record "VAT Statement Line";
                VATStatementReportLine: Record "VAT Statement Report Line";
                VATStatementName: Record "VAT Statement Name";
                VATStmtReportLineDataCZL: Record "VAT Stmt. Report Line Data CZL";
                VATStatement: Report "VAT Statement";
                VATStatementHandlerCZL: Codeunit "VAT Statement Handler CZL";
                Amount: Decimal;
                LineNo: Integer;
            begin
                Copy(Rec);
                CheckOnlyStandardVATReportInPeriod(true);

                VATStatementName.SetRange("Statement Template Name", "Statement Template Name");
                VATStatementName.SetRange(Name, "Statement Name");
                VATStatementName.SetRange("Date Filter", "Start Date", "End Date");

                VATStatementName.CopyFilter("Date Filter", VATStatementLine."Date Filter");

                VATStatementLine.SetRange("Statement Template Name", "Statement Template Name");
                VATStatementLine.SetRange("Statement Name", "Statement Name");
                VATStatementLine.SetFilter("Box No.", '<>%1', '');
                VATStatementLine.FindSet();

                BindSubscription(VATStatementHandlerCZL);
                VATStatement.InitializeRequest(
                  VATStatementName, VATStatementLine, VATStatementReportSelection, VATStatementReportPeriodSelection, RoundToInteger, "Amounts in Add. Rep. Currency");
                VATStatementHandlerCZL.Initialize(
                  VATStatementName, VATStatementLine, VATStatementReportSelection, VATStatementReportPeriodSelection, RoundToInteger,
                  "Amounts in Add. Rep. Currency", "Start Date", "End Date", '', RoundingDirection);

                VATStatementReportLine.SetRange("VAT Report No.", "No.");
                VATStatementReportLine.SetRange("VAT Report Config. Code", "VAT Report Config. Code");
                VATStatementReportLine.DeleteAll();

                VATStmtReportLineDataCZL.SetCurrentKey("VAT Report No.", "VAT Report Config. Code");
                VATStmtReportLineDataCZL.SetRange("VAT Report No.", "No.");
                VATStmtReportLineDataCZL.SetRange("VAT Report Config. Code", "VAT Report Config. Code");
                VATStmtReportLineDataCZL.DeleteAll();

                LineNo := 0;
                repeat
                    VATAttributeCodeCZL.Get(VATStatementLine."Statement Template Name", VATStatementLine."Attribute Code CZL");
                    if not SkipVATStatementLine("VAT Report Header", VATAttributeCodeCZL) then begin
                        VATStatement.CalcLineTotal(VATStatementLine, Amount, 0);
                        case VATStatementLine."Show CZL" of
                            VATStatementLine."Show CZL"::"Zero If Negative":
                                if Amount < 0 then
                                    Amount := 0;
                            VATStatementLine."Show CZL"::"Zero If Positive":
                                if Amount > 0 then
                                    Amount := 0;
                        end;
                        if VATStatementLine."Print with" = VATStatementLine."Print with"::"Opposite Sign" then
                            Amount := -Amount;

                        TempVATStatementReportLine.SetRange("Box No.", VATStatementLine."Box No.");
                        if not TempVATStatementReportLine.FindFirst() then begin
                            LineNo += 10000;
                            TempVATStatementReportLine.Init();
                            TempVATStatementReportLine."VAT Report No." := "No.";
                            TempVATStatementReportLine."VAT Report Config. Code" := "VAT Report Config. Code";
                            TempVATStatementReportLine."Line No." := LineNo;
                            TempVATStatementReportLine."Box No." := VATStatementLine."Box No.";
                            TempVATStatementReportLine."Row No." :=
                                CopyStr(TempVATStatementReportLine."Box No.", 1, MaxStrLen(TempVATStatementReportLine."Row No."));
                            TempVATStatementReportLine.Description := StrSubstNo(RowsLbl, TempVATStatementReportLine."Box No.");
                            TempVATStatementReportLine.Insert();
                        end;

                        TempVATStmtReportLineDataCZL.Init();
                        TempVATStmtReportLineDataCZL.CopyFrom(TempVATStatementReportLine);
                        TempVATStmtReportLineDataCZL.CopyFrom(VATStatementLine);
                        TempVATStmtReportLineDataCZL.CopyFrom(VATAttributeCodeCZL);
                        TempVATStmtReportLineDataCZL.Amount := Amount;
                        TempVATStmtReportLineDataCZL.Insert();
                    end;
                until VATStatementLine.Next() = 0;
                UnbindSubscription(VATStatementHandlerCZL);

                TempVATStatementReportLine.Reset();
                if TempVATStatementReportLine.FindSet() then
                    repeat
                        VATStatementReportLine.Init();
                        VATStatementReportLine := TempVATStatementReportLine;
                        VATStatementReportLine.Validate("VAT Report No.");
                        VATStatementReportLine.Validate("VAT Report Config. Code");
                        VATStatementReportLine.Validate("Line No.");
                        VATStatementReportLine.Validate("Box No.");
                        VATStatementReportLine.Validate("Row No.");
                        VATStatementReportLine.Validate(Description);
                        VATStatementReportLine.Insert(true);

                        TempVATStmtReportLineDataCZL.SetFilterTo(TempVATStatementReportLine);
                        if TempVATStmtReportLineDataCZL.FindSet() then
                            repeat
                                VATStmtReportLineDataCZL.Init();
                                VATStmtReportLineDataCZL := TempVATStmtReportLineDataCZL;
                                VATStmtReportLineDataCZL."VAT Report Line No." := VATStatementReportLine."Line No.";
                                VATStmtReportLineDataCZL.Insert(true);
                            until TempVATStmtReportLineDataCZL.Next() = 0;
                    until TempVATStatementReportLine.Next() = 0;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        ShowFilter = false;
        SourceTable = "VAT Report Header";

        layout
        {
            area(content)
            {
                group(Options)
                {
                    field(Selection; VATStatementReportSelection)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Include VAT entries';
                        ShowMandatory = true;
                        ToolTip = 'Specifies whether to include VAT entries based on their status. For example, Open is useful when submitting for the first time, Open and Closed is useful when resubmitting.';
                    }
                    field(PeriodSelection; VATStatementReportPeriodSelection)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Include VAT entries';
                        ShowMandatory = true;
                        ToolTip = 'Specifies whether to include VAT entries only from the specified period, or also from previous periods within the specified year.';
                    }
                    field(VATStatementTemplate; Rec."Statement Template Name")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'VAT Statement Template';
                        ShowMandatory = true;
                        TableRelation = "VAT Statement Template";
                        ToolTip = 'Specifies the VAT Statement to generate the VAT report.';
                    }
                    field(VATStatementName; Rec."Statement Name")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'VAT Statement Name';
                        LookupPageID = "VAT Statement Names";
                        ShowMandatory = true;
                        TableRelation = "VAT Statement Name".Name where("Statement Template Name" = field("Statement Template Name"));
                        ToolTip = 'Specifies the VAT Statement to generate the VAT report.';
                    }
                    field("Period Year"; Rec."Period Year")
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = PeriodIsEditable;
                        ToolTip = 'Specifies the year of the reporting period.';
                    }
                    field("Period Type"; Rec."Period Type")
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = PeriodIsEditable;
                        ToolTip = 'Specifies the length of the reporting period.';
                    }
                    field("Period No."; Rec."Period No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = PeriodIsEditable;
                        ToolTip = 'Specifies the specific reporting period to use.';
                    }
                    field("Start Date"; Rec."Start Date")
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = PeriodIsEditable;
                        Importance = Additional;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the first date of the reporting period.';
                    }
                    field("End Date"; Rec."End Date")
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = PeriodIsEditable;
                        Importance = Additional;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the last date of the reporting period.';
                    }
                    field("Amounts in ACY"; Rec."Amounts in Add. Rep. Currency")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Amounts in Add. Reporting Currency';
                        Importance = Additional;
                        ToolTip = 'Specifies if you want to report amounts in the additional reporting currency.';
                    }
                    field(RoundToIntegerField; RoundToInteger)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Round to Integer';
                        ToolTip = 'Specifies if the vat statement will be rounded to integer';
                    }
                    group(RoundingDirectionGroup)
                    {
                        ShowCaption = false;
                        Visible = RoundToInteger;

                        field(RoundingDirectionField; RoundingDirection)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Rounding Direction';
                            OptionCaption = 'Nearest,Down,Up';
                            ToolTip = 'Specifies rounding direction';
                        }
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            Rec.CopyFilters("VAT Report Header");
            Rec.FindFirst();

            PeriodIsEditable := Rec."Return Period No." = '';
            RoundToInteger := true;
            OnAfterSetPeriodIsEditable(Rec, PeriodIsEditable);
        end;
    }

    var
        PeriodIsEditable: Boolean;
        RowsLbl: Label 'Rows %1', Comment = '%1 = box no.';

    protected var
        VATStatementReportSelection: Enum "VAT Statement Report Selection";
        VATStatementReportPeriodSelection: Enum "VAT Statement Report Period Selection";
        RoundToInteger: Boolean;
        RoundingDirection: Option Nearest,Down,Up;

    local procedure SkipVATStatementLine(VATReportHeader: Record "VAT Report Header"; VATAttributeCodeCZL: Record "VAT Attribute Code CZL"): Boolean
    begin
        exit(((VATReportHeader."VAT Report Type" = VATReportHeader."VAT Report Type"::Supplementary) and
              (VATAttributeCodeCZL."XML Code" in ['dano_no', 'dano_da'])) or
             ((VATReportHeader."VAT Report Type" <> VATReportHeader."VAT Report Type"::Supplementary) and
              (VATAttributeCodeCZL."XML Code" in ['dano'])));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetPeriodIsEditable(VATReportHeader: Record "VAT Report Header"; var PeriodIsEditable: Boolean)
    begin
    end;
}

