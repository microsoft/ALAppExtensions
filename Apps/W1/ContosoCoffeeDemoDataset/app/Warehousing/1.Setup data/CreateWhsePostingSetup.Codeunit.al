codeunit 4788 "Create Whse Posting Setup"
{
    Permissions = tabledata "Inventory Posting Group" = rim,
        tabledata "Inventory Setup" = rim,
        tabledata "Inventory Posting Setup" = rim;

    var
        DoInsertTriggers: Boolean;
        WhseDemoDataSetup: Record "Whse Demo Data Setup";
        WhseDemoAccount: record "Whse. Demo Account";
        WhseDemoAccounts: Codeunit "Whse. Demo Accounts";
        XSmallGBGTxt: Label 'Small customers', MaxLength = 50;
        XLargeGBGTxt: Label 'Large customers', MaxLength = 50;
        XDomesticTxt: Label 'Domestic customers and vendors', MaxLength = 50;
        XRetailTxt: Label 'Retail Items', MaxLength = 50;
        XVATSetupDescTok: Label 'Setup for %1 / %2', MaxLength = 100, Comment = '%1 is the VAT Bus. Posting Group Code, %2 is the VAT Prod. Posting Group Code';
        XVATIdentifierTok: Label 'VAT25', MaxLength = 50;
        XSeriesItemNosTok: Label 'ITEM1', MaxLength = 20;
        XSeriesItemNosDescTok: Label 'Items', MaxLength = 100;
        XSeriesItemNosStartTok: Label '1000', MaxLength = 20;
        XSeriesItemNosEndTok: Label '9999', MaxLength = 20;
        XSeriesTransferOrderNosTok: Label 'T-ORD', MaxLength = 20;
        XSeriesTransferOrderNosDescTok: Label 'Transfer Order', MaxLength = 100;
        XSeriesTransferOrderNosStartTok: Label '1001', MaxLength = 20;
        XSeriesTransferOrderNosEndTok: Label '9999', MaxLength = 20;
        XSeriesPostedTransferShptNosTok: Label 'T-SHIP', MaxLength = 20;
        XSeriesPostedTransferShptNosDescTok: Label 'Transfer Shipment', MaxLength = 100;
        XSeriesPostedTransferShptNosStartTok: Label '108001', MaxLength = 20;
        XSeriesPostedTransferShptNosEndTok: Label '108999', MaxLength = 20;
        XSeriesPostedTransferRcptNosTok: Label 'T-RCPT', MaxLength = 20;
        XSeriesPostedTransferRcptNosDescTok: Label 'Transfer Receipt', MaxLength = 100;
        XSeriesPostedTransferRcptNosStartTok: Label '109000', MaxLength = 20;
        XSeriesPostedTransferRcptNosEndTok: Label '109999', MaxLength = 20;
        XSeriesInventoryPickNosTok: Label 'I-PICK', MaxLength = 20;
        XSeriesInventoryPickNosDescTok: Label 'Inventory Pick', MaxLength = 100;
        XSeriesInventoryPickNosStartTok: Label 'IPI000001', MaxLength = 20;
        XSeriesInventoryPickNosEndTok: Label 'IPI999999', MaxLength = 20;
        XSeriesPostedInvtPickNosTok: Label 'I-PICK+', MaxLength = 20;
        XSeriesPostedInvtPickNosDescTok: Label 'Posted Invt. Pick', MaxLength = 100;
        XSeriesPostedInvtPickNosStartTok: Label 'PPI000001', MaxLength = 20;
        XSeriesPostedInvtPickNosEndTok: Label 'PPI999999', MaxLength = 20;
        XSeriesInventoryPutAwayNosTok: Label 'I-PUT', MaxLength = 20;
        XSeriesInventoryPutAwayNosDescTok: Label 'Inventory Put-Away', MaxLength = 100;
        XSeriesInventoryPutAwayNosStartTok: Label 'IPI000001', MaxLength = 20;
        XSeriesInventoryPutAwayNosEndTok: Label 'IPU999999', MaxLength = 20;
        XSeriesPostedInvtPutAwayNosTok: Label 'I-PUT+', MaxLength = 20;
        XSeriesPostedInvtPutAwayNosDescTok: Label 'Posted Invt. Put-Away', MaxLength = 100;
        XSeriesPostedInvtPutAwayNosStartTok: Label 'PPU000001', MaxLength = 20;
        XSeriesPostedInvtPutAwayNosEndTok: Label 'PPI999999', MaxLength = 20;
        XSeriesInventoryMovementNosTok: Label 'I-MOVE', MaxLength = 20;
        XSeriesInventoryMovementNosDescTok: Label 'Inventory Movement', MaxLength = 100;
        XSeriesInventoryMovementNosStartTok: Label 'IM000001', MaxLength = 20;
        XSeriesInventoryMovementNosEndTok: Label 'IM999999', MaxLength = 20;
        XSeriesRegisteredInvtMovementNosTok: Label 'I-MOVE+', MaxLength = 20;
        XSeriesRegisteredInvtMovementNosDescTok: Label 'Reg. Inventory Movement', MaxLength = 100;
        XSeriesRegisteredInvtMovementNosStartTok: Label 'RIM000001', MaxLength = 20;
        XSeriesRegisteredInvtMovementNosEndTok: Label 'RIM999999', MaxLength = 20;
        XSeriesInternalMovementNosTok: Label 'INT-MOVE', MaxLength = 20;
        XSeriesInternalMovementNosDescTok: Label 'Internal Movement', MaxLength = 100;
        XSeriesInternalMovementNosStartTok: Label 'RINTM000001', MaxLength = 20;
        XSeriesInternalMovementNosEndTok: Label 'RINTM999999', MaxLength = 20;
        XSeriesWhseReceiptNosTok: Label 'WMS-RCPT', MaxLength = 20;
        XSeriesWhseReceiptNosDescTok: Label 'Whse. Receipt', MaxLength = 100;
        XSeriesWhseReceiptNosStartTok: Label 'RE000001', MaxLength = 20;
        XSeriesWhseReceiptNosEndTok: Label 'RE999999', MaxLength = 20;
        XSeriesWhsePostedReceiptNosTok: Label 'WMS-RCPT+', MaxLength = 20;
        XSeriesWhsePostedReceiptNosDescTok: Label 'Posted Whse. Receipt', MaxLength = 100;
        XSeriesWhsePostedReceiptNosStartTok: Label 'R_000001', MaxLength = 20;
        XSeriesWhsePostedReceiptNosEndTok: Label 'R_999999', MaxLength = 20;
        XSeriesWhseShipNosTok: Label 'WMS-SHIP', MaxLength = 20;
        XSeriesWhseShipNosDescTok: Label 'Whse. Ship', MaxLength = 100;
        XSeriesWhseShipNosStartTok: Label 'SH000001', MaxLength = 20;
        XSeriesWhseShipNosEndTok: Label 'SH999999', MaxLength = 20;
        XSeriesWhsePostedShipNosTok: Label 'WMS-SHIP+', MaxLength = 20;
        XSeriesWhsePostedShipNosDescTok: Label 'Posted Whse. Shpt.', MaxLength = 100;
        XSeriesWhsePostedShipNosStartTok: Label 'S_000001', MaxLength = 20;
        XSeriesWhsePostedShipNosEndTok: Label 'S_999999', MaxLength = 20;
        XSeriesWhsePutAwayNosTok: Label 'WMS-PUT', MaxLength = 20;
        XSeriesWhsePutAwayNosDescTok: Label 'Whse. Put-away', MaxLength = 100;
        XSeriesWhsePutAwayNosStartTok: Label 'PU000001', MaxLength = 20;
        XSeriesWhsePutAwayNosEndTok: Label 'PU999999', MaxLength = 20;
        XSeriesWhseRegPutAwayNosTok: Label 'WMS-PUT-+', MaxLength = 20;
        XSeriesWhseRegPutAwayNosDescTok: Label 'Registered Whse. Put-away', MaxLength = 100;
        XSeriesWhseRegPutAwayNosStartTok: Label 'PU_000001', MaxLength = 20;
        XSeriesWhseRegPutAwayNosEndTok: Label 'PU_999999', MaxLength = 20;
        XSeriesWhsePickNosTok: Label 'WMS-PICK', MaxLength = 20;
        XSeriesWhsePickNosDescTok: Label 'Whse. Pick', MaxLength = 100;
        XSeriesWhsePickNosStartTok: Label 'PI000001', MaxLength = 20;
        XSeriesWhsePickNosEndTok: Label 'PI999999', MaxLength = 20;
        XSeriesWhseRegPickNosTok: Label 'WMS-PICK+', MaxLength = 20;
        XSeriesWhseRegPickNosDescTok: Label 'Registered Whse. Put-away', MaxLength = 100;
        XSeriesWhseRegPickNosStartTok: Label 'P_000001', MaxLength = 20;
        XSeriesWhseRegPickNosEndTok: Label 'P_999999', MaxLength = 20;
        XSeriesWhseMovementNosTok: Label 'WMS-MOV', MaxLength = 20;
        XSeriesWhseMovementNosDescTok: Label 'Whse. Movement', MaxLength = 100;
        XSeriesWhseMovementNosStartTok: Label 'WM000001', MaxLength = 20;
        XSeriesWhseMovementNosEndTok: Label 'WM999999', MaxLength = 20;
        XSeriesWhseRegMovementNosTok: Label 'WMS-MOVE+', MaxLength = 20;
        XSeriesWhseRegMovementNosDescTok: Label 'Registered Whse. Movement', MaxLength = 100;
        XSeriesWhseRegMovementNosStartTok: Label 'WM_000001', MaxLength = 20;
        XSeriesWhseRegMovementNosEndTok: Label 'WM_999999', MaxLength = 20;


    trigger OnRun()
    begin
        WhseDemoDataSetup.Get();

        CreateGLAccounts();
        CreatePostingGroups();
        CreatePostingSetups();

        CreateCollection(true);
    end;


    local procedure CreateGLAccounts()
    var
        GLAccount: Record "G/L Account";
        GLAccountIndent: Codeunit "G/L Account-Indent";
    begin
        WhseDemoAccount.ReturnAccountKey(true);

        InsertGLAccount(WhseDemoAccount.CustDomestic(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Balance Sheet");
        InsertGLAccount(WhseDemoAccount.VendDomestic(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Balance Sheet");
        InsertGLAccount(WhseDemoAccount.SalesDomestic(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement");
        InsertGLAccount(WhseDemoAccount.PurchDomestic(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement");
        InsertGLAccount(WhseDemoAccount.SalesVAT(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Balance Sheet");
        InsertGLAccount(WhseDemoAccount.PurchaseVAT(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Balance Sheet");

        WhseDemoAccount.ReturnAccountKey(false);
        GLAccountIndent.Indent();
    end;

    local procedure CreatePostingGroups()
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        CustomerPostingGroup: Record "Customer Posting Group";
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        if WhseDemoDataSetup."Company Type" = WhseDemoDataSetup."Company Type"::VAT then
            InsertVATBusPostingGroup(WhseDemoDataSetup."Domestic Code", XDomesticTxt);

        InsertGenBusPostingGroup(WhseDemoDataSetup."SCust. Gen. Bus. Posting Group", XSmallGBGTxt, WhseDemoDataSetup."Domestic Code");
        InsertGenBusPostingGroup(WhseDemoDataSetup."LCust. Gen. Bus. Posting Group", XLargeGBGTxt, WhseDemoDataSetup."Domestic Code");
        InsertGenBusPostingGroup(WhseDemoDataSetup."Vend. Gen. Bus. Posting Group", XDomesticTxt, WhseDemoDataSetup."Domestic Code");

        if WhseDemoDataSetup."Company Type" = WhseDemoDataSetup."Company Type"::VAT then
            InsertVATProdPostingGroup(WhseDemoDataSetup."Retail Code", XRetailTxt);
        InsertGenProdPostingGroup(WhseDemoDataSetup."Retail Code", XRetailTxt, WhseDemoDataSetup."Retail Code");

        InsertCustomerPostingGroup(WhseDemoDataSetup."S. Cust. Posting Group", WhseDemoAccount.CustDomestic());
        InsertCustomerPostingGroup(WhseDemoDataSetup."L. Cust. Posting Group", WhseDemoAccount.CustDomestic());

        InsertVendorPostingGroup(WhseDemoDataSetup."Vendor Posting Group", WhseDemoAccount.VendDomestic());
    end;

    local procedure CreatePostingSetups()
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        InsertGeneralPostingSetup(WhseDemoDataSetup."Domestic Code", WhseDemoDataSetup."Retail Code", WhseDemoAccount.SalesDomestic(), WhseDemoAccount.PurchDomestic());
        if WhseDemoDataSetup."Company Type" = WhseDemoDataSetup."Company Type"::VAT then
            InsertVATPostingSetup(WhseDemoDataSetup."Domestic Code", WhseDemoDataSetup."Retail Code");
    end;

    local procedure InsertGLAccount("No.": Code[20]; AccountType: Enum "G/L Account Type"; "Income/Balance": Enum "G/L Account Income/Balance")
    var
        GLAccount: Record "G/L Account";
    begin
        WhseDemoAccount := WhseDemoAccounts.GetDemoAccount("No.");

        if GLAccount.Get(WhseDemoAccount."Account Value") then
            exit;

        GLAccount.Init();
        GLAccount.Validate("No.", WhseDemoAccount."Account Value");
        GLAccount.Validate(Name, WhseDemoAccount."Account Description");
        GLAccount.Validate("Account Type", AccountType);
        GLAccount.Validate("Income/Balance", "Income/Balance");
        GLAccount.Insert();
    end;

    local procedure InsertGenProdPostingGroup(NewCode: Code[20]; NewDescription: Text[50]; DefVATProdPostingGroup: Code[20])
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
    begin
        if GenProductPostingGroup.Get(NewCode) then
            exit;

        GenProductPostingGroup.Init();
        GenProductPostingGroup.Validate(Code, NewCode);
        GenProductPostingGroup.Validate(Description, NewDescription);

        if WhseDemoDataSetup."Company Type" = WhseDemoDataSetup."Company Type"::VAT then
            GenProductPostingGroup."Def. VAT Prod. Posting Group" := DefVATProdPostingGroup;

        OnBeforeGenProductPostingGroupInsert(GenProductPostingGroup);

        GenProductPostingGroup.Insert();
    end;

    local procedure InsertGenBusPostingGroup("Code": Code[20]; Description: Text[50]; DefVATBusPostingGroup: Code[20])
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
    begin
        if GenBusinessPostingGroup.Get("Code") then
            exit;

        GenBusinessPostingGroup.Init();
        GenBusinessPostingGroup.Validate(Code, Code);
        GenBusinessPostingGroup.Validate(Description, Description);
        GenBusinessPostingGroup."Def. VAT Bus. Posting Group" := DefVATBusPostingGroup;
        if DefVATBusPostingGroup <> '' then
            GenBusinessPostingGroup."Auto Insert Default" := true;

        OnBeforeGenBusinessPostingGroupInsert(GenBusinessPostingGroup);

        GenBusinessPostingGroup.Insert();
    end;

    local procedure InsertGeneralPostingSetup(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20];
                                        SalesAcc: Code[20]; PurchaseAcc: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if GeneralPostingSetup.Get(GenBusPostingGroup, GenProdPostingGroup) then
            exit;

        GeneralPostingSetup.Init();
        GeneralPostingSetup.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        GeneralPostingSetup.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);

        if PurchaseAcc <> '' then begin
            GeneralPostingSetup.Validate("Sales Account", SalesAcc);
            GeneralPostingSetup.Validate("Sales Credit Memo Account", SalesAcc);

            GeneralPostingSetup.Validate("Purch. Account", PurchaseAcc);
            GeneralPostingSetup.Validate("Purch. Credit Memo Account", PurchaseAcc);
        end;

        OnBeforeGeneralPostingSetupInsert(GeneralPostingSetup);

        GeneralPostingSetup.Insert();
    end;

    local procedure CreateInventoryPostingGroup(
        Code: Code[20];
        Description: Text[100]
    )
    var
        InventoryPostingGroup: Record "Inventory Posting Group";
    begin
        if InventoryPostingGroup.Get(Code) then
            exit;
        InventoryPostingGroup.Init();
        InventoryPostingGroup."Code" := Code;
        InventoryPostingGroup."Description" := Description;
        InventoryPostingGroup.Insert(DoInsertTriggers);
    end;

    local procedure CreateInventorySetup(
        PrimaryKey: Code[10];
        AutomaticCostPosting: Boolean;
        LocationMandatory: Boolean;
        ItemNos: Code[20];
        CopyItemDescrtoEntries: Boolean;
        TransferOrderNos: Code[20];
        PostedTransferShptNos: Code[20];
        PostedTransferRcptNos: Code[20];
        InventoryPutawayNos: Code[20];
        InventoryPickNos: Code[20];
        PostedInvtPutawayNos: Code[20];
        PostedInvtPickNos: Code[20];
        InventoryMovementNos: Code[20];
        RegisteredInvtMovementNos: Code[20];
        InternalMovementNos: Code[20]
    )
    var
        InventorySetup: Record "Inventory Setup";
    begin
        if not InventorySetup.Get() then begin
            InventorySetup.Init();
            InventorySetup."Primary Key" := PrimaryKey;
            InventorySetup."Location Mandatory" := LocationMandatory;
            InventorySetup."Copy Item Descr. to Entries" := CopyItemDescrtoEntries;
            InventorySetup.Insert(DoInsertTriggers);
        end;
        // Validate that key Number Series fields are populated, often required in CRONUS SaaS Eval Data
        InventorySetup."Item Nos." := CheckNoSeriesSetup(InventorySetup."Item Nos.", ItemNos, XSeriesItemNosDescTok, XSeriesItemNosStartTok, XSeriesItemNosEndTok);
        InventorySetup."Transfer Order Nos." := CheckNoSeriesSetup(InventorySetup."Transfer Order Nos.", TransferOrderNos, XSeriesTransferOrderNosDescTok, XSeriesTransferOrderNosStartTok, XSeriesTransferOrderNosEndTok);
        InventorySetup."Posted Transfer Shpt. Nos." := CheckNoSeriesSetup(InventorySetup."Posted Transfer Shpt. Nos.", PostedTransferShptNos, XSeriesPostedTransferShptNosDescTok, XSeriesPostedTransferShptNosStartTok, XSeriesPostedTransferShptNosEndTok);
        InventorySetup."Posted Transfer Rcpt. Nos." := CheckNoSeriesSetup(InventorySetup."Posted Transfer Rcpt. Nos.", PostedTransferRcptNos, XSeriesPostedTransferRcptNosDescTok, XSeriesPostedTransferRcptNosStartTok, XSeriesPostedTransferRcptNosEndTok);
        InventorySetup."Inventory Pick Nos." := CheckNoSeriesSetup(InventorySetup."Inventory Pick Nos.", InventoryPickNos, XSeriesInventoryPickNosDescTok, XSeriesInventoryPickNosStartTok, XSeriesInventoryPickNosEndTok);
        InventorySetup."Posted Invt. Pick Nos." := CheckNoSeriesSetup(InventorySetup."Posted Invt. Pick Nos.", PostedInvtPickNos, XSeriesPostedInvtPickNosDescTok, XSeriesPostedInvtPickNosStartTok, XSeriesPostedInvtPickNosEndTok);
        InventorySetup."Inventory Put-Away Nos." := CheckNoSeriesSetup(InventorySetup."Inventory Put-Away Nos.", InventoryPutAwayNos, XSeriesInventoryPutAwayNosDescTok, XSeriesInventoryPutAwayNosStartTok, XSeriesInventoryPutAwayNosEndTok);
        InventorySetup."Posted Invt. Put-Away Nos." := CheckNoSeriesSetup(InventorySetup."Posted Invt. Put-Away Nos.", PostedInvtPutAwayNos, XSeriesPostedInvtPutAwayNosDescTok, XSeriesPostedInvtPutAwayNosStartTok, XSeriesPostedInvtPutAwayNosEndTok);
        InventorySetup."Inventory Movement Nos." := CheckNoSeriesSetup(InventorySetup."Inventory Movement Nos.", InventoryMovementNos, XSeriesInventoryMovementNosDescTok, XSeriesInventoryMovementNosStartTok, XSeriesInventoryMovementNosEndTok);
        InventorySetup."Registered Invt. Movement Nos." := CheckNoSeriesSetup(InventorySetup."Registered Invt. Movement Nos.", RegisteredInvtMovementNos, XSeriesRegisteredInvtMovementNosDescTok, XSeriesRegisteredInvtMovementNosStartTok, XSeriesRegisteredInvtMovementNosEndTok);
        InventorySetup."Internal Movement Nos." := CheckNoSeriesSetup(InventorySetup."Internal Movement Nos.", InternalMovementNos, XSeriesInternalMovementNosDescTok, XSeriesInternalMovementNosStartTok, XSeriesInternalMovementNosEndTok);
        InventorySetup.Modify(DoInsertTriggers);
    end;

    local procedure CreateInventoryPostingSetup(
        LocationCode: Code[10];
        InvtPostingGroupCode: Code[20];
        InventoryAccount: Code[20];
        Description: Text[100];
        ViewAllAccountsonLookup: Boolean;
        InventoryAccountInterim: Code[20]
    )
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        if InventoryPostingSetup.Get(LocationCode, InvtPostingGroupCode) then
            exit;
        InventoryPostingSetup.Init();
        InventoryPostingSetup."Location Code" := LocationCode;
        InventoryPostingSetup."Invt. Posting Group Code" := InvtPostingGroupCode;
        InventoryPostingSetup."Inventory Account" := InventoryAccount;
        InventoryPostingSetup."Description" := Description;
        InventoryPostingSetup."View All Accounts on Lookup" := ViewAllAccountsonLookup;
        InventoryPostingSetup."Inventory Account (Interim)" := InventoryAccountInterim;
        InventoryPostingSetup.Insert(DoInsertTriggers);
    end;

    local procedure CreateWarehouseSetup(
        WhseReceiptNos: Code[20];
        WhsePostedReceiptNos: Code[20];
        WhseShipNos: Code[20];
        WhsePostedShipNos: Code[20];
        WhsePutAwayNos: Code[20];
        WhseRegPutAwayNos: Code[20];
        WhsePickNos: Code[20];
        WhseRegPickNos: Code[20];
        WhseMovementNos: Code[20];
        WhseRegMovementNos: Code[20]
    )
    var
        WarehouseSetup: Record "Warehouse Setup";
    begin
        if not WarehouseSetup.Get() then begin
            WarehouseSetup.Init();
            WarehouseSetup.Insert(DoInsertTriggers);
        end;
        WarehouseSetup."Whse. Receipt Nos." := CheckNoSeriesSetup(WarehouseSetup."Whse. Receipt Nos.", WhseReceiptNos, XSeriesWhseReceiptNosDescTok, XSeriesWhseReceiptNosStartTok, XSeriesWhseReceiptNosEndTok);
        WarehouseSetup."Posted Whse. Receipt Nos." := CheckNoSeriesSetup(WarehouseSetup."Posted Whse. Receipt Nos.", WhsePostedReceiptNos, XSeriesWhsePostedReceiptNosDescTok, XSeriesWhsePostedReceiptNosStartTok, XSeriesWhsePostedReceiptNosEndTok);
        WarehouseSetup."Whse. Ship Nos." := CheckNoSeriesSetup(WarehouseSetup."Whse. Ship Nos.", WhseShipNos, XSeriesWhseShipNosDescTok, XSeriesWhseShipNosStartTok, XSeriesWhseShipNosEndTok);
        WarehouseSetup."Posted Whse. Shipment Nos." := CheckNoSeriesSetup(WarehouseSetup."Posted Whse. Shipment Nos.", WhsePostedShipNos, XSeriesWhsePostedShipNosDescTok, XSeriesWhsePostedShipNosStartTok, XSeriesWhsePostedShipNosEndTok);
        WarehouseSetup."Whse. Put-away Nos." := CheckNoSeriesSetup(WarehouseSetup."Whse. Put-away Nos.", WhsePutAwayNos, XSeriesWhsePutAwayNosDescTok, XSeriesWhsePutAwayNosStartTok, XSeriesWhsePutAwayNosEndTok);
        WarehouseSetup."Registered Whse. Put-away Nos." := CheckNoSeriesSetup(WarehouseSetup."Registered Whse. Put-away Nos.", WhseRegPutAwayNos, XSeriesWhseRegPutAwayNosDescTok, XSeriesWhseRegPutAwayNosStartTok, XSeriesWhseRegPutAwayNosEndTok);
        WarehouseSetup."Whse. Pick Nos." := CheckNoSeriesSetup(WarehouseSetup."Whse. Pick Nos.", WhsePickNos, XSeriesWhsePickNosDescTok, XSeriesWhsePickNosStartTok, XSeriesWhsePickNosEndTok);
        WarehouseSetup."Registered Whse. Pick Nos." := CheckNoSeriesSetup(WarehouseSetup."Registered Whse. Pick Nos.", WhseRegPickNos, XSeriesWhseRegPickNosDescTok, XSeriesWhseRegPickNosStartTok, XSeriesWhseRegPickNosEndTok);
        WarehouseSetup."Whse. Movement Nos." := CheckNoSeriesSetup(WarehouseSetup."Whse. Movement Nos.", WhseMovementNos, XSeriesWhseMovementNosDescTok, XSeriesWhseMovementNosStartTok, XSeriesWhseMovementNosEndTok);
        WarehouseSetup."Registered Whse. Movement Nos." := CheckNoSeriesSetup(WarehouseSetup."Registered Whse. Movement Nos.", WhseRegMovementNos, XSeriesWhseRegMovementNosDescTok, XSeriesWhseRegMovementNosStartTok, XSeriesWhseRegMovementNosEndTok);
        WarehouseSetup.Modify(DoInsertTriggers);
    end;

    local procedure CreateCollection(ShouldRunInsertTriggers: Boolean)
    begin
        DoInsertTriggers := ShouldRunInsertTriggers;
        CreateInventoryPostingGroup(WhseDemoDataSetup."Resale Code", 'Resale items');

        CreateInventorySetup('', false, false, XSeriesItemNosTok, false, XSeriesTransferOrderNosTok, XSeriesPostedTransferShptNosTok, XSeriesPostedTransferRcptNosTok,
            XSeriesInventoryPutAwayNosTok, XSeriesInventoryPickNosTok, XSeriesInventoryPutAwayNosTok, XSeriesInventoryPickNosTok,
            XSeriesInventoryMovementNosTok, XSeriesRegisteredInvtMovementNosTok, XSeriesInternalMovementNosTok);

        CreateInventoryPostingSetup('', WhseDemoDataSetup."Resale Code", WhseDemoAccount.Resale(), '', false, WhseDemoAccount.ResaleInterim());
        CreateInventoryPostingSetup(WhseDemoDataSetup."Location Basic", WhseDemoDataSetup."Resale Code", WhseDemoAccount.Resale(), '', false, WhseDemoAccount.ResaleInterim());
        CreateInventoryPostingSetup(WhseDemoDataSetup."Location Simple Logistics", WhseDemoDataSetup."Resale Code", WhseDemoAccount.Resale(), '', false, WhseDemoAccount.ResaleInterim());
        CreateInventoryPostingSetup(WhseDemoDataSetup."Location Advanced Logistics", WhseDemoDataSetup."Resale Code", WhseDemoAccount.Resale(), '', false, WhseDemoAccount.ResaleInterim());

        CreateWarehouseSetup(XSeriesWhseReceiptNosTok, XSeriesWhsePostedReceiptNosTok, XSeriesWhseShipNosTok, XSeriesWhsePostedShipNosTok,
            XSeriesWhsePutAwayNosTok, XSeriesWhseRegPutAwayNosTok, XSeriesWhsePickNosTok, XSeriesWhseRegPickNosTok, XSeriesWhseMovementNosTok, XSeriesWhseRegMovementNosTok);
    end;

    local procedure InsertCustomerPostingGroup(CustPostingGroupCode: Code[20]; ReceivablesAccount: Code[20])
    var
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        if CustomerPostingGroup.Get(CustPostingGroupCode) then
            exit;

        CustomerPostingGroup.Init();
        CustomerPostingGroup.Code := CustPostingGroupCode;
        CustomerPostingGroup.Validate("Receivables Account", ReceivablesAccount);
        OnBeforeCustomerPostingGroupInsert(CustomerPostingGroup);
        CustomerPostingGroup.Insert(DoInsertTriggers);
    end;

    local procedure InsertVendorPostingGroup(VendorPostingGroupCode: Code[20]; PayablesAccount: Code[20])
    var
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        if VendorPostingGroup.Get(VendorPostingGroupCode) then
            exit;

        VendorPostingGroup.Init();
        VendorPostingGroup.Code := VendorPostingGroupCode;
        VendorPostingGroup.Validate("Payables Account", PayablesAccount);
        OnBeforeVendorPostingGroupInsert(VendorPostingGroup);
        VendorPostingGroup.Insert(DoInsertTriggers);
    end;

    local procedure InsertVATBusPostingGroup(BusinessGroupCode: Code[10]; BusinessGroupDescription: Text)
    var
        VATBusPostingGroup: Record "VAT Business Posting Group";
    begin
        if VATBusPostingGroup.Get(BusinessGroupCode) then
            exit;

        VATBusPostingGroup.Init();
        VATBusPostingGroup.Code := BusinessGroupCode;
        VATBusPostingGroup.Description := BusinessGroupDescription;
        OnBeforeInsertVATBusPostingGroup(VATBusPostingGroup);
        VATBusPostingGroup.Insert(DoInsertTriggers);
    end;

    local procedure InsertVATProdPostingGroup(ProductGroupCode: Code[10]; ProductGroupDescriptionText: Text)
    var
        VATProdPostingGroup: Record "VAT Product Posting Group";
    begin
        if VATProdPostingGroup.Get(ProductGroupCode) then
            exit;

        VATProdPostingGroup.Init();
        VATProdPostingGroup.Code := ProductGroupCode;
        VATProdPostingGroup.Description := ProductGroupDescriptionText;
        OnBeforeInsertVATProdPostingGroup(VATProdPostingGroup);
        VATProdPostingGroup.Insert(DoInsertTriggers);
    end;

    local procedure InsertVATPostingSetup(BusinessGroupCode: Code[10]; ProductGroupCode: Code[10])
    var
        VATPostingSetup: Record "VAT Posting Setup";
        IsHandled: Boolean;
    begin
        if VATPostingSetup.Get(BusinessGroupCode, ProductGroupCode) then
            exit;

        OnBeforeCreateVATPostingSetup(BusinessGroupCode, ProductGroupCode, IsHandled);
        if IsHandled then
            exit;

        VATPostingSetup.Init();
        VATPostingSetup."VAT Bus. Posting Group" := BusinessGroupCode;
        VATPostingSetup."VAT Prod. Posting Group" := ProductGroupCode;
        VATPostingSetup.Description := StrSubstNo(XVATSetupDescTok, BusinessGroupCode, ProductGroupCode);
        VATPostingSetup."Sales VAT Account" := WhseDemoAccount.SalesVAT();
        VATPostingSetup."Purchase VAT Account" := WhseDemoAccount.PurchaseVAT();
        VATPostingSetup."VAT Identifier" := XVATIdentifierTok;
        VATPostingSetup."VAT %" := 25;
        VATPostingSetup."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type"::"Normal VAT";
        OnBeforeInsertVATPostingSetup(VATPostingSetup);
        VATPostingSetup.Insert(DoInsertTriggers);
    end;

    local procedure CheckNoSeriesSetup(CurrentSetupField: Code[20]; NumberSeriesCode: Code[20]; SeriesDescription: Text[100]; StartNo: Code[20]; EndNo: Code[20]) NewSetupValue: Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if CurrentSetupField <> '' then
            exit(CurrentSetupField);

        if not NoSeries.Get(NumberSeriesCode) then begin
            NoSeries.Init();
            NoSeries.Code := NumberSeriesCode;
            NoSeries.Description := SeriesDescription;
            NoSeries.Validate("Default Nos.", true);
            NoSeries.Insert(DoInsertTriggers);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := NumberSeriesCode;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine.Insert(DoInsertTriggers);
            NoSeriesLine.Validate("Starting No.", StartNo);
            NoSeriesLine.Validate("Ending No.", EndNo);
            NoSeriesLine.Validate("Increment-by No.", 1);
            NoSeriesLine.Validate("Allow Gaps in Nos.", true);
            NoSeriesLine.Modify(true);
        end;

        exit(NumberSeriesCode);
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeGenProductPostingGroupInsert(var GenProductPostingGroup: Record "Gen. Product Posting Group")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGeneralPostingSetupInsert(var GeneralPostingSetup: Record "General Posting Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGenBusinessPostingGroupInsert(var GenBusinessPostingGroup: Record "Gen. Business Posting Group")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCustomerPostingGroupInsert(CustomerPostingGroup: Record "Customer Posting Group")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeVendorPostingGroupInsert(VendorPostingGroup: Record "Vendor Posting Group")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertVATBusPostingGroup(VATBusPostingGroup: Record "VAT Business Posting Group")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertVATProdPostingGroup(VATProdPostingGroup: Record "VAT Product Posting Group")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateVATPostingSetup(BusinessGroupCode: Code[10]; ProductGroupCode: Code[10]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertVATPostingSetup(VATPostingSetup: Record "VAT Posting Setup")
    begin
    end;
}
