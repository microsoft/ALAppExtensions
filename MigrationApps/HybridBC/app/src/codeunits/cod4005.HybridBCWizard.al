codeunit 4005 "Hybrid BC Wizard"
{
    var
        ProductIdTxt: Label 'DynamicsBC', Locked = true;
        ProductNameTxt: Label 'Dynamics 365 Business Central', Locked = true;

    procedure ProductId(): Text[250]
    begin
        exit(CopyStr(ProductIdTxt, 1, 250));
    end;

    procedure ProductName(): Text[250]
    begin
        exit(CopyStr(ProductNameTxt, 1, 250));
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", 'CanRunDiagnostic', '', false, false)]
    local procedure OnCanRunDiagnostic(var CanRun: Boolean)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not (IntelligentCloudSetup.Get() and CanHandle(IntelligentCloudSetup."Product ID")) then
            exit;

        CanRun := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", 'CanShowMapUsers', '', false, false)]
    local procedure OnCanShowMapUsers(var Enabled: Boolean)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not (IntelligentCloudSetup.Get() and CanHandle(IntelligentCloudSetup."Product ID")) then
            exit;

        Enabled := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", 'CanShowSetupChecklist', '', false, false)]
    local procedure OnCanShowSetupChecklist(var Enabled: Boolean)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not (IntelligentCloudSetup.Get() and CanHandle(IntelligentCloudSetup."Product ID")) then
            exit;

        Enabled := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", 'CanMapCustomTables', '', false, false)]
    local procedure OnCanMapCustomTables(var Enabled: Boolean)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not (IntelligentCloudSetup.Get() and CanHandle(IntelligentCloudSetup."Product ID")) then
            exit;

        Enabled := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Stat Factbox", 'CanShowTablesNotMigrated', '', false, false)]
    local procedure OnCanShowTablesNotMigrated(var Enabled: Boolean)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not (IntelligentCloudSetup.Get() and CanHandle(IntelligentCloudSetup."Product ID")) then
            exit;

        Enabled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnGetHybridProductType', '', false, false)]
    local procedure OnGetHybridProductType(var HybridProductType: Record "Hybrid Product Type")
    var
        extensionInfo: ModuleInfo;
        extensionId: Guid;
    begin
        NavApp.GetCurrentModuleInfo(extensionInfo);
        extensionId := extensionInfo.Id();
        if not HybridProductType.Get(ProductIdTxt) then begin
            HybridProductType.Init();
            HybridProductType."App ID" := extensionId;
            HybridProductType."Display Name" := ProductName();
            HybridProductType.ID := ProductId();
            HybridProductType.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnGetHybridProductName', '', false, false)]
    local procedure HandleGetHybridProductName(ProductId: Text; var ProductName: Text)
    begin
        if not CanHandle(ProductId) then
            exit;

        ProductName := ProductNameTxt;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Companies IC", 'OnBeforeCreateCompany', '', false, false)]
    local procedure HandleOnBeforeCreateCompany(ProductId: Text; var CompanyDataType: Option "Evaluation Data","Standard Data","None","Extended Data","Full No Data")
    begin
        if not CanHandle(ProductId) then
            exit;

        CompanyDataType := CompanyDataType::None;
    end;

    local procedure CanHandle(ProductId: Text): Boolean
    begin
        exit(ProductId = ProductIdTxt);
    end;

}