codeunit 11413 "Create Marketing Setup BE"
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
    begin
        MarketingSetup.Get();

        MarketingSetup.Validate("Default Country/Region Code", '');
        MarketingSetup.Modify(true);
    end;
}