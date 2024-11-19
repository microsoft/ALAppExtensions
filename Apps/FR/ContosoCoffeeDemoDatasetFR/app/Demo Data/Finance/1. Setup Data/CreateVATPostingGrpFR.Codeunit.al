codeunit 10869 "Create VAT Posting Grp FR"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"VAT Product Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVATPostingGroup(var Rec: Record "VAT Product Posting Group")
    var
        CreateVatPostingGrp: Codeunit "Create VAT Posting Groups";
    begin
        case Rec.Code of
            CreateVatPostingGrp.FullNormal():
                Rec.Validate(Description, StrSubstNo(VATOnlyInvoicesDescriptionLbl, '20'));
            CreateVatPostingGrp.FullRed():
                Rec.Validate(Description, StrSubstNo(VATOnlyInvoicesDescriptionLbl, '5'));
            CreateVatPostingGrp.Reduced():
                Rec.Validate(Description, StrSubstNo(ReducedVatDescriptionLbl, '5'));
            CreateVatPostingGrp.ServNormal():
                Rec.Validate(Description, StrSubstNo(MiscellaneousVATDescriptionLbl, '20'));
            CreateVatPostingGrp.ServRed():
                Rec.Validate(Description, StrSubstNo(MiscellaneousVATDescriptionLbl, '5'));
            CreateVatPostingGrp.Standard():
                Rec.Validate(Description, StrSubstNo(NormalVatDescriptionLbl, '20'));
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Setup Posting Groups", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVatSetupPostingGrp(var Rec: Record "VAT Setup Posting Groups")
    var
        CreateVatPostingGrp: Codeunit "Create VAT Posting Groups";
        CreateFRGLAccount: Codeunit "Create GL Account FR";
    begin
        case Rec."VAT Prod. Posting Group" of
            CreateVatPostingGrp.FullNormal():
                ValidateVATSetupPostingGrp(Rec, StrSubstNo(VATOnlyInvoicesDescriptionLbl, '20'), '', '', 0);
            CreateVatPostingGrp.FullRed():
                ValidateVATSetupPostingGrp(Rec, StrSubstNo(VATOnlyInvoicesDescriptionLbl, '5'), '', '', 0);
            CreateVatPostingGrp.Reduced():
                ValidateVATSetupPostingGrp(Rec, StrSubstNo(SetupforExportDescLbl, CreateVatPostingGrp.Reduced()), CreateFRGLAccount.SalesTaxFl(), CreateFRGLAccount.UseTaxFl(), 5);
            CreateVatPostingGrp.ServNormal():
                ValidateVATSetupPostingGrp(Rec, StrSubstNo(MiscellaneousVATDescriptionLbl, '20'), '', '', 0);
            CreateVatPostingGrp.ServRed():
                ValidateVATSetupPostingGrp(Rec, StrSubstNo(MiscellaneousVATDescriptionLbl, '5'), '', '', 0);
            CreateVatPostingGrp.Standard():
                ValidateVATSetupPostingGrp(Rec, StrSubstNo(SetupforExportDescLbl, CreateVatPostingGrp.Standard()), CreateFRGLAccount.SalesTaxGa(), CreateFRGLAccount.UseTaxGa(), 20);
            CreateVatPostingGrp.Zero():
                ValidateVATSetupPostingGrp(Rec, StrSubstNo(SetupforExportDescLbl, CreateVatPostingGrp.Zero()), CreateFRGLAccount.SalesTaxGa(), CreateFRGLAccount.UseTaxGa(), 0);
        end;
    end;

    local procedure ValidateVATSetupPostingGrp(var VATSetupPostingGrp: Record "VAT Setup Posting Groups"; VatPostingDesc: Text[100]; SalesVatAccount: Code[20]; PurchaseVATAccount: Code[20]; VatPercent: Decimal)
    begin
        VATSetupPostingGrp.Validate("VAT Prod. Posting Grp Desc.", VatPostingDesc);
        VATSetupPostingGrp.Validate("Sales VAT Account", SalesVatAccount);
        VATSetupPostingGrp.Validate("Purchase VAT Account", PurchaseVATAccount);
        VATSetupPostingGrp.Validate("VAT %", VatPercent);
    end;

    procedure UpdateVATPostingSetup()
    var
        ContosoPostingGrpFR: Codeunit "Contoso Posting Grp FR";
        CreateFRGLAccount: Codeunit "Create GL Account FR";
        CreateVATPostingGroup: codeunit "Create VAT Posting Groups";
    begin
        ContosoPostingGrpFR.ValidateVATPostingSetup('', CreateVATPostingGroup.Reduced(), CreateFRGLAccount.SalesTaxFl(), CreateFRGLAccount.UseTaxFl(), '', 0);
        ContosoPostingGrpFR.ValidateVATPostingSetup('', CreateVATPostingGroup.Standard(), CreateFRGLAccount.SalesTaxGa(), CreateFRGLAccount.UseTaxGa(), '', 0);
        ContosoPostingGrpFR.ValidateVATPostingSetup('', CreateVATPostingGroup.Zero(), CreateFRGLAccount.SalesTaxGa(), CreateFRGLAccount.UseTaxGa(), '', 0);

        ContosoPostingGrpFR.ValidateVATPostingSetup(CreateVATPostingGroup.Domestic(), CreateVATPostingGroup.Reduced(), CreateFRGLAccount.SalesTaxFl(), CreateFRGLAccount.UseTaxFl(), '', 5);
        ContosoPostingGrpFR.ValidateVATPostingSetup(CreateVATPostingGroup.Domestic(), CreateVATPostingGroup.Standard(), CreateFRGLAccount.SalesTaxGa(), CreateFRGLAccount.UseTaxGa(), '', 20);
        ContosoPostingGrpFR.ValidateVATPostingSetup(CreateVATPostingGroup.Domestic(), CreateVATPostingGroup.Zero(), CreateFRGLAccount.SalesTaxGa(), CreateFRGLAccount.UseTaxGa(), '', 0);

        ContosoPostingGrpFR.ValidateVATPostingSetup(CreateVATPostingGroup.EU(), CreateVATPostingGroup.Reduced(), CreateFRGLAccount.SalesTaxFl(), CreateFRGLAccount.UseTaxFl(), CreateFRGLAccount.UseTaxFlReversing(), 5);
        ContosoPostingGrpFR.ValidateVATPostingSetup(CreateVATPostingGroup.EU(), CreateVATPostingGroup.Standard(), CreateFRGLAccount.SalesTaxGa(), CreateFRGLAccount.DeductibleVatIntra(), CreateFRGLAccount.UseTaxGaReversing(), 20);
        ContosoPostingGrpFR.ValidateVATPostingSetup(CreateVATPostingGroup.EU(), CreateVATPostingGroup.Zero(), CreateFRGLAccount.SalesTaxGa(), CreateFRGLAccount.UseTaxGa(), '', 0);

        ContosoPostingGrpFR.ValidateVATPostingSetup(CreateVATPostingGroup.Export(), CreateVATPostingGroup.Reduced(), CreateFRGLAccount.SalesTaxFl(), CreateFRGLAccount.UseTaxFl(), '', 0);
        ContosoPostingGrpFR.ValidateVATPostingSetup(CreateVATPostingGroup.Export(), CreateVATPostingGroup.Standard(), CreateFRGLAccount.SalesTaxGa(), CreateFRGLAccount.UseTaxGa(), '', 0);
        ContosoPostingGrpFR.ValidateVATPostingSetup(CreateVATPostingGroup.Export(), CreateVATPostingGroup.Zero(), CreateFRGLAccount.SalesTaxGa(), CreateFRGLAccount.UseTaxGa(), '', 0);
    end;

    var
        VATOnlyInvoicesDescriptionLbl: Label 'VAT Only Invoices %1%', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        ReducedVatDescriptionLbl: Label 'Reduced VAT (%1%)', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        MiscellaneousVATDescriptionLbl: Label 'Miscellaneous %1 VAT', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        NormalVatDescriptionLbl: Label 'Standard VAT (%1%)', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        SetupforExportDescLbl: Label 'Setup for EXPORT / %1', Comment = '%1 is Vat Prod. Posting Grp Desc', MaxLength = 100;
}