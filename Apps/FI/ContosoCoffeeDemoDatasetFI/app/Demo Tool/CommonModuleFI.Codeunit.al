codeunit 13404 "Common Module FI"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure LocalizationVATPostingSetup(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CommonPostingGroup: Codeunit "Create Common Posting Group";
        CreateFIGLAccounts: Codeunit "Create FI GL Accounts";
        LocalStandardVATPercentage: Decimal;
    begin
        if Module = Enum::"Contoso Demo Data Module"::"Common Module" then
            if ContosoDemoDataLevel = Enum::"Contoso Demo Data Level"::"Setup Data" then begin
                LocalStandardVATPercentage := 24;
                ContosoPostingSetup.SetOverwriteData(true);
                ContosoPostingSetup.InsertVATPostingSetup(CommonPostingGroup.Domestic(), CommonPostingGroup.StandardVAT(), CreateFIGLAccounts.Deferredtaxliability8(), CreateFIGLAccounts.Deferredtaxreceivables1(), CommonPostingGroup.StandardVAT(), LocalStandardVATPercentage, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
                ContosoPostingSetup.SetOverwriteData(false);
            end;
    end;
}