// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

page 31176 "Sales Adv. Letter FactBox CZZ"
{
    Caption = 'Sales Advance Letter';
    PageType = CardPart;
    SourceTable = "Sales Adv. Letter Header CZZ";
    Editable = false;

    layout
    {
        area(content)
        {
            field("Amount Including VAT"; Rec."Amount Including VAT")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies amount including VAT.';
            }
            field("Amount Including VAT (LCY)"; Rec."Amount Including VAT (LCY)")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies amount including VAT (LCY).';
            }
            field("To Pay"; Rec."To Pay")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies to pay.';
            }
            field("To Use"; Rec."To Use")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies to use.';
            }
            field("To Use (LCY)"; Rec."To Use (LCY)")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies to use (LCY).';
            }
            field("VAT Base Amount"; -VATBaseAmount)
            {
                Caption = 'VAT Base Amount';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies VAT base amount.';
                BlankZero = true;
            }
            field("VAT Base Amount (LCY)"; -VATBaseAmountLCY)
            {
                Caption = 'VAT Base Amount (LCY)';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies VAT base amount (LCY).';
                BlankZero = true;
            }
            field("VAT Amount"; -VATAmount)
            {
                Caption = 'VAT Amount';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies VAT amount.';
                BlankZero = true;
            }
            field("VAT Amount (LCY)"; -VATAmountLCY)
            {
                Caption = 'VAT Amount (LCY)';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies VAT amount (LCY).';
                BlankZero = true;
            }
        }
    }

    var
        VATBaseAmount: Decimal;
        VATAmount: Decimal;
        VATBaseAmountLCY: Decimal;
        VATAmountLCY: Decimal;

    trigger OnAfterGetRecord()
    begin
        Rec.GetVATAmounts(VATBaseAmount, VATAmount, VATBaseAmountLCY, VATAmountLCY);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(VATBaseAmount);
        Clear(VATAmount);
        Clear(VATBaseAmountLCY);
        Clear(VATAmountLCY);
    end;
}
