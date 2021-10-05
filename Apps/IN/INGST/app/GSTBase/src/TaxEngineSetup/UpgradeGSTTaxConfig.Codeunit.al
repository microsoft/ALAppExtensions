codeunit 18016 "Upgrade GST Tax Config"
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
        TaxTypes := GSTTaxConfiguration.GetMsTaxTypes();
        ReadTaxTypes(TaxTypes);
    end;

    local procedure UpgradeUseCases()
    var
        UseCases: List of [Guid];
    begin
        UseCases := GSTTaxConfiguration.GetMsUseCases();
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

        MajorVersion := GSTTaxConfiguration.GetMSTaxTypeVersion(TaxTypeCode);
        exit(TaxType."Major Version" < MajorVersion);
    end;

    local procedure CanUpgradeUseCase(CaseID: Guid): Boolean
    var
        TaxUseCase: Record "Tax Use Case";
        MajorVersion: Integer;
    begin
        if not TaxUseCase.Get(CaseID) then
            exit(true);

        MajorVersion := GSTTaxConfiguration.GetMSUseCaseVersion(CaseID);
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
        GSTTaxTypeData: Codeunit "GST Tax Type Data";
        CessTaxTypeData: Codeunit "Cess Tax Type Data";
        GSTTDSTCSTaxTypeData: Codeunit "GST TDS TCS Tax Type Data";
    begin
        if not CanUpgradeTaxType(TaxTypeCode) then
            exit;

        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.SkipVersionCheck(true);
        case TaxTypeCode of
            GSTTaxTypeLbl:
                TaxJsonDeserialization.ImportTaxTypes(GSTTaxTypeData.GetText());
            CessTaxTypeLbl:
                TaxJsonDeserialization.ImportTaxTypes(CessTaxTypeData.GetText());
            GSTTDSTCSTaxTypeLbl:
                TaxJsonDeserialization.ImportTaxTypes(GSTTDSTCSTaxTypeData.GetText());
        end;
    end;

    local procedure ImportUseCases(CaseID: Guid)
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        UseCaseConfig: Text;
        IsHandled: Boolean;
    begin
        if IsNullGuid(CaseID) then
            exit;
        if not CanUpgradeUseCase(CaseID) then
            exit;

        CanUpgradeTree := true;
        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.SkipVersionCheck(true);
        TaxJsonDeserialization.SkipUseCaseIndentation(true);
        OnUpgradeGSTUseCases(CaseID, UseCaseConfig, IsHandled);
        TaxJsonDeserialization.ImportUseCases(UseCaseConfig);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpgradeGSTUseCases(CaseID: Guid; var UseCaseConfig: Text; var IsHandled: Boolean)
    begin
    end;

    var
        GSTTaxConfiguration: Codeunit "GST Tax Configuration";
        CanUpgradeTree: Boolean;
        GSTTaxTypeLbl: Label 'GST';
        CESSTaxTypeLbl: Label 'GST CESS';
        GSTTDSTCSTaxTypeLbl: Label 'GST TDS TCS';
}