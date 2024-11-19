codeunit 17121 "Create AU VAT Posting Groups"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertVATProductPostingGroup();
        InsertVATBusinessPostingGroups();
    end;

    procedure UpdateVATPostingSetup()
    var
        ContosoPostingSetup: codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateAUGLAccounts: Codeunit "Create AU GL Accounts";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup('', '', '', '', '', 0, Enum::"Tax Calculation Type"::"Normal VAT", '', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', NonGst(), '', '', NonGst(), 0, Enum::"Tax Calculation Type"::"Normal VAT");
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroups.DomesticPostingGroup(), Gst10(), CreateAUGLAccounts.GstPayable(), CreateAUGLAccounts.GstReceivable(), Gst10(), 10, Enum::"Tax Calculation Type"::"Normal VAT");
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroups.DomesticPostingGroup(), NonGst(), CreateAUGLAccounts.GstPayable(), CreateAUGLAccounts.GstReceivable(), NonGst(), 0, Enum::"Tax Calculation Type"::"Normal VAT");
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroups.ExportPostingGroup(), Gst10(), CreateAUGLAccounts.GstPayable(), CreateAUGLAccounts.GstReceivable(), Gst10(), 10, Enum::"Tax Calculation Type"::"Normal VAT");
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroups.ExportPostingGroup(), NonGst(), CreateAUGLAccounts.GstPayable(), CreateAUGLAccounts.GstReceivable(), NonGst(), 0, Enum::"Tax Calculation Type"::"Normal VAT");
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroups.MiscPostingGroup(), Gst10(), CreateAUGLAccounts.GstPayable(), CreateAUGLAccounts.GstReceivable(), Gst10(), 10, Enum::"Tax Calculation Type"::"Normal VAT");
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroups.MiscPostingGroup(), NonGst(), CreateAUGLAccounts.GstPayable(), CreateAUGLAccounts.GstReceivable(), NonGst(), 0, Enum::"Tax Calculation Type"::"Normal VAT");
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroups.ExportPostingGroup(), '', CreateAUGLAccounts.GstPayable(), CreateAUGLAccounts.GstReceivable(), '', 0, Enum::"Tax Calculation Type"::"Normal VAT");
        ContosoPostingSetup.SetOverwriteData(false);
    end;

    local procedure InsertVATProductPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertVATProductPostingGroup(Gst10(), Gst10Lbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(NoVat(), MiscellaneousWithoutVatLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(NonGst(), NonGstLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(Vat10(), Miscellaneous10VatLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(Vat15(), Miscellaneous15VatLbl);
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    local procedure InsertVATBusinessPostingGroups()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertVATBusinessPostingGroup(CreatePostingGroups.ExportPostingGroup(), 'Other customers and vendors (not MISC)');
        ContosoPostingGroup.InsertVATBusinessPostingGroup(CreatePostingGroups.MiscPostingGroup(), CustomersAndVendorsInMiscLbl);
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    procedure Gst10(): Code[20]
    begin
        exit(Gst10Tok);
    end;

    procedure NoVat(): Code[20]
    begin
        exit(NoVatTok);
    end;

    procedure NonGst(): Code[20]
    begin
        exit(NonGstTok);
    end;

    procedure Vat10(): Code[20]
    begin
        exit(Vat10Tok);
    end;

    procedure Vat15(): Code[20]
    begin
        exit(Vat15Tok);
    end;

    var
        Gst10Tok: Label 'GST10', MaxLength = 20, Locked = true;
        NoVatTok: Label 'NO VAT', MaxLength = 20, Locked = true;
        NonGstTok: Label 'NON GST', MaxLength = 20, Locked = true;
        Vat10Tok: Label 'VAT10', MaxLength = 20, Locked = true;
        Vat15Tok: Label 'VAT15', MaxLength = 20, Locked = true;
        Gst10Lbl: Label 'GST10', MaxLength = 100;
        MiscellaneousWithoutVatLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
        NonGstLbl: Label 'NON GST', MaxLength = 100;
        Miscellaneous10VatLbl: Label 'Miscellaneous 10 VAT', MaxLength = 100;
        Miscellaneous15VatLbl: Label 'Miscellaneous 15 VAT', MaxLength = 100;
        CustomersAndVendorsInMiscLbl: Label 'Customers and vendors in MISC', MaxLength = 100;
}