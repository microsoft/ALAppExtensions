codeunit 13452 "Create Gen. Journal Line FI"
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
                        GenJournalLine.Validate(Amount, -2757.62);
                    20000:
                        GenJournalLine.Validate(Amount, -4136.43);
                    30000,
                    40000:
                        begin
                            GenJournalLine.Validate(Amount, -5515.24);
                            GenJournalLine.Validate(Description, DeposittoAccountLbl);
                        end;
                end;

                GenJournalLine.Modify(true);
            until GenJournalLine.Next() = 0;
    end;

    var
        DeposittoAccountLbl: Label 'Deposit to Account 18.01.24', MaxLength = 100;
}