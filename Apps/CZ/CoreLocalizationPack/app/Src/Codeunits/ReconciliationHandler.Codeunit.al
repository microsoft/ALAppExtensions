#if not CLEAN18
#pragma warning disable AL0432
#endif
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
                  GenJnlLine."Amount (LCY)", GenJnlLine."VAT Amount (LCY)");
                SaveNetChange(GLAccountNetChange, GenJnlLine,
                  GenJnlLine."Bal. Account Type", GenJnlLine."Bal. Account No.",
                  -GenJnlLine."Amount (LCY)", GenJnlLine."Bal. VAT Amount (LCY)");
                GenJnlAlloccation.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
                GenJnlAlloccation.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
                GenJnlAlloccation.SetRange("Journal Line No.", GenJnlLine."Line No.");
                if GenJnlAlloccation.FindSet() then
                    repeat
                        SaveNetChange(GLAccountNetChange, GenJnlLine,
                          GenJnlLine."Account Type"::"G/L Account", GenJnlAlloccation."Account No.",
                          GenJnlAlloccation.Amount, GenJnlAlloccation."VAT Amount");
                    until GenJnlAlloccation.Next() = 0;
            until GenJnlLine.Next() = 0;

        GLAccountNetChange.Reset();
        GLAccountNetChange.SetCurrentKey("Account Type CZL", "Account No. CZL");
    end;

    local procedure SaveNetChange(var GLAccountNetChange: Record "G/L Account Net Change"; GenJournalLine: Record "Gen. Journal Line";
                                  GenJournalAccountType: Enum "Gen. Journal Account Type"; AccNo: Code[20]; Amount: Decimal; VATAmount: Decimal)
    var
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        BankAccount: Record "Bank Account";
        FixedAsset: Record "Fixed Asset";
        ICPartner: Record "IC Partner";
        Employee: Record Employee;
        NetChange: Decimal;
    begin
        if AccNo = '' then
            exit;
        NetChange := Amount - VATAmount;

        GLAccountNetChange.SetCurrentKey("Account Type CZL", "Account No. CZL");
        GLAccountNetChange.SetRange("Account Type CZL", GenJournalAccountType);
        GLAccountNetChange.SetRange("Account No. CZL", AccNo);
        if GLAccountNetChange.FindFirst() then begin
            GLAccountNetChange."Net Change in Jnl." += NetChange;
            GLAccountNetChange."Balance after Posting" += NetChange;
            GLAccountNetChange.Modify();
        end else begin
            GLAccountNetChange.Reset();
            GLAccountNetChange.Init();
            GLAccountNetChange."No." := Format(GLAccountNetChange.Count() + 1);
            GLAccountNetChange."Account Type CZL" := GenJournalAccountType;
            GLAccountNetChange."Account No. CZL" := AccNo;
            GLAccountNetChange."Net Change in Jnl." := NetChange;
            case GenJournalAccountType of
                GenJournalLine."Account Type"::"G/L Account":
                    begin
                        GLAccount.Get(AccNo);
                        GLAccountNetChange.Name := GLAccount.Name;
                        GLAccount.CalcFields("Balance at Date");
                        GLAccountNetChange."Balance after Posting" := GLAccount."Balance at Date" + NetChange;
                    end;
                GenJournalLine."Account Type"::Customer:
                    begin
                        Customer.Get(AccNo);
                        GLAccountNetChange.Name := Customer.Name;
                        Customer.CalcFields("Balance (LCY)");
                        GLAccountNetChange."Balance after Posting" := Customer."Balance (LCY)" + NetChange;
                    end;
                GenJournalLine."Account Type"::Vendor:
                    begin
                        Vendor.Get(AccNo);
                        GLAccountNetChange.Name := Vendor.Name;
                        Vendor.CalcFields("Balance (LCY)");
                        GLAccountNetChange."Balance after Posting" := -Vendor."Balance (LCY)" + NetChange;
                    end;
                GenJournalLine."Account Type"::"Bank Account":
                    begin
                        BankAccount.Get(AccNo);
                        GLAccountNetChange.Name := BankAccount.Name;
                        BankAccount.CalcFields("Balance (LCY)");
                        GLAccountNetChange."Balance after Posting" := BankAccount."Balance (LCY)" + NetChange;
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
                        GLAccountNetChange."Balance after Posting" := -Employee.Balance + NetChange;
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
