codeunit 11721 "Cash Document-Post + Print CZP"
{
    TableNo = "Cash Document Header CZP";

    trigger OnRun()
    begin
        CashDocumentHeaderCZP.Copy(Rec);
        Code();
        Rec := CashDocumentHeaderCZP;
    end;

    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        WithoutConfirmation: Boolean;

    procedure PostWithoutConfirmation(var ParmCashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        WithoutConfirmation := true;
        CashDocumentHeaderCZP.Copy(ParmCashDocumentHeaderCZP);
        Code();
        ParmCashDocumentHeaderCZP := CashDocumentHeaderCZP;
    end;

    local procedure Code()
    begin
        if WithoutConfirmation then
            Codeunit.Run(Codeunit::"Cash Document-Post CZP", CashDocumentHeaderCZP)
        else
            Codeunit.Run(Codeunit::"Cash Document-Post(Yes/No) CZP", CashDocumentHeaderCZP);

        GetReport(CashDocumentHeaderCZP);
        Commit();
    end;

    procedure GetReport(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    var
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
    begin
        PostedCashDocumentHdrCZP.Get(CashDocumentHeaderCZP."Cash Desk No.", CashDocumentHeaderCZP."No.");
        PostedCashDocumentHdrCZP.SetRecFilter();
        PostedCashDocumentHdrCZP.PrintRecords(false);
    end;
}
