codeunit 31351 "Export Launcher SEPA CZB"
{
    TableNo = "Iss. Payment Order Header CZB";

    trigger OnRun()
    var
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        IssPaymentOrderHeaderCZB.Copy(Rec);

        BankAccount.Get(IssPaymentOrderHeaderCZB."Bank Account No.");
        BankAccount.TestField("Payment Jnl. Template Name CZB");
        BankAccount.TestField("Payment Jnl. Batch Name CZB");

        GenJournalLine.SetRange("Journal Template Name", BankAccount."Payment Jnl. Template Name CZB");
        GenJournalLine.SetRange("Journal Batch Name", BankAccount."Payment Jnl. Batch Name CZB");
        GenJournalLine.SetRange("Document No.", IssPaymentOrderHeaderCZB."No.");
        if not GenJournalLine.IsEmpty() then
            GenJournalLine.DeleteAll(true);

        IssPaymentOrderHeaderCZB.CreatePaymentJournal(BankAccount."Payment Jnl. Template Name CZB", BankAccount."Payment Jnl. Batch Name CZB");

        GenJournalLine.FindFirst();
        Commit();

        if not Codeunit.Run(Codeunit::"SEPA CT-Export File", GenJournalLine) then begin
            Page.Run(Page::"Payment Journal", GenJournalLine);
            Error(GetLastErrorText);
        end;

        GenJournalLine.DeleteAll(true);
    end;
}
