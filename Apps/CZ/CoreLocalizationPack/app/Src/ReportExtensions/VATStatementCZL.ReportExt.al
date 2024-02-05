// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.VAT.Ledger;

reportextension 11703 "VAT Statement CZL" extends "VAT Statement"
{
    dataset
    {
        modify("VAT Statement Line")
        {
            trigger OnAfterAfterGetRecord()
            var
                TempTotalAmount: Decimal;
            begin
                if "Print with" = "Print with"::"Opposite Sign" then
                    TempTotalAmount := -TotalAmount;
                case "Show CZL" of
                    "Show CZL"::"Zero If Negative":
                        if TempTotalAmount < 0 then
                            TotalAmount := 0;
                    "Show CZL"::"Zero If Positive":
                        if TempTotalAmount > 0 then
                            TotalAmount := 0;
                end;
            end;
        }
    }

    requestpage
    {
        layout
        {
            modify(RoundToWholeNumbers)
            {
                trigger OnAfterValidate()
                begin
                    RoundingDirectionVisible := PrintInIntegers;
                end;
            }
            addafter(RoundToWholeNumbers)
            {
                group(RoundingDirectionGroupCZL)
                {
                    ShowCaption = false;
                    Visible = RoundingDirectionVisible;
                    field(RoundingDirectionCZL; RoundingDirection)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Rounding Direction';
                        OptionCaption = 'Nearest,Down,Up';
                        ToolTip = 'Specifies rounding direction of the vat statement';
                    }
                }
            }
            addafter(ShowAmtInAddCurrency)
            {
                field(SettlementNoFilterCZL; SettlementNoFilter)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Filter VAT Settlement No.';
                    ToolTip = 'Specifies the filter setup of document number which the VAT entries were closed.';
                }
            }
        }

        trigger OnOpenPage()
        begin
            RoundingDirectionVisible := PrintInIntegers;
        end;
    }

    trigger OnPreReport()
    var
        VATEntry: Record "VAT Entry";
    begin
        if SettlementNoFilter <> '' then
            Heading2 := Heading2 + ',' + VATEntry.FieldCaption("VAT Settlement No. CZL") + ':' + SettlementNoFilter;

        VATStatementHandler.Initialize(
            "VAT Statement Name", "VAT Statement Line", Selection, PeriodSelection, PrintInIntegers, UseAmtsInAddCurr,
            StartDate, EndDate, SettlementNoFilter, RoundingDirection);
        BindSubscription(VATStatementHandler);
    end;

    var
        VATStatementHandler: Codeunit "VAT Statement Handler CZL";
        SettlementNoFilter: Text[50];
        RoundingDirection: Option Nearest,Down,Up;
        RoundingDirectionVisible: Boolean;

    internal procedure GetAmtRoundingDirectionCZL() Direction: Text[1]
    begin
        case RoundingDirection of
            RoundingDirection::Nearest:
                Direction := '=';
            RoundingDirection::Up:
                Direction := '>';
            RoundingDirection::Down:
                Direction := '<';
        end;
    end;

    procedure InitializeRequestCZL(var NewVATStatementName: Record "VAT Statement Name"; var NewVATStatementLine: Record "VAT Statement Line"; NewSelection: Enum "VAT Statement Report Selection"; NewPeriodSelection: Enum "VAT Statement Report Period Selection"; NewPrintInIntegers: Boolean; NewUseAmtsInAddCurr: Boolean; NewSettlementNoFilter: Text[50]; NewRoundingDirection: Option)
    begin
        InitializeRequestCZL(NewVATStatementName, NewVATStatementLine, NewSelection, NewPeriodSelection, NewPrintInIntegers, NewUseAmtsInAddCurr, NewSettlementNoFilter, NewRoundingDirection, true);
    end;

    procedure InitializeRequestCZL(var NewVATStatementName: Record "VAT Statement Name"; var NewVATStatementLine: Record "VAT Statement Line"; NewSelection: Enum "VAT Statement Report Selection"; NewPeriodSelection: Enum "VAT Statement Report Period Selection"; NewPrintInIntegers: Boolean; NewUseAmtsInAddCurr: Boolean; NewSettlementNoFilter: Text[50]; NewRoundingDirection: Option; WithBinding: Boolean)
    begin
        InitializeRequest(NewVATStatementName, NewVATStatementLine, NewSelection, NewPeriodSelection, NewPrintInIntegers, NewUseAmtsInAddCurr);
        SettlementNoFilter := NewSettlementNoFilter;
        RoundingDirection := NewRoundingDirection;

        if WithBinding then begin
            Clear(VATStatementHandler);
            VATStatementHandler.Initialize(
                NewVATStatementName, NewVATStatementLine, NewSelection, NewPeriodSelection, NewPrintInIntegers, NewUseAmtsInAddCurr,
                StartDate, EndDate, SettlementNoFilter, RoundingDirection);
            BindSubscription(VATStatementHandler);
        end;
    end;
}