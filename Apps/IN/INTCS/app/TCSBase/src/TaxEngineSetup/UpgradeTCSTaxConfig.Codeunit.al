codeunit 18814 "Upgrade TCS Tax Config"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        TaxType: Record "Tax Type";
        TaxEngineAssistedSetup: Codeunit "Tax Engine Assisted Setup";
    begin
        if TaxType.IsEmpty() then
            exit;

        TCSTaxConfiguration.GetTaxTypes();
        TCSTaxConfiguration.GetUseCases();
        TaxEngineAssistedSetup.PushTaxEngineNotifications();
    end;

    var
        TCSTaxConfiguration: Codeunit "TCS Tax Configuration";
}