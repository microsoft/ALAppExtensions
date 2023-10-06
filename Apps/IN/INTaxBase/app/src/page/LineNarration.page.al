// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

page 18551 "Line Narration"
{
    AutoSplitKey = true;
    Caption = 'Line Narration';
    DelayedInsert = true;
    PageType = Worksheet;
    SourceTable = "Gen. Journal Narration";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            field("Document No."; Rec."Document No.")
            {
                Editable = false;
                ApplicationArea = Basic, Suite;
                Caption = 'Document No.';
                ToolTip = 'Specifies the document number for which the voucher lines will be posted.';
            }
            repeater(Control1500000)
            {
                field(Narration; Rec.Narration)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Narration';
                    ToolTip = 'Specifies the narration option of a voucher.';
                }
            }
        }
    }
}
