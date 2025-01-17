codeunit 10513 "Create GB VAT Posting Group"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"VAT Product Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "VAT Product Posting Group"; RunTrigger: Boolean)
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        case Rec.Code of
            CreateVATPostingGroups.FullNormal():
                ValidateRecordFields(Rec, StrSubstNo(VATOnlyInvoicesDescriptionLbl, '20'));
            CreateVATPostingGroups.FullRed():
                ValidateRecordFields(Rec, StrSubstNo(VATOnlyInvoicesDescriptionLbl, '5'));
            CreateVATPostingGroups.Reduced():
                ValidateRecordFields(Rec, StrSubstNo(ReducedVatDescriptionLbl, '5'));
            CreateVATPostingGroups.ServNormal():
                ValidateRecordFields(Rec, StrSubstNo(MiscellaneousVATDescriptionLbl, '20'));
            CreateVATPostingGroups.ServRed():
                ValidateRecordFields(Rec, StrSubstNo(MiscellaneousVATDescriptionLbl, '5'));
            CreateVATPostingGroups.Standard():
                ValidateRecordFields(Rec, StrSubstNo(NormalVatDescriptionLbl, '20'));
        end;
    end;

    local procedure ValidateRecordFields(var VATProductPostingGroup: Record "VAT Product Posting Group"; Description: Text[100])
    begin
        VATProductPostingGroup.Validate(Description, Description);
    end;

    procedure UpdateVATPostingSetup()
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateGBGLAccounts: Codeunit "Create GB GL Accounts";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup('', CreateVATPostingGroups.Reduced(), CreateGBGLAccounts.SalesVATReduced(), CreateGBGLAccounts.PurchaseVATReduced(), CreateVATPostingGroups.Reduced(), 0, Enum::"Tax Calculation Type"::"Normal VAT", ETaxCategoryLbl, '', CreateVATPostingGroups.Reduced(), false);
        ContosoPostingSetup.InsertVATPostingSetup('', CreateVATPostingGroups.Standard(), CreateGBGLAccounts.SalesVATNormal(), CreateGBGLAccounts.PurchaseVATNormal(), CreateVATPostingGroups.Standard(), 0, Enum::"Tax Calculation Type"::"Normal VAT", ETaxCategoryLbl, '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', CreateVATPostingGroups.Zero(), CreateGBGLAccounts.SalesVATNormal(), CreateGBGLAccounts.PurchaseVATReduced(), CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", ETaxCategoryLbl, '', CreateVATPostingGroups.zero(), false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Reduced(), CreateGBGLAccounts.SalesVATReduced(), CreateGBGLAccounts.PurchaseVATReduced(), CreateVATPostingGroups.Reduced(), 5, Enum::"Tax Calculation Type"::"Normal VAT", STaxCategoryLbl, '', CreateVATPostingGroups.Reduced(), false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), CreateGBGLAccounts.SalesVATNormal(), CreateGBGLAccounts.PurchaseVATNormal(), CreateVATPostingGroups.Standard(), 20, Enum::"Tax Calculation Type"::"Normal VAT", STaxCategoryLbl, '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), CreateGBGLAccounts.SalesVATNormal(), CreateGBGLAccounts.PurchaseVATReduced(), CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", ETaxCategoryLbl, '', CreateVATPostingGroups.Zero(), false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroups.Reduced(), CreateGBGLAccounts.SalesVATReduced(), CreateGBGLAccounts.PurchaseVATReduced(), CreateVATPostingGroups.Reduced(), 0, Enum::"Tax Calculation Type"::"Reverse Charge VAT", STaxCategoryLbl, '', CreateVATPostingGroups.Reduced(), true);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), CreateGBGLAccounts.SalesVATNormal(), CreateGBGLAccounts.PurchaseVATNormal(), CreateVATPostingGroups.Standard(), 20, Enum::"Tax Calculation Type"::"Reverse Charge VAT", STaxCategoryLbl, CreateGBGLAccounts.PurchaseVATNormal(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroups.Zero(), CreateGBGLAccounts.SalesVATNormal(), CreateGBGLAccounts.PurchaseVATReduced(), CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", ETaxCategoryLbl, '', CreateVATPostingGroups.Zero(), false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), CreateVATPostingGroups.Reduced(), CreateGBGLAccounts.SalesVATReduced(), CreateGBGLAccounts.PurchaseVATReduced(), CreateVATPostingGroups.Reduced(), 0, Enum::"Tax Calculation Type"::"Normal VAT", ETaxCategoryLbl, '', CreateVATPostingGroups.Reduced(), false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), CreateVATPostingGroups.Standard(), CreateGBGLAccounts.SalesVATNormal(), CreateGBGLAccounts.PurchaseVATNormal(), CreateVATPostingGroups.Standard(), 0, Enum::"Tax Calculation Type"::"Normal VAT", ETaxCategoryLbl, '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), CreateVATPostingGroups.Zero(), CreateGBGLAccounts.SalesVATNormal(), CreateGBGLAccounts.PurchaseVATReduced(), CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", ETaxCategoryLbl, '', CreateVATPostingGroups.Zero(), false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.FullNormal(), CreateGBGLAccounts.SalesVATNormal(), CreateGBGLAccounts.PurchaseVATNormal(), CreateVATPostingGroups.FullNormal(), 100, Enum::"Tax Calculation Type"::"Full VAT", STaxCategoryLbl, '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.FullRed(), CreateGBGLAccounts.SalesVATReduced(), CreateGBGLAccounts.PurchaseVATReduced(), CreateVATPostingGroups.FullRed(), 100, Enum::"Tax Calculation Type"::"Full VAT", STaxCategoryLbl, '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.ServRed(), CreateGBGLAccounts.SalesVATReduced(), CreateGBGLAccounts.PurchaseVATReduced(), CreateVATPostingGroups.ServRed(), 5, Enum::"Tax Calculation Type"::"Normal VAT", STaxCategoryLbl, '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroups.ServNormal(), CreateGBGLAccounts.SalesVATNormal(), CreateGBGLAccounts.PurchaseVATNormal(), CreateVATPostingGroups.ServNormal(), 20, Enum::"Tax Calculation Type"::"Reverse Charge VAT", STaxCategoryLbl, CreateGBGLAccounts.PurchaseVATNormal(), '', true);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroups.ServRed(), CreateGBGLAccounts.SalesVATReduced(), CreateGBGLAccounts.PurchaseVATReduced(), CreateVATPostingGroups.ServRed(), 5, Enum::"Tax Calculation Type"::"Reverse Charge VAT", STaxCategoryLbl, CreateGBGLAccounts.PurchaseVATReduced(), '', true);
        ContosoPostingSetup.SetOverwriteData(false);
    end;

    var
        MiscellaneousVATDescriptionLbl: Label 'Miscellaneous %1 VAT', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        VATOnlyInvoicesDescriptionLbl: Label 'VAT Only Invoices %1%', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        NormalVatDescriptionLbl: Label 'Standard VAT (%1%)', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        ReducedVatDescriptionLbl: Label 'Reduced VAT (%1%)', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        STaxCategoryLbl: Label 'S', Locked = true;
        ETaxCategoryLbl: Label 'E', Locked = true;
}