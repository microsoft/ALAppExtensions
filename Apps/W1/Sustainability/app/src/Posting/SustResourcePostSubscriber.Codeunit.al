// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Posting;

using Microsoft.Projects.Resources.Journal;
using Microsoft.Projects.Resources.Ledger;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Setup;

codeunit 6286 "Sust. Resource Post Subscriber"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Res. Jnl.-Post Line", 'OnAfterResLedgEntryInsert', '', false, false)]
    local procedure OnAfterResLedgEntryInsert(ResJournalLine: Record "Res. Journal Line"; var ResLedgerEntry: Record "Res. Ledger Entry")
    begin
        if CanCreateSustValueEntry(ResJournalLine) then
            PostSustainabilityValueEntry(ResJournalLine, ResLedgerEntry);
    end;

    local procedure CanCreateSustValueEntry(ResJournalLine: Record "Res. Journal Line"): Boolean
    begin
        if not SustainabilitySetup.IsValueChainTrackingEnabled() then
            exit(false);

        exit(ResJournalLine."Sust. Account No." <> '');
    end;

    local procedure PostSustainabilityValueEntry(var ResJournalLine: Record "Res. Journal Line"; var ResLedgerEntry: Record "Res. Ledger Entry")
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
    begin
        SustainabilityJnlLine.Init();
        SustainabilityJnlLine."Journal Template Name" := '';
        SustainabilityJnlLine."Journal Batch Name" := '';
        SustainabilityJnlLine."Source Code" := ResJournalLine."Source Code";
        SustainabilityJnlLine.Validate("Posting Date", ResJournalLine."Posting Date");
        SustainabilityJnlLine.Validate("Document No.", ResJournalLine."Document No.");
        SustainabilityJnlLine.Validate("Account No.", ResJournalLine."Sust. Account No.");
        SustainabilityJnlLine.Validate("Reason Code", ResJournalLine."Reason Code");
        SustainabilityJnlLine.Validate("Account Category", ResJournalLine."Sust. Account Category");
        SustainabilityJnlLine.Validate("Account Subcategory", ResJournalLine."Sust. Account Subcategory");
        SustainabilityJnlLine.Validate("Unit of Measure", SustainabilitySetup."Emission Unit of Measure Code");
        SustainabilityJnlLine."Dimension Set ID" := ResLedgerEntry."Dimension Set ID";
        SustainabilityJnlLine."Shortcut Dimension 1 Code" := ResLedgerEntry."Global Dimension 1 Code";
        SustainabilityJnlLine."Shortcut Dimension 2 Code" := ResLedgerEntry."Global Dimension 2 Code";
        SustainabilityJnlLine.Validate("CO2e Emission", ResJournalLine."Total CO2e");
        SustainabilityPostMgt.InsertValueEntry(SustainabilityJnlLine, ResLedgerEntry);
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
}