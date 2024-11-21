codeunit 13703 "Create VAT Setup Post.Grp. DK"
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
    end;

    local procedure CreateVatSetupPostingGrp()
    var
        CreateVatPostingGroup: Codeunit "Create VAT Posting Groups";
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
        CreateVatPostingGroupDK: Codeunit "Create VAT Posting Groups DK";
        CreateGLAccDK: Codeunit "Create GL Acc. DK";
    begin
        ContosoVATStatement.SetOverwriteData(true);
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.Standard(), true, 25, CreateGLAccDk.SalestaxpayableSalesTax(), CreateGLAccDk.SalestaxreceivableInputTax(), true, 1, NormalVatDescriptionLbl);
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.Zero(), true, 0, CreateGLAccDk.SalestaxpayableSalesTax(), CreateGLAccDk.SalestaxreceivableInputTax(), true, 1, NoVatDescriptionLbl);
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroupDK.Vat25Serv(), true, 25, CreateGLAccDk.SalestaxpayableSalesTax(), CreateGLAccDk.SalestaxreceivableInputTax(), true, 1, Vat25ServDescriptionLbl);
        ContosoVATStatement.SetOverwriteData(false);
    end;

    var
        NormalVatDescriptionLbl: Label 'Setup for EXPORT / STANDARD', MaxLength = 100;
        NoVatDescriptionLbl: Label 'Setup for EXPORT / ZERO', MaxLength = 100;
        Vat25ServDescriptionLbl: Label 'Setup for EXPORT / VAT25SERV', MaxLength = 100;
}