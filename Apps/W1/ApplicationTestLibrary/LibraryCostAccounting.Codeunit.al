/// <summary>
/// Provides utility functions for creating and managing cost accounting entities in test scenarios, including cost centers, cost objects, and cost types.
/// </summary>
codeunit 131340 "Library - Cost Accounting"
{

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryRandom: Codeunit "Library - Random";
        AllocSourceID: Label 'AS%1';
        AllocValuesNotMatchingErr: Label 'Amount = %1, CostEntryAmount = %2, Percent = %3, TotalAmount = %4, AllocatedCost = %5, Percent * TotalAmount = %6.';
        GetCostTypesFromGLErr: Label 'Mapping G/L Accounts to Chart of Cost Types Causes Inconsistency.';
        GLAccountFilterDefinition: Label '%1..%2', Locked = true;
        IncorrectGLAccountNo: Label 'The G/L Account No. %1 is aligned to Cost Type No. %2 although G/L Account No. %3 was expected.';
        IncorrectPercentValueErr: Label 'For the Allocation Source %1, the Allocation Target %2  has its Percent field set to %3, although the expected value was %4, when values are rounded to 0.1 precision.';
        NoRecordsInFilterErr: Label 'There are no records within the filters specified for table %1. The filters are: %2.';
        NumberOfRecordsNotMatchingErr: Label 'The number of records %1 of %2 do not match the the number of recods %3 of %4.';
        CostEntriesCountErr: Label 'Incorrect number of cost entries.';
        ExpectedValueIsDifferentErr: Label 'Expected value of %1 field is different than the actual one.';

    procedure AllocateCostsFromTo(var CostAllocation: TestRequestPage "Cost Allocation"; FromLevel: Integer; ToLevel: Integer; AllocDate: Date; AllocGroup: Code[10]; CostBudgetName: Code[10])
    begin
        CostAllocation."From Alloc. Level".SetValue(FromLevel);
        CostAllocation."To Alloc. Level".SetValue(ToLevel);
        CostAllocation."Allocation Date".SetValue(AllocDate);
        CostAllocation.Group.SetValue(AllocGroup);
        CostAllocation."Budget Name".SetValue(CostBudgetName);
    end;

    procedure CheckAllocTargetSharePercent(CostAllocationSource: Record "Cost Allocation Source")
    var
        CostAllocationTarget: Record "Cost Allocation Target";
        CurrentValue: Decimal;
        ExpectedValue: Decimal;
    begin
        CostAllocationSource.CalcFields("Total Share");
        CostAllocationTarget.SetFilter(ID, '%1', CostAllocationSource.ID);
        if CostAllocationTarget.FindSet() then
            repeat
                CurrentValue := Round(CostAllocationTarget.Percent, 0.1, '=');
                ExpectedValue := Round(100 * CostAllocationTarget.Share / CostAllocationSource."Total Share", 0.1, '=');
                Assert.AreEqual(
                  CurrentValue, ExpectedValue,
                  StrSubstNo(IncorrectPercentValueErr, CostAllocationSource.ID, CostAllocationTarget."Line No.", CurrentValue, ExpectedValue));
            until CostAllocationTarget.Next() = 0
        else
            Error(NoRecordsInFilterErr, CostAllocationTarget.TableCaption(), CostAllocationTarget.GetFilters);
    end;

    procedure CheckBlockedDimCombination()
    var
        DimensionCombination: Record "Dimension Combination";
    begin
        DimensionCombination.SetFilter("Dimension 1 Code", '%1|%2', CostCenterDimension(), CostObjectDimension());
        DeleteBlockedDimCombinations(DimensionCombination);

        Clear(DimensionCombination);
        DimensionCombination.SetFilter("Dimension 2 Code", '%1|%2', CostCenterDimension(), CostObjectDimension());
        DeleteBlockedDimCombinations(DimensionCombination);
    end;

    procedure CheckBlockedDimensionValues(AccountNo: Code[20])
    var
        DimensionValue: Record "Dimension Value";
        DefaultDimension: Record "Default Dimension";
    begin
        // Un-block any blocked default dimension values for an account

        LibraryDimension.FindDefaultDimension(DefaultDimension, DATABASE::"G/L Account", AccountNo);
        if DefaultDimension.FindSet() then
            repeat
                DimensionValue.Get(DefaultDimension."Dimension Code", DefaultDimension."Dimension Value Code");
                if DimensionValue.Blocked then begin
                    DimensionValue.Validate(Blocked, false);
                    DimensionValue.Modify(true);
                end;
            until DefaultDimension.Next() = 0;
    end;

    procedure CheckCostJnlLineConsistency(var CostJournalLine: Record "Cost Journal Line")
    var
        CostCenter: Record "Cost Center";
    begin
        if (CostJournalLine."Cost Center Code" = '') and (CostJournalLine."Cost Object Code" = '') then begin
            // either Cost Center or Cost Object must be set in order to post
            CreateCostCenter(CostCenter);
            CostJournalLine.Validate("Cost Center Code", CostCenter.Code);
        end;

        if (CostJournalLine."Bal. Cost Center Code" = '') and (CostJournalLine."Bal. Cost Object Code" = '') then begin
            // either Bal. Cost Center or Bal. Cost Object must be set in order to post
            CreateCostCenter(CostCenter);
            CostJournalLine.Validate("Bal. Cost Center Code", CostCenter.Code);
        end;

        if (CostJournalLine."Cost Center Code" <> '') and (CostJournalLine."Cost Object Code" <> '') then
            // only one of Cost Center or Cost Object must be set in order to post
            CostJournalLine.Validate("Cost Object Code", '');

        if (CostJournalLine."Bal. Cost Center Code" <> '') and (CostJournalLine."Bal. Cost Object Code" <> '') then
            // only one of Bal. Cost Center or Bal. Cost Object fields must be set in order to post
            CostJournalLine.Validate("Bal. Cost Object Code", '');

        CostJournalLine.Modify(true);
    end;

    procedure ClearCostJournalLines(CostJournalBatch: Record "Cost Journal Batch")
    var
        CostJournalLine: Record "Cost Journal Line";
    begin
        CostJournalLine.SetRange("Journal Template Name", CostJournalBatch."Journal Template Name");
        CostJournalLine.SetRange("Journal Batch Name", CostJournalBatch.Name);
        CostJournalLine.DeleteAll(true);
    end;

    procedure CopyCABudgetToCABudget(var CopyCAToCARP: TestRequestPage "Copy Cost Budget"; SourceCostBudget: Code[10]; TargetCostBudget: Code[10]; AmtMultiplicationRatio: Decimal; DateFormula: Text[30]; NoOfCopies: Integer)
    begin
        CopyCAToCARP."Budget Name".SetValue(TargetCostBudget);
        CopyCAToCARP."Amount multiplication factor".SetValue(AmtMultiplicationRatio);
        CopyCAToCARP."Date Change Formula".SetValue(DateFormula);
        CopyCAToCARP."No. of Copies".SetValue(NoOfCopies);
        CopyCAToCARP."Cost Budget Entry".SetFilter("Budget Name", SourceCostBudget);
    end;

    procedure CopyCABudgetToGLBudget(var CopyCAToGLRP: TestRequestPage "Copy Cost Acctg. Budget to G/L"; SourceCostBudget: Code[10]; TargetCostBudget: Code[10]; AmtMultiplicationRatio: Decimal; DateFormula: Text[30]; NoOfCopies: Integer)
    begin
        CopyCAToGLRP."Allocation Target Budget Name".SetValue(TargetCostBudget);
        CopyCAToGLRP."Amount multiplication factor".SetValue(AmtMultiplicationRatio);
        CopyCAToGLRP."Date Change Formula".SetValue(DateFormula);
        CopyCAToGLRP."No. of Copies".SetValue(NoOfCopies);
        CopyCAToGLRP."Cost Budget Entry".SetFilter("Budget Name", SourceCostBudget);
    end;

    procedure CopyGLBudgetToCABudget(var CopyGLToCARP: TestRequestPage "Copy G/L Budget to Cost Acctg."; SourceGLBudget: Code[10]; TargetCostBudget: Code[10])
    begin
        CopyGLToCARP."Budget Name".SetValue(TargetCostBudget);
        CopyGLToCARP."G/L Budget Entry".SetFilter("Budget Name", SourceGLBudget);
    end;

    procedure CostCenterDimension(): Code[20]
    var
        CostAccountingSetup: Record "Cost Accounting Setup";
    begin
        CostAccountingSetup.Get();
        exit(CostAccountingSetup."Cost Center Dimension");
    end;

    procedure CostObjectDimension(): Code[20]
    var
        CostAccountingSetup: Record "Cost Accounting Setup";
    begin
        CostAccountingSetup.Get();
        exit(CostAccountingSetup."Cost Object Dimension");
    end;

    procedure CreateAllocSource(var CostAllocationSource: Record "Cost Allocation Source"; TypeOfID: Option "Auto Generated",Custom)
    var
        CostType: Record "Cost Type";
    begin
        FindCostType(CostType);

        CostAllocationSource.Init();
        if TypeOfID = TypeOfID::Custom then
            CostAllocationSource.Validate(ID, (LastAllocSourceID() + StrSubstNo(AllocSourceID, CostAllocationSource.Count)));
        CostAllocationSource.Validate(Level, LibraryRandom.RandInt(10));
        CostAllocationSource.Validate("Credit to Cost Type", CostType."No.");
        CostAllocationSource.Insert(true);
    end;

    procedure CreateAllocSourceWithCCenter(var CostAllocationSource: Record "Cost Allocation Source"; TypeOfID: Option)
    begin
        CreateAllocSource(CostAllocationSource, TypeOfID);
        UpdateAllocSourceWithCCenter(CostAllocationSource);
    end;

    procedure CreateAllocSourceWithCObject(var CostAllocationSource: Record "Cost Allocation Source"; TypeOfID: Option)
    begin
        CreateAllocSource(CostAllocationSource, TypeOfID);
        UpdateAllocSourceWithCObject(CostAllocationSource);
    end;

    procedure CreateAllocTarget(var CostAllocationTarget: Record "Cost Allocation Target"; CostAllocationSource: Record "Cost Allocation Source"; Share: Decimal; Base: Enum "Cost Allocation Target Base"; AllocationType: Enum "Cost Allocation Target Type")
    var
        LineNo: Integer;
    begin
        LineNo := LastAllocTargetID(CostAllocationSource) + 1;

        CostAllocationTarget.Init();
        CostAllocationTarget.Validate(ID, CostAllocationSource.ID);
        CostAllocationTarget.Validate("Line No.", LineNo);
        CostAllocationTarget.Validate("Target Cost Type", CostAllocationSource."Credit to Cost Type");
        CostAllocationTarget.Validate(Base, Base);
        CostAllocationTarget.Validate("Allocation Target Type", AllocationType);
        CostAllocationTarget.Insert(true);

        // The Share field cannot be updated unless the Allocation Target exists.
        Clear(CostAllocationTarget);
        CostAllocationTarget.Get(CostAllocationSource.ID, LineNo);
        CostAllocationTarget.Validate(Share, Share);
        CostAllocationTarget.Modify(true);
    end;

    procedure CreateAllocTargetWithCCenter(var CostAllocationTarget: Record "Cost Allocation Target"; CostAllocationSource: Record "Cost Allocation Source"; Share: Decimal; Base: Enum "Cost Allocation Target Base"; AllocationType: Enum "Cost Allocation Target Type")
    begin
        CreateAllocTarget(CostAllocationTarget, CostAllocationSource, Share, Base, AllocationType);
        UpdateAllocTargetWithCCenter(CostAllocationTarget);
    end;

    procedure CreateAllocTargetWithCObject(var CostAllocationTarget: Record "Cost Allocation Target"; CostAllocationSource: Record "Cost Allocation Source"; Share: Decimal; Base: Enum "Cost Allocation Target Base"; AllocationType: Enum "Cost Allocation Target Type")
    begin
        CreateAllocTarget(CostAllocationTarget, CostAllocationSource, Share, Base, AllocationType);
        UpdateAllocTargetWithCObject(CostAllocationTarget);
    end;

    procedure CreateBalanceSheetGLAccount(var GLAccount: Record "G/L Account")
    var
        CostAccountingSetup: Record "Cost Accounting Setup";
        AlignGLAccount: Option;
    begin
        CostAccountingSetup.Get();
        AlignGLAccount := CostAccountingSetup."Align G/L Account";
        CostAccountingSetup.Validate("Align G/L Account", CostAccountingSetup."Align G/L Account"::"No Alignment");
        CostAccountingSetup.Modify(true);

        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.TestField("Cost Type No.", '');
        GLAccount.Validate("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
        GLAccount.Modify(true);

        CostAccountingSetup.Get();
        CostAccountingSetup.Validate("Align G/L Account", AlignGLAccount);
        CostAccountingSetup.Modify(true);
    end;

    procedure CreateCostBudgetEntry(var CostBudgetEntry: Record "Cost Budget Entry"; CostBudgetName: Code[10])
    var
        CostType: Record "Cost Type";
        CostCenter: Record "Cost Center";
    begin
        FindCostType(CostType);
        FindCostCenter(CostCenter);

        CostBudgetEntry.Init();
        CostBudgetEntry.Validate(Date, WorkDate());
        CostBudgetEntry.Validate("Budget Name", CostBudgetName);
        CostBudgetEntry.Validate("Cost Type No.", CostType."No.");
        CostBudgetEntry.Validate("Cost Center Code", CostCenter.Code);
        CostBudgetEntry.Validate(Amount, LibraryRandom.RandDec(100, 2));
        CostBudgetEntry.Insert(true);
    end;

    procedure CreateCostBudgetName(var CostBudgetName: Record "Cost Budget Name")
    begin
        CostBudgetName.Init();
        CostBudgetName.Validate(
          Name, LibraryUtility.GenerateRandomCode(CostBudgetName.FieldNo(Description), DATABASE::"Cost Budget Name"));
        CostBudgetName.Validate(Description, CostBudgetName.Name);
        CostBudgetName.Insert(true);
    end;

    procedure CreateCostCenter(var CostCenter: Record "Cost Center")
    begin
        CostCenter.Init();
        CostCenter.Validate(Code, LibraryUtility.GenerateRandomCode(CostCenter.FieldNo(Code), DATABASE::"Cost Center"));
        CostCenter.Validate("Line Type", CostCenter."Line Type"::"Cost Center");
        CostCenter.Insert(true);
    end;

    procedure CreateCostCenterFromDimension(var CostCenter: Record "Cost Center")
    var
        CostAccountingSetup: Record "Cost Accounting Setup";
        DimensionValue: Record "Dimension Value";
    begin
        CostAccountingSetup.Get();
        SetAlignment(
          CostAccountingSetup.FieldNo("Align Cost Center Dimension"), CostAccountingSetup."Align Cost Center Dimension"::Automatic);
        LibraryDimension.CreateDimensionValue(DimensionValue, CostAccountingSetup."Cost Center Dimension");
        CostCenter.Get(DimensionValue.Code);
    end;

    procedure CreateCostJournalBatch(var CostJournalBatch: Record "Cost Journal Batch"; CostJournalTemplateName: Code[10])
    begin
        CreateCostJnlBatchWithDelOpt(CostJournalBatch, CostJournalTemplateName, true);
    end;

    procedure CreateCostJournalTemplate(var CostJournalTemplate: Record "Cost Journal Template")
    begin
        CostJournalTemplate.Init();
        CostJournalTemplate.Validate(
          Name, LibraryUtility.GenerateRandomCode(CostJournalTemplate.FieldNo(Name), DATABASE::"Cost Journal Template"));
        CostJournalTemplate.Insert(true);
    end;

    procedure CreateCostJnlBatchWithDelOpt(var CostJournalBatch: Record "Cost Journal Batch"; CostJournalTemplateName: Code[10]; DeleteAfterPosting: Boolean)
    begin
        CostJournalBatch.Init();
        CostJournalBatch.Validate("Journal Template Name", CostJournalTemplateName);
        CostJournalBatch.Validate("Delete after Posting", DeleteAfterPosting);
        CostJournalBatch.Validate(Name, LibraryUtility.GenerateRandomCode(CostJournalBatch.FieldNo(Name), DATABASE::"Cost Journal Batch"));
        CostJournalBatch.Validate(Description, CostJournalBatch.Name);  // Validating Name as Description because value is not important.
        if CostJournalBatch.Insert(true) then;
    end;

    procedure CreateCostJournalLine(var CostJournalLine: Record "Cost Journal Line"; CostJournalTemplateName: Code[10]; CostJournalBatchName: Code[10])
    var
        CostType: Record "Cost Type";
        BalCostType: Record "Cost Type";
    begin
        FindCostType(CostType);
        FindCostType(BalCostType);

        CreateCostJournalLineBasic(
          CostJournalLine, CostJournalTemplateName, CostJournalBatchName, WorkDate(), CostType."No.", BalCostType."No.");

        CheckCostJnlLineConsistency(CostJournalLine);
    end;

    procedure CreateCostJournalLineBasic(var CostJournalLine: Record "Cost Journal Line"; CostJournalTemplateName: Code[10]; CostJournalBatchName: Code[10]; PostingDate: Date; CostTypeNo: Code[20]; BalCostTypeNo: Code[20])
    var
        RecRef: RecordRef;
    begin
        CostJournalLine.Init();
        CostJournalLine.Validate("Journal Template Name", CostJournalTemplateName);
        CostJournalLine.Validate("Journal Batch Name", CostJournalBatchName);
        RecRef.GetTable(CostJournalLine);
        CostJournalLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, CostJournalLine.FieldNo("Line No.")));
        CostJournalLine.Insert(true);

        CostJournalLine.Validate("Posting Date", PostingDate);
        CostJournalLine.Validate("Document No.", CostTypeNo);
        CostJournalLine.Validate("Cost Type No.", CostTypeNo);
        CostJournalLine.Validate("Bal. Cost Type No.", BalCostTypeNo);
        CostJournalLine.Validate(Amount, LibraryRandom.RandInt(1000));
        CostJournalLine.Modify(true);
    end;

    procedure CreateCostObject(var CostObject: Record "Cost Object")
    begin
        CostObject.Init();
        CostObject.Validate(Code, LibraryUtility.GenerateRandomCode(CostObject.FieldNo(Code), DATABASE::"Cost Object"));
        CostObject.Validate("Line Type", CostObject."Line Type"::"Cost Object");
        CostObject.Insert(true);
    end;

    procedure CreateCostObjectFromDimension(var CostObject: Record "Cost Object")
    var
        CostAccountingSetup: Record "Cost Accounting Setup";
        DimensionValue: Record "Dimension Value";
    begin
        CostAccountingSetup.Get();
        SetAlignment(
          CostAccountingSetup.FieldNo("Align Cost Object Dimension"), CostAccountingSetup."Align Cost Object Dimension"::Automatic);
        LibraryDimension.CreateDimensionValue(DimensionValue, CostAccountingSetup."Cost Object Dimension");
        CostObject.Get(DimensionValue.Code);
    end;

    [Normal]
    procedure CreateCostType(var CostType: Record "Cost Type")
    begin
        CreateCostTypeWithGLRange(CostType, false);
    end;

    procedure CreateCostTypeNoGLRange(var CostType: Record "Cost Type")
    begin
        CostType.Init();
        CostType.Validate("No.", LibraryUtility.GenerateRandomCode(CostType.FieldNo("No."), DATABASE::"Cost Type"));
        CostType.Validate(Type, CostType.Type::"Cost Type");
        CostType.Validate("Combine Entries", CostType."Combine Entries"::None);
        CostType.Insert(true);
    end;

    procedure CreateCostTypeWithCombine(var CostType: Record "Cost Type"; CombineEntries: Option)
    begin
        CreateCostTypeWithGLRange(CostType, true);
        CostType.Validate("Combine Entries", CombineEntries);
        CostType.Modify(true);
    end;

    procedure CreateCostTypeWithGLRange(var CostType: Record "Cost Type"; MultipleGLAccounts: Boolean)
    var
        CostAccountingSetup: Record "Cost Accounting Setup";
        GLAccount: Record "G/L Account";
        GLAccountFilter: Text[50];
        Index: Integer;
    begin
        SetAlignment(CostAccountingSetup.FieldNo("Align G/L Account"), CostAccountingSetup."Align G/L Account"::Automatic);
        CreateIncomeStmtGLAccount(GLAccount);
        CostType.Get(GLAccount."Cost Type No.");
        CostType.TestField("G/L Account Range", GLAccount."No.");
        GLAccount.TestField("Cost Type No.", CostType."No.");

        if MultipleGLAccounts then begin
            SetAlignment(CostAccountingSetup.FieldNo("Align G/L Account"), CostAccountingSetup."Align G/L Account"::"No Alignment");

            for Index := 1 to LibraryRandom.RandInt(5) do begin
                Clear(GLAccount);
                CreateIncomeStmtGLAccount(GLAccount);
            end;

            GLAccountFilter := StrSubstNo(GLAccountFilterDefinition, CostType."G/L Account Range", GLAccount."No.");
            Assert.AreEqual(MaxStrLen(CostType."G/L Account Range"), MaxStrLen(GLAccountFilter), 'Passing filter must fit field length');
            CostType.Validate("G/L Account Range", GLAccountFilter);
            CostType.Modify(true);
        end;
    end;

    procedure CreateIncomeStmtGLAccount(var GLAccount: Record "G/L Account")
    var
        CostType: Record "Cost Type";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Income/Balance", GLAccount."Income/Balance"::"Income Statement");
        GLAccount.Modify(true);

        if CostType.Get(GLAccount."Cost Type No.") then
            if CostType."G/L Account Range" <> GLAccount."No." then
                if CostType."G/L Account Range" = '' then begin
                    CostType.Validate("G/L Account Range", GLAccount."No.");
                    CostType.Modify(true);
                end else
                    Error(IncorrectGLAccountNo, CostType."G/L Account Range", CostType."No.", GLAccount."No.");
    end;

    procedure CreateJnlLine(var GenJournalLine: Record "Gen. Journal Line"; AccountNo: Code[20])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        SetupGeneralJnlBatch(GenJournalBatch);

        // Create General Journal Line.
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          GenJournalLine."Account Type"::"G/L Account", AccountNo, LibraryRandom.RandDec(1000, 2));

        // Update journal line to avoid Posting errors
        GenJournalLine.Validate("Gen. Posting Type", GenJournalLine."Gen. Posting Type"::" ");
        GenJournalLine.Validate("Gen. Bus. Posting Group", '');
        GenJournalLine.Validate("Gen. Prod. Posting Group", '');
        GenJournalLine.Modify(true);
    end;

    procedure DeleteAllCostTypeEntries()
    var
        CostType: Record "Cost Type";
    begin
        if CostType.IsEmpty() then
            exit;

        CostType.DeleteAll(true);
    end;

    procedure DeleteCostBudgetRegEntries()
    var
        CostBudgetRegister: Record "Cost Budget Register";
    begin
        if CostBudgetRegister.FindFirst() then
            DeleteCostBudgetRegEntriesFrom(CostBudgetRegister."No.");
    end;

    procedure DeleteCostBudgetRegEntriesFrom(StartEntry: Integer)
    var
        CostBudgetRegister: Record "Cost Budget Register";
        DeleteCostBudgetEntries: Report "Delete Cost Budget Entries";
    begin
        if CostBudgetRegister.FindLast() then begin
            DeleteCostBudgetEntries.InitializeRequest(StartEntry, CostBudgetRegister."No.");
            DeleteCostBudgetEntries.UseRequestPage := false;
            DeleteCostBudgetEntries.RunModal();
        end;
    end;

    procedure DeleteCostRegisterEntries()
    var
        CostRegister: Record "Cost Register";
    begin
        if CostRegister.FindFirst() then
            DeleteCostRegisterEntriesFrom(CostRegister."No.");
    end;

    procedure DeleteCostRegisterEntriesFrom(StartEntry: Integer)
    var
        CostRegister: Record "Cost Register";
        DeleteCostEntries: Report "Delete Cost Entries";
    begin
        if CostRegister.FindLast() then begin
            DeleteCostEntries.InitializeRequest(StartEntry, CostRegister."No.");
            DeleteCostEntries.UseRequestPage := false;
            DeleteCostEntries.RunModal();
        end;
    end;

    procedure DeleteBlockedDimCombinations(var DimensionCombination: Record "Dimension Combination")
    begin
        if DimensionCombination.FindSet() then
            repeat
                if DimensionCombination."Combination Restriction" = DimensionCombination."Combination Restriction"::Blocked then
                    DimensionCombination.Delete(true);
            until DimensionCombination.Next() = 0;
    end;

    procedure FindAllocSource(var CostAllocationSource: Record "Cost Allocation Source")
    begin
        CostAllocationSource.SetFilter("Credit to Cost Type", '<>%1', '');
        CostAllocationSource.SetFilter("Cost Center Code", '<>%1', '');

        if CostAllocationSource.IsEmpty() then begin
            CostAllocationSource.SetRange("Cost Center Code");
            CostAllocationSource.SetFilter("Cost Object Code", '<>%1', '');
        end;

        if CostAllocationSource.IsEmpty() then
            Error(NoRecordsInFilterErr, CostAllocationSource.TableCaption(), CostAllocationSource.GetFilters);

        CostAllocationSource.Next(LibraryRandom.RandInt(CostAllocationSource.Count));
    end;

    procedure FindCostType(var CostType: Record "Cost Type")
    begin
        GetAllCostTypes(CostType);
        if CostType.IsEmpty() then
            Error(NoRecordsInFilterErr, CostType.TableCaption(), CostType.GetFilters);

        CostType.Next(LibraryRandom.RandInt(CostType.Count));
    end;

    procedure FindCostTypeLinkedToGLAcc(var CostType: Record "Cost Type")
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.SetFilter("Cost Type No.", '<>%1', '');
        if GLAccount.IsEmpty() then
            Error(NoRecordsInFilterErr, GLAccount.TableCaption(), GLAccount.GetFilters);

        GLAccount.FindSet();
        GLAccount.Next(LibraryRandom.RandInt(GLAccount.Count));
        CostType.Get(GLAccount."Cost Type No.");
    end;

    procedure FindCostTypeWithCostCenter(var CostType: Record "Cost Type")
    begin
        GetAllCostTypes(CostType);
        CostType.SetFilter("Cost Center Code", '<>%1', '');
        CostType.SetFilter("Cost Object Code", '%1', '');
        if CostType.IsEmpty() then
            Error(NoRecordsInFilterErr, CostType.TableCaption(), CostType.GetFilters);

        CostType.Next(LibraryRandom.RandInt(CostType.Count));
    end;

    procedure FindCostCenter(var CostCenter: Record "Cost Center")
    begin
        CostCenter.SetFilter("Line Type", Format(CostCenter."Line Type"::"Cost Center"));
        CostCenter.SetFilter(Blocked, '%1', false);
        CostCenter.SetFilter("Net Change", '<>%1', 0);
        CostCenter.SetFilter("Balance at Date", '<>%1', 0);
        if CostCenter.IsEmpty() then
            Error(NoRecordsInFilterErr, CostCenter.TableCaption(), CostCenter.GetFilters);

        CostCenter.Next(LibraryRandom.RandInt(CostCenter.Count));
    end;

    procedure FindCostJournalBatch(var CostJournalBatch: Record "Cost Journal Batch"; CostJournalTemplateName: Code[10])
    begin
        FindCostJnlBatchWithDelOption(CostJournalBatch, CostJournalTemplateName, true);
    end;

    procedure FindCostJnlBatchWithDelOption(var CostJournalBatch: Record "Cost Journal Batch"; CostJournalTemplateName: Code[10]; DeleteAfterPosting: Boolean)
    begin
        CostJournalBatch.SetRange("Journal Template Name", CostJournalTemplateName);
        CostJournalBatch.SetRange("Delete after Posting", DeleteAfterPosting);
        if CostJournalBatch.IsEmpty() then
            CreateCostJournalBatch(CostJournalBatch, CostJournalTemplateName)
        else
            CostJournalBatch.FindFirst();
    end;

    procedure FindCostJournalTemplate(var CostJournalTemplate: Record "Cost Journal Template")
    begin
        CostJournalTemplate.FindFirst();
    end;

    procedure FindCostObject(var CostObject: Record "Cost Object")
    begin
        CostObject.SetFilter("Line Type", Format(CostObject."Line Type"::"Cost Object"));
        CostObject.SetFilter(Blocked, '%1', false);
        CostObject.SetFilter("Net Change", '<>%1', 0);
        CostObject.SetFilter("Balance at Date", '<>%1', 0);
        if CostObject.IsEmpty() then
            Error(NoRecordsInFilterErr, CostObject.TableCaption(), CostObject.GetFilters);

        CostObject.Next(LibraryRandom.RandInt(CostObject.Count));
    end;

    procedure FindGLAccLinkedToCostType(var GLAccount: Record "G/L Account")
    begin
        LibraryERM.FindGLAccount(GLAccount);
        GLAccount.SetFilter("Cost Type No.", '<>%1', '');
        if GLAccount.IsEmpty() then
            Error(NoRecordsInFilterErr, GLAccount.TableCaption(), GLAccount.GetFilters);

        GLAccount.Next(LibraryRandom.RandInt(GLAccount.Count));
    end;

    procedure FindGLAccountsByCostType(var GLAccount: Record "G/L Account"; GLAccountRange: Text[50])
    begin
        GLAccount.SetFilter("No.", GLAccountRange);
        if GLAccount.IsEmpty() then
            Error(NoRecordsInFilterErr, GLAccount.TableCaption(), GLAccount.GetFilters);

        GLAccount.FindSet();
    end;

    procedure FindIncomeStmtGLAccount(var GLAccount: Record "G/L Account")
    begin
        GetAllIncomeStmtGLAccounts(GLAccount);
        GLAccount.Next(LibraryRandom.RandInt(GLAccount.Count));
    end;

    procedure GetAllCostTypes(var CostType: Record "Cost Type")
    begin
        CostType.Init();
        CostType.SetFilter(Type, Format(CostType.Type::"Cost Type"));
        CostType.SetFilter("G/L Account Range", '<>%1', '');
        if CostType.IsEmpty() then
            Error(NoRecordsInFilterErr, CostType.TableCaption(), CostType.GetFilters);
        CostType.FindSet();
    end;

    procedure GetAllIncomeStmtGLAccounts(var GLAccount: Record "G/L Account")
    begin
        LibraryERM.FindGLAccount(GLAccount);
        GLAccount.SetFilter("Income/Balance", Format(GLAccount."Income/Balance"::"Income Statement"));
        if GLAccount.IsEmpty() then
            Error(NoRecordsInFilterErr, GLAccount.TableCaption(), GLAccount.GetFilters);
        GLAccount.FindSet();
    end;

    procedure GetAllocTargetEntryAmount(var CostAllocationTarget: Record "Cost Allocation Target"; TotalAmount: Decimal; TableNumber: Integer; KeyFieldNumber: Integer; AmountFieldNumber: Integer; FromValue: Integer; ToValue: Integer) TotalDebitValue: Decimal
    var
        AmountFieldRef: FieldRef;
        KeyFieldRef: FieldRef;
        RecordRef: RecordRef;
        AllocatedCost: Decimal;
        EntryAmount: Decimal;
        FieldRefAmount: Decimal;
    begin
        RecordRef.Open(TableNumber);
        KeyFieldRef := RecordRef.Field(KeyFieldNumber);
        KeyFieldRef.SetRange(FromValue, (ToValue - 1));
        RecordRef.FindSet();

        if RecordRef.IsEmpty() then
            Error(NoRecordsInFilterErr, RecordRef.Name, RecordRef.GetFilters);

        if RecordRef.Count <> CostAllocationTarget.Count then
            Error(
              StrSubstNo(
                NumberOfRecordsNotMatchingErr, RecordRef.Count, RecordRef.Name, CostAllocationTarget.Count, CostAllocationTarget.TableCaption()));

        AmountFieldRef := RecordRef.Field(AmountFieldNumber);

        repeat
            // To avoid the rounding errors, approximate the decimal numbers by cutting out the fractional part.
            FieldRefAmount := AmountFieldRef.Value();
            EntryAmount := Round(FieldRefAmount, 1);
            AllocatedCost := Round(TotalAmount * (CostAllocationTarget.Percent / 100), 1);

            if EntryAmount <> AllocatedCost then
                if -EntryAmount <> AllocatedCost then
                    Error(
                      StrSubstNo(
                        AllocValuesNotMatchingErr, FieldRefAmount, EntryAmount, CostAllocationTarget.Percent,
                        TotalAmount, AllocatedCost, (CostAllocationTarget.Percent * TotalAmount)));

            TotalDebitValue := TotalDebitValue + FieldRefAmount;
            CostAllocationTarget.Next();
        until RecordRef.Next() = 0;

        exit(TotalDebitValue);
    end;

    procedure InitializeCASetup()
    var
        CostAccountingSetup: Record "Cost Accounting Setup";
    begin
        CostAccountingSetup.Get();
        CostAccountingSetup.Validate("Align G/L Account", CostAccountingSetup."Align G/L Account"::Automatic);
        CostAccountingSetup.Validate("Align Cost Center Dimension", CostAccountingSetup."Align Cost Center Dimension"::Automatic);
        CostAccountingSetup.Validate("Align Cost Object Dimension", CostAccountingSetup."Align Cost Object Dimension"::Automatic);
        CostAccountingSetup.Validate("Auto Transfer from G/L", false);
        if CostAccountingSetup."Last Allocation ID" = '' then
            CostAccountingSetup.Validate("Last Allocation ID", 'A0');
        if CostAccountingSetup."Last Allocation Doc. No." = '' then
            CostAccountingSetup.Validate("Last Allocation Doc. No.", 'ALLOC0');
        CostAccountingSetup.Modify(true);

        InitializeCASourceCodes();
    end;

    procedure InitializeCASourceCodes()
    var
        SourceCodeSetup: Record "Source Code Setup";
        SourceCode: Record "Source Code";
        Modified: Boolean;
    begin
        SourceCodeSetup.Get();

        if SourceCodeSetup."G/L Entry to CA" = '' then begin
            LibraryERM.CreateSourceCode(SourceCode);
            SourceCodeSetup.Validate("G/L Entry to CA", SourceCode.Code);
            Modified := true;
        end;
        if SourceCodeSetup."Cost Journal" = '' then begin
            LibraryERM.CreateSourceCode(SourceCode);
            SourceCodeSetup.Validate("Cost Journal", SourceCode.Code);
            Modified := true;
        end;
        if SourceCodeSetup."Cost Allocation" = '' then begin
            LibraryERM.CreateSourceCode(SourceCode);
            SourceCodeSetup.Validate("Cost Allocation", SourceCode.Code);
            Modified := true;
        end;

        if Modified then
            SourceCodeSetup.Modify(true);
    end;

    procedure LastAllocSourceID(): Code[10]
    var
        CostAccountingSetup: Record "Cost Accounting Setup";
    begin
        CostAccountingSetup.Get();
        exit(CostAccountingSetup."Last Allocation ID");
    end;

    procedure LastAllocTargetID(CostAllocationSource: Record "Cost Allocation Source"): Integer
    var
        CostAllocationTarget: Record "Cost Allocation Target";
    begin
        CostAllocationTarget.SetFilter(ID, '%1', CostAllocationSource.ID);
        if CostAllocationTarget.FindLast() then
            exit(CostAllocationTarget."Line No.");

        exit(0);
    end;

    procedure PostCostJournalLine(CostJournalLine: Record "Cost Journal Line")
    begin
        CODEUNIT.Run(CODEUNIT::"CA Jnl.-Post Batch", CostJournalLine);
    end;

    procedure PostGenJournalLine(AccountNo: Code[20])
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        CreateJnlLine(GenJournalLine, AccountNo);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    procedure SetAlignment(FieldNo: Integer; FieldOptionValue: Option)
    var
        CostAccountingSetup: Record "Cost Accounting Setup";
        "Field": Record "Field";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
    begin
        CostAccountingSetup.Get();
        RecordRef.GetTable(CostAccountingSetup);
        FieldRef := RecordRef.Field(FieldNo);
        Field.Get(RecordRef.Number, FieldRef.Number);
        if Field.Type = Field.Type::Option then begin
            FieldRef.Validate(FieldOptionValue);
            RecordRef.Modify(true);
        end;
    end;

    procedure SetAutotransferFromGL(Autotransfer: Boolean)
    var
        CostAccountingSetup: Record "Cost Accounting Setup";
    begin
        CostAccountingSetup.Get();
        CostAccountingSetup.Validate("Auto Transfer from G/L", Autotransfer);
        CostAccountingSetup.Modify(true);
    end;

    procedure SetDefaultDimension(GLAccountNo: Code[20])
    var
        CostCenter: Record "Cost Center";
        DimValue: Record "Dimension Value";
        DefaultDimension: Record "Default Dimension";
    begin
        if not DefaultDimension.Get(DATABASE::"G/L Account", GLAccountNo, CostCenterDimension()) then begin
            LibraryDimension.FindDimensionValue(DimValue, CostCenterDimension());
            LibraryDimension.CreateDefaultDimensionGLAcc(DefaultDimension, GLAccountNo, DimValue."Dimension Code", DimValue.Code);
        end;

        // Make sure corresponding cost center exists
        if not CostCenter.Get(DefaultDimension."Dimension Value Code") then begin
            CostCenter.Init();
            CostCenter.Validate(Code, DefaultDimension."Dimension Value Code");
            CostCenter.Validate("Line Type", CostCenter."Line Type"::"Cost Center");
            CostCenter.Insert(true);
        end;

        CheckBlockedDimensionValues(GLAccountNo); // check for blocked default dimension values, which prevent posting
        CheckBlockedDimCombination(); // check for blocked dimension combinations, which prevent posting
    end;

    procedure SetupGeneralJnlBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        CreateBalanceSheetGLAccount(GLAccount);
        GenJournalBatch.Validate("Bal. Account No.", GLAccount."No.");
        GenJournalBatch.Modify(true);

        LibraryERM.ClearGenJournalLines(GenJournalBatch);
    end;

    procedure SetupGLAccount(var GLAccount: Record "G/L Account")
    begin
        FindGLAccLinkedToCostType(GLAccount);
        SetDefaultDimension(GLAccount."No.");
    end;

    procedure TransferBudgetToActual(var TransferToActual: TestRequestPage "Transfer Budget to Actual"; BudgetName: Code[10]; DateRange: Text[30])
    begin
        TransferToActual."Cost Budget Entry".SetFilter("Budget Name", BudgetName);
        TransferToActual."Cost Budget Entry".SetFilter(Date, DateRange);
    end;

    procedure TransferGLEntries()
    begin
        CODEUNIT.Run(CODEUNIT::"Transfer GL Entries to CA");
    end;

    procedure UpdateAllocSourceWithCCenter(var CostAllocationSource: Record "Cost Allocation Source")
    var
        CostCenter: Record "Cost Center";
    begin
        FindCostCenter(CostCenter);
        CostAllocationSource.Validate("Cost Center Code", CostCenter.Code);
        CostAllocationSource.Modify(true);
    end;

    procedure UpdateAllocSourceWithCObject(var CostAllocationSource: Record "Cost Allocation Source")
    var
        CostObject: Record "Cost Object";
    begin
        FindCostObject(CostObject);
        CostAllocationSource.Validate("Cost Object Code", CostObject.Code);
        CostAllocationSource.Modify(true);
    end;

    procedure UpdateAllocTargetWithCCenter(var CostAllocationTarget: Record "Cost Allocation Target")
    var
        CostCenter: Record "Cost Center";
    begin
        FindCostCenter(CostCenter);
        CostAllocationTarget.Validate("Target Cost Center", CostCenter.Code);
        CostAllocationTarget.Modify(true);
    end;

    procedure UpdateAllocTargetWithCObject(var CostAllocationTarget: Record "Cost Allocation Target")
    var
        CostObject: Record "Cost Object";
    begin
        FindCostObject(CostObject);
        CostAllocationTarget.Validate("Target Cost Object", CostObject.Code);
        CostAllocationTarget.Modify(true);
    end;

    [Normal]
    procedure UpdateCostTypeWithCostCenter(var CostType: Record "Cost Type")
    var
        CostCenter: Record "Cost Center";
    begin
        FindCostCenter(CostCenter);
        CostType.Validate("Cost Center Code", CostCenter.Code);
        CostType.Modify(true);
    end;

    [Normal]
    procedure UpdateCostTypeWithCostObject(var CostType: Record "Cost Type")
    var
        CostObject: Record "Cost Object";
    begin
        FindCostObject(CostObject);
        CostType.Validate("Cost Object Code", CostObject.Code);
        CostType.Modify(true);
    end;

    procedure ValidateEntriesTransfered()
    var
        GLRegister: Record "G/L Register";
        GLEntry: Record "G/L Entry";
        CostRegister: Record "Cost Register";
        CostEntry: Record "Cost Entry";
        GLAccount: Record "G/L Account";
    begin
        GLRegister.FindLast();
        GLEntry.Get(GLRegister."From Entry No.");
        CostRegister.SetFilter(Source, Format(CostRegister.Source::"Transfer from G/L"));
        CostRegister.FindLast();
        CostEntry.Get(CostRegister."From Cost Entry No.");
        GLAccount.Get(CostEntry."G/L Account");

        // Validate Cost Register Entry
        Assert.AreEqual(1, CostRegister."No. of Entries",
          StrSubstNo(ExpectedValueIsDifferentErr, CostRegister.FieldName("No. of Entries")));
        Assert.AreEqual(0, CostRegister."To Cost Entry No." - CostRegister."From Cost Entry No.", CostEntriesCountErr);
        Assert.AreEqual(GLEntry.Amount, CostRegister."Debit Amount",
          StrSubstNo(ExpectedValueIsDifferentErr, CostRegister.FieldName("Debit Amount")));

        // Validate Cost Entry
        Assert.AreEqual(GLEntry.Amount, CostEntry.Amount, StrSubstNo(ExpectedValueIsDifferentErr, CostEntry.FieldName(Amount)));
        Assert.AreEqual(GLEntry."Entry No.", CostEntry."G/L Entry No.",
          StrSubstNo(ExpectedValueIsDifferentErr, CostEntry.FieldName("G/L Entry No.")));
        Assert.AreEqual(GLAccount."Cost Type No.", CostEntry."Cost Type No.",
          StrSubstNo(ExpectedValueIsDifferentErr, CostEntry.FieldName("Cost Type No.")));
        Assert.AreEqual(GLEntry."G/L Account No.", CostEntry."G/L Account",
          StrSubstNo(ExpectedValueIsDifferentErr, CostEntry.FieldName("G/L Account")));
        Assert.AreEqual(GLEntry."Document No.", CostEntry."Document No.",
          StrSubstNo(ExpectedValueIsDifferentErr, CostEntry.FieldName("Document No.")));
        Assert.AreEqual(false, CostEntry.Allocated, StrSubstNo(ExpectedValueIsDifferentErr, CostEntry.FieldName(Allocated)));
    end;

    procedure ValidateGLAccountCostTypeRef(CostTypeNo: Code[20])
    var
        CostType: Record "Cost Type";
        GLAccount: Record "G/L Account";
    begin
        // The Cost Type has the G/L Account Range filled in.
        CostType.Get(CostTypeNo);
        CostType.TestField("G/L Account Range");

        // The G/L Accounts have the Cost Type No. filled in.
        FindGLAccountsByCostType(GLAccount, CostType."G/L Account Range");
        repeat
            GLAccount.TestField("Cost Type No.", CostType."No.");
        until GLAccount.Next() = 0;
    end;

    procedure ValidateGLAccountIsIncomeStmt(var CostType: Record "Cost Type")
    var
        GLAccount: Record "G/L Account";
    begin
        repeat
            FindGLAccountsByCostType(GLAccount, CostType."G/L Account Range");
            repeat
                GLAccount.TestField("Income/Balance", GLAccount."Income/Balance"::"Income Statement");
            until GLAccount.Next() = 0;
        until CostType.Next() = 0;
    end;

    procedure VerifyCostTypeIntegrity()
    var
        CostType: Record "Cost Type";
        GLAccount: Record "G/L Account";
    begin
        GetAllCostTypes(CostType);
        repeat
            GLAccount.SetFilter("No.", CostType."G/L Account Range");
            if GLAccount.Count > 1 then begin
                GLAccount.FindSet();
                repeat
                    if GLAccount."Cost Type No." <> CostType."No." then
                        Error(GetCostTypesFromGLErr);
                until GLAccount.Next() = 0;
            end;
        until CostType.Next() = 0;
    end;
}

