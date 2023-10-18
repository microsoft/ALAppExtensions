namespace Microsoft.Bank.StatementImport.Yodlee;

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
        if not MSYodleeBankServiceSetup.GET() then
            exit;

        if not (MSYodleeBankServiceSetup.Enabled and MSYodleeBankServiceSetup."Accept Terms of Use") then
            exit;

        if MSYodleeBankServiceSetup.HasDefaultCredentials() and
           (MSYodleeBankServiceSetup."Consumer Name" <> '') and
           MSYodleeBankServiceSetup.HasPassword(MSYodleeBankServiceSetup."Consumer Password")
        then begin
            MSYodleeServiceMgt.SetDisableRethrowException(true);
            MSYodleeServiceMgt.UnregisterConsumer();
        end;
    end;
}

