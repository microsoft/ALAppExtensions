// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.WithholdingTax;

pageextension 6793 "Withholding G/L Registers" extends "G/L Registers"
{
    layout
    {
        addafter("To VAT Entry No.")
        {
            field("From Withholding Tax Entry No."; Rec."From Withholding Tax Entry No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the first withholding tax entry number in the register.';
            }
            field("To Withholding Tax Entry No."; Rec."To Withholding Tax Entry No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the last withholding tax entry number in the register.';
            }
        }
    }
    actions
    {
        addlast(processing)
        {
            action("Withholding Tax Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Withholding Tax Entries';
                RunObject = Codeunit "G/L Reg.-Withholding Entries";
                Image = Register;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'View the withholding tax entries for the register.';
            }
        }
    }
}