// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.HumanResources.Employee;
using Microsoft.Intercompany.Partner;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

codeunit 31431 "Reconciliation Handler CZL"
{
    [EventSubscriber(ObjectType::Page, Page::Reconciliation, 'OnAfterSetGenJnlLine', '', false, false)]
    local procedure OnAfterSetGenJnlLine(var GLAccountNetChange: Record "G/L Account Net Change"; var GenJnlLine: Record "Gen. Journal Line")
    var
        GenJnlAlloccation: Record "Gen. Jnl. Allocation";
    begin
        GLAccountNetChange.DeleteAll();
        if GenJnlLine.FindSet() then
            repeat
                SaveNetChange(GLAccountNetChange, GenJnlLine,
                  GenJnlLine."Account Type", GenJnlLine."Account No.",
                  GenJnlLine."Amount (LCY)", GenJnlLine."VAT Amount (LCY)", GenJnlLine."Amount", GenJnlLine."VAT Amount");
                SaveNetChange(GLAccountNetChange, GenJnlLine,
                  GenJnlLine."Bal. Account Type", GenJnlLine."Bal. Account No.",
                  -GenJnlLine."Amount (LCY)", GenJnlLine."Bal. VAT Amount (LCY)", -GenJnlLine."Amount", GenJnlLine."Bal. VAT Amount");
                GenJnlAlloccation.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
                GenJnlAlloccation.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
                GenJnlAlloccation.SetRange("Journal Line No.", GenJnlLine."Line No.");
                if GenJnlAlloccation.FindSet() then
                    repeat
                        SaveNetChange(GLAccountNetChange, GenJnlLine,
                          GenJnlLine."Account Type"::"G/L Account", GenJnlAlloccation."Account No.",
                          GenJnlAlloccation.Amount, GenJnlAlloccation."VAT Amount", GenJnlAlloccation."Amount", GenJnlAlloccation."VAT Amount");
                    until GenJnlAlloccation.Next() = 0;
            until GenJnlLine.Next() = 0;

        GLAccountNetChange.Reset();
        GLAccountNetChange.SetCurrentKey("Account Type CZL", "Account No. CZL");
    end;

    local procedure SaveNetChange(var GLAccountNetChange: Record "G/L Account Net Change"; GenJournalLine: Record "Gen. Journal Line";
                                  GenJournalAccountType: Enum "Gen. Journal Account Type"; AccNo: Code[20]; AmountLCY: Decimal; VATAmountLCY: Decimal; Amount: Decimal; VATAmount: Decimal)
    var
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        BankAccount: Record "Bank Account";
        FixedAsset: Record "Fixed Asset";
        ICPartner: Record "IC Partner";
        Employee: Record Employee;
        NetChangeLCY: Decimal;
        NetChange: Decimal;
    begin
        if AccNo = '' then
            exit;
        NetChangeLCY := AmountLCY - VATAmountLCY;
        NetChange := Amount - VATAmount;

        GLAccountNetChange.SetCurrentKey("Account Type CZL", "Account No. CZL");
        GLAccountNetChange.SetRange("Account Type CZL", GenJournalAccountType);
        GLAccountNetChange.SetRange("Account No. CZL", AccNo);
        if GLAccountNetChange.FindFirst() then begin
            GLAccountNetChange."Net Change in Jnl." += NetChangeLCY;
            GLAccountNetChange."Balance after Posting" += NetChangeLCY;
            if (GenJournalAccountType = GenJournalAccountType::"Bank Account") and (GenJournalLine."Currency Code" <> '') then begin
                GLAccountNetChange."Net Change in Jnl. Curr. CZL" += NetChange;
                GLAccountNetChange."Balance after Posting Curr.CZL" += NetChange;
            end;
            GLAccountNetChange.Modify();
        end else begin
            GLAccountNetChange.Reset();
            GLAccountNetChange.Init();
            GLAccountNetChange."No." := Format(GLAccountNetChange.Count() + 1);
            GLAccountNetChange."Account Type CZL" := GenJournalAccountType;
            GLAccountNetChange."Account No. CZL" := AccNo;
            GLAccountNetChange."Net Change in Jnl." := NetChangeLCY;
            case GenJournalAccountType of
                GenJournalLine."Account Type"::"G/L Account":
                    begin
                        GLAccount.Get(AccNo);
                        GLAccountNetChange.Name := GLAccount.Name;
                        GLAccount.CalcFields("Balance at Date");
                        GLAccountNetChange."Balance after Posting" := GLAccount."Balance at Date" + NetChangeLCY;
                    end;
                GenJournalLine."Account Type"::Customer:
                    begin
                        Customer.Get(AccNo);
                        GLAccountNetChange.Name := Customer.Name;
                        Customer.CalcFields("Balance (LCY)");
                        GLAccountNetChange."Balance after Posting" := Customer."Balance (LCY)" + NetChangeLCY;
                    end;
                GenJournalLine."Account Type"::Vendor:
                    begin
                        Vendor.Get(AccNo);
                        GLAccountNetChange.Name := Vendor.Name;
                        Vendor.CalcFields("Balance (LCY)");
                        GLAccountNetChange."Balance after Posting" := -Vendor."Balance (LCY)" + NetChangeLCY;
                    end;
                GenJournalLine."Account Type"::"Bank Account":
                    begin
                        BankAccount.Get(AccNo);
                        GLAccountNetChange.Name := BankAccount.Name;
                        BankAccount.CalcFields("Balance (LCY)", Balance);
                        GLAccountNetChange."Balance after Posting" := BankAccount."Balance (LCY)" + NetChangeLCY;
                        if (GenJournalLine."Currency Code" <> '') then begin
                            GLAccountNetChange."Currency Code CZL" := BankAccount."Currency Code";
                            GLAccountNetChange."Balance after Posting Curr.CZL" := BankAccount.Balance + NetChange;
                            GLAccountNetChange."Net Change in Jnl. Curr. CZL" := NetChange;
                        end;
                    end;
                GenJournalLine."Account Type"::"Fixed Asset":
                    begin
                        FixedAsset.Get(AccNo);
                        GLAccountNetChange.Name := FixedAsset.Description;
                    end;
                GenJournalLine."Account Type"::"IC Partner":
                    begin
                        ICPartner.Get(AccNo);
                        GLAccountNetChange.Name := ICPartner.Name;
                    end;
                GenJournalLine."Account Type"::Employee:
                    begin
                        Employee.Get(AccNo);
                        GLAccountNetChange.Name := CopyStr(Employee.FullName(), 1, MaxStrLen(GLAccountNetChange.Name));
                        Employee.CalcFields(Balance);
                        GLAccountNetChange."Balance after Posting" := -Employee.Balance + NetChangeLCY;
                    end;
            end;
            GLAccountNetChange.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::Reconciliation, 'OnBeforeSaveNetChange', '', false, false)]
    local procedure OnBeforeSaveNetChange(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
}
