codeunit 13450 "Create Marketing Setup FI"
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