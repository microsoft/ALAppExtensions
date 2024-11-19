codeunit 10794 "Create ES VAT Posting Groups"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertVATProductPostingGroup();
    end;

    procedure InsertVATPostingSetupWithGLAccounts()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateESGLAccounts: Codeunit "Create ES GL Accounts";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup('', NoVat(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), NoVat(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', Vat21(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), Vat21(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', Vat7(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), Vat7(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', Vat4(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), Vat4(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), NoVat(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), NoVaT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), NoTax(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), NoTax(), 0, Enum::"Tax Calculation Type"::"No Taxable VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), Vat21(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), Vat21(), 21, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), Vat7(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), Vat7(), 7, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), Vat4(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), Vat4(), 4, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), NoVat(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), NoVaT(), 0, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'E', CreateESGLAccounts.VatEuReversion(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), NoTax(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), NoTax(), 0, Enum::"Tax Calculation Type"::"No Taxable VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), Vat21(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), Vat21(), 21, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateESGLAccounts.VatEuReversion(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), Vat7(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), Vat7(), 7, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateESGLAccounts.VatEuReversion(), '', true);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), Vat4(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), Vat4(), 4, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateESGLAccounts.VatEuReversion(), '', true);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), NoVat(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), NoVaT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), NoTax(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), NoTax(), 0, Enum::"Tax Calculation Type"::"No Taxable VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), Vat21(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), Vat21(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), Vat7(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), Vat7(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), Vat4(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), Vat4(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.SetOverwriteData(false);
    end;

    local procedure InsertVATProductPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertVATProductPostingGroup(NoTax(), NotchargeableVatLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(NoVat(), MiscellaneousWithoutVatLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(Vat7(), Miscellaneous7VatLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(Vat21(), Miscellaneous21VatLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(Vat4(), Vat21VatLbl);
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    var
    procedure NoTax(): Code[20]
    begin
        exit(NoTaxTok);
    end;

    procedure NoVat(): Code[20]
    begin
        exit(NoVatTok);
    end;

    procedure Vat7(): Code[20]
    begin
        exit(Vat7Tok);
    end;

    procedure Vat21(): Code[20]
    begin
        exit(Vat21Tok);
    end;

    procedure Vat4(): Code[20]
    begin
        exit(Vat4Tok);
    end;

    var
        NoTaxTok: Label 'NO TAX', MaxLength = 20, Locked = true;
        NoVatTok: Label 'NO VAT', MaxLength = 20, Locked = true;
        Vat7Tok: Label 'VAT7', MaxLength = 20, Locked = true;
        Vat21Tok: Label 'VAT21', MaxLength = 20, Locked = true;
        Vat4Tok: Label 'VAT4', MaxLength = 20, Locked = true;
        NotchargeableVatLbl: Label 'Not chargeable VAT', MaxLength = 100;
        MiscellaneousWithoutVatLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
        Vat21VatLbl: Label 'Reduced VAT', MaxLength = 100;
        Miscellaneous21VatLbl: Label 'Miscellaneous 21 VAT', MaxLength = 100;
        Miscellaneous7VatLbl: Label 'Miscellaneous 7 VAT', MaxLength = 100;
}