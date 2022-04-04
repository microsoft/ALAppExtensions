codeunit 18693 "Upgrade TDS Tax Config"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        TaxType: Record "Tax Type";
        TaxEngineAssistedSetup: Codeunit "Tax Engine Assisted Setup";
    begin
        if TaxType.IsEmpty() then
            exit;

        TDSTaxConfiguration.GetTaxTypes();
        TDSTaxConfiguration.GetUseCases();
        TaxEngineAssistedSetup.PushTaxEngineNotifications();
    end;

    var
        TDSTaxConfiguration: Codeunit "TDS Tax Configuration";
}