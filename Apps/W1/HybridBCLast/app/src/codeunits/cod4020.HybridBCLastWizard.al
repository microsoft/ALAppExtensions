codeunit 4020 "Hybrid BC Last Wizard"
{
    var
        ProductIdTxt: Label 'DynamicsBCLast', Locked = true;
        ProductNameTxt: Label 'Dynamics 365 Business Central', Locked = true;
        ProductNameQualifierTxt: Label '(Previous Version)';

    procedure ProductId(): Text[250]
    begin
        exit(CopyStr(ProductIdTxt, 1, 250));
    end;

    procedure ProductName(): Text[250]
    var
        Name: Text;
    begin
        Name := StrSubstNo('%1 %2', ProductNameTxt, ProductNameQualifierTxt);
        exit(CopyStr(Name, 1, 250));
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnAfterEnableMigration', '', false, false)]
    local procedure PopulateMappingsOnAfterEnableMigration(HybridProductType: Record "Hybrid Product Type")
    var
        W1Management: Codeunit "W1 Management";
    begin
        if not CanHandle(HybridProductType.ID) then
            exit;

        W1Management.PopulateTableMapping();
    end;

    local procedure CanHandle(productId: Text): Boolean
    begin
        exit(productId = ProductIdTxt);
    end;

}