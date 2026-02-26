// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

page 42800 "SL Hist. GLTran Entries"
{
    AdditionalSearchTerms = 'SL G/L Transactions, SL Historical Entries, SL Historical GL Entries';
    ApplicationArea = Basic, Suite;
    Caption = 'SL Historical Journal Transaction Entries';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    MultipleNewLines = false;
    PageType = List;
    SourceTable = "SL Hist. GLTran Archive";
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Module; Rec.Module)
                {
                    Editable = false;
                    ToolTip = 'Specifies the Module that the entry belongs to.';
                }
                field("Journal Type"; Rec.JrnlType)
                {
                    Caption = 'Journal Type';
                    Editable = false;
                    ToolTip = 'Specifies the Journal Type that the entry belongs to.';
                }
                field("Batch Number"; Rec.BatNbr)
                {
                    Caption = 'Batch Number';
                    Editable = false;
                    ToolTip = 'Specifies the Batch Number that the entry belongs to.';
                }
                field("Transaction Type"; Rec.TranType)
                {
                    Caption = 'Transaction Type';
                    Editable = false;
                    ToolTip = 'Specifies the Transaction Type that the entry belongs to.';
                }
                field("Company ID"; Rec.CpnyID)
                {
                    Caption = 'Company ID';
                    Editable = false;
                    ToolTip = 'Specifies the Company ID that the entry belongs to.';
                }
                field("Original Company ID"; Rec.OrigCpnyID)
                {
                    Caption = 'Original Company ID';
                    Editable = false;
                    ToolTip = 'Specifies the Original Company ID that the entry belongs to.';
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
                field("Reference Number"; Rec.RefNbr)
                {
                    Caption = 'Reference Number';
                    Editable = false;
                    ToolTip = 'Specifies the entry''s Reference Number';
                }
                field("Transaction Date"; Rec.TranDate)
                {
                    Caption = 'Transaction Date';
                    Editable = false;
                    ToolTip = 'Specifies the entry''s Transaction Date.';
                }
                field("Transaction Description"; Rec.TranDesc)
                {
                    Caption = 'Transaction Description';
                    Editable = false;
                    ToolTip = 'Specifies the entry''s Transaction Description.';
                }
                field("Debit Amount"; Rec.DrAmt)
                {
                    Caption = 'Debit Amount';
                    Editable = false;
                    ToolTip = 'Specifies the debit amount that was posted on the entry.';
                }
                field("Credit Amount"; Rec.CrAmt)
                {
                    Caption = 'Credit Amount';
                    Editable = false;
                    ToolTip = 'Specifies the credit amount that was posted on the entry.';
                }
                field("Period to Post"; Rec.PerPost)
                {
                    Caption = 'Period to Post';
                    Editable = false;
                    ToolTip = 'Specifies the period that the entry was posted to.';
                }
                field(Posted; Rec.Posted)
                {
                    Editable = false;
                    ToolTip = 'Specifies the entry''s Posted status.';
                }
                field(Released; Rec.Rlsed)
                {
                    ToolTip = 'Specifies the entry''s Released status.';
                }
                field("Ledger ID"; Rec.LedgerID)
                {
                    Caption = 'Ledger ID';
                    Editable = false;
                    ToolTip = 'Specifies the Ledger ID that the entry is posted to.';
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
                field("Employee ID"; Rec.EmployeeID)
                {
                    Caption = 'Employee ID';
                    Editable = false;
                    ToolTip = 'Specifies the Employee ID that the entry is associated with';
                    Visible = false;
                }
                field("Labor Class Code"; Rec.Labor_Class_Cd)
                {
                    Caption = 'Labor Class Code';
                    Editable = false;
                    ToolTip = 'Specifies the Labor Class Code that the entry is associated with.';
                    Visible = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if FilterAcct <> '' then
            Rec.SetRange(Acct, FilterAcct);

        if FilterLedgerID <> '' then
            Rec.SetRange(LedgerID, FilterLedgerID);
    end;

    procedure SetFilterAcct(Acct: Text[10])
    begin
        FilterAcct := Acct;
    end;

    procedure SetLedgerID(LedgerID: Code[10])
    begin
        FilterLedgerID := LedgerID;
    end;

    var
        FilterAcct: Text[10];
        FilterLedgerID: Code[10];
}