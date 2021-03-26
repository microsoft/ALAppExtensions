codeunit 147105 "CD HotFixes"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        isInitialized := false;
    end;

    var
        LibraryCDTracking: Codeunit "Library - CD Tracking";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        ItemTrackingOption: Option AssignPackageNo,ReclassPackageNo;
        isInitialized: Boolean;

    [Test]
    [HandlerFunctions('ItemTrackingLinesPageHandler')]
    [Scope('OnPrem')]
    procedure NewCDNoSavedAfterModification()
    var
        Item: Record Item;
        Location: Record Location;
        ItemTrackingCode: Record "Item Tracking Code";
        CDLocationSetup: Record "CD Location Setup";
        ItemJournalLine: Record "Item Journal Line";
        CDNo: array[3] of Code[50];
        Qty: Integer;
        I: Integer;
    begin
        // [FEATURE] [Item Reclassfication]
        // [SCENARIO 229926] "New Package No." should be saved when it is defined and then changed in the item tracking page

        Initialize();

        // [GIVEN] Item "I" with CD tracking
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true);
        LibraryItemTracking.CreateItemWithItemTrackingCode(Item, ItemTrackingCode);
        LibraryCDTracking.CreateCDTracking(CDLocationSetup, ItemTrackingCode.Code, Location.Code);

        for I := 1 to ArrayLen(CDNo) do
            CDNo[I] := LibraryUtility.GenerateGUID();
        Qty := LibraryRandom.RandInt(100);

        // [GIVEN] Post inbound inventory for item "I" and assign CD no. "CD1"
        LibraryInventory.CreateItemJnlLine(
          ItemJournalLine, ItemJournalLine."Entry Type"::"Positive Adjmt.", WorkDate(), Item."No.", Qty, Location.Code);
        LibraryVariableStorage.Enqueue(ItemTrackingOption::AssignPackageNo);
        LibraryVariableStorage.Enqueue(CDNo[1]);
        LibraryVariableStorage.Enqueue(ItemJournalLine."Quantity (Base)");
        ItemJournalLine.OpenItemTrackingLines(false);
        LibraryInventory.PostItemJnlLineWithCheck(ItemJournalLine);

        // [GIVEN] Create an item reclassification journal line for item "I", assign new CD "CD2"
        LibraryInventory.CreateItemJnlLine(
          ItemJournalLine, ItemJournalLine."Entry Type"::Transfer, WorkDate(), Item."No.", Qty, Location.Code);
        ItemJournalLine.Validate("New Location Code", Location.Code);
        ItemJournalLine.Modify(true);

        AssignTrackingReclassification(ItemJournalLine, CDNo[1], CDNo[2]);

        // [WHEN] Reopen item tracking for the same journal line and change "New Package No." from "CD2" to "CD3"
        AssignTrackingReclassification(ItemJournalLine, CDNo[1], CDNo[3]);

        // [THEN] Reservation entry is updated. "New Package No." is "CD3"
        VerifyTrackingReclassification(ItemJournalLine, CDNo[3]);
    end;

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        if isInitialized then
            exit;

        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.UpdateVATPostingSetup();
        LibraryERMCountryData.UpdateLocalData();

        UpdateSalesSetup();
        UpdateInventorySetup();

        isInitialized := true;
        Commit();
    end;

    local procedure AssignTrackingReclassification(var ItemJournalLine: Record "Item Journal Line"; PackageNo: Code[50]; NewPackageNo: Code[50])
    begin
        LibraryVariableStorage.Enqueue(ItemTrackingOption::ReclassPackageNo);
        LibraryVariableStorage.Enqueue(PackageNo);
        LibraryVariableStorage.Enqueue(ItemJournalLine."Quantity (Base)");
        LibraryVariableStorage.Enqueue(NewPackageNo);
        ItemJournalLine.OpenItemTrackingLines(true);
    end;

    local procedure UpdateSalesSetup()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Exact Cost Reversing Mandatory" := true;
        SalesReceivablesSetup.Modify();
    end;

    local procedure UpdateInventorySetup()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        InventorySetup.Validate("Location Mandatory", true);
        InventorySetup.Modify();
    end;

    local procedure VerifyTrackingReclassification(ItemJournalLine: Record "Item Journal Line"; ExpectedPackageNo: Code[50])
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        with ReservationEntry do begin
            SetRange("Item No.", ItemJournalLine."Item No.");
            SetRange("Source Type", DATABASE::"Item Journal Line");
            SetRange("Source ID", ItemJournalLine."Journal Template Name");
            SetRange("Source Batch Name", ItemJournalLine."Journal Batch Name");
            FindFirst();

            TestField("New Package No.", ExpectedPackageNo);
        end;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ItemTrackingLinesPageHandler(var ItemTrackingLines: TestPage "Item Tracking Lines")
    var
        TrackingOption: Option;
    begin
        TrackingOption := LibraryVariableStorage.DequeueInteger();
        ItemTrackingLines."Package No.".SetValue(LibraryVariableStorage.DequeueText());
        ItemTrackingLines."Quantity (Base)".SetValue(LibraryVariableStorage.DequeueDecimal());
        if TrackingOption = ItemTrackingOption::ReclassPackageNo then
            ItemTrackingLines."New Package No.".SetValue(LibraryVariableStorage.DequeueText());
        ItemTrackingLines.OK().Invoke();
    end;
}

