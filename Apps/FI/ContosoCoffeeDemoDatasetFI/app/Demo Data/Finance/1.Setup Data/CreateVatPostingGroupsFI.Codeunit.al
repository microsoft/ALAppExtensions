codeunit 13429 "Create Vat Posting Groups FI"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertVATProductPostingGroup();
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Product Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVATProductPostingGroup(var Rec: Record "VAT Product Posting Group")
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        case Rec.Code of
            CreateVATPostingGroups.FullNormal():
                Rec.Validate(Description, StrSubstNo(VATOnlyInvoicesDescriptionLbl, '24'));
            CreateVATPostingGroups.FullRed():
                Rec.Validate(Description, StrSubstNo(VATOnlyInvoicesDescriptionLbl, '17'));
            CreateVATPostingGroups.Reduced():
                Rec.Validate(Description, StrSubstNo(ReducedVatDescriptionLbl, '17'));
            CreateVATPostingGroups.ServNormal():
                Rec.Validate(Description, StrSubstNo(MiscellaneousVATDescriptionLbl, '24'));
            CreateVATPostingGroups.ServRed():
                Rec.Validate(Description, StrSubstNo(MiscellaneousVATDescriptionLbl, '17'));
            CreateVATPostingGroups.Standard():
                Rec.Validate(Description, StrSubstNo(NormalVatDescriptionLbl, '24'));
        end;
    end;

    local procedure InsertVATProductPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT8(), Vat8DescriptionLbl);
    end;

    procedure UpdateVATPostingSetup()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateFIGLAccounts: Codeunit "Create FI GL Accounts";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup('', '', '', '', '', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);

        ContosoPostingSetup.InsertVATPostingSetup('', CreateVATPostingGroups.Reduced(), CreateFIGLAccounts.Deferredtaxliability10(), CreateFIGLAccounts.Deferredtaxreceivables3(), CreateVATPostingGroups.Reduced(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', CreateVATPostingGroups.Reduced(), false);
        ContosoPostingSetup.InsertVATPostingSetup('', CreateVATPostingGroups.Standard(), CreateFIGLAccounts.Deferredtaxliability8(), CreateFIGLAccounts.Deferredtaxreceivables1(), CreateVATPostingGroups.Standard(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', VAT8(), CreateFIGLAccounts.Deferredtaxliability10(), CreateFIGLAccounts.Deferredtaxreceivables3(), VAT8(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', CreateVATPostingGroups.Zero(), CreateFIGLAccounts.Deferredtaxliability8(), CreateFIGLAccounts.Deferredtaxreceivables1(), CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', CreateVATPostingGroups.Zero(), false);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Reduced(), CreateFIGLAccounts.Deferredtaxliability10(), CreateFIGLAccounts.Deferredtaxreceivables3(), CreateVATPostingGroups.Reduced(), 17, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', CreateVATPostingGroups.Reduced(), false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), CreateFIGLAccounts.Deferredtaxliability8(), CreateFIGLAccounts.Deferredtaxreceivables1(), CreateVATPostingGroups.Standard(), 24, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT8(), CreateFIGLAccounts.Deferredtaxliability10(), CreateFIGLAccounts.Deferredtaxreceivables3(), VAT8(), 8, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), CreateFIGLAccounts.Deferredtaxliability8(), CreateFIGLAccounts.Deferredtaxreceivables1(), CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', CreateVATPostingGroups.Zero(), false);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroups.Reduced(), CreateFIGLAccounts.Deferredtaxliability10(), CreateFIGLAccounts.Deferredtaxreceivables3(), CreateVATPostingGroups.Reduced(), 17, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateFIGLAccounts.Deferredtaxreceivables6(), CreateVATPostingGroups.Reduced(), true);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), CreateFIGLAccounts.Deferredtaxliability8(), CreateFIGLAccounts.Deferredtaxreceivables1(), CreateVATPostingGroups.Standard(), 24, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateFIGLAccounts.Deferredtaxreceivables4(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), VAT8(), CreateFIGLAccounts.Deferredtaxliability10(), CreateFIGLAccounts.Deferredtaxreceivables3(), VAT8(), 8, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateFIGLAccounts.Deferredtaxreceivables6(), '', true);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroups.Zero(), CreateFIGLAccounts.Deferredtaxliability8(), CreateFIGLAccounts.Deferredtaxreceivables1(), CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', CreateVATPostingGroups.Zero(), false);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), CreateVATPostingGroups.Reduced(), CreateFIGLAccounts.Deferredtaxliability10(), CreateFIGLAccounts.Deferredtaxreceivables3(), CreateVATPostingGroups.Reduced(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', CreateVATPostingGroups.Reduced(), false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), CreateVATPostingGroups.Standard(), CreateFIGLAccounts.Deferredtaxliability8(), CreateFIGLAccounts.Deferredtaxreceivables1(), CreateVATPostingGroups.Standard(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), VAT8(), CreateFIGLAccounts.Deferredtaxliability10(), CreateFIGLAccounts.Deferredtaxreceivables3(), VAT8(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), CreateVATPostingGroups.Zero(), CreateFIGLAccounts.Deferredtaxliability8(), CreateFIGLAccounts.Deferredtaxreceivables1(), CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', CreateVATPostingGroups.Zero(), false);
        ContosoPostingSetup.SetOverwriteData(false);
    end;

    procedure VAT8(): Code[20]
    begin
        exit(VAT8Tok);
    end;

    var
        VAT8Tok: Label 'VAT8', Locked = true;
        Vat8DescriptionLbl: Label 'Miscellaneous 8 VAT', MaxLength = 100;
        MiscellaneousVATDescriptionLbl: Label 'Miscellaneous %1 VAT', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        VATOnlyInvoicesDescriptionLbl: Label 'VAT Only Invoices %1%', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        NormalVatDescriptionLbl: Label 'Standard VAT (%1%)', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        ReducedVatDescriptionLbl: Label 'Reduced VAT (%1%)', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
}