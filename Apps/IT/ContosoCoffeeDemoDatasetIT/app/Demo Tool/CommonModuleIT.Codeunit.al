codeunit 12169 "Common Module IT"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "VAT Identifier" = rim;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingSetupDataForCommonModule(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CommonPostingGroup: Codeunit "Create Common Posting Group";
    begin
        if Module = Enum::"Contoso Demo Data Module"::"Common Module" then
            if ContosoDemoDataLevel = Enum::"Contoso Demo Data Level"::"Setup Data" then
                InsertVATIdentifier(CommonPostingGroup.StandardVAT(), VAT20Lbl);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure LocalizationVATPostingSetup(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CommonPostingGroup: Codeunit "Create Common Posting Group";
        CommonGLAccount: Codeunit "Create Common GL Account";
        CreateVATPostingGroupsIT: Codeunit "Create VAT Posting Groups IT";
        LocalStandardVATPercentage: Decimal;
    begin
        if Module = Enum::"Contoso Demo Data Module"::"Common Module" then
            if ContosoDemoDataLevel = Enum::"Contoso Demo Data Level"::"Setup Data" then begin
                LocalStandardVATPercentage := 20;
                ContosoPostingSetup.SetOverwriteData(true);
                ContosoPostingSetup.InsertVATPostingSetup(CommonPostingGroup.Domestic(), CommonPostingGroup.StandardVAT(), CommonGLAccount.SalesVATStandard(), CommonGLAccount.PurchaseVATStandard(), CommonPostingGroup.StandardVAT(), LocalStandardVATPercentage, Enum::"Tax Calculation Type"::"Normal VAT");
                ContosoPostingSetup.SetOverwriteData(false);
            end;

        CreateVATPostingGroupsIT.UpdateVATPostingSetupIT();
    end;


    procedure InsertVATIdentifier(VATCode: Code[20]; Description: Text[50])
    var
        VATIdentifier: Record "VAT Identifier";
        Exists: Boolean;
    begin
        if VATIdentifier.Get(VATCode) then
            Exists := true;

        VATIdentifier.Validate(Code, VATCode);
        VATIdentifier.Validate(Description, Description);

        if Exists then
            VATIdentifier.Modify(true)
        else
            VATIdentifier.Insert(true);
    end;

    var
        VAT20Lbl: Label 'VAT 20%', MaxLength = 50;
}