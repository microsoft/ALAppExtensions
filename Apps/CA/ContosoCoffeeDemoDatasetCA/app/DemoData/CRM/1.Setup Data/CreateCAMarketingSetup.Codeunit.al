codeunit 27074 "Create CA Marketing Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateMarketingSetup();
    end;

    local procedure UpdateMarketingSetup()
    var
        MarketingSetup: Record "Marketing Setup";
        CreateLanguage: Codeunit "Create Language";
    begin
        MarketingSetup.Get();

        MarketingSetup.Validate("Default Language Code", CreateLanguage.ENC());
        MarketingSetup.Validate("Mergefield Language ID", 4105);
        MarketingSetup.Modify(true);
    end;
}