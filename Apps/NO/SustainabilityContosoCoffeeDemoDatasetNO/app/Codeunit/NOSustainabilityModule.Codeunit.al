#pragma warning disable AA0247
codeunit 10761 "NO Sustainability Module"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure LocalizationVATPostingSetup(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        if Module = Enum::"Contoso Demo Data Module"::"Sustainability Module" then begin
            if ContosoDemoDataLevel = Enum::"Contoso Demo Data Level"::"Setup Data" then
                UpdateSustainabilityGLAccountPostingGroup();

            if ContosoDemoDataLevel = Enum::"Contoso Demo Data Level"::"Master Data" then
                UpdateSustainabilityVendorPostingGroup();
        end;
    end;

    local procedure UpdateSustainabilityVendorPostingGroup()
    var
        Vendor: Record Vendor;
        CreatePostingGrp: Codeunit "Create Posting Groups";
        CreateSustVendor: Codeunit "Create Sust. Vendor";
        CreateVatPostingGrpNO: Codeunit "Create Vat Posting Groups NO";
    begin
        Vendor.Get(CreateSustVendor.SustVendor64000());
        if Vendor."VAT Bus. Posting Group" = CreatePostingGrp.DomesticPostingGroup() then
            Vendor.Validate("VAT Bus. Posting Group", CreateVatPostingGrpNO.VENDHIGH());

        Vendor.Modify();
    end;

    local procedure UpdateSustainabilityGLAccountPostingGroup()
    var
        GLAccount: Record "G/L Account";
        CreatePostingGrp: Codeunit "Create Posting Groups";
        CreateSustainabilityAccount: Codeunit "Create Sustainability Account";
        CreateVatPostingGrpNO: Codeunit "Create Vat Posting Groups NO";
    begin
        GLAccount.Get(CreateSustainabilityAccount.UtilitiesExpensePowerPlant());
        if GLAccount."VAT Bus. Posting Group" = CreatePostingGrp.DomesticPostingGroup() then
            GLAccount.Validate("VAT Bus. Posting Group", CreateVatPostingGrpNO.VENDHIGH());

        GLAccount.Modify();
    end;
}
