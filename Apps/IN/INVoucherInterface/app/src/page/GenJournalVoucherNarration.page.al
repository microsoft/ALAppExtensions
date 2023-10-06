// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

using Microsoft.Finance.TaxBase;

page 18932 "Gen. Journal Voucher Narration"
{
    AutoSplitKey = true;
    Caption = 'Voucher Narration';
    DelayedInsert = true;
    PageType = Worksheet;
    SourceTable = "Gen. Journal Narration";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            field("Document No."; "Document No.")
            {
                Editable = false;
                ApplicationArea = Basic, Suite;
                Caption = 'Document No.';
                ToolTip = 'Specifies document number for which the voucher lines will be posted.';
            }
            repeater(Control1500000)
            {
                field(Narration; Narration)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Narration';
                    ToolTip = 'Select narration option to enter narration for a particular line.';
                }
            }
        }
    }
}
