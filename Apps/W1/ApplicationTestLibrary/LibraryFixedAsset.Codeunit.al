/// <summary>
/// Provides utility functions for creating and managing fixed assets, depreciation books, and FA posting in test scenarios.
/// </summary>
codeunit 131330 "Library - Fixed Asset"
{
    Permissions = tabledata "FA Depreciation Book" = rimd,
                  tabledata "G/L Entry" = r;

    trigger OnRun()
    begin
    end;

    var
        FASetup: Record "FA Setup";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        FARegisterGLRegisterErr: Label 'There should be only one FA Register related to the last GL register.';

    procedure CreateCommentLine(var CommentLine: Record "Comment Line"; TableName: Enum "Comment Line Table Name"; No: Code[20])
    var
        RecRef: RecordRef;
    begin
        CommentLine.Init();
        CommentLine.Validate("Table Name", TableName);
        CommentLine.Validate("No.", No);
        RecRef.GetTable(CommentLine);
        CommentLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, CommentLine.FieldNo("Line No.")));
        CommentLine.Insert(true);
    end;

    procedure CreateDepreciationBook(var DepreciationBook: Record "Depreciation Book")
    begin
        DepreciationBook.Init();
        DepreciationBook.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(DepreciationBook.FieldNo(Code), DATABASE::"Depreciation Book"),
            1, LibraryUtility.GetFieldLength(DATABASE::"Depreciation Book", DepreciationBook.FieldNo(Code))));
        DepreciationBook.Validate(Description, DepreciationBook.Code);  // Validating Description as Code because value is not important.
        DepreciationBook.Insert(true);
    end;

    procedure CreateFADepreciationBook(var FADepreciationBook: Record "FA Depreciation Book"; FANo: Code[20]; DepreciationBookCode: Code[10])
    begin
        FADepreciationBook.Init();
        FADepreciationBook.Validate("FA No.", FANo);
        FADepreciationBook.Validate("Depreciation Book Code", DepreciationBookCode);
        FADepreciationBook.Insert(true);
    end;

    procedure CreateFAAllocation(var FAAllocation: Record "FA Allocation"; "Code": Code[20]; AllocationType: Enum "FA Allocation Type")
    var
        RecRef: RecordRef;
    begin
        FAAllocation.Init();
        FAAllocation.Validate(Code, Code);
        FAAllocation.Validate("Allocation Type", AllocationType);
        RecRef.GetTable(FAAllocation);
        FAAllocation.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, FAAllocation.FieldNo("Line No.")));
        FAAllocation.Insert(true);
    end;

    procedure CreateFAJournalLine(var FAJournalLine: Record "FA Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10])
    var
        RecRef: RecordRef;
    begin
        // Create a Fixed Asset General Journal Entry.
        FAJournalLine.Init();
        FAJournalLine.Validate("Journal Template Name", JournalTemplateName);
        FAJournalLine.Validate("Journal Batch Name", JournalBatchName);
        RecRef.GetTable(FAJournalLine);
        FAJournalLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, FAJournalLine.FieldNo("Line No.")));
        FAJournalLine.Insert(true);
    end;

    procedure CreateFAJournalSetup(var FAJournalSetup: Record "FA Journal Setup"; DepreciationBookCode: Code[10]; UserID: Code[50])
    begin
        FAJournalSetup.Init();
        FAJournalSetup.Validate("Depreciation Book Code", DepreciationBookCode);
        FAJournalSetup.Validate("User ID", UserID);
        FAJournalSetup.Insert(true);
    end;

    procedure CreateFAPostingGroup(var FAPostingGroup: Record "FA Posting Group")
    begin
        FAPostingGroup.Init();
        FAPostingGroup.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(FAPostingGroup.FieldNo(Code), DATABASE::"FA Posting Group"),
            1, LibraryUtility.GetFieldLength(DATABASE::"FA Posting Group", FAPostingGroup.FieldNo(Code))));
        FAPostingGroup.Validate("Acquisition Cost Account", LibraryERM.CreateGLAccountWithPurchSetup());
        FAPostingGroup.Validate("Accum. Depreciation Account", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Write-Down Account", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Appreciation Account", LibraryERM.CreateGLAccountWithPurchSetup());
        FAPostingGroup.Validate("Custom 1 Account", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Custom 2 Account", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Acq. Cost Acc. on Disposal", LibraryERM.CreateGLAccountWithPurchSetup());
        FAPostingGroup.Validate("Accum. Depr. Acc. on Disposal", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Write-Down Acc. on Disposal", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Appreciation Acc. on Disposal", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Custom 1 Account on Disposal", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Custom 2 Account on Disposal", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Gains Acc. on Disposal", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Losses Acc. on Disposal", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Book Val. Acc. on Disp. (Gain)", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Sales Acc. on Disp. (Gain)", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Write-Down Bal. Acc. on Disp.", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Apprec. Bal. Acc. on Disp.", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Custom 1 Bal. Acc. on Disposal", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Custom 2 Bal. Acc. on Disposal", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Maintenance Expense Account", LibraryERM.CreateGLAccountWithPurchSetup());
        FAPostingGroup.Validate("Maintenance Bal. Acc.", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Acquisition Cost Bal. Acc.", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Depreciation Expense Acc.", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Write-Down Expense Acc.", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Appreciation Bal. Account", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Custom 1 Expense Acc.", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Custom 2 Expense Acc.", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Sales Bal. Acc.", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Sales Acc. on Disp. (Loss)", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Book Val. Acc. on Disp. (Loss)", LibraryERM.CreateGLAccountNo());

        FAPostingGroup.Insert(true);
    end;

    procedure CreateFAReclassJournal(var FAReclassJournalLine: Record "FA Reclass. Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10])
    var
        RecRef: RecordRef;
    begin
        // Create a Fixed Asset Reclass Journal Entry.
        FAReclassJournalLine.Init();
        FAReclassJournalLine.Validate("Journal Template Name", JournalTemplateName);
        FAReclassJournalLine.Validate("Journal Batch Name", JournalBatchName);
        RecRef.GetTable(FAReclassJournalLine);
        FAReclassJournalLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, FAReclassJournalLine.FieldNo("Line No.")));
        FAReclassJournalLine.Insert(true);
    end;

    [Scope('OnPrem')]
    procedure CreateFAReclassJournalTemplate(var FAReclassJournalTemplate: Record "FA Reclass. Journal Template")
    begin
        FAReclassJournalTemplate.Init();
        FAReclassJournalTemplate.Name := LibraryUtility.GenerateGUID();
        FAReclassJournalTemplate.Insert();
    end;

    procedure CreateFAReclassJournalBatch(var FAReclassJournalBatch: Record "FA Reclass. Journal Batch"; JournalTemplateName: Code[10])
    begin
        FAReclassJournalBatch.Init();
        FAReclassJournalBatch.Validate("Journal Template Name", JournalTemplateName);
        FAReclassJournalBatch.Validate(
          Name,
          CopyStr(
            LibraryUtility.GenerateRandomCode(FAReclassJournalBatch.FieldNo(Name), DATABASE::"FA Reclass. Journal Batch"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"FA Journal Batch", FAReclassJournalBatch.FieldNo(Name))));

        // Validating Description as Name because value is not important.
        FAReclassJournalBatch.Validate(Description, FAReclassJournalBatch.Name);
        FAReclassJournalBatch.Insert(true);
    end;

    procedure CreateFAJournalBatch(var FAJournalBatch: Record "FA Journal Batch"; JournalTemplateName: Code[10])
    begin
        // creates a new FA Journal Batch named with the next available number (if it does not yet exist), OR
        // returns the FA Journal batch named with the next available number

        FAJournalBatch.Init();
        FAJournalBatch.Validate("Journal Template Name", JournalTemplateName);
        FAJournalBatch.Validate(
          Name,
          CopyStr(
            LibraryUtility.GenerateRandomCode(FAJournalBatch.FieldNo(Name), DATABASE::"FA Journal Batch"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"FA Journal Batch", FAJournalBatch.FieldNo(Name))));
        FAJournalBatch.Validate(Description, FAJournalBatch.Name);  // Validating Description as Name because value is not important.
        if FAJournalBatch.Insert(true) then;
    end;

    procedure CreateFixedAsset(var FixedAsset: Record "Fixed Asset")
    begin
        LibraryUtility.UpdateSetupNoSeriesCode(DATABASE::"FA Setup", FASetup.FieldNo("Fixed Asset Nos."));

        FixedAsset.Init();
        FixedAsset.Insert(true);
        FixedAsset.Validate(Description, FixedAsset."No.");  // Validating Description as No because value is not important.
        FixedAsset.Modify(true);
    end;

    procedure CreateFAWithPostingGroup(var FixedAsset: Record "Fixed Asset")
    var
        FAPostingGroup: Record "FA Posting Group";
    begin
        CreateFAPostingGroup(FAPostingGroup);
        CreateFixedAsset(FixedAsset);
        FixedAsset.Validate("FA Posting Group", FAPostingGroup.Code);
        FixedAsset.Modify(true);
    end;

    procedure CreateFixedAssetWithSetup(var FixedAsset: Record "Fixed Asset")
    var
        FADeprBook: Record "FA Depreciation Book";
        FAPostingGroup: Record "FA Posting Group";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        CreateFixedAsset(FixedAsset);
        CreateFAPostingGroup(FAPostingGroup);
        LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);
        UpdateFAPostingGroupGLAccounts(FAPostingGroup, VATPostingSetup);
        FADeprBook.ModifyAll("FA Posting Group", FAPostingGroup.Code);
        FADeprBook.ModifyAll("No. of Depreciation Years", LibraryRandom.RandIntInRange(2, 5));
    end;

    procedure CreateFixedAssetNo(): Code[20]
    var
        FixedAsset: Record "Fixed Asset";
    begin
        CreateFixedAssetWithSetup(FixedAsset);
        exit(FixedAsset."No.");
    end;

    procedure CreateGLBudgetName(var GLBudgetName: Record "G/L Budget Name")
    begin
        GLBudgetName.Init();
        GLBudgetName.Validate(
          Name,
          CopyStr(
            LibraryUtility.GenerateRandomCode(GLBudgetName.FieldNo(Name), DATABASE::"G/L Budget Name"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"G/L Budget Name", GLBudgetName.FieldNo(Name))));

        // Validating Description as Name because value is not important.
        GLBudgetName.Validate(Description, GLBudgetName.Name);
        GLBudgetName.Insert(true);
    end;

    procedure CreateInsurance(var Insurance: Record Insurance)
    begin
        LibraryUtility.UpdateSetupNoSeriesCode(DATABASE::"FA Setup", FASetup.FieldNo("Insurance Nos."));

        Insurance.Init();
        Insurance.Insert(true);
        Insurance.Validate(Description, Insurance."No.");  // Validating Description as No because value is not important.
        Insurance.Modify(true);
    end;

    [Scope('OnPrem')]
    procedure CreateInsuranceJournalTemplate(var InsuranceJournalTemplate: Record "Insurance Journal Template")
    begin
        InsuranceJournalTemplate.Init();
        InsuranceJournalTemplate.Name := LibraryUtility.GenerateGUID();
        InsuranceJournalTemplate.Insert();
    end;

    procedure CreateInsuranceJournalBatch(var InsuranceJournalBatch: Record "Insurance Journal Batch"; JournalTemplateName: Code[10])
    begin
        InsuranceJournalBatch.Init();
        InsuranceJournalBatch.Validate("Journal Template Name", JournalTemplateName);
        InsuranceJournalBatch.Validate(
          Name,
          CopyStr(
            LibraryUtility.GenerateRandomCode(InsuranceJournalBatch.FieldNo(Name), DATABASE::"Insurance Journal Batch"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Insurance Journal Batch", InsuranceJournalBatch.FieldNo(Name))));

        // Validating Description as Name because value is not important.
        InsuranceJournalBatch.Validate(Description, InsuranceJournalBatch.Name);
        InsuranceJournalBatch.Insert(true);
    end;

    procedure CreateInsuranceJournalLine(var InsuranceJournalLine: Record "Insurance Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10])
    var
        RecRef: RecordRef;
    begin
        // Create an Insurance Journal Entry.
        InsuranceJournalLine.Init();
        InsuranceJournalLine.Validate("Journal Template Name", JournalTemplateName);
        InsuranceJournalLine.Validate("Journal Batch Name", JournalBatchName);
        RecRef.GetTable(InsuranceJournalLine);
        InsuranceJournalLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, InsuranceJournalLine.FieldNo("Line No.")));
        InsuranceJournalLine.Insert(true);
    end;

    procedure CreateMaintenance(var Maintenance: Record Maintenance)
    begin
        Maintenance.Init();
        Maintenance.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(Maintenance.FieldNo(Code), DATABASE::Maintenance),
            1,
            LibraryUtility.GetFieldLength(DATABASE::Maintenance, Maintenance.FieldNo(Code))));

        // Validating Description as Code because value is not important.
        Maintenance.Validate(Description, Maintenance.Code);
        Maintenance.Insert(true);
    end;

    procedure CreateInsuranceType(var InsuranceType: Record "Insurance Type")
    begin
        InsuranceType.Init();
        InsuranceType.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(InsuranceType.FieldNo(Code), DATABASE::"Insurance Type"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Insurance Type", InsuranceType.FieldNo(Code))));

        // Validating Description as Code because value is not important.
        InsuranceType.Validate(Description, InsuranceType.Code);
        InsuranceType.Insert(true);
    end;

    procedure CreateJournalTemplate(var FAJournalTemplate: Record "FA Journal Template")
    begin
        FAJournalTemplate.Init();
        FAJournalTemplate.Validate(
          Name,
          CopyStr(
            LibraryUtility.GenerateRandomCode(FAJournalTemplate.FieldNo(Name), DATABASE::"FA Journal Template"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"FA Journal Template", FAJournalTemplate.FieldNo(Name))));

        // Validating Description as Name because value is not important.
        FAJournalTemplate.Validate(Description, FAJournalTemplate.Name);
        FAJournalTemplate.Insert(true);
    end;

    procedure CreateDepreciationTableHeader(var DepreciationTableHeader: Record "Depreciation Table Header")
    begin
        DepreciationTableHeader.Init();
        DepreciationTableHeader.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(DepreciationTableHeader.FieldNo(Code), DATABASE::"Depreciation Table Header"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Depreciation Table Header", DepreciationTableHeader.FieldNo(Code))));

        // Validating Description as Code because value is not important.
        DepreciationTableHeader.Validate(Description, DepreciationTableHeader.Code);
        DepreciationTableHeader.Insert(true);
    end;

    procedure CreateDepreciationTableLine(var DepreciationTableLine: Record "Depreciation Table Line"; DepreciationTableCode: Code[10])
    begin
        DepreciationTableLine.SetRange("Depreciation Table Code", DepreciationTableCode);
        // Check if Lines are alredy exist.
        if DepreciationTableLine.FindLast() then;
        DepreciationTableLine.Init();
        DepreciationTableLine.Validate("Depreciation Table Code", DepreciationTableCode);
        DepreciationTableLine.Validate("Period No.", DepreciationTableLine."Period No." + 1);
        DepreciationTableLine.Insert(true);
    end;

    procedure CreateMainAssetComponent(var MainAssetComponent: Record "Main Asset Component"; MainAssetNo: Code[20]; FANo: Code[20])
    begin
        MainAssetComponent.Init();
        MainAssetComponent.Validate("Main Asset No.", MainAssetNo);
        MainAssetComponent.Validate("FA No.", FANo);
        MainAssetComponent.Insert(true);
    end;

    procedure CreateFAClass(var FAClass: Record "FA Class")
    begin
        FAClass.Init();
        FAClass.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(FAClass.FieldNo(Code), DATABASE::"FA Class"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"FA Class", FAClass.FieldNo(Code))));

        FAClass.Validate(Name, 'NameOf' + FAClass.Code);
        FAClass.Insert(true);
    end;

    procedure CreateFASubclass(var FASubclass: Record "FA Subclass")
    begin
        FASubclass.Init();
        FASubclass.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(FASubclass.FieldNo(Code), DATABASE::"FA Subclass"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"FA Subclass", FASubclass.FieldNo(Code))));

        FASubclass.Validate(Name, 'NameOf' + FASubclass.Code);
        FASubclass.Insert(true);
    end;

    procedure CreateFASubclassDetailed(var FASubclass: Record "FA Subclass"; FAClassCode: Code[10]; FAPostingGroupCode: Code[20])
    begin
        FASubclass.Init();
        FASubclass.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(FASubclass.FieldNo(Code), DATABASE::"FA Subclass"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"FA Subclass", FASubclass.FieldNo(Code))));

        FASubclass.Validate(Name, 'NameOf' + FASubclass.Code);
        FASubclass.Validate("FA Class Code", FAClassCode);
        FASubclass.Validate("Default FA Posting Group", FAPostingGroupCode);
        FASubclass.Insert(true);
    end;

    procedure FindEmployee(var Employee: Record Employee)
    begin
        Employee.FindSet();
    end;

    procedure FindFAClass(var FAClass: Record "FA Class")
    begin
        FAClass.FindSet();
    end;

    procedure FindFAJournalBatch(var FAJournalBatch: Record "FA Journal Batch"; JournalTemplateName: Code[10])
    begin
        FAJournalBatch.SetRange("Journal Template Name", JournalTemplateName);
        FAJournalBatch.FindFirst();
    end;

    procedure FindFAJournalTemplate(var FAJournalTemplate: Record "FA Journal Template")
    begin
        FAJournalTemplate.FindFirst();
    end;

    procedure FindFALocation(var FALocation: Record "FA Location")
    begin
        FALocation.FindSet();
    end;

    procedure FindFASubclass(var FASubclass: Record "FA Subclass")
    begin
        FASubclass.FindSet();
    end;

    procedure FindInsurance(var Insurance: Record Insurance)
    begin
        Insurance.FindSet();
    end;

    procedure GetDefaultDeprBook(): Code[10]
    begin
        FASetup.Get();
        exit(FASetup."Default Depr. Book");
    end;

    procedure PostFAJournalLine(var FAJournalLine: Record "FA Journal Line")
    begin
        FAJournalLine.SetRange("Journal Template Name", FAJournalLine."Journal Template Name");
        FAJournalLine.SetRange("Journal Batch Name", FAJournalLine."Journal Batch Name");
        CODEUNIT.Run(CODEUNIT::"FA Jnl.-Post Batch", FAJournalLine);
    end;

    procedure PostInsuranceJournal(var InsuranceJournalLine: Record "Insurance Journal Line")
    begin
        InsuranceJournalLine.SetRange("Journal Template Name", InsuranceJournalLine."Journal Template Name");
        InsuranceJournalLine.SetRange("Journal Batch Name", InsuranceJournalLine."Journal Batch Name");
        CODEUNIT.Run(CODEUNIT::"Insurance Jnl.-Post Batch", InsuranceJournalLine);
    end;

    procedure PostFAJournalLineBatch(var FAJournalBatch: Record "FA Journal Batch")
    begin
        CODEUNIT.Run(CODEUNIT::"FA. Jnl.-B.Post", FAJournalBatch);
    end;

    procedure UpdateFAPostingGroupGLAccounts(var FAPostingGroup: Record "FA Posting Group"; VATPostingSetup: Record "VAT Posting Setup")
    begin
        FAPostingGroup.Validate("Acquisition Cost Account", LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, "General Posting Type"::" "));
        FAPostingGroup.Validate("Acq. Cost Acc. on Disposal", FAPostingGroup."Acquisition Cost Account");
        FAPostingGroup.Validate("Accum. Depreciation Account", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Accum. Depr. Acc. on Disposal", FAPostingGroup."Accum. Depreciation Account");
        FAPostingGroup.Validate("Depreciation Expense Acc.", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Gains Acc. on Disposal", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Losses Acc. on Disposal", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Sales Bal. Acc.", LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, "General Posting Type"::" "));
        FAPostingGroup.Modify(true);
    end;

    procedure UpdateFASetupDefaultDeprBook(DefaultDeprBook: Code[10])
    var
        FASetup: Record "FA Setup";
    begin
        FASetup.Get();
        FASetup.Validate("Default Depr. Book", DefaultDeprBook);
        FASetup.Modify(true);
    end;

    procedure VerifyLastFARegisterGLRegisterOneToOneRelation()
    var
        FARegister: Record "FA Register";
        GLRegister: Record "G/L Register";
        GLEntry: Record "G/L Entry";
    begin
        GLRegister.FindLast();
        FARegister.FindLast();
        Assert.AreEqual(GLRegister."No.", FARegister."G/L Register No.", FARegisterGLRegisterErr);

        GLEntry.SetRange("Entry No.", GLRegister."From Entry No.", GLRegister."To Entry No.");
        GLEntry.SetRange("FA Entry Type", GLEntry."FA Entry Type"::"Fixed Asset");
        GLEntry.FindSet();
        repeat
            Assert.IsTrue(
              GLEntry."FA Entry No." in [FARegister."From Entry No." .. FARegister."To Entry No."],
              FARegisterGLRegisterErr);
        until GLEntry.Next() = 0;
    end;

    procedure VerifyMaintenanceLastFARegisterGLRegisterOneToOneRelation()
    var
        FARegister: Record "FA Register";
        GLRegister: Record "G/L Register";
        GLEntry: Record "G/L Entry";
    begin
        GLRegister.FindLast();
        FARegister.FindLast();
        Assert.AreEqual(GLRegister."No.", FARegister."G/L Register No.", FARegisterGLRegisterErr);

        GLEntry.SetRange("Entry No.", GLRegister."From Entry No.", GLRegister."To Entry No.");
        GLEntry.SetRange("FA Entry Type", GLEntry."FA Entry Type"::Maintenance);
        GLEntry.FindSet();
        repeat
            Assert.IsTrue(
              GLEntry."FA Entry No." in [FARegister."From Maintenance Entry No." .. FARegister."To Maintenance Entry No."],
              FARegisterGLRegisterErr);
        until GLEntry.Next() = 0;
    end;
}

