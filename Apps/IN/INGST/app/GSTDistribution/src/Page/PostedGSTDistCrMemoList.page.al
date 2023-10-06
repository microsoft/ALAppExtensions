// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

page 18209 "Posted GST Dist.-Cr. Memo List"
{
    Caption = 'Posted GST Dist.-Cr. Memo List';
    CardPageID = "Posted GST Dist.- Cr. Memo";
    Editable = false;
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;
    SourceTable = "Posted GST Distribution Header";
    SourceTableView = where("ISD Document Type" = const("Credit Memo"));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the transaction.';
                }
                field("From GSTIN No."; Rec."From GSTIN No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST registration number  of the GST distribution location.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry''s posting date.';
                }
                field("Dist. Document Type"; Rec."Dist. Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type of the posted transaction.';
                }
                field(Reversal; Rec.Reversal)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the document is for reversal purpose.';
                }
                field("Reversal Invoice No."; Rec."Reversal Invoice No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the invoice number of distribution in case of reversal.';
                }
                field("ISD Document Type"; Rec."ISD Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type of input service distribution.';
                }
                field("From Location Code"; Rec."From Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location from which GST credit will be distributed.';
                }
                field("Dist. Credit Type"; Rec."Dist. Credit Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the credit type has to be availed or not.';
                }
                field("Pre Distribution No."; Rec."Pre Distribution No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number assigned to the distribution before posting.';
                }
            }
        }
    }
}

