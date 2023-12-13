// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Security.User;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.FixedAssets.Insurance;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Projects.Project.Journal;
using Microsoft.Projects.Resources.Journal;

codeunit 31072 "User Setup Adv. Management CZL"
{
    Permissions = tabledata "User Setup" = m;
    TableNo = "User Setup";

    trigger OnRun()
    begin
        Rec.Modify();
    end;

    var
        Item: Record Item;
        UserSetup: Record "User Setup";
        JournalPermErr: Label 'Access to journal %1 is not allowed in extended user check.', Comment = '%1 = journal template code';
        ReqWkshPermErr: Label 'Access to worksheet %1 is not allowed in extended user check.', Comment = '%1 = journal template code';
        VATStmtPermErr: Label 'Access to statement %1 is not allowed in extended user check.', Comment = '%1 = journal template code';

    [TryFunction]
    procedure CheckJournalTemplate(Type: Enum "User Setup Line Type CZL"; JournalTemplateCode: Code[10])
    var
        UserSetupLineCZL: Record "User Setup Line CZL";
    begin
        if not IsCheckAllowed() then
            exit;

        GetUserSetup();
        if not UserSetup."Check Journal Templates CZL" then
            exit;

        if not CheckUserSetupLineCZL(UserSetup."User ID", Type, JournalTemplateCode) then
            case Type of
                UserSetupLineCZL.Type::"Req. Worksheet":
                    Error(ReqWkshPermErr, JournalTemplateCode);
                UserSetupLineCZL.Type::"VAT Statement":
                    Error(VATStmtPermErr, JournalTemplateCode);
                else
                    Error(JournalPermErr, JournalTemplateCode);
            end;
    end;

    [TryFunction]
    procedure CheckGeneralJournalLine(GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."Document Date" <> 0D then begin
            if not CheckWorkDocDate(GenJournalLine."Document Date") then
                GenJournalLine.TestField("Document Date", WorkDate());
            if not CheckSysDocDate(GenJournalLine."Document Date") then
                GenJournalLine.TestField("Document Date", Today);
        end;
        if not CheckWorkPostingDate(GenJournalLine."Posting Date") then
            GenJournalLine.TestField("Posting Date", WorkDate());
        if not CheckSysPostingDate(GenJournalLine."Posting Date") then
            GenJournalLine.TestField("Posting Date", Today);

        // Bank Account checks
        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account") and (GenJournalLine."Account No." <> '') then
            if not CheckBankAccount(GenJournalLine."Account No.") then
                GenJournalLine.FieldError("Account No.");
        if (GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Bank Account") and (GenJournalLine."Bal. Account No." <> '') then
            if not CheckBankAccount(GenJournalLine."Bal. Account No.") then
                GenJournalLine.FieldError("Bal. Account No.");
    end;

    [TryFunction]
    procedure CheckItemJournalLine(ItemJournalLine: Record "Item Journal Line")
    begin
        if not CheckWorkDocDate(ItemJournalLine."Document Date") then
            ItemJournalLine.TestField("Document Date", WorkDate());
        if not CheckSysDocDate(ItemJournalLine."Document Date") then
            ItemJournalLine.TestField("Document Date", Today);
        if not CheckWorkPostingDate(ItemJournalLine."Posting Date") then
            ItemJournalLine.TestField("Posting Date", WorkDate());
        if not CheckSysPostingDate(ItemJournalLine."Posting Date") then
            ItemJournalLine.TestField("Posting Date", Today);

        // Location checks
        if ItemJournalLine."Value Entry Type" <> ItemJournalLine."Value Entry Type"::Revaluation then begin
            if not Item.Get(ItemJournalLine."Item No.") then
                Item.Init();
            case ItemJournalLine."Entry Type" of
                ItemJournalLine."Entry Type"::Purchase, ItemJournalLine."Entry Type"::"Positive Adjmt.", ItemJournalLine."Entry Type"::Output:
                    if ItemJournalLine.Quantity > 0 then begin
                        if not CheckLocQuantityIncrease(ItemJournalLine."Location Code") then
                            ItemJournalLine.FieldError("Location Code")
                    end else
                        if ItemJournalLine.Quantity < 0 then
                            if not CheckLocQuantityDecrease(ItemJournalLine."Location Code") then
                                ItemJournalLine.FieldError("Location Code");
                ItemJournalLine."Entry Type"::Sale, ItemJournalLine."Entry Type"::"Negative Adjmt.", ItemJournalLine."Entry Type"::Consumption:
                    if ItemJournalLine.Quantity > 0 then begin
                        if not CheckLocQuantityDecrease(ItemJournalLine."Location Code") then
                            ItemJournalLine.FieldError("Location Code")
                    end else
                        if ItemJournalLine.Quantity < 0 then
                            if not CheckLocQuantityIncrease(ItemJournalLine."Location Code") then
                                ItemJournalLine.FieldError("Location Code");
                ItemJournalLine."Entry Type"::Transfer:
                    begin
                        if not CheckLocQuantityDecrease(ItemJournalLine."Location Code") then
                            ItemJournalLine.FieldError("Location Code");
                        if not CheckLocQuantityIncrease(ItemJournalLine."New Location Code") then
                            ItemJournalLine.FieldError("New Location Code");
                    end;
            end;

            if not CheckWhseNetChangeTemplate(ItemJournalLine) then
                ItemJournalLine.FieldError("Invt. Movement Template CZL");
        end;
    end;

    [TryFunction]
    procedure CheckJobJournalLine(JobJournalLine: Record "Job Journal Line")
    begin
        if not CheckWorkDocDate(JobJournalLine."Document Date") then
            JobJournalLine.TestField("Document Date", WorkDate());
        if not CheckSysDocDate(JobJournalLine."Document Date") then
            JobJournalLine.TestField("Document Date", Today);
        if not CheckWorkPostingDate(JobJournalLine."Posting Date") then
            JobJournalLine.TestField("Posting Date", WorkDate());
        if not CheckSysPostingDate(JobJournalLine."Posting Date") then
            JobJournalLine.TestField("Posting Date", Today);
    end;

    [TryFunction]
    procedure CheckResJournalLine(ResJournalLine: Record "Res. Journal Line")
    begin
        if not CheckWorkDocDate(ResJournalLine."Document Date") then
            ResJournalLine.TestField("Document Date", WorkDate());
        if not CheckSysDocDate(ResJournalLine."Document Date") then
            ResJournalLine.TestField("Document Date", Today);
        if not CheckWorkPostingDate(ResJournalLine."Posting Date") then
            ResJournalLine.TestField("Posting Date", WorkDate());
        if not CheckSysPostingDate(ResJournalLine."Posting Date") then
            ResJournalLine.TestField("Posting Date", Today);
    end;

    [TryFunction]
    procedure CheckInsuranceJournalLine(InsuranceJournalLine: Record "Insurance Journal Line")
    begin
        if not CheckWorkDocDate(InsuranceJournalLine."Document Date") then
            InsuranceJournalLine.TestField("Document Date", WorkDate());
        if not CheckSysDocDate(InsuranceJournalLine."Document Date") then
            InsuranceJournalLine.TestField("Document Date", Today);
        if not CheckWorkPostingDate(InsuranceJournalLine."Posting Date") then
            InsuranceJournalLine.TestField("Posting Date", WorkDate());
        if not CheckSysPostingDate(InsuranceJournalLine."Posting Date") then
            InsuranceJournalLine.TestField("Posting Date", Today);
    end;

    procedure CheckWorkDocDate(Date: Date): Boolean
    begin
        GetUserSetup();
        if not UserSetup."Check Doc. Date(work date) CZL" then
            exit(true);
        exit(Date = WorkDate());
    end;

    procedure CheckSysDocDate(Date: Date): Boolean
    begin
        GetUserSetup();
        if not UserSetup."Check Doc. Date(sys. date) CZL" then
            exit(true);
        exit(Date = Today);
    end;

    procedure CheckWorkPostingDate(Date: Date): Boolean
    begin
        GetUserSetup();
        if not UserSetup."Check Post.Date(work date) CZL" then
            exit(true);
        exit(Date = WorkDate());
    end;

    procedure CheckSysPostingDate(Date: Date): Boolean
    begin
        GetUserSetup();
        if not UserSetup."Check Post.Date(sys. date) CZL" then
            exit(true);
        exit(Date = Today);
    end;

    procedure CheckLocQuantityIncrease(LocationCode: Code[10]): Boolean
    var
        UserSetupLineCZL: Record "User Setup Line CZL";
    begin
        GetUserSetup();
        if not UserSetup."Check Location Code CZL" then
            exit(true);

        if Item.IsNonInventoriableType() then
            exit(true);

        exit(CheckUserSetupLineCZL(UserSetup."User ID", UserSetupLineCZL.Type::"Location (quantity increase)", LocationCode));
    end;

    procedure CheckLocQuantityDecrease(LocationCode: Code[10]): Boolean
    var
        UserSetupLineCZL: Record "User Setup Line CZL";
    begin
        GetUserSetup();
        if not UserSetup."Check Location Code CZL" then
            exit(true);

        if Item.IsNonInventoriableType() then
            exit(true);

        exit(CheckUserSetupLineCZL(UserSetup."User ID", UserSetupLineCZL.Type::"Location (quantity decrease)", LocationCode));
    end;

    procedure CheckBankAccount(BankAcc: Code[20]): Boolean
    var
        UserSetupLineCZL: Record "User Setup Line CZL";
    begin
        GetUserSetup();
        if not UserSetup."Check Bank Accounts CZL" then
            exit(true);

        exit(CheckUserSetupLineCZL(UserSetup."User ID", UserSetupLineCZL.Type::"Bank Account", BankAcc));
    end;

    procedure CheckFiscalYear(GLEntry: Record "G/L Entry"): Boolean
    begin
        GetUserSetup();
        if not UserSetup."Allow Post.toClosed Period CZL" then
            GLEntry.TestField("Prior-Year Entry", false);
        exit(true);
    end;

    procedure CheckItemUnapply()
    begin
        GetUserSetup();
        UserSetup.TestField("Allow Item Unapply CZL", true);
    end;

    procedure SelectDimensionsToCheck(UserSetup2: Record "User Setup")
    var
        Dimension: Record Dimension;
        TempDimensionSelectionBuffer: Record "Dimension Selection Buffer" temporary;
        SelectedDimension: Record "Selected Dimension";
        DimensionSelectionChange: Page "Dimension Selection-Change";
    begin
        Clear(DimensionSelectionChange);
        if Dimension.FindSet() then
            repeat
                DimensionSelectionChange.InsertDimSelBuf(
                  SelectedDimension.Get(UserSetup2."User ID", 1, DATABASE::"User Setup", '', Dimension.Code),
                  Dimension.Code, Dimension.GetMLName(GlobalLanguage),
                  SelectedDimension."New Dimension Value Code",
                  SelectedDimension."Dimension Value Filter");
            until Dimension.Next() = 0;

        DimensionSelectionChange.LookupMode := true;
        if DimensionSelectionChange.RunModal() = ACTION::LookupOK then begin
            DimensionSelectionChange.GetDimSelBuf(TempDimensionSelectionBuffer);
            // Set Dimension Selection
            SelectedDimension.SetRange("User ID", UserSetup2."User ID");
            SelectedDimension.SetRange("Object Type", 1);
            SelectedDimension.SetRange("Object ID", DATABASE::"User Setup");
            SelectedDimension.SetRange("Analysis View Code", '');
            SelectedDimension.DeleteAll();
            TempDimensionSelectionBuffer.SetCurrentKey(Level, Code);
            TempDimensionSelectionBuffer.SetRange(Selected, true);
            if TempDimensionSelectionBuffer.FindSet() then
                repeat
                    SelectedDimension."User ID" := UserSetup2."User ID";
                    SelectedDimension."Object Type" := 1;
                    SelectedDimension."Object ID" := DATABASE::"User Setup";
                    SelectedDimension."Analysis View Code" := '';
                    SelectedDimension."Dimension Code" := TempDimensionSelectionBuffer.Code;
                    SelectedDimension."New Dimension Value Code" := TempDimensionSelectionBuffer."New Dimension Value Code";
                    SelectedDimension."Dimension Value Filter" := TempDimensionSelectionBuffer."Dimension Value Filter";
                    SelectedDimension.Level := TempDimensionSelectionBuffer.Level;
                    SelectedDimension.Insert();
                until TempDimensionSelectionBuffer.Next() = 0;
        end;
    end;

    [TryFunction]
    procedure GetUserSetup()
    var
        TempUserID: Code[50];
    begin
        TempUserID := GetUserID();
        if UserSetup."User ID" <> TempUserID then
            UserSetup.Get(TempUserID);
    end;

    procedure GetUserID() TempUserID: Code[50]
    begin
        TempUserID := CopyStr(UserId, 1, MaxStrLen(TempUserID));
    end;

    procedure CheckWhseNetChangeTemplate(var ItemJournalLine: Record "Item Journal Line"): Boolean
    var
        UserSetupLineCZL: Record "User Setup Line CZL";
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        if (ItemJournalLine."Source Type" = ItemJournalLine."Source Type"::Customer) or
           (ItemJournalLine."Source Type" = ItemJournalLine."Source Type"::Vendor) or
           (ItemJournalLine."Source Type" = ItemJournalLine."Source Type"::Item) or
           (ItemJournalLine."Order No." <> '') or
           ItemJournalLine.Correction or
           ItemJournalLine.Adjustment
        then
            exit(true);

        if ItemJournalTemplate.Get(ItemJournalLine."Journal Template Name") then
            if ItemJournalTemplate.Type = ItemJournalTemplate.Type::Revaluation then
                exit(true);

        GetUserSetup();
        if not UserSetup."Check Invt. Movement Temp. CZL" then
            exit(true);

        exit(
          CheckUserSetupLineCZL(
            UserSetup."User ID",
            UserSetupLineCZL.Type::"Invt. Movement Templates",
            ItemJournalLine."Invt. Movement Template CZL"));
    end;

    procedure CheckReleasLocQuantityIncrease(LocationCode: Code[10]): Boolean
    var
        UserSetupLineCZL: Record "User Setup Line CZL";
    begin
        GetUserSetup();
        if not UserSetup."Check Release LocationCode CZL" then
            exit(true);

        if Item.IsNonInventoriableType() then
            exit(true);

        exit(CheckUserSetupLineCZL(UserSetup."User ID", UserSetupLineCZL.Type::"Release Location (quantity increase)", LocationCode));
    end;

    procedure CheckReleasLocQuantityDecrease(LocationCode: Code[10]): Boolean
    var
        UserSetupLineCZL: Record "User Setup Line CZL";
    begin
        GetUserSetup();
        if not UserSetup."Check Release LocationCode CZL" then
            exit(true);

        if Item.IsNonInventoriableType() then
            exit(true);

        exit(CheckUserSetupLineCZL(UserSetup."User ID", UserSetupLineCZL.Type::"Release Location (quantity decrease)", LocationCode));
    end;

    procedure CheckUserSetupLineCZL(UserCode: Code[50]; Type: Enum "User Setup Line Type CZL"; CodeName: Code[20]): Boolean
    var
        UserSetupLineCZL: Record "User Setup Line CZL";
    begin
        UserSetupLineCZL.SetRange("User ID", UserCode);
        UserSetupLineCZL.SetRange(Type, Type);
        UserSetupLineCZL.SetRange("Code / Name", CodeName);
        exit(not UserSetupLineCZL.IsEmpty())
    end;

    procedure IsCheckAllowed(): Boolean
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        exit(GeneralLedgerSetup."User Checks Allowed CZL");
    end;

    procedure SetItem(ItemNo: Code[20])
    begin
        if not Item.Get(ItemNo) then
            Item.Init();
    end;

    procedure CheckCompleteJob()
    begin
        GetUserSetup();
        UserSetup.TestField("Allow Complete Job CZL");
    end;

    procedure CheckVATDateChanging()
    begin
        GetUserSetup();
        UserSetup.TestField("Allow VAT Date Changing CZL");
    end;
}
