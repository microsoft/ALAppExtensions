codeunit 1453 "MS - Yodlee Account Cleanup"
{

    trigger OnRun();
    begin
        CleanUpAccount();
    end;

    local procedure CleanUpAccount();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
    begin
        IF NOT MSYodleeBankServiceSetup.GET() THEN
            EXIT;

        IF NOT (MSYodleeBankServiceSetup.Enabled AND MSYodleeBankServiceSetup."Accept Terms of Use") THEN
            EXIT;

        IF MSYodleeBankServiceSetup.HasDefaultCredentials() AND
           (MSYodleeBankServiceSetup."Consumer Name" <> '') AND
           MSYodleeBankServiceSetup.HasPassword(MSYodleeBankServiceSetup."Consumer Password")
        THEN BEGIN
            MSYodleeServiceMgt.SetDisableRethrowException(TRUE);
            MSYodleeServiceMgt.UnregisterConsumer();
        END;
    end;
}

