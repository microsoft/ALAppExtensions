// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.Currency;
using Microsoft.Utilities;

page 31172 "Sales Advance Letter Line CZZ"
{
    Caption = 'Sales Advance Letter Line';
    PageType = ListPart;
    SourceTable = "Sales Adv. Letter Line CZZ";
    DelayedInsert = true;
    MultipleNewLines = true;
    LinksAllowed = false;
    AutoSplitKey = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT prod. posting group.';

                    trigger OnValidate()
                    begin
                        DeltaUpdateTotals();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies description.';
                }
                field("VAT %"; Rec."VAT %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT %.';
                    BlankZero = true;
                }
                field("VAT Calculation Type"; Rec."VAT Calculation Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT calculation type.';
                    Visible = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies amount';
                    BlankZero = true;
                    Visible = false;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT Amount';
                    BlankZero = true;
                    Visible = false;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies amount including VAT.';
                    BlankZero = true;

                    trigger OnValidate()
                    begin
                        DeltaUpdateTotals();
                    end;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies amount (LCY).';
                    BlankZero = true;
                    Visible = false;
                }
                field("VAT Amount (LCY)"; Rec."VAT Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT amount (LCY).';
                    BlankZero = true;
                    Visible = false;
                }
                field("Amount Including VAT (LCY)"; Rec."Amount Including VAT (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies amount including VAT (LCY).';
                    BlankZero = true;
                    Visible = false;
                }
            }
            group(Totals)
            {
                ShowCaption = false;
                field("Total Amount Incl. VAT"; SalesAdvLetterLineCZZ."Amount Including VAT")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Currency.Code;
                    AutoFormatType = 1;
                    CaptionClass = DocumentTotals.GetTotalInclVATCaption(Currency.Code);
                    Caption = 'Total Amount Incl. VAT';
                    Editable = false;
                    ToolTip = 'Specifies the sum of the value in the Line Amount Incl. VAT field on all lines in the document.';
                }
                field("Total Amount Incl. VAT (LCY)"; SalesAdvLetterLineCZZ."Amount Including VAT (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Currency.Code;
                    AutoFormatType = 1;
                    CaptionClass = DocumentTotals.GetTotalInclVATCaption('');
                    Caption = 'Total Amount Incl. VAT';
                    Editable = false;
                    ToolTip = 'Specifies the sum of the value in the Line Amount Incl. VAT field on all lines in the document.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        SuppressTotals := CurrentClientType() = ClientType::ODataV4;
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        AdvanceLetterDocTotalsCZZ.SalesCheckAndClearTotals(Rec, xRec, SalesAdvLetterLineCZZ);
        exit(Rec.Find(Which));
    end;

    trigger OnModifyRecord(): Boolean
    begin
        AdvanceLetterDocTotalsCZZ.SalesCheckIfDocumentChanged(Rec, xRec);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        GetTotalSalesHeader();
        CalculateTotals();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        AdvanceLetterDocTotalsCZZ.SalesDocTotalsNotUpToDate();
    end;

    var
        Currency: Record Currency;
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        AdvanceLetterDocTotalsCZZ: Codeunit "Advance Letter Doc. Totals CZZ";
        DocumentTotals: Codeunit "Document Totals";
        SuppressTotals: Boolean;

    local procedure GetTotalSalesHeader()
    begin
        AdvanceLetterDocTotalsCZZ.GetTotalSalesHeaderAndCurrency(Rec, SalesAdvLetterHeaderCZZ, Currency);
    end;

    local procedure CalculateTotals()
    begin
        if SuppressTotals then
            exit;

        AdvanceLetterDocTotalsCZZ.SalesCheckIfDocumentChanged(Rec, xRec);
        AdvanceLetterDocTotalsCZZ.CalculateSalesSubPageTotals(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);
    end;

    procedure DeltaUpdateTotals()
    begin
        if SuppressTotals then
            exit;

        AdvanceLetterDocTotalsCZZ.SalesDeltaUpdateTotals(Rec, xRec, SalesAdvLetterLineCZZ);
    end;

    procedure ClearAdvLetterDocTotals()
    begin
        Clear(AdvanceLetterDocTotalsCZZ);
        Clear(SalesAdvLetterHeaderCZZ);
        Clear(Currency);
    end;
}
