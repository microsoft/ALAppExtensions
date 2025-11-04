/// <summary>
/// Provides utility functions for creating and managing job (project) entities in test scenarios, including job tasks, job planning lines, and job journals.
/// </summary>
codeunit 131920 "Library - Job"
{

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryResource: Codeunit "Library - Resource";
        LibraryInventory: Codeunit "Library - Inventory";
        ConsumptionSource: Option Job,Service,GenJournal,Purchase;
        PrefixTxt: Label 'ZZZ';
        TemplateNameTxt: Label 'T';
        NoSeriesCodeTxt: Label 'JOBTEST';
        JobNosTok: Label 'JOB NOS', Locked = true;
        ErrorMsg: Label 'Unsupported type.';
        JobNoErr: Label 'GLEntry."Job No."';

    procedure CreateJob(var Job: Record Job)
    begin
        CreateJob(Job, CreateCustomer());
    end;

    procedure CreateJob(var Job: Record Job; SellToCustomerNo: Code[20])
    var
        JobNo: Code[20];
    begin
        // create a (LCY) job for a random customer

        // Find the next available job no.
        JobNo := PrefixTxt + 'J000';
        repeat
            JobNo := IncStr(JobNo);
        until not Job.Get(JobNo);

        Job.Init();
        Job.Validate("No.", JobNo);
        Job.Insert(true);
        Job.Validate("Sell-to Customer No.", SellToCustomerNo);
        Job.Validate("Job Posting Group", FindJobPostingGroup());
        Job.Modify(true)
    end;

    procedure CreateJobTask(Job: Record Job; var JobTask: Record "Job Task")
    var
        JobTaskLocal: Record "Job Task";
        JobTaskNo: Code[20];
    begin
        // Create a (posting) task for a job

        JobTaskNo := PrefixTxt + 'JT001';

        // Find the last task no. (as an integer)
        JobTaskLocal.SetRange("Job No.", Job."No.");
        if JobTaskLocal.FindLast() then
            JobTaskNo := IncStr(JobTaskLocal."Job Task No.");

        JobTask.Init();
        JobTask.Validate("Job No.", Job."No.");
        JobTask.Validate("Job Task No.", JobTaskNo);
        JobTask.Insert(true);

        JobTask.Validate("Job Task Type", JobTask."Job Task Type"::Posting);
        JobTask.Modify(true)
    end;

    procedure CreateJobPlanningLine(LineType: Enum "Job Planning Line Line Type"; Type: Enum "Job Planning Line Type"; JobTask: Record "Job Task"; var JobPlanningLine: Record "Job Planning Line")
    begin
        // Create a job planning line for job task <JobTask> of type <LineType> for consumable type <Type>

        JobPlanningLine.Init();
        JobPlanningLine.Validate("Job No.", JobTask."Job No.");
        JobPlanningLine.Validate("Job Task No.", JobTask."Job Task No.");
        JobPlanningLine.Validate("Line No.", GetNextLineNo(JobPlanningLine));
        JobPlanningLine.Insert(true);

        JobPlanningLine.Validate("Planning Date", WorkDate());
        JobPlanningLine.Validate("Line Type", LineType);
        JobPlanningLine.Validate(Type, Type);
        if JobPlanningLine.Type <> JobPlanningLine.Type::Text then begin
            JobPlanningLine.Validate("No.", FindConsumable(Type));
            JobPlanningLine.Validate(Quantity, LibraryRandom.RandInt(100)); // 1 <= Quantity <= 100
            if Type = GLAccountType() then begin
                JobPlanningLine.Validate("Unit Cost", LibraryRandom.RandInt(10)); // 1 <= Unit Cost <= 10
                JobPlanningLine.Validate("Unit Price", JobPlanningLine."Unit Cost" * (LibraryRandom.RandIntInRange(2, 10) / 10)); // 10% <= Markup <= 100%
            end;
        end;
        JobPlanningLine.Validate(Description, LibraryUtility.GenerateGUID());
        JobPlanningLine.Modify(true);

        JobPlanningLine.SetRange("Job No.", JobTask."Job No.");
        JobPlanningLine.SetRange("Job Task No.", JobTask."Job Task No.")
    end;

    procedure CreateJobPlanningLine(JobTask: Record "Job Task"; LineType: Enum "Job Planning Line Line Type"; Type: Enum "Job Planning Line Type"; No: Code[20]; Quantity: Decimal; var JobPlanningLine: Record "Job Planning Line")
    begin
        JobPlanningLine.Init();
        JobPlanningLine.Validate("Job No.", JobTask."Job No.");
        JobPlanningLine.Validate("Job Task No.", JobTask."Job Task No.");
        JobPlanningLine.Validate("Line No.", GetNextLineNo(JobPlanningLine));
        JobPlanningLine.Insert(true);
        JobPlanningLine.Validate("Planning Date", WorkDate());
        JobPlanningLine.Validate("Line Type", LineType);
        JobPlanningLine.Validate(Type, Type);
        JobPlanningLine.Validate("No.", No);
        JobPlanningLine.Validate(Quantity, Quantity);
        JobPlanningLine.Modify(true);
    end;

    procedure CreateJobJournalLine(LineType: Enum "Job Line Type"; JobTask: Record "Job Task"; var JobJournalLine: Record "Job Journal Line")
    var
        JobJournalTemplate: Record "Job Journal Template";
        JobJournalBatch: Record "Job Journal Batch";
        NoSeries: Codeunit "No. Series";
    begin
        // Create a job journal line for a job task.
        // This helper function allows to easily create multiple journal lines in a single batch.
        JobJournalLine.SetRange("Job No.", JobTask."Job No.");
        // Setup primary keys and filters.
        if JobJournalLine.FindLast() then
            // A job journal line for this task already exists: increase line and document nos.
            JobJournalLine.Validate("Line No.", JobJournalLine."Line No." + 1)
        else begin
            // No job journal lines exist for this task: setup the first one.
            CreateJobJournalBatch(GetJobJournalTemplate(JobJournalTemplate), JobJournalBatch);
            JobJournalLine.Validate("Journal Template Name", JobJournalTemplate.Name);
            JobJournalLine.Validate("Journal Batch Name", JobJournalBatch.Name);
            JobJournalLine.Validate("Line No.", 1);
            // Only use these template and batch.
            JobJournalLine.SetRange("Journal Template Name", JobJournalLine."Journal Template Name");
            JobJournalLine.SetRange("Journal Batch Name", JobJournalLine."Journal Batch Name");
        end;

        JobJournalLine.Init();
        JobJournalLine.Insert(true);

        JobJournalLine.Validate("Line Type", LineType);
        JobJournalLine.Validate("Posting Date", WorkDate());
        JobJournalLine.Validate("Job No.", JobTask."Job No.");
        JobJournalLine.Validate("Job Task No.", JobTask."Job Task No.");
        JobJournalBatch.Get(GetJobJournalTemplate(JobJournalTemplate), JobJournalLine."Journal Batch Name");
        JobJournalLine.Validate("Document No.", NoSeries.PeekNextNo(JobJournalBatch."No. Series", JobJournalLine."Posting Date"));
        JobJournalLine.Modify(true)
    end;

    procedure CreateJobJournalLineForType(LineType: Enum "Job Line Type"; ConsumableType: Enum "Job Planning Line Type"; JobTask: Record "Job Task"; var JobJournalLine: Record "Job Journal Line")
    begin
        CreateJobJournalLine(LineType, JobTask, JobJournalLine);

        // Attach requested consumable type to the created job journal line
        Attach2JobJournalLine(ConsumableType, JobJournalLine);
        JobJournalLine.Validate(Description, Format(LibraryUtility.GenerateGUID()));
        JobJournalLine.Modify(true)
    end;

    procedure CreateJobJournalLineForPlan(JobPlanningLine: Record "Job Planning Line"; UsageLineType: Enum "Job Line Type"; Fraction: Decimal; var JobJournalLine: Record "Job Journal Line")
    var
        JobTask: Record "Job Task";
        ChangeFactor: Decimal;
    begin
        Assert.IsTrue(JobPlanningLine."Usage Link", 'Usage link should be enabled');

        JobTask.Get(JobPlanningLine."Job No.", JobPlanningLine."Job Task No.");
        CreateJobJournalLine(UsageLineType, JobTask, JobJournalLine);
        JobJournalLine.Validate(Type, JobPlanningLine.Type);
        JobJournalLine.Validate("No.", JobPlanningLine."No.");
        JobJournalLine.Validate(Description, LibraryUtility.GenerateGUID());
        JobJournalLine.Validate(Quantity, Round(Fraction * JobPlanningLine."Remaining Qty."));
        // unit costs, prices may change (e.g., +/- 10%)
        if not IsStandardCosting(JobJournalLine.Type, JobJournalLine."No.") then begin
            ChangeFactor := Round((1 + (LibraryRandom.RandInt(21) - 11) / 100));
            JobJournalLine.Validate("Unit Cost", Round(ChangeFactor * JobPlanningLine."Unit Cost") / JobPlanningLine.Quantity);
            JobJournalLine.Validate("Unit Price", Round(ChangeFactor * JobPlanningLine."Unit Price") / JobPlanningLine.Quantity)
        end;
        JobJournalLine.Modify(true)
    end;

    procedure CreateGenJournalLineForPlan(JobPlanningLine: Record "Job Planning Line"; UsageLineType: Enum "Job Line Type"; Fraction: Decimal; var GenJournalLine: Record "Gen. Journal Line")
    var
        JobTask: Record "Job Task";
    begin
        Assert.IsTrue(JobPlanningLine."Usage Link", 'Usage link should be enabled');

        JobTask.Get(JobPlanningLine."Job No.", JobPlanningLine."Job Task No.");
        CreateJobGLJournalLine(UsageLineType, JobTask, GenJournalLine);

        GenJournalLine."Account No." := JobPlanningLine."No.";
        GenJournalLine.Validate(Description, LibraryUtility.GenerateGUID());
        GenJournalLine.Validate("Job Planning Line No.", JobPlanningLine."Line No.");
        GenJournalLine.Validate("Job Quantity", Round(Fraction * JobPlanningLine."Remaining Qty."));
        GenJournalLine.Modify(true)
    end;

    procedure CreateJobWIPMethod(var JobWIPMethod: Record "Job WIP Method")
    begin
        JobWIPMethod.Init();
        JobWIPMethod.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(JobWIPMethod.FieldNo(Code), DATABASE::"Job WIP Method"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"Job WIP Method", JobWIPMethod.FieldNo(Code))));
        JobWIPMethod.Insert(true)
    end;

    procedure CreatePurchaseLineForPlan(JobPlanningLine: Record "Job Planning Line"; UsageLineType: Enum "Job Line Type"; Fraction: Decimal; var PurchaseLine: Record "Purchase Line")
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        PurchaseHeader: Record "Purchase Header";
    begin
        Assert.IsTrue(JobPlanningLine."Usage Link", 'Usage link should be enabled');

        JobTask.Get(JobPlanningLine."Job No.", JobPlanningLine."Job Task No.");
        Job.Get(JobPlanningLine."Job No.");

        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, '');
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, Job2PurchaseConsumableType(JobPlanningLine.Type),
          JobPlanningLine."No.", Round(Fraction * JobPlanningLine."Remaining Qty."));
        // VALIDATE(Description,LibraryUtility.GenerateGUID());
        PurchaseLine.Validate(Description, JobPlanningLine."No.");
        PurchaseLine.Validate("Unit of Measure Code", JobPlanningLine."Unit of Measure Code");
        PurchaseLine.Validate("Job Line Type", UsageLineType);
        PurchaseLine.Validate("Job No.", JobPlanningLine."Job No.");
        PurchaseLine.Validate("Job Task No.", JobPlanningLine."Job Task No.");
        PurchaseLine.Validate("Job Planning Line No.", JobPlanningLine."Line No.");
        PurchaseLine.Modify(true)
    end;

