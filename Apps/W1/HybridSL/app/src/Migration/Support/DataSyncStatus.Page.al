// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using System.Integration;
using Microsoft.Finance.GeneralLedger.Journal;

page 42003 SLDataSyncStatus
{
    ApplicationArea = All;
    Caption = 'Data Sync Status';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            part("Data Migration Status"; "Data Migration Overview Part")
            {
                ApplicationArea = All;
                Visible = ShowMigrationErrors;
            }
            part("Migration Errors"; "Data Migration Error Part")
            {
                ApplicationArea = All;
                Caption = 'Migration Errors';
                SubPageView = where("Destination Table ID" = filter(> 0));
                Visible = ShowMigrationErrors;
            }
            part("Posting Errors"; "Data Migration Error Part")
            {
                ApplicationArea = All;
                Caption = 'Posting Errors';
                SubPageView = where("Destination Table ID" = filter(= 0));
                Visible = not ShowMigrationErrors;
            }
        }
    }

    var
        GenJournalLine: Record "Gen. Journal Line";
        ShowMigrationErrors: Boolean;
        SLBatchTxt: Label 'SL*', Locked = true;
        CustomerBatchTxt: Label 'SLCUST', Locked = true;
        VendorBatchTxt: Label 'SLVEND', Locked = true;
        JnlTemplateNameTxt: Label 'GENERAL', Locked = true;

    internal procedure PostingErrors(JournalBatchName: Text)
    var
        SkipPostingErrors: Boolean;
    begin
        OnSkipPostingErrors(SkipPostingErrors, JournalBatchName);
        if SkipPostingErrors then
            exit;

        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", JnlTemplateNameTxt);
        GenJournalLine.SetFilter("Journal Batch Name", JournalBatchName);
        if GenJournalLine.FindSet() then
            Report.Run(Report::"Auto Posting Errors", false, false, GenJournalLine);
    end;

    internal procedure ParsePosting()
    var
        DataMigrationStatus: Record "Data Migration Status";
    begin
        DataMigrationStatus.Reset();
        if not DataMigrationStatus.IsEmpty() then begin
            PostingErrors(SLBatchTxt);
            PostingErrors(VendorBatchTxt);
            PostingErrors(CustomerBatchTxt);
        end;
    end;

    internal procedure SetMigrationVisibility(IsMigration: Boolean)
    begin
        ShowMigrationErrors := IsMigration;
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSkipPostingErrors(var SkipPostingErrors: Boolean; JournalBatchName: Text)
    begin
    end;
}
