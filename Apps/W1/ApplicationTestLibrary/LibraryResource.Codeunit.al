/// <summary>
/// Provides utility functions for creating and managing resource entities in test scenarios, including resources, resource groups, and resource prices.
/// </summary>
codeunit 130511 "Library - Resource"
{

    trigger OnRun()
    begin
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";

    procedure CreateResource(var Resource: Record Resource; VATBusPostingGroup: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        UnitOfMeasure: Record "Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        Resource.Init();
        Resource.Validate("No.", LibraryUtility.GenerateRandomCode(Resource.FieldNo("No."), DATABASE::Resource));
        Resource.Insert(true);

        LibraryInventory.FindUnitOfMeasure(UnitOfMeasure);

        GeneralPostingSetup.SetFilter("Gen. Bus. Posting Group", '<>%1', '');
        GeneralPostingSetup.SetFilter("Gen. Prod. Posting Group", '<>%1', '');
        GeneralPostingSetup.SetFilter("Sales Account", '<>%1', '');
        GeneralPostingSetup.FindFirst();

        Resource.Validate(Name, Resource."No.");  // Validate Name as No. because value is not important.
        Resource.Validate("Base Unit of Measure", UnitOfMeasure.Code);
        Resource.Validate("Direct Unit Cost", LibraryRandom.RandInt(100));  // Required field - value is not important.
        Resource.Validate("Unit Price", LibraryRandom.RandInt(100));  // Required field - value is not important.
        Resource.Validate("Gen. Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group");

        VATPostingSetup.SetRange("VAT Bus. Posting Group", VATBusPostingGroup);
        VATPostingSetup.SetRange("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        if VATPostingSetup.FindFirst() then
            Resource.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        Resource.Modify(true);
    end;

    procedure CreateResourceNew(var Resource: Record Resource)
    var
        GeneralPostingSetup: Record "General Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        UnitOfMeasure: Record "Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        ResNoSeriesSetup();
        LibraryInventory.FindUnitOfMeasure(UnitOfMeasure);
        LibraryERM.FindGeneralPostingSetupInvtFull(GeneralPostingSetup);
        LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);

        Clear(Resource);
        Resource.Insert(true);
        Resource.Validate(Name, Resource."No.");  // Validate Name as No. because value is not important.
        Resource.Validate("Base Unit of Measure", UnitOfMeasure.Code);
        Resource.Validate("Direct Unit Cost", LibraryRandom.RandInt(100));  // Required field - value is not important.
        Resource.Validate("Unit Price", LibraryRandom.RandInt(100));  // Required field - value is not important.
        Resource.Validate("Gen. Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group");
        Resource.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        Resource.Modify(true);
    end;

    procedure CreateResourceNo(): Code[20]
    var
        Resource: Record Resource;
    begin
        CreateResourceNew(Resource);
        exit(Resource."No.");
    end;

    procedure CreateResourceGroup(var ResourceGroup: Record "Resource Group")
    begin
        ResourceGroup.Init();
        ResourceGroup.Validate("No.", LibraryUtility.GenerateRandomCode(ResourceGroup.FieldNo("No."), DATABASE::"Resource Group"));
        ResourceGroup.Validate(Name, ResourceGroup."No.");  // Validate Name as No. because value is not important.
        ResourceGroup.Insert(true);
    end;

    procedure CreateResourcePrice(var ResourcePrice: Record "Resource Price"; Type: Option; "Code": Code[20]; WorkTypeCode: Code[10]; CurrencyCode: Code[10])
    begin
        ResourcePrice.Init();
        ResourcePrice.Validate(Type, Type);
        ResourcePrice.Validate(Code, Code);
        ResourcePrice.Validate("Work Type Code", WorkTypeCode);
        ResourcePrice.Validate("Currency Code", CurrencyCode);
        ResourcePrice.Insert(true);
    end;

    procedure CreateResJournalLine(var ResJournalLine: Record "Res. Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10])
    var
        RecRef: RecordRef;
    begin
        ResJournalLine.Init();
        ResJournalLine.Validate("Journal Template Name", JournalTemplateName);
        ResJournalLine.Validate("Journal Batch Name", JournalBatchName);
        RecRef.GetTable(ResJournalLine);
        ResJournalLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, ResJournalLine.FieldNo("Line No.")));
        ResJournalLine.Insert(true);
    end;

    procedure CreateResourceSkill(var ResourceSkill: Record "Resource Skill"; Type: Enum "Resource Skill Type"; No: Code[20]; SkillCode: Code[10])
    begin
        ResourceSkill.Init();
        ResourceSkill.Validate(Type, Type);
        ResourceSkill.Validate("No.", No);
        ResourceSkill.Validate("Skill Code", SkillCode);
        ResourceSkill.Insert(true);
    end;

    procedure CreateResourceUnitOfMeasure(var ResourceUnitOfMeasure: Record "Resource Unit of Measure"; ResourceNo: Code[20]; UnitOfMeasureCode: Code[10]; QtyPerUoM: Decimal)
    begin
        ResourceUnitOfMeasure.Init();
        ResourceUnitOfMeasure.Validate("Resource No.", ResourceNo);
        ResourceUnitOfMeasure.Validate(Code, UnitOfMeasureCode);
        if QtyPerUoM = 0 then
            QtyPerUoM := 1;
        ResourceUnitOfMeasure.Validate("Qty. per Unit of Measure", QtyPerUoM);
        ResourceUnitOfMeasure.Insert(true);
    end;

    procedure CreateResourceWithUsers(var Resource: Record Resource)
    begin
        CreateResource(Resource, '');
        Resource."Time Sheet Owner User ID" := UserId;
        Resource."Time Sheet Approver User ID" := UserId;
        Resource.Modify();
    end;

    procedure CreateSkillCode(var SkillCode: Record "Skill Code")
    begin
        SkillCode.Init();
        SkillCode.Validate(Code, LibraryUtility.GenerateRandomCode(SkillCode.FieldNo(Code), DATABASE::"Skill Code"));
        SkillCode.Insert(true);
        SkillCode.Validate(Description, SkillCode.Code);  // Validate Description as Code because value is not important.
        SkillCode.Modify(true);
    end;

    procedure CreateResourceJournalTemplate(var ResJournalTemplate: Record "Res. Journal Template")
    begin
        ResJournalTemplate.Init();
        ResJournalTemplate.Validate(
          Name,
          CopyStr(LibraryUtility.GenerateRandomCode(ResJournalTemplate.FieldNo(Name), DATABASE::"Res. Journal Template"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Res. Journal Template", ResJournalTemplate.FieldNo(Name))));
        ResJournalTemplate.Validate(Description, ResJournalTemplate.Name);  // Validate Description as Name because value is not important.
        ResJournalTemplate.Insert(true);
    end;

    procedure CreateResourceJournalBatch(var ResJournalBatch: Record "Res. Journal Batch"; JournalTemplateName: Code[10])
    begin
        ResJournalBatch.Init();
        ResJournalBatch.Validate("Journal Template Name", JournalTemplateName);
        ResJournalBatch.Validate(
          Name,
          CopyStr(LibraryUtility.GenerateRandomCode(ResJournalBatch.FieldNo(Name), DATABASE::"Res. Journal Batch"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Res. Journal Batch", ResJournalBatch.FieldNo(Name))));
        // Validate Description as Primary Key because value is not important.
        ResJournalBatch.Validate(Description, ResJournalBatch."Journal Template Name" + ResJournalBatch.Name);
        ResJournalBatch.Insert(true);
    end;

    procedure CreateWorkType(var WorkType: Record "Work Type")
    var
        UnitOfMeasure: Record "Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        LibraryInventory.FindUnitOfMeasure(UnitOfMeasure);

        WorkType.Init();
        WorkType.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(WorkType.FieldNo(Code), DATABASE::"Work Type"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Work Type", WorkType.FieldNo(Code))));

        // Validating Description as Code because value is not important.
        WorkType.Validate(Description, WorkType.Code);
        WorkType.Validate("Unit of Measure Code", UnitOfMeasure.Code);
        WorkType.Insert(true);
    end;

    procedure CreateWorkHourTemplate(var WorkHourTemplate: Record "Work-Hour Template")
    begin
        WorkHourTemplate.Init();
        WorkHourTemplate.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(WorkHourTemplate.FieldNo(Code), DATABASE::"Work-Hour Template"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"Work-Hour Template", WorkHourTemplate.FieldNo(Code))));
        WorkHourTemplate.Insert(true);
    end;

    procedure FindResource(var Resource: Record Resource)
    begin
        // Filter Resource so that errors are not generated due to mandatory fields.
        Resource.SetFilter("Gen. Prod. Posting Group", '<>''''');
        Resource.SetFilter("VAT Prod. Posting Group", '<>''''');
        Resource.SetRange(Blocked, false);

        Resource.FindSet();
    end;

    procedure FindResJournalBatch(var ResJournalBatch: Record "Res. Journal Batch"; JournalTemplateName: Code[10])
    begin
        ResJournalBatch.SetRange("Journal Template Name", JournalTemplateName);
        ResJournalBatch.FindFirst();
    end;

    procedure FindResJournalTemplate(var ResJournalTemplate: Record "Res. Journal Template")
    begin
        ResJournalTemplate.FindFirst();
    end;

    procedure FindWorkType(var WorkType: Record "Work Type")
    begin
        WorkType.FindSet();
    end;

    [Normal]
    procedure PostResourceJournalLine(var ResJournalLine: Record "Res. Journal Line")
    begin
        ResJournalLine.SetRange("Journal Template Name", ResJournalLine."Journal Template Name");
        ResJournalLine.SetRange("Journal Batch Name", ResJournalLine."Journal Batch Name");
        CODEUNIT.Run(CODEUNIT::"Res. Jnl.-Post", ResJournalLine);
    end;

    local procedure ResNoSeriesSetup()
    var
        ResourcesSetup: Record "Resources Setup";
        NoSeriesCode: Code[20];
    begin
        ResourcesSetup.Get();
        NoSeriesCode := LibraryUtility.GetGlobalNoSeriesCode();
        if NoSeriesCode <> ResourcesSetup."Resource Nos." then begin
            ResourcesSetup.Validate("Resource Nos.", LibraryUtility.GetGlobalNoSeriesCode());
            ResourcesSetup.Modify(true);
        end;
    end;

    procedure SetResourceBlocked(var Resource: Record Resource)
    begin
        Resource.Validate(Blocked, true);
        Resource.Modify(true);
    end;
}

