codeunit 13714 "Create Posting Groups DK"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertGenBusinessPostingGroup();
        InsertGenPostingSetupWithoutGLAccounts();
        UpdateGenProductPostingGroup()
    end;

    procedure InsertGenPostingGroup()
    var
        CreateVATPostingGroupsDK: Codeunit "Create VAT Posting Groups DK";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertGenProductPostingGroup(ServicePostingGroup(), ServiceDescriptionLbl, CreateVATPostingGroupsDK.Vat25Serv());
    end;

    local procedure UpdateGenProductPostingGroup()
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateVATPostingGroupsDK: Codeunit "Create VAT Posting Groups DK";
    begin
        GenProductPostingGroup.Get(CreatePostingGroups.ServicesPostingGroup());
        GenProductPostingGroup.Validate("Def. VAT Prod. Posting Group", CreateVATPostingGroupsDK.Vat25Serv());
        GenProductPostingGroup.Modify(true);
    end;

    local procedure InsertGenBusinessPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertGenBusinessPostingGroup(IntercompanyPostingGroup(), IntercompanyPostingGroupDescriptionLbl, '');
    end;

    local procedure InsertGenPostingSetupWithoutGLAccounts()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
    end;

    procedure UpdateGenPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateDKGLAcc: Codeunit "Create GL Acc. DK";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RetailPostingGroup(), '', '', CreateDKGLAcc.Iteminventoryadjustment(), CreateDKGLAcc.InventoryPosting(), '', '', '', '', '', '', CreateDKGLAcc.Costofgoodssold(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.ZeroPostingGroup(), '', '', CreateDKGLAcc.Iteminventoryadjustment(), CreateDKGLAcc.InventoryPosting(), '', '', '', '', '', '', CreateDKGLAcc.Costofgoodssold(), '', '');

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateDKGLAcc.Salesofgoodsandservicestoothercountries(), CreateDKGLAcc.InventoryPosting(), CreateDKGLAcc.Iteminventoryadjustment(), CreateDKGLAcc.InventoryPosting(), '', '', CreateDKGLAcc.Discountsgranted(), CreateDKGLAcc.Discountsgranted(), CreateDKGLAcc.Discountsreceived(), CreateDKGLAcc.Discountsreceived(), CreateDKGLAcc.Costofgoodssold(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateDKGLAcc.Salesofgoodsandservicestoothercountries(), CreateDKGLAcc.Foreignlabor(), CreateDKGLAcc.Iteminventoryadjustment(), '', '', '', CreateDKGLAcc.Discountsgranted(), CreateDKGLAcc.Discountsgranted(), CreateDKGLAcc.Discountsreceived(), CreateDKGLAcc.Discountsreceived(), '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), CreateDKGLAcc.Salesofgoodsandservicestoothercountries(), CreateDKGLAcc.InventoryPosting(), CreateDKGLAcc.Iteminventoryadjustment(), CreateDKGLAcc.InventoryPosting(), '', '', CreateDKGLAcc.Discountsgranted(), CreateDKGLAcc.Discountsgranted(), CreateDKGLAcc.Discountsreceived(), CreateDKGLAcc.Discountsreceived(), CreateDKGLAcc.Costofgoodssold(), '', '');

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateDKGLAcc.Eusalesofgoodsandservices(), CreateDKGLAcc.InventoryPosting(), CreateDKGLAcc.Iteminventoryadjustment(), CreateDKGLAcc.InventoryPosting(), '', '', CreateDKGLAcc.Discountsgranted(), CreateDKGLAcc.Discountsgranted(), CreateDKGLAcc.Discountsreceived(), CreateDKGLAcc.Discountsreceived(), CreateDKGLAcc.Costofgoodssold(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateDKGLAcc.Eusalesofgoodsandservices(), CreateDKGLAcc.Foreignlabor(), CreateDKGLAcc.Iteminventoryadjustment(), '', '', '', CreateDKGLAcc.Discountsgranted(), CreateDKGLAcc.Discountsgranted(), CreateDKGLAcc.Discountsreceived(), CreateDKGLAcc.Discountsreceived(), '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), CreateDKGLAcc.Eusalesofgoodsandservices(), CreateDKGLAcc.InventoryPosting(), CreateDKGLAcc.Iteminventoryadjustment(), CreateDKGLAcc.InventoryPosting(), '', '', CreateDKGLAcc.Discountsgranted(), CreateDKGLAcc.Discountsgranted(), CreateDKGLAcc.Discountsreceived(), CreateDKGLAcc.Discountsreceived(), CreateDKGLAcc.Costofgoodssold(), '', '');

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateDKGLAcc.Domesticsalesofgoodsandservices(), CreateDKGLAcc.InventoryPosting(), CreateDKGLAcc.Iteminventoryadjustment(), CreateDKGLAcc.InventoryPosting(), '', '', CreateDKGLAcc.Discountsgranted(), CreateDKGLAcc.Discountsgranted(), CreateDKGLAcc.Discountsreceived(), CreateDKGLAcc.Discountsreceived(), CreateDKGLAcc.Costofgoodssold(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateDKGLAcc.Domesticsalesofgoodsandservices(), CreateDKGLAcc.Foreignlabor(), CreateDKGLAcc.Iteminventoryadjustment(), '', '', '', CreateDKGLAcc.Discountsgranted(), CreateDKGLAcc.Discountsgranted(), CreateDKGLAcc.Discountsreceived(), CreateDKGLAcc.Discountsreceived(), '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), CreateDKGLAcc.Domesticsalesofgoodsandservices(), CreateDKGLAcc.InventoryPosting(), CreateDKGLAcc.Iteminventoryadjustment(), CreateDKGLAcc.InventoryPosting(), '', '', CreateDKGLAcc.Discountsgranted(), CreateDKGLAcc.Discountsgranted(), CreateDKGLAcc.Discountsreceived(), CreateDKGLAcc.Discountsreceived(), CreateDKGLAcc.Costofgoodssold(), '', '');
        ContosoGenPostingSetup.SetOverwriteData(false);
    end;

    procedure ServicePostingGroup(): Code[20]
    begin
        exit(ServiceTok);
    end;

    procedure IntercompanyPostingGroup(): Code[20]
    begin
        exit(IntercompanyTok);
    end;

    var
        ServiceTok: Label 'SERVICE', Locked = true;
        ServiceDescriptionLbl: Label 'Resources, etc.', MaxLength = 100, Locked = true;
        IntercompanyTok: Label 'INTERCOMP', Locked = true;
        IntercompanyPostingGroupDescriptionLbl: Label 'Intercompany', MaxLength = 100, Locked = true;
}