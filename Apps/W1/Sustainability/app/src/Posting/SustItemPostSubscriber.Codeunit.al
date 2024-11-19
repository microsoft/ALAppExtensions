namespace Microsoft.Sustainability.Posting;

using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Posting;
using Microsoft.Sustainability.Journal;

codeunit 6256 "Sust. Item Post Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInsertValueEntry', '', false, false)]
    local procedure OnBeforeInsertValueEntry(ItemJournalLine: Record "Item Journal Line"; var ValueEntry: Record "Value Entry"; var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        if CanCreateSustValueEntry(ItemJournalLine, ValueEntry) then
            PostSustainabilityValueEntry(ItemJournalLine, ValueEntry, ItemLedgerEntry);
    end;

    local procedure CanCreateSustValueEntry(ItemJournalLine: Record "Item Journal Line"; var ValueEntry: Record "Value Entry"): Boolean
    begin
        exit((ItemJournalLine."Sust. Account No." <> '') and (ValueEntry."Entry Type" = ValueEntry."Entry Type"::"Direct Cost"));
    end;

    local procedure PostSustainabilityValueEntry(ItemJournalLine: Record "Item Journal Line"; ValueEntry: Record "Value Entry"; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
    begin
        SustainabilityJnlLine.Init();
        SustainabilityJnlLine.Validate("Posting Date", ItemJournalLine."Posting Date");
        SustainabilityJnlLine.Validate("Document No.", ValueEntry."Document No.");
        SustainabilityJnlLine.Validate("Account No.", ItemJournalLine."Sust. Account No.");
        SustainabilityJnlLine.Validate("Account Category", ItemJournalLine."Sust. Account Category");
        SustainabilityJnlLine.Validate("Account Subcategory", ItemJournalLine."Sust. Account Subcategory");
        SustainabilityJnlLine."Dimension Set ID" := ItemJournalLine."Dimension Set ID";
        SustainabilityJnlLine."Shortcut Dimension 1 Code" := ItemJournalLine."Shortcut Dimension 1 Code";
        SustainabilityJnlLine."Shortcut Dimension 2 Code" := ItemJournalLine."Shortcut Dimension 2 Code";
        SustainabilityJnlLine.Validate("Emission CO2", ItemJournalLine."Emission CO2");
        SustainabilityJnlLine.Validate("Emission CH4", ItemJournalLine."Emission CH4");
        SustainabilityJnlLine.Validate("Emission N2O", ItemJournalLine."Emission N2O");
        SustainabilityJnlLine.Validate("Country/Region Code", ItemJournalLine."Country/Region Code");
        SustainabilityPostMgt.InsertValueEntry(SustainabilityJnlLine, ValueEntry, ItemLedgerEntry);
    end;
}