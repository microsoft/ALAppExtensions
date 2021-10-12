codeunit 148063 "Date Order Invt. Change CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Core] [Date Order Inventory Change]
        isInitialized := false;
    end;

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
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Date Order Invt. Change CZL");
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Date Order Invt. Change CZL");

        InventorySetup.Get();
        InventorySetup."Location Mandatory" := false;
        InventorySetup."Date Order Invt. Change CZL" := true;
        InventorySetup.Modify();

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Date Order Invt. Change CZL");
    end;

    [Test]
    procedure PostItemWithNewerDate()
    var
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        // [SCENARIO] Check posting item with newer date
        Initialize();

        // [GIVEN] New Item has been created
        LibraryInventory.CreateItem(Item);

        // [GIVEN] New Item Journal Batch has been created
        LibraryInventory.CreateItemJournalTemplate(ItemJournalTemplate);
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);

        // [GIVEN] New positive Item Journal Line has been created
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                            ItemJournalLine."Entry Type"::"Positive Adjmt.", Item."No.", 10);
        ItemJournalLine.Validate("Posting Date", WorkDate());

        // [GIVEN] Positive Item Journal Line has been posted
        ItemJnlPostLine.RunWithCheck(ItemJournalLine);

        // [GIVEN] New negative Item Journal Line has been created
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                            ItemJournalLine."Entry Type"::"Negative Adjmt.", Item."No.", 2);
        ItemJournalLine.Validate("Posting Date", WorkDate());

        // [WHEN] Negative Item Journal Line post
        ItemJnlPostLine.RunWithCheck(ItemJournalLine);

        // [THEN] Two Item Ledger Entries will exist
        ItemLedgerEntry.SetCurrentKey("Item No.");
        ItemLedgerEntry.SetRange("Item No.", Item."No.");
        Assert.AreEqual(2, ItemLedgerEntry.Count(), 'Two item ledger entries expected for item.');

        // [THEN] Item Application Entry will exist
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
        Initialize();

        // [GIVEN] New Item has been created
        LibraryInventory.CreateItem(Item);

        // [GIVEN] New Item Journal Batch has been created
        LibraryInventory.CreateItemJournalTemplate(ItemJournalTemplate);
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);

        // [GIVEN] New positive Item Journal Line has been created
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                            ItemJournalLine."Entry Type"::"Positive Adjmt.", Item."No.", 10);
        ItemJournalLine.Validate("Posting Date", WorkDate());

        // [GIVEN] Positive Item Journal Line has been posted
        ItemJnlPostLine.RunWithCheck(ItemJournalLine);

        // [GIVEN] New negative Item Journal Line has been created
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                            ItemJournalLine."Entry Type"::"Negative Adjmt.", Item."No.", 2);
        ItemJournalLine.Validate("Posting Date", CalcDate('<-1D>', WorkDate()));

        // [WHEN] Try negative Item Journal Line post
        asserterror ItemJnlPostLine.RunWithCheck(ItemJournalLine);

        // [THEN] Error wrong application will occurs
        Assert.ExpectedError(WrongItemEntryApplicationErr);
    end;

    [Test]
    procedure PostItemWithOlderDateEnabled()
    var
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        // [SCENARIO] Check posting item with older date enabled
        Initialize();

        // [GIVEN] Date Order Inventory Change has been disabled
        InventorySetup.Get();
        InventorySetup."Date Order Invt. Change CZL" := false;
        InventorySetup.Modify();

        // [GIVEN] New Item has been created
        LibraryInventory.CreateItem(Item);

        // [GIVEN] New Item Journal Batch has been created
        LibraryInventory.CreateItemJournalTemplate(ItemJournalTemplate);
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);

        // [GIVEN] New positive Item Journal Line has been created
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                            ItemJournalLine."Entry Type"::"Positive Adjmt.", Item."No.", 10);
        ItemJournalLine.Validate("Posting Date", WorkDate());

        // [GIVEN] Positive Item Journal Line has been posted
        ItemJnlPostLine.RunWithCheck(ItemJournalLine);

        // [GIVEN] New negative Item Journal Line has been created
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                            ItemJournalLine."Entry Type"::"Negative Adjmt.", Item."No.", 10);
        ItemJournalLine.Validate("Posting Date", CalcDate('<-1D>', WorkDate()));

        // [WHEN] Negative Item Journal Line poste
        ItemJnlPostLine.RunWithCheck(ItemJournalLine);

        // [THEN] Two Item Ledger Entries will exist
        ItemLedgerEntry.SetCurrentKey("Item No.");
        ItemLedgerEntry.SetRange("Item No.", Item."No.");
        Assert.AreEqual(2, ItemLedgerEntry.Count(), 'Two item ledger entries expected for item.');

        // [THEN] No open Item Ledger Entry will exist
        ItemLedgerEntry.SetRange(Open, true);
        Assert.AreEqual(0, ItemLedgerEntry.Count(), 'No opened item ledger entry expected for item.');
    end;
}
