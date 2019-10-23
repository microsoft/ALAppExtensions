codeunit 1958 "Late Payment Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany();
    var
        AppInfo: ModuleInfo;
    begin
        FillLastPostingDateFromExactInvoiceCount();
        NavApp.GetCurrentModuleInfo(AppInfo);
        if (AppInfo.DataVersion().Major() = 1) and (AppInfo.DataVersion().Minor() = 0) then
            UpgradeSecretsToIsolatedStorage();
    end;

    trigger OnUpgradePerDatabase();
    begin
    end;

    trigger OnValidateUpgradePerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if (AppInfo.DataVersion().Major() = 1) and (AppInfo.DataVersion().Minor() = 0) then
            VerifySecretsUpgradeToIsolatedStorage();
    end;

    local procedure FillLastPostingDateFromExactInvoiceCount();
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        LPFeatureTableHelper: Codeunit "LP Feature Table Helper";
        LppSalesInvoiceHeaderInput: Query "LPP Sales Invoice Header Input";
        CountedInvoices: Integer;
        CountedTilTheLastInvoiceUsedLastTime: Boolean;
    begin
        if not LPMachineLearningSetup.Get() then // never been initialized
            exit;
        if LPMachineLearningSetup."Exact Invoice No OnLastML" <= 0 then // never been trained
            exit;
        if LPMachineLearningSetup."Posting Date OnLastML" <> 0D then // already trained with the last posting date
            exit;
        LPFeatureTableHelper.SetFiltersOnSalesInvoiceHeaderToAddToInput(LppSalesInvoiceHeaderInput, '');
        LppSalesInvoiceHeaderInput.Open();
        while CountedTilTheLastInvoiceUsedLastTime or LppSalesInvoiceHeaderInput.Read() do begin
            CountedInvoices += 1;
            if CountedInvoices >= LPMachineLearningSetup."Exact Invoice No OnLastML" then
                CountedTilTheLastInvoiceUsedLastTime := true;
        end;
        LPMachineLearningSetup."Posting Date OnLastML" := LppSalesInvoiceHeaderInput.PostingDate;
        LppSalesInvoiceHeaderInput.Close();
        LPMachineLearningSetup."Exact Invoice No OnLastML" := 0; // empty this field as it will not be needed anymore
        LPMachineLearningSetup.Modify(true);
    end;

    local procedure UpgradeSecretsToIsolatedStorage()
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
    begin
        if LPMachineLearningSetup.Get() then begin
            MoveSecretToIsolatedStorage(LPMachineLearningSetup."Custom API Key");
            MoveSecretToIsolatedStorage(LPMachineLearningSetup."Custom API Uri");
        end;
    end;

    local procedure VerifySecretsUpgradeToIsolatedStorage()
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
    begin
        if LPMachineLearningSetup.Get() then begin
            VerifySecret(LPMachineLearningSetup."Custom API Key");
            VerifySecret(LPMachineLearningSetup."Custom API Uri");
        end;
    end;

    local procedure MoveSecretToIsolatedStorage(ServicePasswordKey: Text[200])
    var
        ServicePassword: Record "Service Password";
        ServicePasswordKeyGuid: Guid;
    begin
        if ServicePasswordKey = '' then
            exit;

        if not Evaluate(ServicePasswordKeyGuid, ServicePasswordKey) then
            exit;

        if not ServicePassword.Get(ServicePasswordKeyGuid) then
            exit;

        if EncryptionEnabled() then
            IsolatedStorage.SetEncrypted(ServicePasswordKey, ServicePassword.GetPassword(), DataScope::Company)
        else
            IsolatedStorage.Set(ServicePasswordKey, ServicePassword.GetPassword(), DataScope::Company);
    end;

    local procedure VerifySecret(ServicePasswordKey: Text[200])
    var
        ServicePassword: Record "Service Password";
        IsolatedStorageValue: Text;
        ServicePasswordValue: Text;
        ServicePasswordKeyGuid: Guid;
    begin
        if ServicePasswordKey = '' then
            exit;

        if not Evaluate(ServicePasswordKeyGuid, ServicePasswordKey) then
            exit;

        if not ServicePassword.Get(ServicePasswordKeyGuid) then
            exit;

        if not IsolatedStorage.Get(ServicePasswordKey, DataScope::Company, IsolatedStorageValue) then
            Error('Could not retrieve the secret from isolated storage after the Upgrade for key "%1"', ServicePasswordKey);

        ServicePasswordValue := ServicePassword.GetPassword();

        if IsolatedStorageValue <> ServicePasswordValue then
            Error('The secret value for key "%1" in isolated storage does not match the one in service password.', ServicePasswordKey);
    end;
}
