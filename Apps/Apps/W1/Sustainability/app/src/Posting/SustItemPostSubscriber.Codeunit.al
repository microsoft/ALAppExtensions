namespace Microsoft.Sustainability.Posting;

using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Posting;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Journal;

codeunit 6256 "Sust. Item Post Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInsertValueEntry', '', false, false)]
    local procedure OnBeforeInsertValueEntry(ItemJournalLine: Record "Item Journal Line"; var ValueEntry: Record "Value Entry"; var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        if CanCreateSustValueEntry(ItemJournalLine, ValueEntry) then
            PostSustainabilityValueEntry(ItemJournalLine, ValueEntry, ItemLedgerEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInsertCapValueEntry', '', false, false)]
    local procedure OnAfterInsertCapValueEntry(ItemJnlLine: Record "Item Journal Line"; var ValueEntry: Record "Value Entry")
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        if CanCreateSustValueEntry(ItemJnlLine, ValueEntry) then
            PostSustainabilityValueEntry(ItemJnlLine, ValueEntry, ItemLedgerEntry);
    end;

    local procedure CanCreateSustValueEntry(ItemJournalLine: Record "Item Journal Line"; var ValueEntry: Record "Value Entry"): Boolean
    begin
        if ValueEntry."Order Type" = ValueEntry."Order Type"::Transfer then
            if (ValueEntry."Document Type" = ValueEntry."Document Type"::"Transfer Shipment") and (ValueEntry."Valued Quantity" > 0) then
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
            CheckSustainabilityItemJnlLine(ItemJournalLine."Sust. Account No.", ItemJournalLine."Sust. Account Category", ItemJournalLine."Sust. Account Subcategory", ItemJournalLine."Total CO2e");
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

        if ItemJournalLine."Order Type" = ItemJournalLine."Order Type"::Production then
            SustainabilityJnlLine.Validate("CO2e Emission", Sign * ItemJournalLine."Total CO2e")
        else
            SustainabilityJnlLine.Validate("CO2e Emission", ItemJournalLine."Total CO2e");

        SustainabilityJnlLine.Validate("Emission CO2", ItemJournalLine."Emission CO2");
        SustainabilityJnlLine.Validate("Emission CH4", ItemJournalLine."Emission CH4");
        SustainabilityJnlLine.Validate("Emission N2O", ItemJournalLine."Emission N2O");
        SustainabilityJnlLine.Validate("Country/Region Code", ItemJournalLine."Country/Region Code");
        SustainabilityPostMgt.InsertValueEntry(SustainabilityJnlLine, ValueEntry, ItemLedgerEntry);
    end;

    local procedure CheckSustainabilityItemJnlLine(AccountNo: Code[20]; AccountCategory: Code[20]; AccountSubCategory: Code[20]; CO2eToPost: Decimal)
    var
        SustAccountCategory: Record "Sustain. Account Category";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
    begin
        if SustAccountCategory.Get(AccountCategory) then
            if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                Error(NotAllowedToPostSustValueEntryForWaterOrWasteErr, AccountNo);

        if SustainAccountSubcategory.Get(AccountCategory, AccountSubCategory) then
            if not SustainAccountSubcategory."Renewable Energy" then
                if (CO2eToPost = 0) then
                    Error(CO2eMustNotBeZeroErr);
    end;

    var
        CO2eMustNotBeZeroErr: Label 'The CO2e fields must have a value that is not 0.';
        NotAllowedToPostSustValueEntryForWaterOrWasteErr: Label 'It is not allowed to post Sustainability Value Entry for water or waste in Production document for Account No. %1', Comment = '%1 = Sustainability Account No.';
}