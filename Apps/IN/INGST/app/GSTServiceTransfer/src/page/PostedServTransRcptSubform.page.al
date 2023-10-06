// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ServicesTransfer;

page 18352 "Posted ServTrans Rcpt. Subform"
{
    AutoSplitKey = true;
    Caption = 'Posted ServTrans Rcpt. Subform';
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Service Transfer Rcpt. Line";

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
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of service received.';
                }
                field(Shipped; Rec.Shipped)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the transaction has been shipped or not.';
                }
                field(Exempted; Rec.Exempted)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the shipment line is exempted from GST.';
                }
                field("Receive Control A/C No."; Rec."Receive Control A/C No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number which will be used as receive control account.';
                }
            }
        }
    }
}
