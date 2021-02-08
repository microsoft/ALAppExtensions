codeunit 148053 "Invt. Mvmt. Templates CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        PositiveInvtMovementTemplateCZL: Record "Invt. Movement Template CZL";
        NegativeInvtMovementTemplateCZL: Record "Invt. Movement Template CZL";
        InventorySetup: Record "Inventory Setup";
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        Job: Record Job;
        JobTask: Record "Job Task";
        JobJournalLine: Record "Job Journal Line";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryJob: Codeunit "Library - Job";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        isInitialized: Boolean;

    local procedure Initialize();
    begin
        LibraryRandom.Init();
        if isInitialized then
            exit;

        PositiveInvtMovementTemplateCZL.Init();
        PositiveInvtMovementTemplateCZL.Name := CopyStr(LibraryRandom.RandText(10), 1, 10);
        PositiveInvtMovementTemplateCZL.Description := CopyStr(LibraryRandom.RandText(100), 1, 100);
        PositiveInvtMovementTemplateCZL."Entry Type" := PositiveInvtMovementTemplateCZL."Entry Type"::"Positive Adjmt.";
        GenBusinessPostingGroup.FindFirst();
        PositiveInvtMovementTemplateCZL."Gen. Bus. Posting Group" := GenBusinessPostingGroup.Code;
        PositiveInvtMovementTemplateCZL.Insert();

        NegativeInvtMovementTemplateCZL.Init();
        NegativeInvtMovementTemplateCZL.Name := CopyStr(LibraryRandom.RandText(10), 1, 10);
        NegativeInvtMovementTemplateCZL.Description := CopyStr(LibraryRandom.RandText(100), 1, 100);
        NegativeInvtMovementTemplateCZL."Entry Type" := NegativeInvtMovementTemplateCZL."Entry Type"::"Negative Adjmt.";
        GenBusinessPostingGroup.FindLast();
        NegativeInvtMovementTemplateCZL."Gen. Bus. Posting Group" := GenBusinessPostingGroup.Code;
        NegativeInvtMovementTemplateCZL.Insert();

        InventorySetup.Get();
        InventorySetup."Def.Tmpl. for Phys.Pos.Adj CZL" := PositiveInvtMovementTemplateCZL.Name;
        InventorySetup."Def.Tmpl. for Phys.Neg.Adj CZL" := NegativeInvtMovementTemplateCZL.Name;
        InventorySetup.Modify();

        isInitialized := true;
        Commit();
    end;

    [Test]
    procedure ValidateInvtMovementTemplateItemJournal()
    begin
        // [FEATURE] Invt Movement Templates
        Initialize();

        // [GIVEN] New Item Journal Template created
        LibraryInventory.CreateItemJournalTemplate(ItemJournalTemplate);

        // [GIVEN] New Item Journal Batch created
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);

        // [GIVEN] New Item Journal Line created
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                            ItemJournalLine."Entry Type"::"Negative Adjmt.", LibraryInventory.CreateItemNo(), LibraryRandom.RandDec(1000, 2));

        // [WHEN] Validate Invt. Movement positive Template
        ItemJournalLine.Validate("Invt. Movement Template CZL", PositiveInvtMovementTemplateCZL.Name);
        // [THEN] Item Journal Line is updated
        Assert.AreEqual(PositiveInvtMovementTemplateCZL."Gen. Bus. Posting Group", ItemJournalLine."Gen. Bus. Posting Group", ItemJournalLine.FieldCaption(ItemJournalLine."Gen. Bus. Posting Group"));
        Assert.AreEqual(PositiveInvtMovementTemplateCZL."Entry Type", ItemJournalLine."Entry Type", ItemJournalLine.FieldCaption(ItemJournalLine."Entry Type"));
    end;

    [Test]
    procedure ValidatePhysInventoryPositiveItemJournal()
    begin
        // [FEATURE] Invt Movement Templates
        Initialize();

        // [GIVEN] Item Journal Template is Physical Inventory
        ItemJournalTemplate.Type := ItemJournalTemplate.Type::"Phys. Inventory";
        ItemJournalTemplate.Modify();

        // [GIVEN] Item Journal Line has Qty. (Calculated)
        ItemJournalLine."Qty. (Calculated)" := LibraryRandom.RandDecInRange(101, 200, 2);

        // [GIVEN] Item Journal Line is Physical Inventory
        ItemJournalLine."Phys. Inventory" := true;

        // [WHEN] Validate Qty. (Phys. Inventory) higher
        ItemJournalLine.Validate("Qty. (Phys. Inventory)", LibraryRandom.RandDecInRange(201, 300, 2));

        // [THEN] Item Journal Line is updated
        Assert.AreEqual(InventorySetup."Def.Tmpl. for Phys.Pos.Adj CZL", ItemJournalLine."Invt. Movement Template CZL", ItemJournalLine.FieldCaption(ItemJournalLine."Invt. Movement Template CZL"));
    end;

    [Test]
    procedure ValidatePhysInventoryNegativeItemJournal()
    begin
        // [FEATURE] Invt Movement Templates
        Initialize();

        // [WHEN] Validate Qty. (Phys. Inventory) lower
        ItemJournalLine.Validate("Qty. (Phys. Inventory)", LibraryRandom.RandDecInRange(1, 100, 2));

        // [THEN] Item Journal Line is updated
        Assert.AreEqual(InventorySetup."Def.Tmpl. for Phys.Neg.Adj CZL", ItemJournalLine."Invt. Movement Template CZL", ItemJournalLine.FieldCaption(ItemJournalLine."Invt. Movement Template CZL"));
    end;

    [Test]
    procedure ValidateInvtMovementPositiveTemplateJobJournal()
    begin
        // [FEATURE] Invt Movement Templates
        Initialize();

        // [GIVEN] New Job created
        LibraryJob.CreateJob(Job);

        // [GIVEN] New Job Task Line created
        LibraryJob.CreateJobTask(Job, JobTask);

        // [GIVEN] New Item Journal Line created
        LibraryJob.CreateJobJournalLine(JobJournalLine."Line Type"::Billable, JobTask, JobJournalLine);

        // [WHEN] Try validate Invt. Movement Positive Template
        asserterror JobJournalLine.Validate("Invt. Movement Template CZL", PositiveInvtMovementTemplateCZL.Name);
    end;

    [Test]
    procedure ValidateInvtMovementNegativeTemplateJobJournal()
    begin
        // [FEATURE] Invt Movement Templates
        Initialize();

        // [WHEN] Validate Invt. Movement Negative Template
        JobJournalLine.Validate("Invt. Movement Template CZL", NegativeInvtMovementTemplateCZL.Name);

        // [THEN] Job Journal Line is updated
        Assert.AreEqual(NegativeInvtMovementTemplateCZL."Gen. Bus. Posting Group", JobJournalLine."Gen. Bus. Posting Group", JobJournalLine.FieldCaption(JobJournalLine."Gen. Bus. Posting Group"));
    end;
}
