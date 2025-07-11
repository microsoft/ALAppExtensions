// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.HumanResources.Employee;
using Microsoft.Intercompany.Partner;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

tableextension 31047 "G/L Account Net Change CZL" extends "G/L Account Net Change"
{
    fields
    {
        field(31000; "Acc. Type CZL"; Enum "Net Change Account Type CZL")
        {
            Caption = 'Account Type';
            DataClassification = SystemMetadata;
        }
#if not CLEANSCHEMA30
        field(31001; "Account Type CZL"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Account Type (Obsolete)';
            DataClassification = SystemMetadata;
#if not CLEAN27
            ObsoleteState = Pending;
            ObsoleteTag = '27.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '30.0';
#endif
            ObsoleteReason = 'Replaced by "Acc. Type CZL" field.';
        }
#endif
        field(31002; "Account No. CZL"; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = SystemMetadata;
        }
        field(31005; "Net Change in Jnl. Curr. CZL"; Decimal)
        {
            AutoFormatExpression = "Currency Code CZL";
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Net Change in Jnl. (in Currency)';
            DataClassification = SystemMetadata;
        }
        field(31006; "Balance after Posting Curr.CZL"; Decimal)
        {
            AutoFormatExpression = "Currency Code CZL";
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Balance after Posting (in Currency)';
            DataClassification = SystemMetadata;
        }
        field(31007; "Currency Code CZL"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
#if not CLEAN27
        key(AccountTypeNoCZL; "Account Type CZL", "Account No. CZL")
        {
            ObsoleteState = Pending;
            ObsoleteTag = '27.0';
            ObsoleteReason = 'Replaced by "Acc. Type CZL" field.';
        }
#endif
        key(AccTypeNoCZL; "Acc. Type CZL", "Account No. CZL")
        {
        }
    }

    procedure SaveNetChangeCZL(GenJournalLine: Record "Gen. Journal Line")
    var
#if not CLEAN27
        ReconciliationHandler: Codeunit "Reconciliation Handler CZL";
#endif
        NetChangeLCY: Decimal;
        NetChange: Decimal;
    begin
        if GenJournalLine."Account No." = '' then
            exit;

        NetChangeLCY := GenJournalLine."Amount (LCY)" - GenJournalLine."VAT Amount (LCY)";
        NetChange := GenJournalLine."Amount" - GenJournalLine."VAT Amount";

        SetCurrentKey("Acc. Type CZL", "Account No. CZL");
        SetRange("Acc. Type CZL", GenJournalLine."Account Type");
        SetRange("Account No. CZL", GenJournalLine."Account No.");
        if FindFirst() then begin
            UpdateNetChange(NetChangeLCY, NetChange);
            OnSaveNetChangeCZLOnBeforeModify(Rec, GenJournalLine, NetChangeLCY, NetChange);
#if not CLEAN27
            ReconciliationHandler.RaiseOnSetSaveNetChangeBeforeModifyGLAccountNetChange(Rec, GenJournalLine, NetChangeLCY, NetChange);
#endif
            Modify();
        end else begin
            Reset();
            Init();
            "No." := Format(Count() + 1);
            CopyFrom(GenJournalLine);
            PopulateFromAccount();
            UpdateNetChange(NetChangeLCY, NetChange);
            OnSaveNetChangeCZLOnBeforeInsert(Rec, GenJournalLine, NetChangeLCY, NetChange);
#if not CLEAN27
            ReconciliationHandler.RaiseOnSetSaveNetChangeBeforeInsertGLAccountNetChange(Rec, GenJournalLine, NetChangeLCY, NetChange);
#endif
            Insert();
        end;
    end;

    internal procedure CopyFrom(GenJournalLine: Record "Gen. Journal Line")
    begin
        "Acc. Type CZL" := GenJournalLine."Account Type";
        "Account No. CZL" := GenJournalLine."Account No.";
        OnAfterCopyFrom(Rec, GenJournalLine);
    end;

    local procedure UpdateNetChange(NetChangeLCY: Decimal; NetChange: Decimal)
    begin
        "Net Change in Jnl." += NetChangeLCY;
        "Balance after Posting" += NetChangeLCY;
        if ("Acc. Type CZL" = "Acc. Type CZL"::"Bank Account") and ("Currency Code CZL" <> '') then begin
            "Net Change in Jnl. Curr. CZL" += NetChange;
            "Balance after Posting Curr.CZL" += NetChange;
        end;
        OnAfterUpdateNetChange(Rec, NetChangeLCY, NetChange);
    end;

    local procedure PopulateFromAccount()
    begin
        case "Acc. Type CZL" of
            "Acc. Type CZL"::"G/L Account":
                PopulateFromGLAccount();
            "Acc. Type CZL"::Customer:
                PopulateFromCustomer();
            "Acc. Type CZL"::Vendor:
                PopulateFromVendor();
            "Acc. Type CZL"::"Bank Account":
                PopulateFromBankAccount();
            "Acc. Type CZL"::"Fixed Asset":
                PopulateFromFixedAsset();
            "Acc. Type CZL"::"IC Partner":
                PopulateFromICPartner();
            "Acc. Type CZL"::Employee:
                PopulateFromEmployee();
            else
                OnPopulateFromAccountOnElse(Rec)
        end;
    end;

    local procedure PopulateFromGLAccount()
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Get("Account No. CZL");
        GLAccount.CalcFields("Balance at Date");
        Name := GLAccount.Name;
        "Balance after Posting" := GLAccount."Balance at Date";
        OnAfterPopulateFromGLAccount(Rec, GLAccount);
    end;

    local procedure PopulateFromCustomer()
    var
        Customer: Record Customer;
    begin
        Customer.Get("Account No. CZL");
        Customer.CalcFields("Balance (LCY)");
        Name := Customer.Name;
        "Balance after Posting" := Customer."Balance (LCY)";
        OnAfterPopulateFromCustomer(Rec, Customer);
    end;

    local procedure PopulateFromVendor()
    var
        Vendor: Record Vendor;
    begin
        Vendor.Get("Account No. CZL");
        Vendor.CalcFields("Balance (LCY)");
        Name := Vendor.Name;
        "Balance after Posting" := -Vendor."Balance (LCY)";
        OnAfterPopulateFromVendor(Rec, Vendor);
    end;

    local procedure PopulateFromBankAccount()
    var
        BankAccount: Record "Bank Account";
    begin
        BankAccount.Get("Account No. CZL");
        BankAccount.CalcFields("Balance (LCY)", Balance);
        Name := BankAccount.Name;
        "Balance after Posting" := BankAccount."Balance (LCY)";
        if BankAccount."Currency Code" <> '' then begin
            "Currency Code CZL" := BankAccount."Currency Code";
            "Balance after Posting Curr.CZL" := BankAccount.Balance;
        end;
        OnAfterPopulateFromBankAccount(Rec, BankAccount);
    end;

    local procedure PopulateFromFixedAsset()
    var
        FixedAsset: Record "Fixed Asset";
    begin
        FixedAsset.Get("Account No. CZL");
        Name := FixedAsset.Description;
        OnAfterPopulateFromFixedAsset(Rec, FixedAsset);
    end;

    local procedure PopulateFromICPartner()
    var
        ICPartner: Record "IC Partner";
    begin
        ICPartner.Get("Account No. CZL");
        Name := ICPartner.Name;
        OnAfterPopulateFromICPartner(Rec, ICPartner);
    end;

    local procedure PopulateFromEmployee()
    var
        Employee: Record Employee;
    begin
        Employee.Get("Account No. CZL");
        Name := Employee.FullName();
        "Balance after Posting" := -Employee.Balance;
        OnAfterPopulateFromEmployee(Rec, Employee);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateNetChange(var GLAccountNetChange: Record "G/L Account Net Change"; NetChangeLCY: Decimal; NetChange: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSaveNetChangeCZLOnBeforeModify(var GLAccountNetChange: Record "G/L Account Net Change"; GenJournalLine: Record "Gen. Journal Line"; NetChangeLCY: Decimal; NetChange: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSaveNetChangeCZLOnBeforeInsert(var GLAccountNetChange: Record "G/L Account Net Change"; GenJournalLine: Record "Gen. Journal Line"; NetChangeLCY: Decimal; NetChange: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPopulateFromGLAccount(var GLAccountNetChange: Record "G/L Account Net Change"; GLAccount: Record "G/L Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPopulateFromCustomer(var GLAccountNetChange: Record "G/L Account Net Change"; Customer: Record Customer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPopulateFromVendor(var GLAccountNetChange: Record "G/L Account Net Change"; Vendor: Record Vendor)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPopulateFromBankAccount(var GLAccountNetChange: Record "G/L Account Net Change"; BankAccount: Record "Bank Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPopulateFromFixedAsset(var GLAccountNetChange: Record "G/L Account Net Change"; FixedAsset: Record "Fixed Asset")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPopulateFromICPartner(var GLAccountNetChange: Record "G/L Account Net Change"; ICPartner: Record "IC Partner")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPopulateFromEmployee(var GLAccountNetChange: Record "G/L Account Net Change"; Employee: Record Employee)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFrom(var GLAccountNetChange: Record "G/L Account Net Change"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPopulateFromAccountOnElse(var GLAccountNetChange: Record "G/L Account Net Change")
    begin
    end;
}
