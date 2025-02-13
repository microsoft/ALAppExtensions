codeunit 31214 "Create VAT Period CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        InsertData(ContosoUtilities.AdjustDate(19010101D), ContosoUtilities.AdjustDate(19040101D));
    end;

    procedure InsertData(StartingDate: Date; EndingDate: Date)
    var
        ContosoVATStatementCZ: Codeunit "Contoso VAT Statement CZ";
    begin
        while StartingDate <= EndingDate do begin
            ContosoVATStatementCZ.InsertVATPeriod(StartingDate);
            StartingDate := CalcDate('<1M>', StartingDate);
        end;
    end;
}

