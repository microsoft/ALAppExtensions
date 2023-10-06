// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

page 18935 "Posted Narration"
{
    Caption = 'Posted Narration';
    PageType = List;
    SourceTable = "Posted Narration";
    Editable = false;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("Document Type"; "Document Type")
                {
                    Caption = 'Document Type';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type that the posted voucher line belongs to.';
                }
                field("Document No."; "Document No.")
                {
                    Caption = 'Document No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies document number of the journal line posted.';
                }
                field("Posting Date"; "Posting Date")
                {
                    Caption = 'Posting Date';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date that the posted voucher line belongs to.';
                }
                field(Narration; Narration)
                {
                    Caption = 'Narration';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the narration that the posted voucher line belongs to.';
                }
            }
        }
    }
}
