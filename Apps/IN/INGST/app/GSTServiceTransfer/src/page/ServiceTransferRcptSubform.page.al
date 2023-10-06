// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ServicesTransfer;

page 18359 "Service Transfer Rcpt. Subform"
{
    AutoSplitKey = true;
    Caption = 'Service Transfer Rcpt. Subform';
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Service Transfer Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Transfer To G/L Account No."; Rec."Transfer To G/L Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the service general ledger account to which service transfer receive value will be posted.';
                }
                field("Transfer Price"; Rec."Transfer Price")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of service received.';
                }
                field("GST Group Code"; Rec."GST Group Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Group code for the calculation of GST on Service line.';
                }
                field("SAC Code"; Rec."SAC Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the SAC code for the calculation of GST on Service line.';
                }
                field(Shipped; Rec.Shipped)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the transaction has been shipped or not.';
                }
                field("Receive Control A/C No."; Rec."Receive Control A/C No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number which will be used as receive control account.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the code for global dimension 1, which is one of two global dimension codes that you can setup in general ledger setup window.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the code for global dimension 2, which is one of two global dimension codes that you can setup in general ledger setup window.';
                }
            }
        }
    }
}
