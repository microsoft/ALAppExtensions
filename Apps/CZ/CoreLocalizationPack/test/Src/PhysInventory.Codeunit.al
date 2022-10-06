codeunit 148093 "Phys. Inventory CZL"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        isInitialized: Boolean;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Phys. Inventory CZL");

        LibraryRandom.SetSeed(1);  // Use Random Number Generator to generate the seed for RANDOM function.
        LibraryVariableStorage.Clear();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Phys. Inventory CZL");

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Phys. Inventory CZL");
    end;

    [Test]
    procedure LoadingStoredItems()
    var
        Item: Record Item;
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalTemplate: Record "Item Journal Template";
        InvtMovementTemplateCZL1: Record "Invt. Movement Template CZL";
        InvtMovementTemplateCZL2: Record "Invt. Movement Template CZL";
    begin
        Initialize();

        // [GIVEN] The inventory movement template of positive adjustment type has been created.
        CreateInvtMovementTemplate(
          InvtMovementTemplateCZL1, InvtMovementTemplateCZL1."Entry Type"::"Positive Adjmt.");

        // [GIVEN] The inventory movement template of nagative adjustment type has been created.
        CreateInvtMovementTemplate(
          InvtMovementTemplateCZL2, InvtMovementTemplateCZL2."Entry Type"::"Negative Adjmt.");

        // [GIVEN] The item journal lines have been cleared.
        LibraryInventory.SelectItemJournalTemplateName(ItemJournalTemplate, ItemJournalTemplate.Type::Item);
        LibraryInventory.SelectItemJournalBatchName(ItemJournalBatch, ItemJournalTemplate.Type::Item, ItemJournalTemplate.Name);
        LibraryInventory.ClearItemJournal(ItemJournalTemplate, ItemJournalBatch);

        // [GIVEN] The item has been created.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] The item journal line with created item has been created.
        LibraryInventory.CreateItemJournalLine(
          ItemJournalLine, ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name, ItemJournalLine."Entry Type"::Purchase,
          Item."No.", LibraryRandom.RandInt(10));

        // [GIVEN] The item journal lines have been posted.
        LibraryInventory.PostItemJournalLine(ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name);

        // [GIVEN] The item journal lines have been initialized.
        LibraryInventory.SelectItemJournalTemplateName(ItemJournalTemplate, ItemJournalTemplate.Type::"Phys. Inventory");
        LibraryInventory.SelectItemJournalBatchName(ItemJournalBatch, ItemJournalTemplate.Type::"Phys. Inventory", ItemJournalTemplate.Name);
        LibraryInventory.ClearItemJournal(ItemJournalTemplate, ItemJournalBatch);
        MakeItemJournalLine(ItemJournalLine, ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name);

        // [WHEN] Run calculate inventory.
        LibraryInventory.CalculateInventoryForSingleItem(ItemJournalLine, Item."No.", WorkDate(), false, false);

        // [THEN] The created inventory templates will used in item journal lines.
        ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
        ItemJournalLine.SetRange("Item No.", Item."No.");
        ItemJournalLine.FindFirst();

        ItemJournalLine.Validate("Qty. (Phys. Inventory)", ItemJournalLine."Qty. (Calculated)" + 1);
        ItemJournalLine.TestField("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");
        ItemJournalLine.TestField("Invt. Movement Template CZL", InvtMovementTemplateCZL1.Name);

        ItemJournalLine.Validate("Qty. (Phys. Inventory)", ItemJournalLine."Qty. (Calculated)" - 1);
        ItemJournalLine.TestField("Entry Type", ItemJournalLine."Entry Type"::"Negative Adjmt.");
        ItemJournalLine.TestField("Invt. Movement Template CZL", InvtMovementTemplateCZL2.Name);
    end;

    local procedure CreateGenBusPostingGroup(var GenBusinessPostingGroup: Record "Gen. Business Posting Group")
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
    begin
        LibraryERM.FindVATBusinessPostingGroup(VATBusinessPostingGroup);
        LibraryERM.CreateGenBusPostingGroup(GenBusinessPostingGroup);
        GenBusinessPostingGroup.Validate("Def. VAT Bus. Posting Group", VATBusinessPostingGroup.Code);
        GenBusinessPostingGroup.Modify();
    end;

    local procedure CreateInvtMovementTemplate(var InvtMovementTemplateCZL: Record "Invt. Movement Template CZL"; EntryType: Option)
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
    begin
        CreateGenBusPostingGroup(GenBusinessPostingGroup);
        InvtMovementTemplateCZL.Init();
        InvtMovementTemplateCZL.Validate(
          Name,
          CopyStr(LibraryUtility.GenerateRandomCode(InvtMovementTemplateCZL.FieldNo(Name), Database::"Invt. Movement Template CZL"),
            1, LibraryUtility.GetFieldLength(Database::"Invt. Movement Template CZL", InvtMovementTemplateCZL.FieldNo(Name))));
        InvtMovementTemplateCZL.Validate("Entry Type", EntryType);
        InvtMovementTemplateCZL.Validate("Gen. Bus. Posting Group", GenBusinessPostingGroup.Code);
        InvtMovementTemplateCZL.Insert();

        case EntryType of
            InvtMovementTemplateCZL."Entry Type"::"Positive Adjmt.":
                SetDefTemplateForPhysPosAdj(InvtMovementTemplateCZL.Name);
            InvtMovementTemplateCZL."Entry Type"::"Negative Adjmt.":
                SetDefTemplateForPhysNegAdj(InvtMovementTemplateCZL.Name);
        end;
    end;

    local procedure MakeItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10])
    begin
        ItemJournalLine.Init();
        ItemJournalLine."Journal Template Name" := JournalTemplateName;
        ItemJournalLine."Journal Batch Name" := JournalBatchName;
        ItemJournalLine."Document No." :=
          LibraryUtility.GenerateRandomCode(ItemJournalLine.FieldNo("Document No."), Database::"Item Journal Line");
    end;

    local procedure SetDefTemplateForPhysPosAdj(InvtMovementTemplateName: Code[10])
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        InventorySetup.Validate("Def.Tmpl. for Phys.Pos.Adj CZL", InvtMovementTemplateName);
        InventorySetup.Modify();
    end;

    local procedure SetDefTemplateForPhysNegAdj(InvtMovementTemplateName: Code[10])
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        InventorySetup.Validate("Def.Tmpl. for Phys.Neg.Adj CZL", InvtMovementTemplateName);
        InventorySetup.Modify();
    end;
}
