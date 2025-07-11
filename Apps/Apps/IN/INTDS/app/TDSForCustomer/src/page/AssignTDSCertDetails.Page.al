// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSForCustomer;

using Microsoft.Sales.Receivables;

page 18665 "Assign TDS Cert. Details"
{
    Caption = 'Assign TDS Cert. Details';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    Permissions = TableData "Cust. Ledger Entry" = rm;
    SourceTable = "Cust. Ledger Entry";
    SourceTableView = sorting("Entry No.")
                      where("TDS Certificate Receivable" = const(false));

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the entry, when the entry was created.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the customer number from whom TDS certificate is received.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the posting date of the customer ledger entry.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of document of the customer ledger entry.';
                }
                field("Document No."; Rec."Document No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the customer ledger entry.';
                }
                field(Amount; Rec.Amount)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of the customer ledger entry.';
                }
                field("TDS Certificate Receivable"; Rec."TDS Certificate Receivable")
                {
                    Editable = true;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify customer ledger entries against which TDS certificate is receivable.';
                }
            }
        }
    }
}
