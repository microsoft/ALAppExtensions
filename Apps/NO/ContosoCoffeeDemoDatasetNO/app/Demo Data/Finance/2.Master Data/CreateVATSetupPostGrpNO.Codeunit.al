codeunit 10725 "Create VAT Setup Post Grp. NO"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        CreateVatSetupPostingGrp();
        CreateVATAssistedSetupGrp();
    end;

    local procedure CreateVatSetupPostingGrp()
    var
        CreateVatPostingGroupNO: Codeunit "Create VAT Posting Groups NO";
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroupNO.Full(), true, 0, CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), true, 1, StrSubstNo(VendHighDescLbl, CreateVatPostingGroupNO.Full()));
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroupNO.High(), true, 11.11, CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), true, 1, StrSubstNo(VendNoVatDescLbl, CreateVatPostingGroupNO.High()));
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroupNO.Low(), true, 11.11, CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10(), true, 1, StrSubstNo(VendNoVatDescLbl, CreateVatPostingGroupNO.Low()));
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroupNO.OutSide(), true, 0, CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), true, 1, StrSubstNo(CustNoVatDescLbl, CreateVatPostingGroupNO.OutSide()));
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroupNO.Service(), true, 25, CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), true, 1, StrSubstNo(VendNoVatDescLbl, CreateVatPostingGroupNO.Service()));
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroupNO.Without(), true, 0, CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), true, 1, StrSubstNo(VendNoVatDescLbl, CreateVatPostingGroupNO.Without()));
    end;

    local procedure CreateVATAssistedSetupGrp()
    var
        CreateVatPostingGroupNO: Codeunit "Create VAT Posting Groups NO";
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
    begin
        ContosoVATStatement.InsertVATAssistedSetupBusGrp(CreateVatPostingGroupNO.CUSTHIGH(), CustHighDescriptionLbl, true, true);
        ContosoVATStatement.InsertVATAssistedSetupBusGrp(CreateVatPostingGroupNO.CUSTLOW(), CustLowDescriptionLbl, true, true);
        ContosoVATStatement.InsertVATAssistedSetupBusGrp(CreateVatPostingGroupNO.CUSTNOVAT(), CustNoVatDescriptionLbl, true, true);
        ContosoVATStatement.InsertVATAssistedSetupBusGrp(CreateVatPostingGroupNO.VENDHIGH(), VendHighDescriptionLbl, true, true);
        ContosoVATStatement.InsertVATAssistedSetupBusGrp(CreateVatPostingGroupNO.VENDLOW(), VendLowDescriptionLbl, true, true);
        ContosoVATStatement.InsertVATAssistedSetupBusGrp(CreateVatPostingGroupNO.VENDNOVAT(), VendNoVatDescriptionLbl, true, true);
    end;

    var
        CustHighDescriptionLbl: Label 'Customer - high vat', MaxLength = 100;
        CustLowDescriptionLbl: Label 'Customer - low vat', MaxLength = 100;
        CustNoVatDescriptionLbl: Label 'Customer - no vat.', MaxLength = 100;
        VendHighDescriptionLbl: Label 'Vendor - high vat', MaxLength = 100;
        VendLowDescriptionLbl: Label 'Vendor - low vat', MaxLength = 100;
        VendNoVatDescriptionLbl: Label 'Vendor - no vat.', MaxLength = 100;
        VendHighDescLbl: Label 'Setup for VENDHIGH / %1', Comment = '%1 is Vat Assist Code', MaxLength = 100;
        VendNoVatDescLbl: Label 'Setup for VENDNOVAT / %1', Comment = '%1 is Vat Assist Code', MaxLength = 100;
        CustNoVatDescLbl: Label 'Setup for CUSTNOVAT / %1', Comment = '%1 is Vat Assist Code', MaxLength = 100;
}