#if not CLEAN27
    [Obsolete('Moved to codeunit Library Service', '27.0')]
    procedure CreateServiceLineForPlan(JobPlanningLine: Record "Job Planning Line"; UsageLineType: Enum "Job Line Type"; Fraction: Decimal; var ServiceLine: Record "Service Line")
    var
        LibraryService: Codeunit "Library - Service";
    begin
        LibraryService.CreateServiceLineForPlan(JobPlanningLine, UsageLineType, Fraction, ServiceLine);
    end;
#endif

    procedure CreateJobGLAccountPrice(var JobGLAccountPrice: Record "Job G/L Account Price"; JobNo: Code[20]; JobTaskNo: Code[20]; GLAccountNo: Code[20]; CurrencyCode: Code[10])
    begin
        JobGLAccountPrice.Init();
        JobGLAccountPrice.Validate("Job No.", JobNo);
        JobGLAccountPrice.Validate("Job Task No.", JobTaskNo);
        JobGLAccountPrice.Validate("G/L Account No.", GLAccountNo);
        JobGLAccountPrice.Validate("Currency Code", CurrencyCode);
        JobGLAccountPrice.Insert(true);
    end;

    procedure CreateJobItemPrice(var JobItemPrice: Record "Job Item Price"; JobNo: Code[20]; JobTaskNo: Code[20]; ItemNo: Code[20]; CurrencyCode: Code[10]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10])
    begin
        JobItemPrice.Init();
        JobItemPrice.Validate("Job No.", JobNo);
        JobItemPrice.Validate("Job Task No.", JobTaskNo);
        JobItemPrice.Validate("Item No.", ItemNo);
        JobItemPrice.Validate("Currency Code", CurrencyCode);
        JobItemPrice.Validate("Variant Code", VariantCode);
        JobItemPrice.Validate("Unit of Measure Code", UnitOfMeasureCode);
        JobItemPrice.Insert(true);
    end;

    procedure CreateJobResourcePrice(var JobResourcePrice: Record "Job Resource Price"; JobNo: Code[20]; JobTaskNo: Code[20]; Type: Option; "Code": Code[20]; WorkTypeCode: Code[10]; CurrencyCode: Code[10])
    begin
        JobResourcePrice.Init();
        JobResourcePrice.Validate("Job No.", JobNo);
        JobResourcePrice.Validate("Job Task No.", JobTaskNo);
        JobResourcePrice.Validate(Type, Type);
        JobResourcePrice.Validate(Code, Code);
        JobResourcePrice.Validate("Work Type Code", WorkTypeCode);
        JobResourcePrice.Validate("Currency Code", CurrencyCode);
        JobResourcePrice.Insert(true);
    end;

    procedure CreateJobJournalBatch(JobJournalTemplateName: Code[10]; var JobJournalBatch: Record "Job Journal Batch") BatchName: Code[10]
    begin
        Clear(JobJournalBatch);

        // Find a unique batch name (wrt existing and previously posted batches)
        BatchName := PrefixTxt + 'B000';
        repeat
            BatchName := IncStr(BatchName);
        until not JobJournalBatch.Get(JobJournalTemplateName, BatchName);

        JobJournalBatch.Validate("Journal Template Name", JobJournalTemplateName);
        JobJournalBatch.Validate(Name, BatchName);
        JobJournalBatch.SetupNewBatch();
        JobJournalBatch.Insert(true)
    end;

    procedure CreateJobJournalTemplate(var JobJournalTemplate: Record "Job Journal Template")
    begin
        JobJournalTemplate.Init();
        JobJournalTemplate.Validate(
          Name, LibraryUtility.GenerateRandomCode(JobJournalTemplate.FieldNo(Name), DATABASE::"Job Journal Template"));
        JobJournalTemplate.Insert(true);
    end;

    procedure CreateJobPostingGroup(var JobPostingGroup: Record "Job Posting Group")
    begin
        Clear(JobPostingGroup);
        JobPostingGroup.Validate(Code,
          LibraryUtility.GenerateRandomCode(JobPostingGroup.FieldNo(Code), DATABASE::"Job Posting Group"));
        JobPostingGroup.Validate("WIP Costs Account", LibraryERM.CreateGLAccountNo());
        JobPostingGroup.Validate("WIP Accrued Costs Account", LibraryERM.CreateGLAccountNo());
        JobPostingGroup.Validate("Job Costs Applied Account", LibraryERM.CreateGLAccountNo());
        JobPostingGroup.Validate("Job Costs Adjustment Account", LibraryERM.CreateGLAccountNo());
        JobPostingGroup.Validate("G/L Expense Acc. (Contract)", LibraryERM.CreateGLAccountNo());
        JobPostingGroup.Validate("Job Sales Adjustment Account", LibraryERM.CreateGLAccountNo());
        JobPostingGroup.Validate("WIP Accrued Sales Account", LibraryERM.CreateGLAccountNo());
        JobPostingGroup.Validate("WIP Invoiced Sales Account", LibraryERM.CreateGLAccountNo());
        JobPostingGroup.Validate("Job Sales Applied Account", LibraryERM.CreateGLAccountNo());
        JobPostingGroup.Validate("Recognized Costs Account", LibraryERM.CreateGLAccountNo());
        JobPostingGroup.Validate("Recognized Sales Account", LibraryERM.CreateGLAccountNo());
        JobPostingGroup.Validate("Item Costs Applied Account", LibraryERM.CreateGLAccountNo());
        JobPostingGroup.Validate("Resource Costs Applied Account", LibraryERM.CreateGLAccountNo());
        JobPostingGroup.Validate("G/L Costs Applied Account", LibraryERM.CreateGLAccountNo());
        JobPostingGroup.Insert(true);
    end;

    procedure GetJobJournalTemplate(var JobJournalTemplate: Record "Job Journal Template"): Code[10]
    begin
        Clear(JobJournalTemplate);
        if not JobJournalTemplate.Get(PrefixTxt + TemplateNameTxt) then begin
            JobJournalTemplate.Validate(Name, PrefixTxt + TemplateNameTxt);
            JobJournalTemplate.Insert(true)
        end;

        JobJournalTemplate.Validate("No. Series", GetJobTestNoSeries());
        JobJournalTemplate.Modify(true);
        exit(JobJournalTemplate.Name)
    end;

    procedure DeleteJobJournalTemplate()
    var
        JobJournalTemplate: Record "Job Journal Template";
    begin
        if JobJournalTemplate.Get(PrefixTxt + TemplateNameTxt) then
            JobJournalTemplate.Delete(true);
    end;

    procedure CreateJobGLJournalLine(JobLineType: Enum "Job Line Type"; JobTask: Record "Job Task"; var GenJournalLine: Record "Gen. Journal Line")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GLAccount: Record "G/L Account";
        NoSeries: Codeunit "No. Series";
    begin
        // Create a general journal line for a job task.
        // This helper function allows to easily create multiple journal lines in a single batch.
        // These journal lines can be traced using their document number and batch.
        LibraryERM.CreateGLAccount(GLAccount);
        GenJournalLine.SetRange("Job No.", JobTask."Job No.");
        if GenJournalLine.FindLast() then
            GenJournalLine.Validate("Line No.", GenJournalLine."Line No." + 1)
        else begin
            Clear(GenJournalLine);
            CreateGenJournalBatch(GetGenJournalTemplate(GenJournalTemplate), GenJournalBatch);
            GenJournalLine.Validate("Journal Template Name", GenJournalTemplate.Name);
            GenJournalLine.Validate("Journal Batch Name", GenJournalBatch.Name);
            GenJournalLine.Validate("Line No.", 1);
            GenJournalLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
            GenJournalLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        end;

        GenJournalLine.Init();
        GenJournalLine.Insert(true);

        GenJournalLine.Validate("Posting Date", WorkDate());
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"G/L Account");
        GenJournalLine.Validate("Account No.", GLAccount."No.");
        GenJournalLine.Validate(Description, GLAccount."No.");
        LibraryERM.CreateGLAccount(GLAccount);
        GenJournalLine.Validate("Bal. Account No.", GLAccount."No.");
        GenJournalLine.Validate(Amount, LibraryRandom.RandDec(100, 2));
        GenJournalLine.Validate("Job Line Type", JobLineType);
        GenJournalLine.Validate("Job No.", JobTask."Job No.");
        GenJournalLine.Validate("Job Task No.", JobTask."Job Task No.");
        GenJournalLine.Validate("Job Quantity", LibraryRandom.RandInt(10));
        GenJournalBatch.Get(GetGenJournalTemplate(GenJournalTemplate), GenJournalLine."Journal Batch Name");
        GenJournalLine.Validate("Document No.", NoSeries.PeekNextNo(GenJournalBatch."No. Series", GenJournalLine."Posting Date"));
        GenJournalLine.Validate("Source Code", GenJournalTemplate."Source Code");
        GenJournalLine.Modify(true)
    end;

    procedure CreateGenJournalBatch(GenJournalTemplateName: Code[10]; var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GLEntry: Record "G/L Entry";
        JobLedgerEntry: Record "Job Ledger Entry";
        BatchName: Code[10];
    begin
        Clear(GenJournalBatch);

        // Find a unique name (wrt existing and previously posted batches)
        BatchName := PrefixTxt + 'B000';
        repeat
            BatchName := IncStr(BatchName);
            GLEntry.SetRange("Journal Batch Name", BatchName);
            JobLedgerEntry.SetRange("Journal Batch Name", BatchName);
        until GLEntry.IsEmpty() and JobLedgerEntry.IsEmpty() and not GenJournalBatch.Get(GenJournalTemplateName, BatchName);

        GenJournalBatch.Validate("Journal Template Name", GenJournalTemplateName);
        GenJournalBatch.Validate(Name, BatchName);
        GenJournalBatch.SetupNewBatch();
        GenJournalBatch.Insert(true)
    end;

    procedure GetGenJournalTemplate(var GenJournalTemplate: Record "Gen. Journal Template"): Code[10]
    var
        SourceCode: Record "Source Code";
    begin
        // In this test codeunit we always use the same gen. journal template

        Clear(GenJournalTemplate);
        if not GenJournalTemplate.Get(PrefixTxt + TemplateNameTxt) then begin
            GenJournalTemplate.Validate(Name, PrefixTxt + TemplateNameTxt);
            GenJournalTemplate.Insert(true)
        end;

        LibraryERM.CreateSourceCode(SourceCode);
        GenJournalTemplate.Validate("Source Code", SourceCode.Code);
        GenJournalTemplate.Validate("No. Series", GetJobTestNoSeries());
        GenJournalTemplate.Modify(true);

        exit(GenJournalTemplate.Name)
    end;

    procedure GetJobTestNoSeries(): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if not NoSeries.Get(NoSeriesCodeTxt) then begin
            LibraryUtility.CreateNoSeries(NoSeriesCodeTxt, true, false, false);
            LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeriesCodeTxt, '', '')
        end;

        exit(NoSeriesCodeTxt)
    end;

    procedure SetJobNoSeriesCode()
    var
        JobsSetup: Record "Jobs Setup";
        NoSeriesLine: Record "No. Series Line";
    begin
        JobsSetup.Get();
        if JobsSetup."Job Nos." = '' then begin
            LibraryUtility.CreateNoSeries(JobNosTok, true, true, false);
            LibraryUtility.CreateNoSeriesLine(NoSeriesLine, JobNosTok, 'J0000001', 'J9999991');
            JobsSetup.Validate("Job Nos.", JobNosTok);
            JobsSetup.Modify(true);
        end;
    end;

    procedure CreateConsumable(Type: Enum "Job Planning Line Type"): Code[20]
    var
        Item: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        Resource: Record Resource;
        ResourceUnitOfMeasure: Record "Resource Unit of Measure";
        GLAccount: Record "G/L Account";
    begin
        case Type of
            "Job Planning Line Type"::Resource:
                begin
                    Resource.Get(FindConsumable(Type));
                    ResourceUnitOfMeasure.Get(Resource."No.", Resource."Base Unit of Measure");
                    Resource."No." := '';
                    Resource.Insert(true);
                    ResourceUnitOfMeasure."Resource No." := Resource."No.";
                    ResourceUnitOfMeasure.Insert(true);
                    exit(Resource."No.")
                end;
            "Job Planning Line Type"::Item:
                begin
                    Item.Get(FindConsumable(Type));
                    ItemUnitOfMeasure.Get(Item."No.", Item."Base Unit of Measure");
                    Item."No." := '';
                    Item.Insert(true);
                    ItemUnitOfMeasure."Item No." := Item."No.";
                    ItemUnitOfMeasure.Insert(true);
                    exit(Item."No.")
                end;
            GLAccountType():
                begin
                    GLAccount.Get(FindConsumable(Type));
                    GLAccount."No." := '';
                    GLAccount.Insert(true);
                    exit(GLAccount."No.")
                end;
            else
                Assert.Fail('Unsupported consumable type');
        end
    end;

    procedure Attach2PurchaseLine(ConsumableType: Enum "Purchase Line Type"; var PurchaseLine: Record "Purchase Line")
    begin
        // Attach a random number of random consumables to the purchase line.
        PurchaseLine.Validate(Type, ConsumableType);
        PurchaseLine.Validate("No.", FindConsumable(Purchase2JobConsumableType(ConsumableType)));
        PurchaseLine.Validate(Quantity, LibraryRandom.RandInt(100));
        if PurchaseLine.Type = PurchaseLine.Type::"G/L Account" then
            PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandInt(100));
        PurchaseLine.Modify(true)
    end;

    local procedure Attach2JobJournalLine(ConsumableType: Enum "Job Planning Line Type"; var JobJournalLine: Record "Job Journal Line")
    begin
        // Attach a random number of random consumables to the job journal line.
        JobJournalLine.Validate(Type, ConsumableType);
        JobJournalLine.Validate("No.", FindConsumable(ConsumableType));
        JobJournalLine.Validate(Quantity, LibraryRandom.RandInt(100));
        if JobJournalLine.Type = JobJournalLine.Type::"G/L Account" then
            JobJournalLine.Validate("Unit Price", LibraryRandom.RandInt(100));
        JobJournalLine.Modify(true)
    end;

    procedure AttachJobTask2PurchaseLine(JobTask: Record "Job Task"; var PurchaseLine: Record "Purchase Line")
    begin
        // Attach the job task to the purchase line.
        PurchaseLine.Validate("Job No.", JobTask."Job No.");
        PurchaseLine.Validate("Job Task No.", JobTask."Job Task No.");
        PurchaseLine.Modify(true)
    end;

    local procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        exit(Customer."No.")
    end;

    procedure FindConsumable(Type: Enum "Job Planning Line Type"): Code[20]
    begin
        case Type of
            "Job Planning Line Type"::Resource:
                exit(LibraryResource.CreateResourceNo());
            "Job Planning Line Type"::Item:
                exit(FindItem());
            "Job Planning Line Type"::"G/L Account":
                exit(LibraryERM.CreateGLAccountWithSalesSetup());
            else
                Error(ErrorMsg);
        end
    end;

    procedure FindItem(): Code[20]
    var
        Item: Record Item;
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("Unit Price", LibraryRandom.RandDec(100, 2));
        Item.Validate("Unit Cost", LibraryRandom.RandDec(100, 2));
        Item.Modify(true);
        exit(Item."No.");
    end;

    procedure FindJobPostingGroup(): Code[20]
    var
        JobPostingGroup: Record "Job Posting Group";
    begin
        if not JobPostingGroup.FindFirst() then
            CreateJobPostingGroup(JobPostingGroup);
        exit(JobPostingGroup.Code);
    end;

    procedure UseJobPlanningLine(JobPlanningLine: Record "Job Planning Line"; UsageLineType: Enum "Job Line Type"; Fraction: Decimal; var JobJournalLine: Record "Job Journal Line")
    begin
        CreateJobJournalLineForPlan(JobPlanningLine, UsageLineType, Fraction, JobJournalLine);
        PostJobJournal(JobJournalLine)
    end;

    procedure UseJobPlanningLineExplicit(JobPlanningLine: Record "Job Planning Line"; UsageLineType: Enum "Job Line Type"; Fraction: Decimal; Source: Option; var JobJournalLine: Record "Job Journal Line")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        case Source of
            JobConsumption():
                begin
                    CreateJobJournalLineForPlan(JobPlanningLine, UsageLineType, Fraction, JobJournalLine);
                    JobJournalLine.Validate("Job Planning Line No.", JobPlanningLine."Line No.");
                    JobJournalLine.Modify(true);
                    PostJobJournal(JobJournalLine)
                end;
            GenJournalConsumption():
                begin
                    Assert.AreEqual(GLAccountType(), JobPlanningLine.Type, 'Can only consume G/L Account via Job Gen. Journal.');
                    CreateGenJournalLineForPlan(JobPlanningLine, UsageLineType, Fraction, GenJournalLine);
                    LibraryERM.PostGeneralJnlLine(GenJournalLine);
                    JobJournalLine."Line Type" := GenJournalLine."Job Line Type";
                    JobJournalLine."Remaining Qty." := GenJournalLine."Job Remaining Qty.";
                    JobJournalLine.Quantity := GenJournalLine."Job Quantity";
                    JobJournalLine.Description := GenJournalLine.Description;
                    JobJournalLine."Total Cost" := GenJournalLine."Job Total Cost";
                    JobJournalLine."Total Cost (LCY)" := GenJournalLine."Job Total Cost (LCY)";
                    JobJournalLine."Line Amount" := GenJournalLine."Job Line Amount";
                end;
            PurchaseConsumption():
                begin
                    CreatePurchaseLineForPlan(JobPlanningLine, UsageLineType, Fraction, PurchaseLine);
                    PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
                    LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
                    JobJournalLine."Line Type" := PurchaseLine."Job Line Type";
                    JobJournalLine."Remaining Qty." := PurchaseLine."Job Remaining Qty.";
                    JobJournalLine.Quantity := PurchaseLine."Qty. to Invoice";
                    JobJournalLine.Description := PurchaseLine.Description;
                    JobJournalLine."Total Cost" := PurchaseLine."Qty. to Invoice" * PurchaseLine."Unit Cost (LCY)";
                    JobJournalLine."Total Cost (LCY)" := PurchaseLine."Qty. to Invoice" * PurchaseLine."Unit Cost (LCY)";
                    JobJournalLine."Total Price" := PurchaseLine."Job Total Price";
                    JobJournalLine."Line Amount" := PurchaseLine."Job Line Amount";
                end;
            else
                Assert.Fail('Consumption method not supported');
        end
    end;

    procedure PostJobJournal(var JobJournalLine: Record "Job Journal Line")
    var
        JobJournalLine2: Record "Job Journal Line";
    begin
        // Post a job journal.
        JobJournalLine2 := JobJournalLine;
        CODEUNIT.Run(CODEUNIT::"Job Jnl.-Post", JobJournalLine2)
    end;

    local procedure GetGLEntry(var JobLedgerEntry: Record "Job Ledger Entry"; var GLEntry: Record "G/L Entry")
    var
        Item: Record Item;
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        GLEntry.Reset();
        GLEntry.SetRange("Posting Date", JobLedgerEntry."Posting Date");
        GLEntry.SetRange("Document No.", JobLedgerEntry."Document No.");
        GLEntry.SetRange("Job No.", JobLedgerEntry."Job No.");

        case JobLedgerEntry."Ledger Entry Type" of
            JobLedgerEntry."Ledger Entry Type"::"G/L Account":
                GLEntry.SetRange("G/L Account No.", JobLedgerEntry."No.");
            JobLedgerEntry."Ledger Entry Type"::Item:
                begin
                    GeneralPostingSetup.Get(JobLedgerEntry."Gen. Bus. Posting Group", JobLedgerEntry."Gen. Prod. Posting Group");
                    Item.Get(JobLedgerEntry."No.");
                    GLEntry.SetRange("Gen. Prod. Posting Group", JobLedgerEntry."Gen. Prod. Posting Group");
                    GLEntry.SetRange("Gen. Bus. Posting Group", JobLedgerEntry."Gen. Bus. Posting Group");
                    GLEntry.SetRange("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
                    GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Purch. Account");
                end;
            else
                Assert.Fail(StrSubstNo('Unsupported entry type: %1', JobLedgerEntry."Ledger Entry Type"));
        end;

        GLEntry.FindFirst();
    end;

    procedure VerifyGLEntries(var JobLedgerEntry: Record "Job Ledger Entry")
    var
        GLEntry: Record "G/L Entry";
    begin
        // Verify that each job entry has corresponding g/l entry with a job no.
        JobLedgerEntry.FindSet();
        repeat
            GetGLEntry(JobLedgerEntry, GLEntry);
            Assert.AreEqual(JobLedgerEntry."Job No.", GLEntry."Job No.", JobNoErr);
        until JobLedgerEntry.Next() = 0
    end;

    procedure VerifyPurchaseDocPostingForJob(var PurchaseLine: Record "Purchase Line")
    var
        TempJobJournalLine: Record "Job Journal Line" temporary;
        Job: Record Job;
    begin
        // Verify posting of a purchase line for a job.
        PurchaseLine.SetFilter("Job No.", '<>''''');
        PurchaseLine.FindSet();
        Job.Get(PurchaseLine."Job No.");

        repeat
            TempJobJournalLine."Line No." := PurchaseLine."Line No.";
            TempJobJournalLine."Job No." := PurchaseLine."Job No.";
            TempJobJournalLine."Job Task No." := PurchaseLine."Job Task No.";
            TempJobJournalLine.Description := PurchaseLine.Description;
            TempJobJournalLine."Line Type" := PurchaseLine."Job Line Type";
            TempJobJournalLine.Quantity := PurchaseLine.Quantity;
            TempJobJournalLine."Unit Cost (LCY)" := PurchaseLine."Unit Cost (LCY)";
            TempJobJournalLine."Unit Price (LCY)" := PurchaseLine."Unit Price (LCY)";
            TempJobJournalLine."Currency Code" := Job."Currency Code";
            TempJobJournalLine.Insert();
        until PurchaseLine.Next() = 0;

        VerifyJobJournalPosting(false, TempJobJournalLine)
    end;

    procedure VerifyJobJournalPosting(UsageLink: Boolean; var JobJournalLine: Record "Job Journal Line")
    begin
        // Verify that the journal lines were posted correctly.

        Assert.IsFalse(JobJournalLine.IsEmpty, 'Not verifying any Job Journal Lines!');
        JobJournalLine.FindSet();
        repeat
            VerifyJobLedger(JobJournalLine);
            VerifyPlanningLines(JobJournalLine, UsageLink)
        until JobJournalLine.Next() = 0
    end;

    procedure VerifyJobLedger(JobJournalLine: Record "Job Journal Line")
    var
        JobLedgerEntry: Record "Job Ledger Entry";
        Precision: Decimal;
    begin
        // A posted job journal line gives one corresponding entry in the job ledger.
        JobLedgerEntry.SetRange(Description, JobJournalLine.Description);

        Assert.AreEqual(
          1, JobLedgerEntry.Count(),
          StrSubstNo('Invalid Job Ledger Entry for Batch %1 Document %2', JobJournalLine."Journal Batch Name", JobJournalLine."Document No."));

        JobLedgerEntry.FindFirst();
        Precision := max(GetAmountRoundingPrecision(''), GetAmountRoundingPrecision(JobJournalLine."Currency Code"));
        Assert.AreEqual(JobJournalLine."Job No.", JobLedgerEntry."Job No.", JobLedgerEntry.FieldCaption("Job No."));
        Assert.AreEqual(JobJournalLine."Job Task No.", JobLedgerEntry."Job Task No.", JobLedgerEntry.FieldCaption("Job Task No."));
        Assert.AreNearlyEqual(JobJournalLine."Unit Cost (LCY)", JobLedgerEntry."Unit Cost (LCY)", Precision * 10, JobLedgerEntry.FieldCaption("Unit Cost (LCY)"));
        Assert.AreNearlyEqual(JobJournalLine."Unit Price (LCY)", JobLedgerEntry."Unit Price (LCY)", Precision, JobLedgerEntry.FieldCaption("Unit Price (LCY)"));
        Assert.AreEqual(JobJournalLine.Quantity, JobLedgerEntry.Quantity, JobLedgerEntry.FieldCaption(Quantity));
    end;

    procedure VerifyPlanningLines(JobJournalLine: Record "Job Journal Line"; UsageLink: Boolean)
    var
        JobPlanningLine: Record "Job Planning Line";
        Precision: Decimal;
    begin
        // A posted job journal line gives
        // 0 (Blank),
        // 1 (Contract or Schedule), or
        // 2 (Both)
        // corresponding planning lines.
        JobPlanningLine.SetRange(Description, JobJournalLine.Description);
        // Verify line count and type
        case JobJournalLine."Line Type" of
            UsageLineTypeBlank():
                VerifyPlanningLineCountBlank(JobJournalLine, UsageLink);
            UsageLineTypeSchedule():
                VerifyPlanningLineCountSchedul(JobJournalLine);
            UsageLineTypeContract():
                VerifyPlanningLineCountContrac(JobJournalLine, UsageLink);
            UsageLineTypeBoth():
                VerifyPlanningLineCountBoth(JobJournalLine);
            else
                Assert.Fail('Invalid line type.');
        end;
        // Verify Unit Cost, Price.
        Precision := max(GetAmountRoundingPrecision(''), GetAmountRoundingPrecision(JobJournalLine."Currency Code"));
        if JobPlanningLine.FindSet() then
            repeat
                Assert.AreEqual(JobJournalLine.Quantity, JobPlanningLine.Quantity, JobPlanningLine.FieldCaption(Quantity));
                Assert.AreEqual(JobJournalLine."Job No.", JobPlanningLine."Job No.", JobPlanningLine.FieldCaption("Job No."));
                Assert.AreEqual(JobJournalLine."Job Task No.", JobPlanningLine."Job Task No.", JobPlanningLine.FieldCaption("Job Task No."));
                Assert.AreNearlyEqual(JobJournalLine."Unit Cost (LCY)", JobPlanningLine."Unit Cost (LCY)", Precision * 10, JobPlanningLine.FieldCaption("Unit Cost (LCY)"));
                Assert.AreNearlyEqual(JobJournalLine."Unit Price (LCY)", JobPlanningLine."Unit Price (LCY)", Precision, JobPlanningLine.FieldCaption("Unit Price (LCY)"))
            until JobPlanningLine.Next() = 0
    end;

    local procedure VerifyPlanningLineCountBlank(JobJournalLine: Record "Job Journal Line"; UsageLink: Boolean)
    var
        JobPlanningLine: Record "Job Planning Line";
        Job: Record Job;
    begin
        JobPlanningLine.SetRange(Description, JobJournalLine.Description);
        Job.Get(JobJournalLine."Job No.");
        if UsageLink then begin
            Assert.AreEqual(1, JobPlanningLine.Count, StrSubstNo('# planning lines for Line Type %1.', JobJournalLine."Line Type"));
            JobPlanningLine.FindFirst();
            Assert.AreEqual(PlanningLineTypeSchedule(), JobPlanningLine."Line Type", JobPlanningLine.FieldCaption("Line Type"))
        end else
            Assert.IsTrue(JobPlanningLine.IsEmpty, StrSubstNo('No planning lines should be created for %1.', JobJournalLine."Line Type"));
    end;

    local procedure VerifyPlanningLineCountSchedul(JobJournalLine: Record "Job Journal Line")
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        JobPlanningLine.SetRange(Description, JobJournalLine.Description);
        Assert.AreEqual(1, JobPlanningLine.Count, StrSubstNo('# planning lines for Line Type %1.', JobJournalLine."Line Type"));
        JobPlanningLine.FindFirst();
        Assert.AreEqual(PlanningLineTypeSchedule(), JobPlanningLine."Line Type", JobPlanningLine.FieldCaption("Line Type"))
    end;

    local procedure VerifyPlanningLineCountContrac(JobJournalLine: Record "Job Journal Line"; UsageLink: Boolean)
    var
        Job: Record Job;
        JobPlanningLine: Record "Job Planning Line";
    begin
        JobPlanningLine.SetRange(Description, JobJournalLine.Description);
        if UsageLink then begin
            Job.Get(JobJournalLine."Job No.");
            if Job."Allow Schedule/Contract Lines" then begin
                Assert.AreEqual(1, JobPlanningLine.Count, StrSubstNo('# planning lines for Line Type %1.', JobJournalLine."Line Type"));
                JobPlanningLine.FindFirst();
                Assert.AreEqual(PlanningLineTypeBoth(), JobPlanningLine."Line Type", JobPlanningLine.FieldCaption("Line Type"))
            end else begin
                Assert.AreEqual(2, JobPlanningLine.Count, StrSubstNo('# planning lines for Line Type %1.', JobJournalLine."Line Type"));
                JobPlanningLine.SetRange("Line Type", PlanningLineTypeSchedule());
                Assert.AreEqual(1, JobPlanningLine.Count, StrSubstNo('# schedule planning line for Line Type %1.', JobJournalLine."Line Type"));
                JobPlanningLine.SetRange("Line Type", PlanningLineTypeContract());
                Assert.AreEqual(1, JobPlanningLine.Count, StrSubstNo('# contract planning lines for Line Type %1.', JobJournalLine."Line Type"))
            end
        end else begin
            Assert.AreEqual(1, JobPlanningLine.Count, StrSubstNo('# planning lines for Line Type %1.', JobJournalLine."Line Type"));
            JobPlanningLine.FindFirst();
            Assert.AreEqual(PlanningLineTypeContract(), JobPlanningLine."Line Type", JobPlanningLine.FieldCaption("Line Type"))
        end
    end;

    local procedure VerifyPlanningLineCountBoth(JobJournalLine: Record "Job Journal Line")
    var
        Job: Record Job;
        JobPlanningLine: Record "Job Planning Line";
    begin
        JobPlanningLine.SetRange(Description, JobJournalLine.Description);
        Job.Get(JobJournalLine."Job No.");
        if Job."Allow Schedule/Contract Lines" then begin
            Assert.AreEqual(1, JobPlanningLine.Count, StrSubstNo('# planning lines for Line Type %1.', JobJournalLine."Line Type"));
            JobPlanningLine.FindFirst();
            Assert.AreEqual(PlanningLineTypeBoth(), JobPlanningLine."Line Type", JobPlanningLine.FieldCaption("Line Type"))
        end else begin
            Assert.AreEqual(2, JobPlanningLine.Count, StrSubstNo('# planning lines for Line Type %1.', JobJournalLine."Line Type"));
            JobPlanningLine.SetRange("Line Type", PlanningLineTypeSchedule());
            Assert.AreEqual(1, JobPlanningLine.Count, StrSubstNo('# schedule planning line for Line Type %1.', JobJournalLine."Line Type"));
            JobPlanningLine.SetRange("Line Type", PlanningLineTypeContract());
            Assert.AreEqual(1, JobPlanningLine.Count, StrSubstNo('# contract planning lines for Line Type %1.', JobJournalLine."Line Type"))
        end
    end;

    procedure UpdateJobPostingGroup(var JobPostingGroup: Record "Job Posting Group")
    var
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        JobPostingGroup.Validate("WIP Costs Account", GLAccount."No.");
        JobPostingGroup.Validate("WIP Invoiced Sales Account", GLAccount."No.");
        JobPostingGroup.Validate("WIP Accrued Costs Account", GLAccount."No.");
        JobPostingGroup.Validate("WIP Accrued Sales Account", GLAccount."No.");
        JobPostingGroup.Validate("Job Costs Applied Account", GLAccount."No.");
        JobPostingGroup.Validate("Job Costs Adjustment Account", GLAccount."No.");
        JobPostingGroup.Validate("Job Sales Applied Account", GLAccount."No.");
        JobPostingGroup.Validate("Job Sales Adjustment Account", GLAccount."No.");
        JobPostingGroup.Validate("Resource Costs Applied Account", GLAccount."No.");
        JobPostingGroup.Validate("Recognized Costs Account", GLAccount."No.");
        JobPostingGroup.Validate("Recognized Sales Account", GLAccount."No.");
        JobPostingGroup.Validate("G/L Costs Applied Account", GLAccount."No.");
        JobPostingGroup.Modify(true);
    end;

    procedure ConfigureGeneralPosting()
    var
        GeneralPostingSetup: Record "General Posting Setup";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        RecordRef: RecordRef;
        GenBusinessPostingGroupCode: Code[20];
    begin
        // create a posting setup for each combination of product and business group
        // including "empty" business group (in the first iteration)

        repeat
            GenBusinessPostingGroupCode := GenBusinessPostingGroup.Code;
            GenProductPostingGroup.FindSet();
            repeat
                if not GeneralPostingSetup.Get(GenBusinessPostingGroupCode, GenProductPostingGroup.Code) then
                    CreateGeneralPostingSetup(GenBusinessPostingGroupCode, GenProductPostingGroup.Code, GeneralPostingSetup);

                RecordRef.GetTable(GeneralPostingSetup);
                // general posting => income statement
                SetIncomeStatementGLAccounts(RecordRef);
            until GenProductPostingGroup.Next() = 0;
        until GenBusinessPostingGroup.Next() = 0;
    end;

    procedure CreateGeneralPostingSetup(GenBusinessPostingGroupCode: Code[20]; GenProductPostingGroupCode: Code[20]; var GeneralPostingSetup: Record "General Posting Setup")
    begin
        GeneralPostingSetup."Gen. Bus. Posting Group" := GenBusinessPostingGroupCode;
        GeneralPostingSetup."Gen. Prod. Posting Group" := GenProductPostingGroupCode;
        GeneralPostingSetup.Init();
        GeneralPostingSetup.Insert(true);
    end;

    procedure ConfigureVATPosting()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        RecordRef: RecordRef;
        VATBusinessPostingGroupCode: Code[20];
        VATProductPostingGroupCode: Code[20];
    begin
        // create a posting setup for each combination of product and business group
        // including "empty" business and product group combinations

        repeat
            VATBusinessPostingGroupCode := VATBusinessPostingGroup.Code;
            Clear(VATProductPostingGroup);
            repeat
                VATProductPostingGroupCode := VATProductPostingGroup.Code;
                if not VATPostingSetup.Get(VATBusinessPostingGroupCode, VATProductPostingGroupCode) then
                    CreateVATPostingSetup(VATBusinessPostingGroupCode, VATProductPostingGroupCode, VATPostingSetup);

                RecordRef.GetTable(VATPostingSetup);
                // VAT posting => income statement
                SetIncomeStatementGLAccounts(RecordRef);
            until VATProductPostingGroup.Next() = 0;
        until VATBusinessPostingGroup.Next() = 0;
    end;

    procedure CreateVATPostingSetup(VATBusinessPostingGroupCode: Code[20]; VATProductPostingGroupCode: Code[20]; var VATPostingSetup: Record "VAT Posting Setup")
    begin
        VATPostingSetup."VAT Bus. Posting Group" := VATBusinessPostingGroupCode;
        VATPostingSetup."VAT Prod. Posting Group" := VATProductPostingGroupCode;
        VATPostingSetup.Init();
        VATPostingSetup."VAT %" := LibraryRandom.RandIntInRange(10, 25);
        // 10 <= VAT % <= 25
        VATPostingSetup."VAT Identifier" := Format(VATPostingSetup."VAT %");
        VATPostingSetup."Sales VAT Account" := LibraryERM.CreateGLAccountWithSalesSetup();
        VATPostingSetup."Sales VAT Unreal. Account" := VATPostingSetup."Sales VAT Account";
        VATPostingSetup."Purchase VAT Account" := VATPostingSetup."Sales VAT Account";
        VATPostingSetup."Purch. VAT Unreal. Account" := VATPostingSetup."Sales VAT Account";
        VATPostingSetup.Insert(true);
    end;

    procedure SetAutomaticUpdateJobItemCost(IsEnabled: Boolean)
    var
        JobsSetup: Record "Jobs Setup";
    begin
        JobsSetup.Get();
        JobsSetup.Validate("Automatic Update Job Item Cost", IsEnabled);
        JobsSetup.Modify(true);
    end;

    procedure SetIncomeStatementGLAccounts(RecordRef: RecordRef)
    var
        GLAccount: Record "G/L Account";
        FieldRef: FieldRef;
        Idx: Integer;
    begin
        // Set all GLAccount fields in RecordRef to a (different) account
        for Idx := 1 to RecordRef.FieldCount do begin
            FieldRef := RecordRef.FieldIndex(Idx);
            if FieldRef.Relation = DATABASE::"G/L Account" then begin
                GLAccount.Get(LibraryERM.CreateGLAccountWithSalesSetup());
                GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Income Statement";
                GLAccount.Modify(true);
                FieldRef.Value := GLAccount."No.";
                FieldRef.TestField();
                RecordRef.Modify();
            end
        end
    end;

    procedure GetNextLineNo(JobPlanningLine: Record "Job Planning Line"): Integer
    begin
        JobPlanningLine.Reset();
        JobPlanningLine.SetRange("Job No.", JobPlanningLine."Job No.");
        JobPlanningLine.SetRange("Job Task No.", JobPlanningLine."Job Task No.");
        if JobPlanningLine.FindLast() then
            exit(JobPlanningLine."Line No." + 10000);
        exit(10000)
    end;

    local procedure IsStandardCosting(Type: Enum "Job Planning Line Type"; No: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        if Type <> "Job Planning Line Type"::Item then
            exit(false);

        Item.Get(No);
        exit(Item."Costing Method" = Item."Costing Method"::Standard)
    end;

    procedure Service2JobConsumableType(Type: Enum "Service Line Type"): Enum "Job Planning Line Type"
    var
        ServiceLine: Record "Service Line";
    begin
        case Type of
            ServiceLine.Type::Item:
                exit("Job Planning Line Type"::Item);
            ServiceLine.Type::Resource:
                exit("Job Planning Line Type"::Resource);
            ServiceLine.Type::"G/L Account":
                exit("Job Planning Line Type"::"G/L Account");
            else
                Assert.Fail('Unsupported consumable type');
        end
    end;

    procedure Purchase2JobConsumableType(Type: Enum "Purchase Line Type"): Enum "Job Planning Line Type"
    var
        PurchaseLine: Record "Purchase Line";
    begin
        case Type of
            PurchaseLine.Type::Item:
                exit("Job Planning Line Type"::Item);
            PurchaseLine.Type::"G/L Account":
                exit("Job Planning Line Type"::"G/L Account");
            else
                Assert.Fail('Unsupported consumable type');
        end
    end;

    procedure Job2PurchaseConsumableType(Type: Enum "Job Planning Line Type"): Enum "Purchase Line Type"
    var
        PurchaseLine: Record "Purchase Line";
    begin
        case Type of
            "Job Planning Line Type"::Item:
                exit(PurchaseLine.Type::Item);
            "Job Planning Line Type"::"G/L Account":
                exit(PurchaseLine.Type::"G/L Account");
            else
                Assert.Fail('Unsupported consumable type');
        end
    end;

    procedure Job2SalesConsumableType(Type: Enum "Job Planning Line Type"): Enum "Sales Line Type"
    var
        SalesLine: Record "Sales Line";
    begin
        case Type of
            "Job Planning Line Type"::Resource:
                exit(SalesLine.Type::Resource);
            "Job Planning Line Type"::Item:
                exit(SalesLine.Type::Item);
            "Job Planning Line Type"::"G/L Account":
                exit(SalesLine.Type::"G/L Account");
            else
                Assert.Fail('Unsupported consumable type');
        end
    end;

#if not CLEAN27
    [Obsolete('Moved to codeunit Library Service', '27.0')]
    procedure Job2ServiceConsumableType(Type: Enum "Job Planning Line Type"): Enum "Service Line Type"
    var
        LibraryService: Codeunit "Library - Service";
    begin
        exit(LibraryService.Job2ServiceConsumableType(Type));
    end;
#endif

    procedure GetUnitAmountRoundingPrecision(CurrencyCode: Code[10]): Decimal
    var
        Currency: Record Currency;
    begin
        if CurrencyCode = '' then
            exit(LibraryERM.GetUnitAmountRoundingPrecision());
        Currency.Get(CurrencyCode);
        exit(Currency."Unit-Amount Rounding Precision")
    end;

    procedure GetAmountRoundingPrecision(CurrencyCode: Code[10]): Decimal
    var
        Currency: Record Currency;
    begin
        if CurrencyCode = '' then
            exit(LibraryERM.GetAmountRoundingPrecision());
        Currency.Get(CurrencyCode);
        exit(Currency."Amount Rounding Precision")
    end;

    procedure CopyPurchaseLines(var FromPurchaseLine: Record "Purchase Line"; var ToPurchaseLine: Record "Purchase Line")
    begin
        FromPurchaseLine.FindSet();
        repeat
            ToPurchaseLine := FromPurchaseLine;
            ToPurchaseLine.Insert();
        until FromPurchaseLine.Next() = 0
    end;

    procedure CopyJobJournalLines(var FromJobJournalLine: Record "Job Journal Line"; var ToJobJournalLine: Record "Job Journal Line")
    begin
        FromJobJournalLine.FindSet();
        repeat
            ToJobJournalLine := FromJobJournalLine;
            ToJobJournalLine.Insert(true);
        until FromJobJournalLine.Next() = 0;
        ToJobJournalLine.CopyFilters(FromJobJournalLine)
    end;

    procedure UsageLineType(PlanningLineType2: Enum "Job Planning Line Line Type"): Enum "Job Line Type"
    begin
        case PlanningLineType2 of
            PlanningLineTypeSchedule():
                exit(UsageLineTypeSchedule());
            PlanningLineTypeContract():
                exit(UsageLineTypeContract());
            PlanningLineTypeBoth():
                exit(UsageLineTypeBoth());
            else
                Assert.Fail(StrSubstNo('Invalid job planning line type: %1', PlanningLineType2));
        end
    end;

    procedure UsageLineTypeBlank(): Enum "Job Line Type"
    var
        JobJournalLine: Record "Job Journal Line";
    begin
        exit(JobJournalLine."Line Type"::" ")
    end;

    procedure UsageLineTypeSchedule(): Enum "Job Line Type"
    var
        JobJournalLine: Record "Job Journal Line";
    begin
        exit(JobJournalLine."Line Type"::Budget)
    end;

    procedure UsageLineTypeContract(): Enum "Job Line Type"
    var
        JobJournalLine: Record "Job Journal Line";
    begin
        exit(JobJournalLine."Line Type"::Billable)
    end;

    procedure UsageLineTypeBoth(): Enum "Job Line Type"
    var
        JobJournalLine: Record "Job Journal Line";
    begin
        exit(JobJournalLine."Line Type"::"Both Budget and Billable")
    end;

    procedure PlanningLineType(UsageLineType2: Enum "Job Line Type"): Enum "Job Planning Line Line Type"
    begin
        case UsageLineType2 of
            UsageLineTypeSchedule():
                exit(PlanningLineTypeSchedule());
            UsageLineTypeContract():
                exit(PlanningLineTypeContract());
            UsageLineTypeBoth():
                exit(PlanningLineTypeContract());
            else
                Assert.Fail(StrSubstNo('No matching job planning line type exists for job usage line type: %1', UsageLineType2));
        end
    end;

    procedure PlanningLineTypeSchedule(): Enum "Job Planning Line Line Type"
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        exit(JobPlanningLine."Line Type"::Budget)
    end;

    procedure PlanningLineTypeContract(): Enum "Job Planning Line Line Type"
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        exit(JobPlanningLine."Line Type"::Billable)
    end;

    procedure PlanningLineTypeBoth(): Enum "Job Planning Line Line Type"
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        exit(JobPlanningLine."Line Type"::"Both Budget and Billable")
    end;

    procedure ItemType(): Enum "Job Planning Line Type"
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        exit(JobPlanningLine.Type::Item)
    end;

    procedure ResourceType(): Enum "Job Planning Line Type"
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        exit(JobPlanningLine.Type::Resource)
    end;

    procedure GLAccountType(): Enum "Job Planning Line Type"
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        exit(JobPlanningLine.Type::"G/L Account")
    end;

    procedure TextType(): Enum "Job Planning Line Type"
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        exit(JobPlanningLine.Type::Text)
    end;

    procedure "Max"(Left: Decimal; Right: Decimal): Decimal
    begin
        if Left > Right then
            exit(Left);

        exit(Right)
    end;

#if not CLEAN27
    [Obsolete('Moved to codeunit Library Service', '27.0')]
    procedure ServiceConsumption(): Integer
    begin
        exit(ConsumptionSource::Service)
    end;
#endif

    procedure JobConsumption(): Integer
    begin
        exit(ConsumptionSource::Job)
    end;

    procedure GenJournalConsumption(): Integer
    begin
        exit(ConsumptionSource::GenJournal)
    end;

    procedure PurchaseConsumption(): Integer
    begin
        exit(ConsumptionSource::Purchase)
    end;

    procedure FindLocation(var Location: Record Location): Code[10]
    begin
        Location.SetRange("Use As In-Transit", false);
        Location.SetRange("Bin Mandatory", false);
        Location.Next(LibraryRandom.RandInt(Location.Count));
        exit(Location.Code);
    end;

    [Normal]
    procedure GetJobWIPMethod(var JobWIPMethod: Record "Job WIP Method"; Method: Option "Completed Contract","Cost of Sales","Cost Value",POC,"Sales Value")
    begin
        case Method of
            Method::"Completed Contract":
                begin
                    JobWIPMethod.SetRange("Recognized Costs", JobWIPMethod."Recognized Costs"::"At Completion");
                    JobWIPMethod.SetRange("Recognized Sales", JobWIPMethod."Recognized Sales"::"At Completion");
                end;
            Method::"Cost of Sales":
                begin
                    JobWIPMethod.SetRange("Recognized Costs", JobWIPMethod."Recognized Costs"::"Cost of Sales");
                    JobWIPMethod.SetRange("Recognized Sales", JobWIPMethod."Recognized Sales"::"Contract (Invoiced Price)");
                end;
            Method::"Cost Value":
                begin
                    JobWIPMethod.SetRange("Recognized Costs", JobWIPMethod."Recognized Costs"::"Cost Value");
                    JobWIPMethod.SetRange("Recognized Sales", JobWIPMethod."Recognized Sales"::"Contract (Invoiced Price)");
                end;
            Method::POC:
                begin
                    JobWIPMethod.SetRange("Recognized Costs", JobWIPMethod."Recognized Costs"::"Usage (Total Cost)");
                    JobWIPMethod.SetRange("Recognized Sales", JobWIPMethod."Recognized Sales"::"Percentage of Completion");
                end;
            Method::"Sales Value":
                begin
                    JobWIPMethod.SetRange("Recognized Costs", JobWIPMethod."Recognized Costs"::"Usage (Total Cost)");
                    JobWIPMethod.SetRange("Recognized Sales", JobWIPMethod."Recognized Sales"::"Sales Value");
                end;
        end;
        JobWIPMethod.FindFirst();
    end;

    procedure RunUpdateJobItemCost(JobNo: Code[20])
    var
        Job: Record Job;
        UpdateJobItemCost: Report "Update Job Item Cost";
    begin
        Clear(UpdateJobItemCost);
        Job.SetRange("No.", JobNo);
        UpdateJobItemCost.SetTableView(Job);
        UpdateJobItemCost.UseRequestPage(false);
        UpdateJobItemCost.Run();
    end;
}
