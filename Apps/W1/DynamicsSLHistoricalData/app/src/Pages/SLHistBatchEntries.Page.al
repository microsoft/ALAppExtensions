// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

page 42803 "SL Hist. Batch Entries"
{
    AdditionalSearchTerms = 'SL Batches, SL Historical Entries, SL Historical Batch Entries';
    ApplicationArea = Basic, Suite;
    Caption = 'SL Historical Batch Entries';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    MultipleNewLines = false;
    PageType = List;
    Permissions = TableData "SL Hist. Batch" = m;
    SourceTable = "SL Hist. Batch";
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Company ID"; Rec.CpnyID)
                {
                    Caption = 'Company ID';
                    Editable = false;
                    ToolTip = 'Specifies the Company ID that the batch belongs to.';
                }
                field("Account"; Rec.Acct)
                {
                    Caption = 'Account';
                    Editable = false;
                    ToolTip = 'Specifies the Account that the batch is associated with.';
                }
                field("Subaccount"; Rec.Sub)
                {
                    Caption = 'Subaccount';
                    Editable = false;
                    ToolTip = 'Specifies the Subaccount that the batch is associated with.';
                }
                field("Batch Number"; Rec.BatNbr)
                {
                    Caption = 'Batch Number';
                    Editable = false;
                    ToolTip = 'Specifies the Batch Number that the entry belongs to.';
                }
                field("Journal Type"; Rec.JrnlType)
                {
                    Caption = 'Journal Type';
                    Editable = false;
                    ToolTip = 'Specifies the Journal Type that the batch belongs to.';
                }
                field("Ledger ID"; Rec.LedgerID)
                {
                    Caption = 'Ledger ID';
                    Editable = false;
                    ToolTip = 'Specifies the Ledger ID that the batch is posted to.';
                }
                field("Description"; Rec.Descr)
                {
                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies the Description of the batch.';
                }
                field("Balance Type"; Rec.BalanceType)
                {
                    Caption = 'Balance Type';
                    Editable = false;
                    ToolTip = 'Specifies the Balance Type of the batch.';
                }
                field("Module"; Rec.Module)
                {
                    Caption = 'Module';
                    Editable = false;
                    ToolTip = 'Specifies the Module that the batch belongs to.';
                }
                field("Period Entered"; Rec.PerEnt)
                {
                    Caption = 'Period Entered';
                    Editable = false;
                    ToolTip = 'Specifies the period that the batch was entered.';
                }
                field("Period to Post"; Rec.PerPost)
                {
                    Caption = 'Period to Post';
                    Editable = false;
                    ToolTip = 'Specifies the period that the batch was posted to.';
                }
                field("Status"; Rec.Status)
                {
                    Caption = 'Status';
                    Editable = false;
                    ToolTip = 'Specifies the status of the batch.';
                }
                field("Credit Total"; Rec.CrTot)
                {
                    Caption = 'Credit Total';
                    Editable = false;
                    ToolTip = 'Specifies the credit total for the batch.';
                }
                field("Debit Total"; Rec.DrTot)
                {
                    Caption = 'Debit Total';
                    Editable = false;
                    ToolTip = 'Specifies the debit total for the batch.';
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
