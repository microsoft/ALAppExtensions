codeunit 148063 "Date Order Invt. Change CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        InventorySetup: Record "Inventory Setup";
        Item: Record Item;
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemApplicationEntry: Record "Item Application Entry";
        Assert: Codeunit Assert;
        LibraryInventory: Codeunit "Library - Inventory";
        isInitialized: Boolean;

    local procedure Initialize()
    begin
        if isInitialized then
            exit;

        InventorySetup.Get();
        InventorySetup."Location Mandatory" := false;
        InventorySetup."Date Order Invt. Change CZL" := true;
        InventorySetup.Modify();

        isInitialized := true;
        Commit();
    end;

    [Test]
    procedure PostItemWithNewerDate()
    var
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        // [SCENARIO] Check posting item with newer date
        // [FEATURE] Date Order Inventory Change
        Initialize();

        // [GIVEN] New Item created
        LibraryInventory.CreateItem(Item);

        // [GIVEN] New Item Journal Template created
        LibraryInventory.CreateItemJournalTemplate(ItemJournalTemplate);

        // [GIVEN] New Item Journal Batch created
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);

        // [GIVEN] New positive Item Journal Line created
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                            ItemJournalLine."Entry Type"::"Positive Adjmt.", Item."No.", 10);
        ItemJournalLine.Validate("Posting Date", WorkDate());

        // [GIVEN] Negative Item Journal Line posted
        ItemJnlPostLine.RunWithCheck(ItemJournalLine);

        // [GIVEN] New negative Item Journal Line created
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                            ItemJournalLine."Entry Type"::"Negative Adjmt.", Item."No.", 2);
        ItemJournalLine.Validate("Posting Date", WorkDate());

        // [WHEN] Negative Item Journal Line posted
        ItemJnlPostLine.RunWithCheck(ItemJournalLine);

        // [THEN] Verify two Item Ledger Entries exist
        ItemLedgerEntry.SetCurrentKey("Item No.");
        ItemLedgerEntry.SetRange("Item No.", Item."No.");
        Assert.AreEqual(2, ItemLedgerEntry.Count(), 'Two item ledger entries expected for item.');

        // [THEN] Verify Item Application Entry exists
        ItemLedgerEntry.FindLast();
        ItemApplicationEntry.FindLast();
        Assert.AreEqual(ItemApplicationEntry."Outbound Item Entry No.", ItemLedgerEntry."Entry No.", 'Outbound entry must be applied.');
    end;

    [Test]
    procedure PostItemWithOlderDateDisabled()
    var
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        WrongItemEntryApplicationErr: Label 'Wrong Item Ledger Entry Application (Date Order)';
    begin
        // [SCENARIO] Check posting item with older date disabled
        // [FEATURE] Date Order Inventory Change
        Initialize();

        // [GIVEN] New negative Item Journal Line created
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                            ItemJournalLine."Entry Type"::"Negative Adjmt.", Item."No.", 8);
        ItemJournalLine.Validate("Posting Date", CalcDate('<-1D>', WorkDate()));

        // [WHEN] Try negative Item Journal Line post
        asserterror ItemJnlPostLine.RunWithCheck(ItemJournalLine);

        // [THEN] Error wrong application expected
        Assert.ExpectedError(WrongItemEntryApplicationErr);
    end;

    [Test]
    procedure PostItemWithOlderDateEnabled()
    var
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        // [SCENARIO] Check posting item with older date enabled
        // [FEATURE] Date Order Inventory Change
        Initialize();

        // [GIVEN] Check Date Order Inventory Change disabled
        InventorySetup.Get();
        InventorySetup."Date Order Invt. Change CZL" := false;
        InventorySetup.Modify();

        // [WHEN] Negative Item Journal Line posted
        ItemJnlPostLine.RunWithCheck(ItemJournalLine);

        // [THEN] Verify three Item Ledger Entries exist
        Assert.AreEqual(3, ItemLedgerEntry.Count(), 'Three item ledger entries expected for item.');

        // [THEN] Verify no Item Ledger Entry opened
        ItemLedgerEntry.SetRange(Open, true);
        Assert.AreEqual(0, ItemLedgerEntry.Count(), 'No opened item ledger entries expected for item.');
    end;
}
