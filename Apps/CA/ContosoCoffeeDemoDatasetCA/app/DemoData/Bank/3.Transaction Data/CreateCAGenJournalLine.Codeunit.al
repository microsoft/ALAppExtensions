codeunit 27025 "Create CA Gen. Journal Line"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateGeneralJournalLine();
    end;

    local procedure UpdateGeneralJournalLine()
    var
        GenJournalLine: Record "Gen. Journal Line";
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateBankJnlBatch: Codeunit "Create Bank Jnl. Batches";
    begin
        GenJournalLine.SetRange("Journal Template Name", CreateGenJournalTemplate.General());
        GenJournalLine.SetRange("Journal Batch Name", CreateBankJnlBatch.Daily());
        if GenJournalLine.FindSet() then
            repeat
                case GenJournalLine."Line No." of
                    10000:
                        GenJournalLine.Validate(Amount, -4121.95);
                    20000:
                        GenJournalLine.Validate(Amount, -6182.93);
                    30000,
                    40000:
                        begin
                            GenJournalLine.Validate(Amount, -8243.90);
                            GenJournalLine.Validate(Description, DeposittoAccountLbl);
                        end;
                end;

                GenJournalLine.Modify(true);
            until GenJournalLine.Next() = 0;
    end;

    var
        DeposittoAccountLbl: Label 'Deposit to Account 24-01-18', MaxLength = 100;
}