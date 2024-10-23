namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.AllocationAccount;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;

codeunit 31155 "Cash Doc. Alloc. Acc. Mgt. CZP"
{
    internal procedure GetOrGenerateAllocationLines(var AllocationLine: Record "Allocation Line"; var ParentSystemId: Guid)
    var
        AmountToAllocate: Decimal;
        PostingDate: Date;
    begin
        GetOrGenerateAllocationLines(AllocationLine, ParentSystemId, AmountToAllocate, PostingDate);
    end;

    internal procedure GetOrGenerateAllocationLines(var AllocationLine: Record "Allocation Line"; var ParentSystemId: Guid; var AmountToAllocate: Decimal; var PostingDate: Date)
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        AllocationAccount: Record "Allocation Account";
        AllocationAccountMgt: Codeunit "Allocation Account Mgt.";
    begin
        CashDocumentLineCZP.ReadIsolation := IsolationLevel::ReadCommitted;
        CashDocumentLineCZP.SetAutoCalcFields("Alloc. Acc. Modified by User");
        CashDocumentLineCZP.GetBySystemId(ParentSystemId);
        AmountToAllocate := CashDocumentLineCZP.Amount;

        CashDocumentHeaderCZP.ReadIsolation := IsolationLevel::ReadUncommitted;
        CashDocumentHeaderCZP.Get(CashDocumentLineCZP."Cash Desk No.", CashDocumentLineCZP."Cash Document No.");
        PostingDate := CashDocumentHeaderCZP."Posting Date";

        if CashDocumentLineCZP."Alloc. Acc. Modified by User" then
            LoadManualAllocationLines(CashDocumentLineCZP, AllocationLine)
        else begin
            CashDocumentLineCZP.GetAllocationAccount(AllocationAccount);
            AllocationAccountMgt.GenerateAllocationLines(
                AllocationAccount, AllocationLine, CashDocumentLineCZP.Amount, PostingDate,
                CashDocumentLineCZP."Dimension Set ID", CashDocumentLineCZP."Currency Code");
            ReplaceInheritFromParent(AllocationLine, CashDocumentLineCZP);
        end;
    end;

    internal procedure LoadManualAllocationLines(var CashDocumentLineCZP: Record "Cash Document Line CZP"; var AllocationLine: Record "Allocation Line")
    var
        AllocAccManualOverride: Record "Alloc. Acc. Manual Override";
    begin
        AllocAccManualOverride.SetRange("Parent System Id", CashDocumentLineCZP.SystemId);
        AllocAccManualOverride.SetRange("Parent Table Id", Database::"Cash Document Line CZP");
        AllocAccManualOverride.ReadIsolation := IsolationLevel::ReadUncommitted;
        if not AllocAccManualOverride.FindSet() then
            exit;

        repeat
            AllocationLine."Line No." := AllocAccManualOverride."Line No.";
            AllocationLine."Destination Account Type" := AllocAccManualOverride."Destination Account Type";
            AllocationLine."Destination Account Number" := AllocAccManualOverride."Destination Account Number";
            AllocationLine."Global Dimension 1 Code" := AllocAccManualOverride."Global Dimension 1 Code";
            AllocationLine."Global Dimension 2 Code" := AllocAccManualOverride."Global Dimension 2 Code";
            AllocationLine."Allocation Account No." := AllocAccManualOverride."Allocation Account No.";
            AllocationLine."Dimension Set ID" := AllocAccManualOverride."Dimension Set ID";
            AllocationLine.Amount := AllocAccManualOverride.Amount;
            AllocationLine.Quantity := AllocAccManualOverride.Quantity;
            AllocationLine.Insert();
        until AllocAccManualOverride.Next() = 0;
    end;

    local procedure ReplaceInheritFromParent(var AllocationLine: Record "Allocation Line"; var CashDocumentLineCZP: Record "Cash Document Line CZP")
    var
        CurrentFilters: Text;
    begin
        CurrentFilters := AllocationLine.GetView();
        AllocationLine.Reset();
        AllocationLine.SetRange(AllocationLine."Destination Account Type", AllocationLine."Destination Account Type"::"Inherit from Parent");
        if AllocationLine.IsEmpty then begin
            AllocationLine.Reset();
            AllocationLine.SetView(CurrentFilters);
            exit;
        end;

        if CashDocumentLineCZP."Account No." = '' then
            Error(MustProvideAccountNoForInheritFromParentErr);

        AllocationLine.ModifyAll("Destination Account Number", CashDocumentLineCZP."Account No.");

        case CashDocumentLineCZP."Account Type" of
            CashDocumentLineCZP."Account Type"::"G/L Account":
                AllocationLine.ModifyAll("Destination Account Type", AllocationLine."Destination Account Type"::"G/L Account");
            else
                Error(InvalidAccountTypeForInheritFromParentErr, CashDocumentLineCZP."Account Type");
        end;

        AllocationLine.Reset();
        AllocationLine.SetView(CurrentFilters);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Document-Post CZP", 'OnBeforePostCashDoc', '', false, false)]
    local procedure HandlePostDocument(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    var
        AllocAccTelemetryCZP: Codeunit "Alloc. Acc. Telemetry CZP";
        ContainsAllocationLines: Boolean;
    begin
        VerifyLinesFromDocument(CashDocumentHeaderCZP, ContainsAllocationLines);
        if not ContainsAllocationLines then
            exit;

        AllocAccTelemetryCZP.LogCashDocumentPostingUsage();
        CreateLinesFromDocument(CashDocumentHeaderCZP)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Document Line CZP", 'OnBeforeShowDimensions', '', false, false)]
    local procedure HandleShowDimensions(var CashDocumentLineCZP: Record "Cash Document Line CZP"; xCashDocumentLineCZP: Record "Cash Document Line CZP"; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        if (CashDocumentLineCZP."Account Type" <> CashDocumentLineCZP."Account Type"::"Allocation Account") then
            exit;

        if GuiAllowed() then
            if not Confirm(ChangeDimensionsOnAllocationDistributionsQst) then
                Error('');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Document Approv. Mgt. CZP", 'OnAfterCheckCashDocApprovalPossible', '', false, false)]
    local procedure HandleAfterCheckSalesApprovalPossible(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    var
        ContainsAllocationLines: Boolean;
    begin
        VerifyLinesFromDocument(CashDocumentHeaderCZP, ContainsAllocationLines);
        if not ContainsAllocationLines then
            exit;

        if not GuiAllowed() then
            Error(ReplaceAllocationLinesBeforeSendingToApprovalErr);

        if not Confirm(ReplaceAllocationLinesBeforeSendingToApprovalQst) then
            Error(ReplaceAllocationLinesBeforeSendingToApprovalErr);

        CreateLinesFromDocument(CashDocumentHeaderCZP);
        Commit();
        if CashDocumentHeaderCZP.Find() then;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Document Line CZP", 'OnBeforeModifyEvent', '', false, false)]
    local procedure CheckBeforeModifyLine(var Rec: Record "Cash Document Line CZP"; var xRec: Record "Cash Document Line CZP"; RunTrigger: Boolean)
    begin
        VerifyCashDocumentLine(Rec);
        DeleteManualDistributionsIfLineChanged(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Document Line CZP", 'OnBeforeValidateEvent', 'Account No.', false, false)]
    local procedure HandleValidateLineNo(CurrFieldNo: Integer; var Rec: Record "Cash Document Line CZP"; var xRec: Record "Cash Document Line CZP")
    var
        AllocationAccount: Record "Allocation Account";
    begin
        if Rec."Account Type" <> Rec."Account Type"::"Allocation Account" then
            exit;

        VerifyCashDocumentLine(Rec);
        if Rec.Description <> '' then
            exit;

        AllocationAccount.Get(Rec."Account No.");
        Rec.Description := AllocationAccount.Name;
    end;

    local procedure DeleteManualDistributionsIfLineChanged(var CashDocumentLineCZP: Record "Cash Document Line CZP")
    var
        PreviousCashDocumentLineCZP: Record "Cash Document Line CZP";
        AllocAccManualOverride: Record "Alloc. Acc. Manual Override";
        DeleteAllocAccManualOverrideNeeded: Boolean;
    begin
        if CashDocumentLineCZP.IsTemporary() then
            exit;

        if (not AllocationAccountUsed(CashDocumentLineCZP)) then
            exit;

        PreviousCashDocumentLineCZP.ReadIsolation := IsolationLevel::ReadUncommitted;
        if not PreviousCashDocumentLineCZP.GetBySystemId(CashDocumentLineCZP.SystemId) then
            exit;

        AllocAccManualOverride.SetRange("Parent System Id", CashDocumentLineCZP.SystemId);
        AllocAccManualOverride.SetRange("Parent Table Id", Database::"Cash Document Line CZP");
        AllocAccManualOverride.ReadIsolation := IsolationLevel::ReadUncommitted;
        if AllocAccManualOverride.IsEmpty() then
            exit;

        DeleteAllocAccManualOverrideNeeded := (CashDocumentLineCZP."Account Type" <> PreviousCashDocumentLineCZP."Account Type") or
                                              (CashDocumentLineCZP."Account No." <> PreviousCashDocumentLineCZP."Account No.") or
                                              (CashDocumentLineCZP.Amount <> PreviousCashDocumentLineCZP.Amount);

        if not DeleteAllocAccManualOverrideNeeded then
            exit;

        if GuiAllowed() then
            if not Confirm(DeleteManualOverridesQst) then
                Error('');

        AllocAccManualOverride.DeleteAll();
    end;

    local procedure AllocationAccountUsed(var CashDocumentLineCZP: Record "Cash Document Line CZP"): Boolean
    begin
        exit((CashDocumentLineCZP."Account Type" = CashDocumentLineCZP."Account Type"::"Allocation Account") or
             (CashDocumentLineCZP."Selected Alloc. Account No." <> ''));
    end;

    local procedure CreateLinesFromDocument(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    var
        AllocationCashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        AllocationCashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
        AllocationCashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
        AllocationCashDocumentLineCZP.SetRange("Account Type", AllocationCashDocumentLineCZP."Account Type"::"Allocation Account");
        CreateLines(AllocationCashDocumentLineCZP);
        AllocationCashDocumentLineCZP.DeleteAll();

        AllocationCashDocumentLineCZP.Reset();
        AllocationCashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
        AllocationCashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
        AllocationCashDocumentLineCZP.SetFilter("Selected Alloc. Account No.", '<>%1', '');
        CreateLines(AllocationCashDocumentLineCZP);
        AllocationCashDocumentLineCZP.DeleteAll();
    end;

    local procedure CreateLines(var AllocationCashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
        AllocationCashDocumentLineCZP.ReadIsolation := IsolationLevel::ReadCommitted;
        if AllocationCashDocumentLineCZP.IsEmpty() then
            exit;

        AllocationCashDocumentLineCZP.ReadIsolation := IsolationLevel::UpdLock;
        AllocationCashDocumentLineCZP.FindSet();
        repeat
            CreateLinesFromAllocationAccountLine(AllocationCashDocumentLineCZP);
        until AllocationCashDocumentLineCZP.Next() = 0;
    end;

    procedure CreateLinesFromAllocationAccountLine(var AllocationAccountCashDocumentLineCZP: Record "Cash Document Line CZP")
    var
        ExistingAccountCashDocumentLineCZP: Record "Cash Document Line CZP";
        AllocationLine: Record "Allocation Line";
        AllocationAccount: Record "Allocation Account";
        DescriptionChanged: Boolean;
        NextLineNo: Integer;
        LastLineNo: Integer;
        Increment: Integer;
        CreatedLines: List of [Guid];
    begin
        if not AllocationAccountCashDocumentLineCZP.GetAllocationAccount(AllocationAccount) then
            Error(CannotGetAllocationAccountFromLineErr, AllocationAccountCashDocumentLineCZP."Line No.");

        VerifyAllocationAccount(AllocationAccount);

        GetOrGenerateAllocationLines(AllocationLine, AllocationAccountCashDocumentLineCZP.SystemId);
#pragma warning disable AA0210
        AllocationLine.SetFilter(Amount, '<>%1', 0);
#pragma warning restore AA0210

        if AllocationLine.Count = 0 then
            Error(NoLinesGeneratedLbl, AllocationAccountCashDocumentLineCZP.RecordId);

        NextLineNo := GetNextLine(AllocationAccountCashDocumentLineCZP);
        LastLineNo := AllocationAccountCashDocumentLineCZP."Line No.";

        Increment := GetLineIncrement(AllocationAccountCashDocumentLineCZP."Line No.", NextLineNo, AllocationLine.Count);
        if Increment < -1 then begin
            Increment := 10000;
            LastLineNo := GetLastLine(AllocationAccountCashDocumentLineCZP)
        end;

        AllocationLine.Reset();
#pragma warning disable AA0210
        AllocationLine.SetFilter(Amount, '<>%1', 0);
#pragma warning restore AA0210

        AllocationLine.FindSet();
        ExistingAccountCashDocumentLineCZP.ReadIsolation := IsolationLevel::ReadUncommitted;
        ExistingAccountCashDocumentLineCZP.SetAutoCalcFields("Alloc. Acc. Modified by User");
        ExistingAccountCashDocumentLineCZP.GetBySystemId(AllocationAccountCashDocumentLineCZP.SystemId);
        DescriptionChanged :=
            GetDescriptionChanged(ExistingAccountCashDocumentLineCZP.Description,
                ExistingAccountCashDocumentLineCZP."Account Type", ExistingAccountCashDocumentLineCZP."Account No.");

        repeat
            CreatedLines.Add(
                CreateCashDocumentLine(ExistingAccountCashDocumentLineCZP, AllocationLine,
                    LastLineNo, Increment, AllocationAccount, DescriptionChanged));
        until AllocationLine.Next() = 0;

        DeleteManualOverrides(AllocationAccountCashDocumentLineCZP);
    end;

    local procedure DeleteManualOverrides(var CashDocumentLineCZP: Record "Cash Document Line CZP")
    var
        AllocAccManualOverride: Record "Alloc. Acc. Manual Override";
    begin
        AllocAccManualOverride.SetRange("Parent System Id", CashDocumentLineCZP.SystemId);
        AllocAccManualOverride.SetRange("Parent Table Id", Database::"Cash Document Line CZP");
        AllocAccManualOverride.ReadIsolation := IsolationLevel::ReadUncommitted;
        if not AllocAccManualOverride.IsEmpty() then
            AllocAccManualOverride.DeleteAll();
    end;

    local procedure VerifyLinesFromDocument(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var ContainsAllocationLines: Boolean)
    var
        AllocationAccountCashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        AllocationAccountCashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
        AllocationAccountCashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
        AllocationAccountCashDocumentLineCZP.SetRange("Account Type", AllocationAccountCashDocumentLineCZP."Account Type"::"Allocation Account");
        AllocationAccountCashDocumentLineCZP.ReadIsolation := IsolationLevel::ReadUncommitted;
        if AllocationAccountCashDocumentLineCZP.FindSet() then begin
            ContainsAllocationLines := true;
            repeat
                VerifyCashDocumentLines(AllocationAccountCashDocumentLineCZP);
            until AllocationAccountCashDocumentLineCZP.Next() = 0;
        end;

        AllocationAccountCashDocumentLineCZP.Reset();
        AllocationAccountCashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
        AllocationAccountCashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
        AllocationAccountCashDocumentLineCZP.SetFilter("Selected Alloc. Account No.", '<>%1', '');
        AllocationAccountCashDocumentLineCZP.ReadIsolation := IsolationLevel::ReadUncommitted;
        if AllocationAccountCashDocumentLineCZP.FindSet() then begin
            ContainsAllocationLines := true;
            repeat
                VerifyCashDocumentLines(AllocationAccountCashDocumentLineCZP);
            until AllocationAccountCashDocumentLineCZP.Next() = 0;
        end;
    end;

    local procedure CreateCashDocumentLine(var AllocationCashDocumentLineCZP: Record "Cash Document Line CZP"; var AllocationLine: Record "Allocation Line"; var LastLineNo: Integer; Increment: Integer; var AllocationAccount: Record "Allocation Account"; var DescriptionChanged: Boolean): Guid
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        CashDocumentLineCZP.TransferFields(AllocationCashDocumentLineCZP, true);
        CashDocumentLineCZP."Line No." := LastLineNo + Increment;
        CashDocumentLineCZP."Cash Desk Event" := '';
        CashDocumentLineCZP."Account Type" := CashDocumentLineCZP."Account Type"::"G/L Account";
        CashDocumentLineCZP.Validate("Account No.", AllocationLine."Destination Account Number");
        if AllocationCashDocumentLineCZP."VAT Bus. Posting Group" <> '' then
            CashDocumentLineCZP.Validate("VAT Bus. Posting Group", AllocationCashDocumentLineCZP."VAT Bus. Posting Group");
        if AllocationCashDocumentLineCZP."VAT Prod. Posting Group" <> '' then
            CashDocumentLineCZP.Validate("VAT Prod. Posting Group", AllocationCashDocumentLineCZP."VAT Prod. Posting Group");

        if DescriptionChanged then begin
            if AllocationCashDocumentLineCZP.Description <> '' then
                CashDocumentLineCZP.Description := AllocationCashDocumentLineCZP.Description;
            if AllocationCashDocumentLineCZP."Description 2" <> '' then
                CashDocumentLineCZP."Description 2" := AllocationCashDocumentLineCZP."Description 2";
        end;

        MoveAmounts(CashDocumentLineCZP, AllocationLine, AllocationAccount);

        TransferDimensionSetID(CashDocumentLineCZP, AllocationLine, AllocationCashDocumentLineCZP."Alloc. Acc. Modified by User");
        CashDocumentLineCZP."Allocation Account No." := AllocationLine."Allocation Account No.";
        CashDocumentLineCZP."Selected Alloc. Account No." := '';
        OnBeforeCreateCashDocumentLine(CashDocumentLineCZP, AllocationLine, AllocationCashDocumentLineCZP);
        CashDocumentLineCZP.Insert(true);
        LastLineNo := CashDocumentLineCZP."Line No.";
        exit(CashDocumentLineCZP.SystemId);
    end;

    local procedure MoveAmounts(var CashDocumentLineCZP: Record "Cash Document Line CZP"; var AllocationLine: Record "Allocation Line"; var AllocationAccount: Record "Allocation Account")
    begin
        if AllocationAccount."Document Lines Split" <> AllocationAccount."Document Lines Split"::"Split Amount" then
            exit;

        CashDocumentLineCZP.Validate(Amount, AllocationLine.Amount);
    end;

    local procedure GetNextLine(var AllocationCashDocumentLineCZP: Record "Cash Document Line CZP"): Integer
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        CashDocumentLineCZP.SetRange("Cash Desk No.", AllocationCashDocumentLineCZP."Cash Desk No.");
        CashDocumentLineCZP.SetRange("Cash Document No.", AllocationCashDocumentLineCZP."Cash Document No.");
        CashDocumentLineCZP.SetFilter("Line No.", '>%1', AllocationCashDocumentLineCZP."Line No.");
        CashDocumentLineCZP.ReadIsolation := IsolationLevel::ReadCommitted;
        if CashDocumentLineCZP.FindFirst() then
            exit(CashDocumentLineCZP."Line No.");

        exit(AllocationCashDocumentLineCZP."Line No." + 10000);
    end;

    local procedure GetLastLine(var AllocationCashDocumentLineCZP: Record "Cash Document Line CZP"): Integer
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        CashDocumentLineCZP.SetRange("Cash Desk No.", AllocationCashDocumentLineCZP."Cash Desk No.");
        CashDocumentLineCZP.SetRange("Cash Document No.", AllocationCashDocumentLineCZP."Cash Document No.");
        CashDocumentLineCZP.SetFilter("Line No.", '>%1', AllocationCashDocumentLineCZP."Line No.");
        CashDocumentLineCZP.ReadIsolation := IsolationLevel::ReadCommitted;
        if CashDocumentLineCZP.FindLast() then
            exit(CashDocumentLineCZP."Line No.");

        exit(AllocationCashDocumentLineCZP."Line No.");
    end;

    local procedure GetLineIncrement(CurrentLineNo: Integer; NextLineNo: Integer; LinesToInsert: Integer): Integer
    var
        Increment: Integer;
    begin
        Increment := Round((NextLineNo - CurrentLineNo) / LinesToInsert, 1);
        if Increment < LinesToInsert then
            exit(-1);

        if Increment >= 1000 then
            exit(1000);

        if Increment >= 100 then
            exit(100);

        if Increment >= 10 then
            exit(10);

        exit(Increment);
    end;

    internal procedure VerifyAllocationAccount(var AllocationAccount: Record "Allocation Account")
    var
        AllocAccountDistribution: Record "Alloc. Account Distribution";
    begin
        AllocationAccount.TestField("Document Lines Split", AllocationAccount."Document Lines Split"::"Split Amount");
        AllocAccountDistribution.SetRange("Allocation Account No.", AllocationAccount."No.");
        AllocAccountDistribution.SetFilter("Destination Account Type", '<>%1&<>%2',
            AllocAccountDistribution."Destination Account Type"::"G/L Account",
            AllocAccountDistribution."Destination Account Type"::"Inherit from Parent");
        if not AllocAccountDistribution.IsEmpty() then
            Error(AllocationAccountMustOnlyDistributeToGLAccountsErr);
    end;

    local procedure TransferDimensionSetID(var CashDocumentLineCZP: Record "Cash Document Line CZP"; var AllocationLine: Record "Allocation Line"; ModifiedByUser: Boolean)
    var
        DimensionManagement: Codeunit DimensionManagement;
        DimensionSetIDArr: array[10] of Integer;
    begin
        if AllocationLine."Dimension Set ID" = 0 then
            exit;

        if CashDocumentLineCZP."Dimension Set ID" = AllocationLine."Dimension Set ID" then
            exit;

        if (CashDocumentLineCZP."Dimension Set ID" = 0) or ModifiedByUser then begin
            CashDocumentLineCZP."Dimension Set ID" := AllocationLine."Dimension Set ID";
            DimensionManagement.UpdateGlobalDimFromDimSetID(
              CashDocumentLineCZP."Dimension Set ID", CashDocumentLineCZP."Shortcut Dimension 1 Code", CashDocumentLineCZP."Shortcut Dimension 2 Code");

            exit;
        end;

        DimensionSetIDArr[1] := CashDocumentLineCZP."Dimension Set ID";
        DimensionSetIDArr[2] := AllocationLine."Dimension Set ID";
        CashDocumentLineCZP."Dimension Set ID" :=
          DimensionManagement.GetCombinedDimensionSetID(
            DimensionSetIDArr, CashDocumentLineCZP."Shortcut Dimension 1 Code", CashDocumentLineCZP."Shortcut Dimension 2 Code");
    end;

    local procedure VerifyCashDocumentLines(var AllocationAccountCashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
        AllocationAccountCashDocumentLineCZP.ReadIsolation := IsolationLevel::ReadCommitted;
        if not AllocationAccountCashDocumentLineCZP.FindSet() then
            exit;

        repeat
            VerifyCashDocumentLine(AllocationAccountCashDocumentLineCZP);
        until AllocationAccountCashDocumentLineCZP.Next() = 0;
    end;

    internal procedure VerifySelectedAllocationAccountNo(var AllocationAccountCashDocumentLineCZP: Record "Cash Document Line CZP")
    var
        AllocationAccount: Record "Allocation Account";
    begin
        if AllocationAccountCashDocumentLineCZP."Selected Alloc. Account No." = '' then
            exit;

        if not (AllocationAccountCashDocumentLineCZP."Account Type" = AllocationAccountCashDocumentLineCZP."Account Type"::"G/L Account") then
            Error(InvalidAccountTypeForInheritFromParentErr, AllocationAccountCashDocumentLineCZP."Account Type");

        AllocationAccount.Get(AllocationAccountCashDocumentLineCZP."Selected Alloc. Account No.");
        VerifyAllocationAccount(AllocationAccount);
    end;

    local procedure GetDescriptionChanged(ExistingDescription: Text; AccountType: Enum "Cash Document Account Type CZP"; AccountNo: Code[20]): Boolean
    var
        GLAccount: Record "G/L Account";
        AllocationAccount: Record "Allocation Account";
        ExpectedDescription: Text;
    begin
        case AccountType of
            AccountType::"G/L Account":
                begin
                    if not GLAccount.Get(AccountNo) then
                        exit(false);

                    ExpectedDescription := GLAccount.Name;
                end;
            AccountType::"Allocation Account":
                begin
                    if not AllocationAccount.Get(AccountNo) then
                        exit(false);

                    ExpectedDescription := AllocationAccount.Name;
                end;
            else
                exit(false);
        end;

        exit(ExistingDescription <> ExpectedDescription);
    end;

    local procedure VerifyCashDocumentLine(var CashDocumentLineCZP: Record "Cash Document Line CZP")
    var
        AllocationAccount: Record "Allocation Account";
        AllocationAccountMgt: Codeunit "Allocation Account Mgt.";
    begin
        if not AllocationAccountUsed(CashDocumentLineCZP) then
            exit;

        OnBeforeVerifyCashDocumentLine(CashDocumentLineCZP);
        if CashDocumentLineCZP."Selected Alloc. Account No." <> '' then
            VerifySelectedAllocationAccountNo(CashDocumentLineCZP)
        else begin
            if CashDocumentLineCZP."Account No." = '' then
                exit;

            AllocationAccount.Get(CashDocumentLineCZP."Account No.");
            VerifyAllocationAccount(AllocationAccount);
            AllocationAccountMgt.VerifyNoInheritFromParentUsed(AllocationAccount."No.");
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateCashDocumentLine(var CashDocumentLineCZP: Record "Cash Document Line CZP"; var AllocationLine: Record "Allocation Line"; var AllocationCashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeVerifyCashDocumentLine(var CashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
    end;

    var
        AllocationAccountMustOnlyDistributeToGLAccountsErr: Label 'The allocation account must contain G/L accounts as distribution accounts.';
        CannotGetAllocationAccountFromLineErr: Label 'Cannot get allocation account from Cash Document line %1.', Comment = '%1 - Line No., it is an integer that identifies the line e.g. 10000, 200000.';
        NoLinesGeneratedLbl: Label 'No allocation account lines were generated for Cash Document line %1.', Comment = '%1 - Unique identification of the line.';
        ChangeDimensionsOnAllocationDistributionsQst: Label 'The line is connected to the Allocation Account. Any dimensions that you change through this action will be merged with dimensions that are defined on the Allocation Line. To change the final dimensions you should invoke the Redistribute Account Allocations action.\\Do you want to continue?';
        DeleteManualOverridesQst: Label 'Modifying the line will delete all manual overrides for allocation account.\\Do you want to continue?';
        InvalidAccountTypeForInheritFromParentErr: Label 'Selected account type - %1 cannot be used for allocation accounts that have inherit from parent defined.', Comment = '%1 - Account type, e.g. G/L Account, Customer, Vendor, Bank Account, Fixed Asset, Item, Resource, Charge, Project, or Blank.';
        MustProvideAccountNoForInheritFromParentErr: Label 'You must provide an account number for allocation account with inherit from parent defined.';
        ReplaceAllocationLinesBeforeSendingToApprovalErr: Label 'You must replace allocation lines before sending the document to approval.';
        ReplaceAllocationLinesBeforeSendingToApprovalQst: Label 'Document contains allocation lines.\\Do you want to replace them before sending the document to approval?';
}
