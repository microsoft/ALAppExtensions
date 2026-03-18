namespace Microsoft.Sustainability.Posting;

using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Posting;
using Microsoft.Manufacturing.Capacity;
using Microsoft.Manufacturing.Document;
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInsertCorrValueEntry', '', false, false)]
    local procedure OnAfterInsertCorrValueEntry(ItemJournalLine: Record "Item Journal Line"; var NewValueEntry: Record "Value Entry"; var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        if CanCreateSustValueEntry(ItemJournalLine, NewValueEntry) then
            PostSustainabilityValueEntry(ItemJournalLine, NewValueEntry, ItemLedgerEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertItemLedgEntry', '', false, false)]
    local procedure OnBeforeInsertItemLedgEntry(ItemJournalLine: Record "Item Journal Line"; var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        if ItemJournalLine."Entry Type" <> ItemJournalLine."Entry Type"::Sale then
            exit;

        ItemLedgerEntry."Sust. Account No." := ItemJournalLine."Sust. Account No.";
        ItemLedgerEntry."Sust. Account Name" := ItemJournalLine."Sust. Account Name";
        ItemLedgerEntry."Sust. Account Category" := ItemJournalLine."Sust. Account Category";
        ItemLedgerEntry."Sust. Account Subcategory" := ItemJournalLine."Sust. Account Subcategory";
        ItemLedgerEntry."EPR Fee per Unit" := ItemJournalLine."EPR Fee Per Unit";
        ItemLedgerEntry."Total EPR Fee" := ItemJournalLine."Total EPR Fee";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnSetupSplitJnlLineOnAfterSetupTempSplitItemJnlLine', '', false, false)]
    local procedure OnSetupSplitJnlLineOnAfterSetupTempSplitItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; var TempSplitItemJournalLine: Record "Item Journal Line" temporary)
    var
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        CO2eAmount: Decimal;
        CO2eQuantity: Decimal;
    begin
        if ItemJournalLine."Sust. Account No." = '' then
            exit;

        if not SustainabilityPostMgt.IsCarbonTrackingSpecificItem(ItemJournalLine."Item No.") then
            exit;

        TempSplitItemJournalLine."Emission CO2" := Abs(ItemJournalLine."Emission CO2" / ItemJournalLine.Quantity) * TempSplitItemJournalLine.Quantity;
        TempSplitItemJournalLine."Emission CH4" := Abs(ItemJournalLine."Emission CH4" / ItemJournalLine.Quantity) * TempSplitItemJournalLine.Quantity;
        TempSplitItemJournalLine."Emission N2O" := Abs(ItemJournalLine."Emission N2O" / ItemJournalLine.Quantity) * TempSplitItemJournalLine.Quantity;

        if TempSplitItemJournalLine."Applies-from Entry" <> 0 then begin
            SustainabilityPostMgt.GetCO2eAmountAndQuantity(TempSplitItemJournalLine."Applies-from Entry", CO2eAmount, CO2eQuantity);
            if CO2eQuantity <> 0 then begin
                TempSplitItemJournalLine."Total CO2e" := Abs(CO2eAmount / CO2eQuantity) * TempSplitItemJournalLine.Quantity;
                TempSplitItemJournalLine."CO2e per Unit" := Abs(CO2eAmount / CO2eQuantity);
            end;
        end;

        TempSplitItemJournalLine.Modify();
    end;

    local procedure CanCreateSustValueEntry(ItemJournalLine: Record "Item Journal Line"; var ValueEntry: Record "Value Entry"): Boolean
    begin
        if (ValueEntry."Item Ledger Entry Type" = ValueEntry."Item Ledger Entry Type"::Transfer) then
            if (ValueEntry."Document Type" in [ValueEntry."Document Type"::"Transfer Shipment", ValueEntry."Document Type"::" "]) and (ValueEntry."Valued Quantity" > 0) then
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
        if ItemJournalLine.ShouldUpdateJournalLineWithPostingSign() then begin
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
        if ItemLedgerEntry."Entry No." <> 0 then
            GetTotalCO2eFromProdOrder(ItemJournalLine, ValueEntry.Type);
        SustainabilityPostMgt.GetTotalCO2eAmount(ItemLedgerEntry, ValueEntry.Type, ItemJournalLine."Total CO2e", ItemJournalLine."CO2e per Unit");
        if ItemJournalLine.ShouldUpdateJournalLineWithPostingSign() then
            SustainabilityJnlLine.Validate("CO2e Emission", Sign * ItemJournalLine."Total CO2e")
        else
            SustainabilityJnlLine.Validate("CO2e Emission", ItemJournalLine."Total CO2e");

        SustainabilityJnlLine.Validate("Emission CO2", ItemJournalLine."Emission CO2");
        SustainabilityJnlLine.Validate("Emission CH4", ItemJournalLine."Emission CH4");
        SustainabilityJnlLine.Validate("Emission N2O", ItemJournalLine."Emission N2O");
        SustainabilityJnlLine.Validate(Correction, ItemJournalLine.Correction);
        SustainabilityJnlLine.Validate("Country/Region Code", ItemJournalLine."Country/Region Code");
        SustainabilityPostMgt.InsertValueEntry(SustainabilityJnlLine, ValueEntry, ItemLedgerEntry);
    end;

    local procedure GetTotalCO2eFromProdOrder(var ItemJournalLine: Record "Item Journal Line"; ValueEntryType: Enum "Capacity Type Journal")
    var
        ProdOrderLine: Record "Prod. Order Line";
        Sustainability: Codeunit "Sustainability Post Mgt";
    begin
        if not (ValueEntryType in [ValueEntryType::"Machine Center", ValueEntryType::"Work Center"]) or
               (ItemJournalLine."Entry Type" <> ItemJournalLine."Entry Type"::Output) then
            exit;

        if not Sustainability.IsCarbonTrackingSpecificItem(ItemJournalLine."Item No.") then
            exit;

        if not ProdOrderLine.Get(ProdOrderLine.Status::Released, ItemJournalLine."Order No.", ItemJournalLine."Order Line No.") then
            exit;

        ProdOrderLine.CalcFields("Expected Operation Total CO2e");
        if ProdOrderLine.Quantity = 0 then
            exit;

        ItemJournalLine."Total CO2e" := (ProdOrderLine."Expected Operation Total CO2e" / ProdOrderLine.Quantity) * ItemJournalLine.Quantity;
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