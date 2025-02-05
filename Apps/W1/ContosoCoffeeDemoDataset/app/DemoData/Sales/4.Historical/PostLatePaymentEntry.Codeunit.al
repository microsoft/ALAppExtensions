codeunit 5668 "Post Late Payment Entry"
{
    trigger OnRun()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        GenJournalLine: Record "Gen. Journal Line";
        GLAccount: Record "G/L Account";
        CreateSalesDocument: Codeunit "Create Sales Document";
    begin
        SalesInvoiceHeader.SetRange("Your Reference", CreateSalesDocument.LateYourReference());
        if SalesInvoiceHeader.FindSet() then
            repeat
                GenJournalLine.SetRange("Account No.", SalesInvoiceHeader."Bill-to Customer No.");
                GenJournalLine.SetRange(Description, SalesInvoiceHeader."Pre-Assigned No.");
                if GenJournalLine.FindFirst() then begin
                    SalesInvoiceHeader.CalcFields("Remaining Amount");
                    if SalesInvoiceHeader."Remaining Amount" = 0 then
                        GenJournalLine.Delete()
                    else begin
                        GenJournalLine.Validate("Document No.", SalesInvoiceHeader."No.");
                        GenJournalLine.Validate("Applies-to Doc. Type", GenJournalLine."Applies-to Doc. Type"::Invoice);
                        GenJournalLine.Validate("Applies-to Doc. No.", SalesInvoiceHeader."No.");
                        GLAccount.SetRange(Blocked, false);
                        GLAccount.SetRange("Direct Posting", true);
                        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
                        GLAccount.SetRange("Gen. Posting Type", GLAccount."Gen. Posting Type"::Sale);
                        GLAccount.FindFirst();
                        GenJournalLine.Validate("Bal. Account No.", GLAccount."No.");
                        GenJournalLine.Validate(Amount, -Round(SalesInvoiceHeader."Remaining Amount", 0.01));
                        CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Line", GenJournalLine);
                        GenJournalLine.Delete();
                    end;
                end;
            until SalesInvoiceHeader.Next() = 0;
    end;
}