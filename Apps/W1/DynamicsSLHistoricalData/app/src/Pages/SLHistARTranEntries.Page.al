// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

page 42801 "SL Hist. ARTran Entries"
{
    AdditionalSearchTerms = 'SL AR Transactions, SL Historical Entries, SL Historical AR Entries, SL Receivables Transactions';
    ApplicationArea = Basic, Suite;
    Caption = 'SL Historical Accounts Receivable Transaction Entries';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    MultipleNewLines = false;
    PageType = List;
    SourceTable = "SL Hist. ARTran Archive";
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Customer ID"; Rec.CustID)
                {
                    Caption = 'Customer ID';
                    Editable = false;
                    ToolTip = 'Specifies the Customer ID that the entry is associated with.';
                }
                field("Transaction Type"; Rec.TranType)
                {
                    Caption = 'Transaction Type';
                    Editable = false;
                    ToolTip = 'Specifies the Transaction Type that the entry belongs to.';
                }
                field("Reference Number"; Rec.RefNbr)
                {
                    Caption = 'Reference Number';
                    Editable = false;
                    ToolTip = 'Specifies the entry''s Reference Number';
                }
                field("Batch Number"; Rec.BatNbr)
                {
                    Caption = 'Batch Number';
                    Editable = false;
                    ToolTip = 'Specifies the Batch Number that the entry belongs to.';
                }
                field(Released; Rec.Rlsed)
                {
                    ToolTip = 'Specifies the entry''s Released status.';
                }
                field("Transaction Description"; Rec.TranDesc)
                {
                    Caption = 'Transaction Description';
                    Editable = false;
                    ToolTip = 'Specifies the entry''s Transaction Description.';
                }
                field("Qty"; Rec.Qty)
                {
                    Caption = 'Quantity';
                    Editable = false;
                    ToolTip = 'Specifies the quantity that was posted on the entry.';
                }
                field("Unit Price"; Rec.UnitPrice)
                {
                    Caption = 'Unit Price';
                    Editable = false;
                    ToolTip = 'Specifies the Unit Price that was posted on the entry.';
                }
                field("Transaction Amount"; Rec.TranAmt)
                {
                    Caption = 'Transaction Amount';
                    Editable = false;
                    ToolTip = 'Specifies the Transaction Amount that was posted on the entry.';
                }
                field("Transaction Date"; Rec.TranDate)
                {
                    Caption = 'Transaction Date';
                    Editable = false;
                    ToolTip = 'Specifies the entry''s Transaction Date.';
                }
                field("Period to Post"; Rec.PerPost)
                {
                    Caption = 'Period to Post';
                    Editable = false;
                    ToolTip = 'Specifies the period that the entry was posted to.';
                }
                field("Company ID"; Rec.CpnyID)
                {
                    Caption = 'Company ID';
                    Editable = false;
                    ToolTip = 'Specifies the Company ID that the entry belongs to.';
                }
                field("Account"; Rec.Acct)
                {
                    Caption = 'Account';
                    Editable = false;
                    ToolTip = 'Specifies the Account that the entry has been posted to.';
                }
                field("Subaccount"; Rec.Sub)
                {
                    Caption = 'Subaccount';
                    Editable = false;
                    ToolTip = 'Specifies the Subaccount that the entry has been posted to.';
                }
                field("Project ID"; Rec.ProjectID)
                {
                    Caption = 'Project ID';
                    Editable = false;
                    ToolTip = 'Specifies the Project ID that the entry is associated with.';
                    Visible = false;
                }
                field("Task ID"; Rec.TaskID)
                {
                    Caption = 'Task ID';
                    Editable = false;
                    ToolTip = 'Specifies the Task ID that the entry is associated with.';
                    Visible = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if FilterAcct <> '' then
            Rec.SetRange(Acct, FilterAcct);
    end;

    procedure SetFilterAcct(Acct: Text[10])
    begin
        FilterAcct := Acct;
    end;

    var
        FilterAcct: Text[10];
}