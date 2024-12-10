codeunit 10839 "Create ES Vat Setup Post Grp"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateVATPostingGroupES: Codeunit "Create ES VAT Posting Groups";
        CreateESGLAccount: Codeunit "Create ES GL Accounts";
    begin
        InsertVATSetupPostingGroup(CreateVATPostingGroupES.NoTax(), SetupExportNoTaxDescLbl, true, 0, CreateESGLAccount.VatCollByTheComp(), CreateESGLAccount.GovVatDeductible(), true);
        InsertVATSetupPostingGroup(CreateVATPostingGroupES.NOVAT(), SetupExportReducedDescLbl, true, 0, CreateESGLAccount.VatCollByTheComp(), CreateESGLAccount.GovVatDeductible(), true);
        InsertVATSetupPostingGroup(CreateVATPostingGroupES.VAT7(), SetupExportStandardDescLbl, true, 7, CreateESGLAccount.VatCollByTheComp(), CreateESGLAccount.GovVatDeductible(), true);
        InsertVATSetupPostingGroup(CreateVATPostingGroupES.VAT4(), SetupExportDecreaseDescLbl, true, 4, CreateESGLAccount.VatCollByTheComp(), CreateESGLAccount.GovVatDeductible(), true);
        InsertVATSetupPostingGroup(CreateVATPostingGroupES.VAT21(), SetupExportIncreaseDescLbl, true, 21, CreateESGLAccount.VatCollByTheComp(), CreateESGLAccount.GovVatDeductible(), true);
    end;

    local procedure InsertVATSetupPostingGroup(VatProdPostingGrp: Code[20]; VatProdPostingDesc: Text[100]; DefaultSetup: boolean; VatPercent: integer; SalesVATAccount: Code[20]; PurchaseVATAccount: Code[20]; SelectedSetup: Boolean)
    var
        VatSetupPostinGroup: Record "VAT Setup Posting Groups";
    begin
        VatSetupPostinGroup.Init();
        VatSetupPostinGroup.Validate("VAT Prod. Posting Group", VatProdPostingGrp);
        VatSetupPostinGroup.Validate(Default, DefaultSetup);
        VatSetupPostinGroup.Validate("VAT Prod. Posting Grp Desc.", VatProdPostingDesc);
        VatSetupPostinGroup.Validate("VAT %", VatPercent);
        VatSetupPostinGroup.Validate("Sales VAT Account", SalesVATAccount);
        VatSetupPostinGroup.Validate("Purchase VAT Account", PurchaseVATAccount);
        VatSetupPostinGroup.Validate(Selected, SelectedSetup);
        VatSetupPostinGroup.Validate("Application Type", VatSetupPostinGroup."Application Type"::Items);
        VatSetupPostinGroup.Insert(true);
    end;

    var
        SetupExportReducedDescLbl: Label 'Setup for EXPORT / NO VAT', MaxLength = 100;
        SetupExportNoTaxDescLbl: Label 'Setup for EXPORT / NO TAX', MaxLength = 100;
        SetupExportStandardDescLbl: Label 'Setup for EXPORT / VAT7', MaxLength = 100;
        SetupExportDecreaseDescLbl: Label 'Setup for EXPORT / VAT4', MaxLength = 100;
        SetupExportIncreaseDescLbl: Label 'Setup for EXPORT / VAT21', MaxLength = 100;
}