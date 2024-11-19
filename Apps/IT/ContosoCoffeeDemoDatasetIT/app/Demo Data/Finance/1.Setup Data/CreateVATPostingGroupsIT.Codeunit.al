codeunit 12213 "Create VAT Posting Groups IT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertVATProductPostingGroup();
    end;

    procedure InsertVATPostingSetup()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateITGLAccounts: Codeunit "Create IT GL Accounts";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup('', CreateVATPostingGroups.Reduced(), '', '', CreateVATPostingGroups.Reduced(), 0, Enum::"Tax Calculation Type"::"Normal VAT", '', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', CreateVATPostingGroups.Standard(), '', '', CreateVATPostingGroups.Standard(), 0, Enum::"Tax Calculation Type"::"Normal VAT", '', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', CreateVATPostingGroups.Zero(), '', '', CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", '', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), E13(), CreateITGLAccounts.SalesVat20Perc(), CreateITGLAccounts.PurchaseVat20Perc(), E13(), 0, Enum::"Tax Calculation Type"::"Normal VAT", '', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), IND50(), '', CreateITGLAccounts.PurchaseVat20Perc(), IND50(), 20, Enum::"Tax Calculation Type"::"Normal VAT", '', '', '', false);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), CreateITGLAccounts.SalesVat20Perc(), CreateITGLAccounts.PurchaseVat20Perc(), CreateVATPostingGroups.Standard(), 25, Enum::"Tax Calculation Type"::"Normal VAT", '', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), CreateITGLAccounts.SalesVat20Perc(), CreateITGLAccounts.PurchaseVat20Perc(), CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", '', '', CreateVATPostingGroups.zero(), false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), CreateITGLAccounts.SalesVat20Perc(), CreateITGLAccounts.PurchaseVat20Perc(), CreateVATPostingGroups.Standard(), 20, Enum::"Tax Calculation Type"::"Reverse Charge VAT", '', CreateITGLAccounts.PurchaseVat20PercEu(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroups.Zero(), CreateITGLAccounts.SalesVat20Perc(), CreateITGLAccounts.PurchaseVat20Perc(), CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", '', '', CreateVATPostingGroups.zero(), false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroups.Reduced(), CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10(), CreateVATPostingGroups.Reduced(), 10, Enum::"Tax Calculation Type"::"Reverse Charge VAT", '', CreateGLAccount.PurchaseVAT10EU(), CreateVATPostingGroups.Reduced(), false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), CreateVATPostingGroups.Reduced(), CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10(), CreateVATPostingGroups.Reduced(), 10, Enum::"Tax Calculation Type"::"Normal VAT", '', '', CreateVATPostingGroups.Reduced(), false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), CreateVATPostingGroups.Standard(), CreateITGLAccounts.SalesVat20Perc(), CreateITGLAccounts.PurchaseVat20Perc(), CreateVATPostingGroups.Standard(), 20, Enum::"Tax Calculation Type"::"Normal VAT", '', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), CreateVATPostingGroups.Zero(), CreateITGLAccounts.SalesVat20Perc(), CreateITGLAccounts.PurchaseVat20Perc(), CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", '', '', CreateVATPostingGroups.zero(), false);
        ContosoPostingSetup.SetOverwriteData(false);

        UpdateVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Reduced(), CreateGLAccount.CustomerPrepaymentsVAT10(), CreateGLAccount.VendorPrepaymentsVAT10(), 100);
        UpdateVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), CreateITGLAccounts.CustomerPrepaymentsVat20Perc(), CreateITGLAccounts.VendorPrepaymentsVat20Perc(), 100);
        UpdateVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), CreateGLAccount.CustomerPrepaymentsVAT0(), CreateGLAccount.VendorPrepaymentsVAT(), 100);
        UpdateVATPostingSetup(CreateVATPostingGroups.Domestic(), E13(), '', '', 100);
        UpdateVATPostingSetup(CreateVATPostingGroups.Domestic(), IND50(), '', '', 50);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Business Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVATBusPostingGroup(var Rec: Record "VAT Business Posting Group")
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateNoSeriesIT: Codeunit "Create No. Series IT";
    begin
        case Rec.Code of
            CreateVATPostingGroups.Domestic():
                ValidateRecordFieldsVATBusPostingGroup(Rec, CreateNoSeriesIT.InvCrMemoVATNoforItalianCust(), CreateNoSeriesIT.InvCrMemoVATNoforItalianVend());
            CreateVATPostingGroups.EU():
                ValidateRecordFieldsVATBusPostingGroup(Rec, CreateNoSeriesIT.InvCrMemoVATNoforEUCust(), CreateNoSeriesIT.InvCrMemoVATNoforEUVend());
            CreateVATPostingGroups.Export():
                ValidateRecordFieldsVATBusPostingGroup(Rec, CreateNoSeriesIT.InvCrMemoVATNoforExtraEUCustomers(), CreateNoSeriesIT.InvCrMemoVATNoforExtraEUVendors());
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Product Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVATProductPostingGroup(var Rec: Record "VAT Product Posting Group")
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        case Rec.Code of
            CreateVATPostingGroups.FullNormal():
                Rec.Validate(Description, StrSubstNo(VATOnlyInvoicesDescriptionLbl, '20'));
            CreateVATPostingGroups.Reduced():
                Rec.Validate(Description, StrSubstNo(ReducedVatDescriptionLbl, '10'));
            CreateVATPostingGroups.ServNormal():
                Rec.Validate(Description, StrSubstNo(MiscellaneousVATDescriptionLbl, '20'));
            CreateVATPostingGroups.Standard():
                Rec.Validate(Description, StrSubstNo(NormalVatDescriptionLbl, '20'));
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVATPostingSetup(var Rec: Record "VAT Posting Setup")
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        if Rec."VAT Prod. Posting Group" = CreateVATPostingGroups.Standard() then
            case Rec."VAT Bus. Posting Group" of
                CreateVATPostingGroups.Domestic(),
                CreateVATPostingGroups.EU(),
                CreateVATPostingGroups.Export():
                    ValidateRecFields(Rec, 20, 100);
                '':
                    Rec.Validate(Description, '');
            end;

        if Rec."VAT Prod. Posting Group" = CreateVATPostingGroups.Zero() then
            case Rec."VAT Bus. Posting Group" of
                CreateVATPostingGroups.Domestic(),
                CreateVATPostingGroups.EU(),
                CreateVATPostingGroups.Export():
                    ValidateRecFields(Rec, 0, 100);
                '':
                    Rec.Validate(Description, '');
            end;

        if Rec."VAT Prod. Posting Group" = CreateVATPostingGroups.Reduced() then
            case Rec."VAT Bus. Posting Group" of
                CreateVATPostingGroups.Domestic(),
                CreateVATPostingGroups.EU():
                    ValidateRecFields(Rec, 0, 100);
                CreateVATPostingGroups.Export():
                    ValidateRecFields(Rec, 10, 100);
                '':
                    Rec.Validate(Description, '');
            end;
    end;

    procedure E13(): Code[20]
    begin
        exit(E13Tok);
    end;

    procedure IND50(): Code[20]
    begin
        exit(IND50Tok);
    end;

    procedure IND100(): Code[20]
    begin
        exit(IND100Tok);
    end;

    procedure NI8(): Code[20]
    begin
        exit(NI8Tok);
    end;

    procedure VAT0(): Code[20]
    begin
        exit(VAT0Tok);
    end;

    procedure VAT04(): Code[20]
    begin
        exit(VAT04Tok);
    end;

    procedure UpdateVATPostingSetupIT()
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if VATPostingSetup.FindSet() then
            repeat
                VATPostingSetup.Validate(Description, '');
                VATPostingSetup.Validate("Tax Category", '');
                VATPostingSetup."VAT Clause Code" := '';
                VATPostingSetup.Modify(true);
            until VATPostingSetup.Next() = 0;
    end;

    local procedure UpdateVATPostingSetup(VATBusinessGroupCode: Code[20]; VATProductGroupCode: Code[20]; SalesPrepaymentsAccountNo: Code[20]; PurchasePrepaymentsAccountNo: Code[20]; DeductiblePerc: Decimal)
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if VATPostingSetup.Get(VATBusinessGroupCode, VATProductGroupCode) then begin
            VATPostingSetup.Validate("Sales Prepayments Account", SalesPrepaymentsAccountNo);
            VATPostingSetup.Validate("Purch. Prepayments Account", PurchasePrepaymentsAccountNo);
            VATPostingSetup.Validate("Deductible %", DeductiblePerc);
            VATPostingSetup.Modify(true);
        end;
    end;

    local procedure InsertVATProductPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertVATProductPostingGroup(E13(), TaxExemptArt13Lbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(IND50(), OrdVat2050NondeductibleLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(IND100(), OrdVat20100NondeductibleLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(NI8(), NonTaxableArt81Lbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT0(), ZeroTaxExemptNIFciOthersLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT04(), MinimumVat4Lbl);
    end;

    local procedure ValidateRecordFieldsVATBusPostingGroup(var VATBusinessPostingGroup: Record "VAT Business Posting Group"; DefaultSalesOperationType: Code[20]; DefaultPurchOperationType: Code[20])
    begin
        VATBusinessPostingGroup.Validate("Default Sales Operation Type", DefaultSalesOperationType);
        VATBusinessPostingGroup.Validate("Default Purch. Operation Type", DefaultPurchOperationType);
    end;

    local procedure ValidateRecFields(var VATPostingSetup: Record "VAT Posting Setup"; VATPerc: Decimal; DeductiblePerc: Decimal)
    begin
        VATPostingSetup.Validate(Description, '');
        VATPostingSetup.Validate("VAT Clause Code", '');
        VATPostingSetup.Validate("Tax Category", '');
        VATPostingSetup.Validate("VAT %", VATPerc);
        VATPostingSetup.Validate("Deductible %", DeductiblePerc);
        VATPostingSetup.Validate("EU Service", false);
    end;

    var
        E13Tok: Label 'E13', MaxLength = 20, Locked = true;
        NI8Tok: Label 'NI8', MaxLength = 20, Locked = true;
        VAT04Tok: Label 'VAT04', MaxLength = 20, Locked = true;
        VAT0Tok: Label 'VAT0', MaxLength = 20, Locked = true;
        IND50Tok: Label 'IND50', MaxLength = 20, Locked = true;
        IND100Tok: Label 'IND100', MaxLength = 20, Locked = true;
        MiscellaneousVATDescriptionLbl: Label 'Miscellaneous %1 VAT', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        VATOnlyInvoicesDescriptionLbl: Label 'VAT Only Invoices %1%', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        NormalVatDescriptionLbl: Label 'Ordinary VAT % - %1%', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        ReducedVatDescriptionLbl: Label 'Reduced VAT % - %1%', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        TaxExemptArt13Lbl: Label 'Tax exempt - art. 13', MaxLength = 100;
        OrdVat20100NondeductibleLbl: Label 'Ord. VAT % (20%) - 100% Nondeductible', MaxLength = 100;
        OrdVat2050NondeductibleLbl: Label 'Ord. VAT % (20%) - 50% Nondeductible', MaxLength = 100;
        NonTaxableArt81Lbl: Label 'Non Taxable - Art. 8/1', MaxLength = 100;
        ZeroTaxExemptNIFciOthersLbl: Label 'Zero % (Tax exempt/N.I./FCI/Others)', MaxLength = 100;
        MinimumVat4Lbl: Label 'Minimum VAT % - 4%', MaxLength = 100;
}