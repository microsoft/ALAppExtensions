codeunit 11187 "Create Vat Setup Post Grp AT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateVATPostingGroupAT: Codeunit "Create VAT Posting Group AT";
        CreateATGLAccount: Codeunit "Create AT GL Account";
    begin
        InsertVATSetupPostingGroup(CreateVATPostingGroupAT.NOVAT(), SetupExportReducedDescLbl, true, 0, CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATStandard(), true);
        InsertVATSetupPostingGroup(CreateVATPostingGroupAT.VAT10(), SetupExportStandardDescLbl, true, 10, CreateATGLAccount.SalesTax10(), CreateATGLAccount.PurchaseVATReduced(), true);
        InsertVATSetupPostingGroup(CreateVATPostingGroupAT.VAT20(), SetupExportIncreaseDescLbl, true, 20, CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATStandard(), true);
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
        SetupExportStandardDescLbl: Label 'Setup for EXPORT / VAT10', MaxLength = 100;
        SetupExportIncreaseDescLbl: Label 'Setup for EXPORT / VAT20', MaxLength = 100;
}