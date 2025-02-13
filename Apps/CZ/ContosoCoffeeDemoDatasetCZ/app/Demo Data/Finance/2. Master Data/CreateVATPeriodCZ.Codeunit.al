codeunit 31214 "Create VAT Period CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "VAT Period CZL" = ri;

    trigger OnRun()
    var
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        InsertData(ContosoUtilities.AdjustDate(19010101D), ContosoUtilities.AdjustDate(19040101D));
    end;

    procedure InsertData(StartingDate: Date; EndingDate: Date)
    var
        VATPeriodCZL: Record "VAT Period CZL";
    begin
        while StartingDate <= EndingDate do begin
            VATPeriodCZL.Init();
            VATPeriodCZL.Validate("Starting Date", StartingDate);
            if (Date2DMY(StartingDate, 1) = 1) and (Date2DMY(StartingDate, 2) = 1) then
                VATPeriodCZL."New VAT Year" := true;
            VATPeriodCZL.Insert();
            StartingDate := CalcDate('<1M>', StartingDate);
        end;
    end;
}

