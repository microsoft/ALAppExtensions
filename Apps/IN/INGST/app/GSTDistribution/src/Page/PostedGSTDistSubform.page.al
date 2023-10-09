// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

page 18212 "Posted GST Dist. Subform"
{
    Caption = 'Posted GST Dist. Subform';
    PageType = ListPart;
    SourceTable = "Posted GST Distribution Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Distribution No."; Rec."Distribution No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number for this transaction.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line number of the document.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry''s posting date.';
                }
                field("From GSTIN No."; Rec."From GSTIN No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GSTIN of posted distribution line.';
                }
                field("Rcpt. GST Credit Type"; Rec."Rcpt. GST Credit Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the credit type of posted distribution line.';
                }
                field("From Location Code"; Rec."From Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location from which GST credit will be distributed.';
                }
                field("To Location Code"; Rec."To Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location to which GST credit has been distributed.';
                }
                field("To GSTIN No."; Rec."To GSTIN No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GSTIN number of the location to which distribution line was posted.';
                }
                field("Distribution Jurisdiction"; Rec."Distribution Jurisdiction")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST jurisdiction of the posted distribution line.';
                }
                field("Distribution %"; Rec."Distribution %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the distribution % of the posted distribution line.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for global dimension 1, which is one of two global dimension codes that you can setup in general ledger setup window.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for global dimension 2, which is one of two global dimension codes that you can setup in general ledger setup window.';
                }
                field("Distribution Amount"; Rec."Distribution Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the distribution amount in posted line.';
                }
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the dimension set id assigned by system to the posted distribution line.';
                }
            }
        }
    }
}

