codeunit 148053 "Invt. Mvmt. Templates CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;


    trigger OnRun()
    begin
        // [FEATURE] [Core] [Inventory Movement Templates]
        isInitialized := false;
    end;

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
        TemplateNotFoundErr: Label 'The field Inventory Movement Template of table Item Document Header contains a value (%1) that cannot be found in the related table (Inventory Movement Template).', Comment = '%1 = name of Invt. Movement Template';
        TemplateMustBeEmptyErr: Label 'Inventory Movement Template must be equal to %1  in Item Document Header', Comment = '%1 = expected value of template';

    local procedure Initialize();
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Invt. Mvmt. Templates CZL");
        LibraryRandom.Init();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Invt. Mvmt. Templates CZL");

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
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Invt. Mvmt. Templates CZL");
    end;

    [Test]
    procedure ValidateInvtMovementTemplateItemJournal()
    begin
        // [SCENARIO] Validate Inventory Movement Template in Item Journal
        Initialize();

        // [GIVEN] New Item Journal Batch has been created
        LibraryInventory.CreateItemJournalTemplate(ItemJournalTemplate);
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);

        // [GIVEN] New Item Journal Line has been created
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                            ItemJournalLine."Entry Type"::"Negative Adjmt.", LibraryInventory.CreateItemNo(), LibraryRandom.RandDec(1000, 2));

        // [WHEN] Validate Inventory Movement positive Template
        ItemJournalLine.Validate("Invt. Movement Template CZL", PositiveInvtMovementTemplateCZL.Name);

        // [THEN] Item Journal Line will be updated
        Assert.AreEqual(PositiveInvtMovementTemplateCZL."Gen. Bus. Posting Group", ItemJournalLine."Gen. Bus. Posting Group", ItemJournalLine.FieldCaption(ItemJournalLine."Gen. Bus. Posting Group"));
        Assert.AreEqual(PositiveInvtMovementTemplateCZL."Entry Type", ItemJournalLine."Entry Type", ItemJournalLine.FieldCaption(ItemJournalLine."Entry Type"));
    end;

    [Test]
    procedure ValidatePhysInventoryPositiveItemJournal()
    begin
        // [SCENARIO] Validate positive Inventory Movement Template in Item Journal of Phycical Inventory
        Initialize();

        // [GIVEN] New Item Journal Template of Phycical Inventory has been created
        LibraryInventory.CreateItemJournalTemplate(ItemJournalTemplate);
        ItemJournalTemplate.Type := ItemJournalTemplate.Type::"Phys. Inventory";
        ItemJournalTemplate.Modify();

        // [GIVEN] New Item Journal Batch has been created
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);

        // [GIVEN] New Item Journal Line of Phycical Inventory has been created
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                            ItemJournalLine."Entry Type"::"Negative Adjmt.", LibraryInventory.CreateItemNo(), 0);
        ItemJournalLine."Phys. Inventory" := true;
        ItemJournalLine."Qty. (Calculated)" := LibraryRandom.RandDecInRange(101, 200, 2);

        // [WHEN] Validate Qty. (Phys. Inventory) higher
        ItemJournalLine.Validate("Qty. (Phys. Inventory)", LibraryRandom.RandDecInRange(201, 300, 2));

        // [THEN] Item Journal Line will be updated
        Assert.AreEqual(InventorySetup."Def.Tmpl. for Phys.Pos.Adj CZL", ItemJournalLine."Invt. Movement Template CZL", ItemJournalLine.FieldCaption(ItemJournalLine."Invt. Movement Template CZL"));
    end;

    [Test]
    procedure ValidatePhysInventoryNegativeItemJournal()
    begin
        // [SCENARIO] Validate negative Inventory Movement Template in Item Journal of Phycical Inventory
        Initialize();

        // [GIVEN] New Item Journal Template of Phycical Inventory has been created
        LibraryInventory.CreateItemJournalTemplate(ItemJournalTemplate);
        ItemJournalTemplate.Type := ItemJournalTemplate.Type::"Phys. Inventory";
        ItemJournalTemplate.Modify();

        // [GIVEN] New Item Journal Batch has been created
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);

        // [GIVEN] New Item Journal Line of Phycical Inventory has been created
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                            ItemJournalLine."Entry Type"::"Positive Adjmt.", LibraryInventory.CreateItemNo(), 0);
        ItemJournalLine."Phys. Inventory" := true;
        ItemJournalLine."Qty. (Calculated)" := LibraryRandom.RandDecInRange(101, 200, 2);

        // [WHEN] Validate Qty. (Phys. Inventory) lower
        ItemJournalLine.Validate("Qty. (Phys. Inventory)", LibraryRandom.RandDecInRange(1, 100, 2));

        // [THEN] Item Journal Line is updated
        Assert.AreEqual(InventorySetup."Def.Tmpl. for Phys.Neg.Adj CZL", ItemJournalLine."Invt. Movement Template CZL", ItemJournalLine.FieldCaption(ItemJournalLine."Invt. Movement Template CZL"));
    end;

    [Test]
    procedure ValidateInvtMovementPositiveTemplateJobJournal()
    begin
        // [SCENARIO] Validate Inventory Movement positive Template in Job Journal
        Initialize();

        // [GIVEN] New Job Task Line has been created
        LibraryJob.CreateJob(Job);
        LibraryJob.CreateJobTask(Job, JobTask);

        // [GIVEN] New Job Journal Line has been created
        LibraryJob.CreateJobJournalLine(JobJournalLine."Line Type"::Billable, JobTask, JobJournalLine);

        // [WHEN] Validate Inventory Movement positive Template
        asserterror JobJournalLine.Validate("Invt. Movement Template CZL", PositiveInvtMovementTemplateCZL.Name);

        // [THEN] Error on Entry Type will occurs
        Assert.ExpectedError('Entry Type must be equal to ''Negative Adjmt.''  in Inventory Movement Template');
    end;

    [Test]
    procedure ValidateInvtMovementNegativeTemplateJobJournal()
    begin
        // [SCENARIO] Validate Inventory Movement negative Template in Job Journal
        Initialize();

        // [GIVEN] New Job Task Line has been created
        LibraryJob.CreateJob(Job);
        LibraryJob.CreateJobTask(Job, JobTask);

        // [GIVEN] New Job Journal Line has been created
        LibraryJob.CreateJobJournalLine(JobJournalLine."Line Type"::Billable, JobTask, JobJournalLine);

        // [WHEN] Validate Inventory Movement negative Template
        JobJournalLine.Validate("Invt. Movement Template CZL", NegativeInvtMovementTemplateCZL.Name);

        // [THEN] Job Journal Line will be updated
        Assert.AreEqual(NegativeInvtMovementTemplateCZL."Gen. Bus. Posting Group", JobJournalLine."Gen. Bus. Posting Group", JobJournalLine.FieldCaption(JobJournalLine."Gen. Bus. Posting Group"));
    end;

    [Test]
    procedure ValidateInvtMovementPositiveTemplateInvtReceiptUT()
    var
        InvtDocumentHeader: Record "Invt. Document Header";
    begin
        // [SCENARIO] The Gen. Bus. Posting Group field is filled from Invt. Movement Template with entry type "Positive Adjmt." by validation of Invt. Movement Template CZL field.
        Initialize();

        // [GIVEN] The document type has been set to Receipt 
        InvtDocumentHeader."Document Type" := Enum::"Invt. Doc. Document Type"::Receipt;

        // [WHEN] Validate the Invt. Movement Template CZL with Invt. Movement Template with entry type "Positive Adjmt."
        InvtDocumentHeader.Validate("Invt. Movement Template CZL", PositiveInvtMovementTemplateCZL.Name);

        // [THEN] The Gen. Bus. Posting Group will be the same as Gen. Bus. Posting Group in Invt. Movement Template
        InvtDocumentHeader.TestField("Gen. Bus. Posting Group", PositiveInvtMovementTemplateCZL."Gen. Bus. Posting Group");
    end;

    [Test]
    procedure ValidateInvtMovementNegativeTemplateInvtReceiptUT()
    var
        InvtDocumentHeader: Record "Invt. Document Header";
    begin
        // [SCENARIO] The Gen. Bus. Posting Group field is empty and error occur when the Invt. Movement Template with entry type "Negative Adjmt." is validating.
        Initialize();

        // [GIVEN] The document type has been set to Receipt
        InvtDocumentHeader."Document Type" := Enum::"Invt. Doc. Document Type"::Receipt;

        // [WHEN] Validate the Invt. Movement Template CZL with Invt. Movement Template with entry type "Negative Adjmt."
        asserterror InvtDocumentHeader.Validate("Invt. Movement Template CZL", NegativeInvtMovementTemplateCZL.Name);

        // [THEN] The Gen. Bus. Posting Group will be empty
        InvtDocumentHeader.TestField("Gen. Bus. Posting Group", '');

        // [THEN] The error will occur
        Assert.ExpectedError(StrSubstNo(TemplateNotFoundErr, NegativeInvtMovementTemplateCZL.Name));
    end;

    [Test]
    procedure ValidateInvtMovementNegativeTemplateInvtShipmentUT()
    var
        InvtDocumentHeader: Record "Invt. Document Header";
    begin
        // [SCENARIO] The Gen. Bus. Posting Group field is filled from Invt. Movement Template with entry type "Negative Adjmt." by validation of Invt. Movement Template CZL field.
        Initialize();

        // [GIVEN] The document type has been set to Shipment 
        InvtDocumentHeader."Document Type" := Enum::"Invt. Doc. Document Type"::Shipment;

        // [WHEN] Validate the Invt. Movement Template CZL with Invt. Movement Template with entry type "Negative Adjmt."
        InvtDocumentHeader.Validate("Invt. Movement Template CZL", NegativeInvtMovementTemplateCZL.Name);

        // [THEN] The Gen. Bus. Posting Group will be the same as Gen. Bus. Posting Group in Invt. Movement Template
        InvtDocumentHeader.TestField("Gen. Bus. Posting Group", NegativeInvtMovementTemplateCZL."Gen. Bus. Posting Group");
    end;

    [Test]
    procedure ValidateInvtMovementPositiveTemplateInvtShipmentUT()
    var
        InvtDocumentHeader: Record "Invt. Document Header";
    begin
        // [SCENARIO] The Gen. Bus. Posting Group field is empty and error occur when the Invt. Movement Template with entry type "Postive Adjmt." is validating.
        Initialize();

        // [GIVEN] The document type has been set to Shipment
        InvtDocumentHeader."Document Type" := Enum::"Invt. Doc. Document Type"::Shipment;

        // [WHEN] Validate the Invt. Movement Template CZL with Invt. Movement Template with entry type "Positive Adjmt."
        asserterror InvtDocumentHeader.Validate("Invt. Movement Template CZL", PositiveInvtMovementTemplateCZL.Name);

        // [THEN] The Gen. Bus. Posting Group will be empty
        InvtDocumentHeader.TestField("Gen. Bus. Posting Group", '');

        // [THEN] The error will occur
        Assert.ExpectedError(StrSubstNo(TemplateNotFoundErr, PositiveInvtMovementTemplateCZL.Name));
    end;

    [Test]
    procedure ValidateGenBusPostingGroupInvtReceiptUT()
    var
        InvtDocumentHeader: Record "Invt. Document Header";
    begin
        // [SCENARIO] If the Gen. Bus. Posting Group is validating and Invt. Movement Template CZL is filled then error must occur.
        Initialize();

        // [GIVEN] The Gen. Bus. Posting Group has been filled
        InvtDocumentHeader."Gen. Bus. Posting Group" := CopyStr(LibraryRandom.RandText(20), 1, 20);

        // [GIVEN] The Invt. Movement Template CZL has been filled
        InvtDocumentHeader."Invt. Movement Template CZL" := CopyStr(LibraryRandom.RandText(10), 1, 10);

        // [WHEN] Validate the Gen. Bus. Posting Group with some value (empty string in this test case)
        asserterror InvtDocumentHeader.Validate("Gen. Bus. Posting Group", '');

        // [THEN] The error will occur
        Assert.ExpectedError(StrSubstNo(TemplateMustBeEmptyErr, ''''''));
    end;
}
