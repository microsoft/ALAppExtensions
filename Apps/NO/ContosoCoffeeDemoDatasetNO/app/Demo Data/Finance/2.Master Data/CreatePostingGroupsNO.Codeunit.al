codeunit 10708 "Create Posting Groups NO"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertGenPostingGroup();
        InsertGenBusinessPostingGroup();
    end;

    local procedure InsertGenPostingGroup()
    var
        CreateVATPostingGroupsNO: Codeunit "Create VAT Posting Groups NO";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        ContosoPostingGroup.InsertGenProductPostingGroup(NoVatPostingGroup(), NoVatDescriptionLbl, CreateVATPostingGroupsNO.Without());

        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertGenProductPostingGroup(CreatePostingGroups.FreightPostingGroup(), FreightDescriptionLbl, CreateVATPostingGroupsNO.High());
        ContosoPostingGroup.InsertGenProductPostingGroup(CreatePostingGroups.MiscPostingGroup(), MiscDescriptionLbl, CreateVATPostingGroupsNO.High());
        ContosoPostingGroup.InsertGenProductPostingGroup(CreatePostingGroups.RawMatPostingGroup(), RawMatDescriptionLbl, CreateVATPostingGroupsNO.High());
        ContosoPostingGroup.InsertGenProductPostingGroup(CreatePostingGroups.RetailPostingGroup(), RetailDescriptionLbl, CreateVATPostingGroupsNO.High());
        ContosoPostingGroup.InsertGenProductPostingGroup(CreatePostingGroups.ServicesPostingGroup(), ServicesDescriptionLbl, CreateVATPostingGroupsNO.Low());
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    local procedure InsertGenBusinessPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateVATPostingGroupsNO: Codeunit "Create VAT Posting Groups NO";
    begin
        ContosoPostingGroup.InsertGenBusinessPostingGroup(CustDom(), CustDomDesLbl, CreateVATPostingGroupsNO.CUSTHIGH());
        ContosoPostingGroup.InsertGenBusinessPostingGroup(CustFor(), CustForDesLbl, CreateVATPostingGroupsNO.CUSTNOVAT());
        ContosoPostingGroup.InsertGenBusinessPostingGroup(VendDom(), VendDomDesLbl, CreateVATPostingGroupsNO.VENDHIGH());
        ContosoPostingGroup.InsertGenBusinessPostingGroup(VendFor(), VendForDesLbl, CreateVATPostingGroupsNO.VENDNOVAT());
    end;

    procedure CustDom(): Code[20]
    begin
        exit(CustDomTok);
    end;

    procedure CustFor(): Code[20]
    begin
        exit(CustForTok);
    end;

    procedure VendDom(): Code[20]
    begin
        exit(VendDomTok);
    end;

    procedure VendFor(): Code[20]
    begin
        exit(VendForTok);
    end;

    procedure UpdateGenPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', NoVatPostingGroup(), '', '', '7170', '7170', '', '', '', '', '', '', '7190', '2112', '5510');
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RetailPostingGroup(), '', '', '7170', '7170', '', '', '', '', '', '', '7190', '2112', '5510');

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CustDom(), NoVatPostingGroup(), '6210', '', '7170', '7170', '', '', '6910', '6910', '7140', '7140', '7190', '2112', '5510');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CustDom(), CreatePostingGroups.RetailPostingGroup(), '6110', '', '7170', '7170', '', '', '6910', '6910', '7140', '7140', '7190', '2112', '5510');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CustDom(), CreatePostingGroups.ServicesPostingGroup(), '6410', '', '7170', '7170', '', '', '6910', '6910', '7140', '7140', '7190', '2112', '5510');

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CustFor(), NoVatPostingGroup(), '6210', '', '7170', '7170', '', '', '6910', '6910', '7140', '7140', '7190', '2112', '5510');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CustFor(), CreatePostingGroups.RetailPostingGroup(), '6130', '', '7170', '7170', '', '', '6910', '6910', '7140', '7140', '7190', '2112', '5510');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CustFor(), CreatePostingGroups.ServicesPostingGroup(), '6430', '', '7170', '7170', '', '', '6910', '6910', '7140', '7140', '7190', '2112', '5510');

        ContosoGenPostingSetup.InsertGeneralPostingSetup(VendDom(), NoVatPostingGroup(), '', '7110', '7170', '7170', '', '', '6910', '6910', '7140', '7140', '7190', '2112', '5510');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(VendDom(), CreatePostingGroups.RetailPostingGroup(), '', '7110', '7170', '7170', '', '', '6910', '6910', '7140', '7140', '7190', '2112', '5510');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(VendDom(), CreatePostingGroups.ServicesPostingGroup(), '', '7110', '7170', '7170', '', '', '6910', '6910', '7140', '7140', '7190', '2112', '5510');

        ContosoGenPostingSetup.InsertGeneralPostingSetup(VendFor(), NoVatPostingGroup(), '', '7230', '7170', '7170', '', '', '6910', '6910', '7140', '7140', '7190', '2112', '5510');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(VendFor(), CreatePostingGroups.RetailPostingGroup(), '', '7130', '7170', '7170', '', '', '6910', '6910', '7140', '7140', '7190', '2112', '5510');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(VendFor(), CreatePostingGroups.ServicesPostingGroup(), '', '7130', '7170', '7170', '', '', '6910', '6910', '7140', '7140', '7190', '2112', '5510');
        ContosoGenPostingSetup.SetOverwriteData(false);
    end;

    procedure NoVatPostingGroup(): Code[20]
    begin
        exit(NoVatTok);
    end;


    var
        NoVatTok: Label 'NO VAT', Locked = true, MaxLength = 20;
        NoVatDescriptionLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
        FreightDescriptionLbl: Label 'Freight, etc.', MaxLength = 100;
        MiscDescriptionLbl: Label 'Miscellaneous with VAT', MaxLength = 100;
        RawMatDescriptionLbl: Label 'Raw Materials', MaxLength = 100;
        RetailDescriptionLbl: Label 'Retail', MaxLength = 100;
        ServicesDescriptionLbl: Label 'Resources, etc.', MaxLength = 100;
        CustDomTok: Label 'CUSTDOM', MaxLength = 20;
        CustDomDesLbl: Label 'Domestic customers', MaxLength = 100;
        CustForTok: Label 'CUSTFOR', MaxLength = 20;
        CustForDesLbl: Label 'Foreign customers', MaxLength = 100;
        VendDomTok: Label 'VENDDOM', MaxLength = 20;
        VendDomDesLbl: Label 'Domestic vendors', MaxLength = 100;
        VendForTok: Label 'VENDFOR', MaxLength = 20;
        VendForDesLbl: Label 'Foreign vendors', MaxLength = 100;
}