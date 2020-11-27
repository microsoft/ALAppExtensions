codeunit 148053 "Invt. Mvmt. Templates CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        InvtMovementTemplateCZLPositive: Record "Invt. Movement Template CZL";
        InvtMovementTemplateCZLNegative: Record "Invt. Movement Template CZL";
        InventorySetup: Record "Inventory Setup";
        GenBussinesPostingGroup: Record "Gen. Business Posting Group";
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

        InvtMovementTemplateCZLPositive.Init();
        InvtMovementTemplateCZLPositive.Name := CopyStr(LibraryRandom.RandText(10), 1, 10);
        InvtMovementTemplateCZLPositive.Description := CopyStr(LibraryRandom.RandText(100), 1, 100);
        InvtMovementTemplateCZLPositive."Entry Type" := InvtMovementTemplateCZLPositive."Entry Type"::"Positive Adjmt.";
        GenBussinesPostingGroup.FindFirst();
        InvtMovementTemplateCZLPositive."Gen. Bus. Posting Group" := GenBussinesPostingGroup.Code;
        InvtMovementTemplateCZLPositive.Insert();

        InvtMovementTemplateCZLNegative.Init();
        InvtMovementTemplateCZLNegative.Name := CopyStr(LibraryRandom.RandText(10), 1, 10);
        InvtMovementTemplateCZLNegative.Description := CopyStr(LibraryRandom.RandText(100), 1, 100);
        InvtMovementTemplateCZLNegative."Entry Type" := InvtMovementTemplateCZLNegative."Entry Type"::"Negative Adjmt.";
        GenBussinesPostingGroup.FindLast();
        InvtMovementTemplateCZLNegative."Gen. Bus. Posting Group" := GenBussinesPostingGroup.Code;
        InvtMovementTemplateCZLNegative.Insert();

        InventorySetup.Get();
        InventorySetup."Def.Tmpl. for Phys.Pos.Adj CZL" := InvtMovementTemplateCZLPositive.Name;
        InventorySetup."Def.Tmpl. for Phys.Neg.Adj CZL" := InvtMovementTemplateCZLNegative.Name;
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
        ItemJournalLine.Validate("Invt. Movement Template CZL", InvtMovementTemplateCZLPositive.Name);
        // [THEN] Item Journal Line is updated
        Assert.AreEqual(InvtMovementTemplateCZLPositive."Gen. Bus. Posting Group", ItemJournalLine."Gen. Bus. Posting Group", ItemJournalLine.FieldCaption(ItemJournalLine."Gen. Bus. Posting Group"));
        Assert.AreEqual(InvtMovementTemplateCZLPositive."Entry Type", ItemJournalLine."Entry Type", ItemJournalLine.FieldCaption(ItemJournalLine."Entry Type"));
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
        asserterror JobJournalLine.Validate("Invt. Movement Template CZL", InvtMovementTemplateCZLPositive.Name);
    end;

    [Test]
    procedure ValidateInvtMovementNegativeTemplateJobJournal()
    begin
        // [FEATURE] Invt Movement Templates
        Initialize();

        // [WHEN] Validate Invt. Movement Negative Template
        JobJournalLine.Validate("Invt. Movement Template CZL", InvtMovementTemplateCZLNegative.Name);

        // [THEN] Job Journal Line is updated
        Assert.AreEqual(InvtMovementTemplateCZLNegative."Gen. Bus. Posting Group", JobJournalLine."Gen. Bus. Posting Group", JobJournalLine.FieldCaption(JobJournalLine."Gen. Bus. Posting Group"));
    end;
}
