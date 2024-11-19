codeunit 12206 "Create Marketing Setup IT"
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

        MarketingSetup.Validate("Mergefield Language ID", 1040);
        MarketingSetup.Modify(true);
    end;
}