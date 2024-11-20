codeunit 17147 "Create NZ Gen. Journal Line"
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
                        GenJournalLine.Validate(Amount, -6132.62);
                    20000:
                        GenJournalLine.Validate(Amount, -9198.93);
                    30000:
                        GenJournalLine.Validate(Amount, -12265.24);
                    40000:
                        GenJournalLine.Validate(Amount, -12265.24);
                end;

                GenJournalLine.Modify();
            until GenJournalLine.Next() = 0;
    end;
}