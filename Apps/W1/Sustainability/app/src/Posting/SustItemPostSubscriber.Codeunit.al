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
        if ValueEntry."Order Type" = ValueEntry."Order Type"::Transfer then
            if (ValueEntry."Document Type" = ValueEntry."Document Type"::"Transfer Shipment") and (ValueEntry."Valued Quantity" > 0) then
                exit(false)
            else
                if (ValueEntry."Document Type" = ValueEntry."Document Type"::"Transfer Receipt") and (ValueEntry."Valued Quantity" < 0) then
                    exit(false);

        exit((ItemJournalLine."Sust. Account No." <> '') and (ValueEntry."Entry Type" = ValueEntry."Entry Type"::"Direct Cost"));
    end;

    local procedure PostSustainabilityValueEntry(ItemJournalLine: Record "Item Journal Line"; ValueEntry: Record "Value Entry"; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        GHGCredit: Boolean;
        Sign: Integer;
    begin
        if ItemJournalLine."Order Type" = ItemJournalLine."Order Type"::Production then begin
            GHGCredit := ItemJournalLine.IsGHGCreditLine();
            Sign := ItemJournalLine.GetPostingSign(GHGCredit);
        end;

        SustainabilityJnlLine.Init();
        SustainabilityJnlLine.Validate("Posting Date", ItemJournalLine."Posting Date");
        SustainabilityJnlLine.Validate("Document No.", ValueEntry."Document No.");
        SustainabilityJnlLine.Validate("Account No.", ItemJournalLine."Sust. Account No.");
        SustainabilityJnlLine.Validate("Account Category", ItemJournalLine."Sust. Account Category");
        SustainabilityJnlLine.Validate("Account Subcategory", ItemJournalLine."Sust. Account Subcategory");
        SustainabilityJnlLine."Dimension Set ID" := ItemJournalLine."Dimension Set ID";
        SustainabilityJnlLine."Shortcut Dimension 1 Code" := ItemJournalLine."Shortcut Dimension 1 Code";
        SustainabilityJnlLine."Shortcut Dimension 2 Code" := ItemJournalLine."Shortcut Dimension 2 Code";

        If ItemJournalLine."Order Type" = ItemJournalLine."Order Type"::Production then
            SustainabilityJnlLine.Validate("CO2e Emission", Sign * ItemJournalLine."Total CO2e")
        else
            SustainabilityJnlLine.Validate("CO2e Emission", ItemJournalLine."Total CO2e");

        SustainabilityJnlLine.Validate("Emission CO2", ItemJournalLine."Emission CO2");
        SustainabilityJnlLine.Validate("Emission CH4", ItemJournalLine."Emission CH4");
        SustainabilityJnlLine.Validate("Emission N2O", ItemJournalLine."Emission N2O");
        SustainabilityJnlLine.Validate("Country/Region Code", ItemJournalLine."Country/Region Code");
        SustainabilityPostMgt.InsertValueEntry(SustainabilityJnlLine, ValueEntry, ItemLedgerEntry);
    end;
}