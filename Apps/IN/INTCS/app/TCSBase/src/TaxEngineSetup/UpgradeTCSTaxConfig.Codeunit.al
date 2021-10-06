codeunit 18814 "Upgrade TCS Tax Config"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        TaxType: Record "Tax Type";
    begin
        if TaxType.IsEmpty() then
            exit;

        CanUpgradeTree := false;
        UpgradeTaxTypes();
        UpgradeUseCases();
        if CanUpgradeTree then
            UpgradeUseCaseTree();
    end;

    local procedure UpgradeTaxTypes()
    var
        TaxTypes: list of [Code[20]];
    begin
        TaxTypes := TCSTaxConfiguration.GetTaxTypes();
        ReadTaxTypes(TaxTypes);
    end;

    local procedure UpgradeUseCases()
    var
        UseCases: List of [Guid];
    begin
        UseCases := TCSTaxConfiguration.GetUseCases();
        ReadUseCases(UseCases);
    end;

    local procedure UpgradeUseCaseTree()
    var
        TaxBaseTaxEngineSetup: Codeunit "Tax Base Tax Engine Setup";
    begin
        TaxBaseTaxEngineSetup.UpgradeUseCaseTree();
    end;

    local procedure ReadTaxTypes(TaxTypes: List of [Code[20]])
    var
        TaxType: Code[20];
    begin
        foreach TaxType in TaxTypes do
            ImportTaxType(TaxType);
    end;

    local procedure CanUpgradeTaxType(TaxTypeCode: Code[20]): Boolean
    var
        TaxType: Record "Tax Type";
        MajorVersion: Integer;
    begin
        if not TaxType.Get(TaxTypeCode) then
            exit(true);

        MajorVersion := TCSTaxConfiguration.GetMSTaxTypeVersion(TaxTypeCode);
        exit(TaxType."Major Version" < MajorVersion);
    end;

    local procedure CanUpgradeUseCase(CaseID: Guid): Boolean
    var
        TaxUseCase: Record "Tax Use Case";
        MajorVersion: Integer;
    begin
        if not TaxUseCase.Get(CaseID) then
            exit(true);

        MajorVersion := TCSTaxConfiguration.GetMSUseCaseVersion(CaseID);
        exit(TaxUseCase."Major Version" < MajorVersion);
    end;

    local procedure ReadUseCases(UseCases: List of [Guid])
    var
        CaseID: Guid;
    begin
        foreach CaseID in UseCases do
            ImportUseCases(CaseID);
    end;

    local procedure ImportTaxType(TaxTypeCode: Code[20])
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        TCSTaxType: Codeunit "TCS Tax Type";
    begin
        if not CanUpgradeTaxType(TaxTypeCode) then
            exit;

        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.SkipVersionCheck(true);
        if TaxTypeCode = TCSLbl then
            TaxJsonDeserialization.ImportTaxTypes(TCSTaxType.GetText());
    end;

    local procedure ImportUseCases(CaseID: Guid)
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        TCSTaxEngineSetup: Codeunit "TCS Tax Engine Setup";
    begin
        if IsNullGuid(CaseID) then
            exit;
        if not CanUpgradeUseCase(CaseID) then
            exit;

        CanUpgradeTree := true;
        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.SkipVersionCheck(true);
        TaxJsonDeserialization.SkipUseCaseIndentation(true);
        TaxJsonDeserialization.ImportUseCases(TCSTaxEngineSetup.GetText(CaseID));
    end;

    var
        TCSTaxConfiguration: Codeunit "TCS Tax Configuration";
        CanUpgradeTree: Boolean;
        TCSLbl: Label 'TCS';
}