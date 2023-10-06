namespace Microsoft.DataMigration.BC;
using Microsoft.DataMigration;

codeunit 4020 "Hybrid BC Last Wizard"
{
    var
        ProductIdTxt: Label 'DynamicsBCLast', Locked = true;
        ProductNameTxt: Label 'Dynamics 365 Business Central', Locked = true;
        ProductNameQualifierTxt: Label 'earlier versions';
        ProductDescriptionTxt: Label 'Use this option if your on-premises deployment of %1 is an earlier major version than this %1 online environment. Because they are not the same version, the migration first copies the data and then runs the upgrade processes. Due to the upgrade processes, we recommend that you run the migration only once.', Comment = '%1 = ProductName';
        ProductNameLbl: Label '%1 %2', Locked = true;

    procedure ProductId(): Text[250]
    begin
        exit(CopyStr(ProductIdTxt, 1, 250));
    end;

    procedure ProductName(): Text[250]
    begin
        exit(CopyStr(StrSubstNo(ProductNameLbl, ProductNameTxt, ProductNameQualifierTxt), 1, 250));
    end;

    procedure IsBCLastMigration(): Boolean
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not (IntelligentCloudSetup.Get()) then
            exit(false);

        exit(CanHandle(IntelligentCloudSetup."Product ID"));
    end;

#pragma warning disable AA0245
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnGetHybridProductDescription', '', false, false)]
    local procedure HandleGetHybridProductDescription(ProductId: Text; var ProductDescription: Text)
    begin
        if ProductId = ProductIdTxt then
            ProductDescription := StrSubstNo(ProductDescriptionTxt, ProductNameTxt);
    end;
#pragma warning restore AA0245

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", 'CanRunDiagnostic', '', false, false)]
    local procedure OnCanRunDiagnostic(var CanRun: Boolean)
    begin
        CanRunDiagnostic(CanRun);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Cloud Migration Management", 'CanRunDiagnostic', '', false, false)]
    local procedure HandleOnCanRunDiagnostic(var CanRun: Boolean)
    begin
        CanRunDiagnostic(CanRun);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", 'CanShowMapUsers', '', false, false)]
    local procedure OnCanShowMapUsers(var Enabled: Boolean)
    begin
        CanShowMapUsers(Enabled);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Cloud Migration Management", 'CanShowMapUsers', '', false, false)]
    local procedure HandleOnCanShowMapUsers(var Enabled: Boolean)
    begin
        CanShowMapUsers(Enabled);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", 'CanShowSetupChecklist', '', false, false)]
    local procedure OnCanShowSetupChecklist(var Enabled: Boolean)
    begin
        CanShowSetupChecklist(Enabled);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Cloud Migration Management", 'CanShowSetupChecklist', '', false, false)]
    local procedure HandleOnCanShowSetupChecklist(var Enabled: Boolean)
    begin
        CanShowSetupChecklist(Enabled);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", 'CanMapCustomTables', '', false, false)]
    local procedure OnCanMapCustomTables(var Enabled: Boolean)
    begin
        CanMapCustomTables(Enabled);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Cloud Migration Management", 'CanMapCustomTables', '', false, false)]
    local procedure HandleOnCanMapCustomTables(var Enabled: Boolean)
    begin
        CanMapCustomTables(Enabled);
    end;

    local procedure CanRunDiagnostic(var CanRun: Boolean)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not (IntelligentCloudSetup.Get() and CanHandle(IntelligentCloudSetup."Product ID")) then
            exit;

        CanRun := true;
    end;

    local procedure CanShowMapUsers(var Enabled: Boolean)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not (IntelligentCloudSetup.Get() and CanHandle(IntelligentCloudSetup."Product ID")) then
            exit;

        Enabled := true;
    end;

    local procedure CanShowSetupChecklist(var Enabled: Boolean)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not (IntelligentCloudSetup.Get() and CanHandle(IntelligentCloudSetup."Product ID")) then
            exit;

        Enabled := true;
    end;

    local procedure CanMapCustomTables(var Enabled: Boolean)
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

#pragma warning disable AA0245
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnGetHybridProductName', '', false, false)]
    local procedure HandleGetHybridProductName(ProductId: Text; var ProductName: Text)
    begin
        if not CanHandle(ProductId) then
            exit;

        ProductName := ProductName();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Companies IC", 'OnBeforeCreateCompany', '', false, false)]
    local procedure HandleOnBeforeCreateCompany(ProductId: Text; var CompanyDataType: Option "Evaluation Data","Standard Data","None","Extended Data","Full No Data")
    begin
        if not CanHandle(ProductId) then
            exit;

        CompanyDataType := CompanyDataType::None;
    end;

    local procedure CanHandle(productId: Text): Boolean
    begin
        exit(productId = ProductIdTxt);
    end;
#pragma warning restore AA0245

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnAfterEnableMigration', '', false, false)]
    local procedure PopulateMappingsOnAfterEnableMigration(HybridProductType: Record "Hybrid Product Type")
    var
        W1Management: Codeunit "W1 Management";
    begin
        if not CanHandle(HybridProductType.ID) then
            exit;

        W1Management.PopulateTableMapping();
    end;

}