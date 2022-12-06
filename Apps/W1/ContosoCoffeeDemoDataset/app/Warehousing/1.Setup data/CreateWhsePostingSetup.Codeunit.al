codeunit 4788 "Create Whse Posting Setup"
{
    Permissions = tabledata "Inventory Posting Group" = rim,
        tabledata "Inventory Setup" = rim,
        tabledata "Inventory Posting Setup" = rim;

    var
        WhseDemoAccount: Record "Whse. Demo Account";
        WhseDemoDataSetup: Record "Whse Demo Data Setup";
        WhseDemoAccounts: Codeunit "Whse. Demo Accounts";
        DoInsertTriggers: Boolean;
        XDomesticTxt: Label 'Domestic customers and vendors', MaxLength = 50;
        XLargeGBGTxt: Label 'Large customers', MaxLength = 50;
        XRetailTxt: Label 'Retail Items', MaxLength = 50;
        XResaleTxt: Label 'Resale Items', MaxLength = 50;
        XSeriesInternalMovementNosDescTok: Label 'Internal Movement', MaxLength = 100;
        XSeriesInternalMovementNosEndTok: Label 'RINTM999999', MaxLength = 20;
        XSeriesInternalMovementNosStartTok: Label 'RINTM000001', MaxLength = 20;
        XSeriesInternalMovementNosTok: Label 'INT-MOVE', MaxLength = 20;
        XSeriesInventoryMovementNosDescTok: Label 'Inventory Movement', MaxLength = 100;
        XSeriesInventoryMovementNosEndTok: Label 'IM999999', MaxLength = 20;
        XSeriesInventoryMovementNosStartTok: Label 'IM000001', MaxLength = 20;
        XSeriesInventoryMovementNosTok: Label 'I-MOVE', MaxLength = 20;
        XSeriesInventoryPickNosDescTok: Label 'Inventory Pick', MaxLength = 100;
        XSeriesInventoryPickNosEndTok: Label 'IPI999999', MaxLength = 20;
        XSeriesInventoryPickNosStartTok: Label 'IPI000001', MaxLength = 20;
        XSeriesInventoryPickNosTok: Label 'I-PICK', MaxLength = 20;
        XSeriesInventoryPutAwayNosDescTok: Label 'Inventory Put-Away', MaxLength = 100;
        XSeriesInventoryPutAwayNosEndTok: Label 'IPU999999', MaxLength = 20;
        XSeriesInventoryPutAwayNosStartTok: Label 'IPI000001', MaxLength = 20;
        XSeriesInventoryPutAwayNosTok: Label 'I-PUT', MaxLength = 20;
        XSeriesItemNosDescTok: Label 'Items', MaxLength = 100;
        XSeriesItemNosEndTok: Label '9999', MaxLength = 20;
        XSeriesItemNosStartTok: Label '1000', MaxLength = 20;
        XSeriesItemNosTok: Label 'ITEM1', MaxLength = 20;
        XSeriesPostedInvtPickNosDescTok: Label 'Posted Invt. Pick', MaxLength = 100;
        XSeriesPostedInvtPickNosEndTok: Label 'PPI999999', MaxLength = 20;
        XSeriesPostedInvtPickNosStartTok: Label 'PPI000001', MaxLength = 20;
        XSeriesPostedInvtPickNosTok: Label 'I-PICK+', MaxLength = 20;
        XSeriesPostedInvtPutAwayNosDescTok: Label 'Posted Invt. Put-Away', MaxLength = 100;
        XSeriesPostedInvtPutAwayNosEndTok: Label 'PPI999999', MaxLength = 20;
        XSeriesPostedInvtPutAwayNosStartTok: Label 'PPU000001', MaxLength = 20;
        XSeriesPostedInvtPutAwayNosTok: Label 'I-PUT+', MaxLength = 20;
        XSeriesPostedTransferRcptNosDescTok: Label 'Transfer Receipt', MaxLength = 100;
        XSeriesPostedTransferRcptNosEndTok: Label '109999', MaxLength = 20;
        XSeriesPostedTransferRcptNosStartTok: Label '109000', MaxLength = 20;
        XSeriesPostedTransferRcptNosTok: Label 'T-RCPT', MaxLength = 20;
        XSeriesPostedTransferShptNosDescTok: Label 'Transfer Shipment', MaxLength = 100;
        XSeriesPostedTransferShptNosEndTok: Label '108999', MaxLength = 20;
        XSeriesPostedTransferShptNosStartTok: Label '108001', MaxLength = 20;
        XSeriesPostedTransferShptNosTok: Label 'T-SHIP', MaxLength = 20;
        XSeriesRegisteredInvtMovementNosDescTok: Label 'Reg. Inventory Movement', MaxLength = 100;
        XSeriesRegisteredInvtMovementNosEndTok: Label 'RIM999999', MaxLength = 20;
        XSeriesRegisteredInvtMovementNosStartTok: Label 'RIM000001', MaxLength = 20;
        XSeriesRegisteredInvtMovementNosTok: Label 'I-MOVE+', MaxLength = 20;
        XSeriesTransferOrderNosDescTok: Label 'Transfer Order', MaxLength = 100;
        XSeriesTransferOrderNosEndTok: Label '9999', MaxLength = 20;
        XSeriesTransferOrderNosStartTok: Label '1001', MaxLength = 20;
        XSeriesTransferOrderNosTok: Label 'T-ORD', MaxLength = 20;
        XSeriesWhseMovementNosDescTok: Label 'Whse. Movement', MaxLength = 100;
        XSeriesWhseMovementNosEndTok: Label 'WM999999', MaxLength = 20;
        XSeriesWhseMovementNosStartTok: Label 'WM000001', MaxLength = 20;
        XSeriesWhseMovementNosTok: Label 'WMS-MOV', MaxLength = 20;
        XSeriesWhsePickNosDescTok: Label 'Whse. Pick', MaxLength = 100;
        XSeriesWhsePickNosEndTok: Label 'PI999999', MaxLength = 20;
        XSeriesWhsePickNosStartTok: Label 'PI000001', MaxLength = 20;
        XSeriesWhsePickNosTok: Label 'WMS-PICK', MaxLength = 20;
        XSeriesWhsePostedReceiptNosDescTok: Label 'Posted Whse. Receipt', MaxLength = 100;
        XSeriesWhsePostedReceiptNosEndTok: Label 'R_999999', MaxLength = 20;
        XSeriesWhsePostedReceiptNosStartTok: Label 'R_000001', MaxLength = 20;
        XSeriesWhsePostedReceiptNosTok: Label 'WMS-RCPT+', MaxLength = 20;
        XSeriesWhsePostedShipNosDescTok: Label 'Posted Whse. Shpt.', MaxLength = 100;
        XSeriesWhsePostedShipNosEndTok: Label 'S_999999', MaxLength = 20;
        XSeriesWhsePostedShipNosStartTok: Label 'S_000001', MaxLength = 20;
        XSeriesWhsePostedShipNosTok: Label 'WMS-SHIP+', MaxLength = 20;
        XSeriesWhsePutAwayNosDescTok: Label 'Whse. Put-away', MaxLength = 100;
        XSeriesWhsePutAwayNosEndTok: Label 'PU999999', MaxLength = 20;
        XSeriesWhsePutAwayNosStartTok: Label 'PU000001', MaxLength = 20;
        XSeriesWhsePutAwayNosTok: Label 'WMS-PUT', MaxLength = 20;
        XSeriesWhseReceiptNosDescTok: Label 'Whse. Receipt', MaxLength = 100;
        XSeriesWhseReceiptNosEndTok: Label 'RE999999', MaxLength = 20;
        XSeriesWhseReceiptNosStartTok: Label 'RE000001', MaxLength = 20;
        XSeriesWhseReceiptNosTok: Label 'WMS-RCPT', MaxLength = 20;
        XSeriesWhseRegMovementNosDescTok: Label 'Registered Whse. Movement', MaxLength = 100;
        XSeriesWhseRegMovementNosEndTok: Label 'WM_999999', MaxLength = 20;
        XSeriesWhseRegMovementNosStartTok: Label 'WM_000001', MaxLength = 20;
        XSeriesWhseRegMovementNosTok: Label 'WMS-MOVE+', MaxLength = 20;
        XSeriesWhseRegPickNosDescTok: Label 'Registered Whse. Put-away', MaxLength = 100;
        XSeriesWhseRegPickNosEndTok: Label 'P_999999', MaxLength = 20;
        XSeriesWhseRegPickNosStartTok: Label 'P_000001', MaxLength = 20;
        XSeriesWhseRegPickNosTok: Label 'WMS-PICK+', MaxLength = 20;
        XSeriesWhseRegPutAwayNosDescTok: Label 'Registered Whse. Put-away', MaxLength = 100;
        XSeriesWhseRegPutAwayNosEndTok: Label 'PU_999999', MaxLength = 20;
        XSeriesWhseRegPutAwayNosStartTok: Label 'PU_000001', MaxLength = 20;
        XSeriesWhseRegPutAwayNosTok: Label 'WMS-PUT-+', MaxLength = 20;
        XSeriesWhseShipNosDescTok: Label 'Whse. Ship', MaxLength = 100;
        XSeriesWhseShipNosEndTok: Label 'SH999999', MaxLength = 20;
        XSeriesWhseShipNosStartTok: Label 'SH000001', MaxLength = 20;
        XSeriesWhseShipNosTok: Label 'WMS-SHIP', MaxLength = 20;
        XSmallGBGTxt: Label 'Small customers', MaxLength = 50;
        XVATIdentifierTok: Label 'VAT25', MaxLength = 20;
        XVATIdentifierDescTok: Label 'Standard VAT (25%)', MaxLength = 20;
        XVATSetupDescTok: Label 'Setup for %1 / %2', MaxLength = 100, Comment = '%1 is the VAT Bus. Posting Group Code, %2 is the VAT Prod. Posting Group Code';


    trigger OnRun()
    begin
        WhseDemoDataSetup.Get();

        CreateGLAccounts();
        OnAfterCreateGLAccounts();
        CreatePostingGroups();
        CreatePostingSetups();
        OnAfterCreatePostingSetups();

        CreateInventorySetups(true);
        OnAfterCreateInventorySetups();
    end;


    local procedure CreateGLAccounts()
    var
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
    begin
        if WhseDemoDataSetup."Company Type" = WhseDemoDataSetup."Company Type"::VAT then
            InsertVATBusPostingGroup(WhseDemoDataSetup."Domestic Code", XDomesticTxt);

        InsertGenBusPostingGroup(WhseDemoDataSetup."SCust. Gen. Bus. Posting Group", XSmallGBGTxt, WhseDemoDataSetup."Domestic Code");
        InsertGenBusPostingGroup(WhseDemoDataSetup."LCust. Gen. Bus. Posting Group", XLargeGBGTxt, WhseDemoDataSetup."Domestic Code");
        InsertGenBusPostingGroup(WhseDemoDataSetup."Vend. Gen. Bus. Posting Group", XDomesticTxt, WhseDemoDataSetup."Domestic Code");

        if WhseDemoDataSetup."Company Type" = WhseDemoDataSetup."Company Type"::VAT then
            InsertVATProdPostingGroup(WhseDemoDataSetup."VAT Prod. Posting Group Code", XVATIdentifierDescTok);
        InsertGenProdPostingGroup(WhseDemoDataSetup."Retail Code", XRetailTxt, WhseDemoDataSetup."VAT Prod. Posting Group Code");

        InsertCustomerPostingGroup(WhseDemoDataSetup."S. Cust. Posting Group", WhseDemoAccount.CustDomestic());
        InsertCustomerPostingGroup(WhseDemoDataSetup."L. Cust. Posting Group", WhseDemoAccount.CustDomestic());

        InsertVendorPostingGroup(WhseDemoDataSetup."Vendor Posting Group", WhseDemoAccount.VendDomestic());
    end;

    local procedure CreatePostingSetups()
    begin
        InsertGeneralPostingSetup('', WhseDemoDataSetup."Retail Code", WhseDemoAccount.SalesDomestic(), WhseDemoAccount.PurchDomestic());

        InsertGeneralPostingSetup(WhseDemoDataSetup."S. Cust. Posting Group", WhseDemoDataSetup."Retail Code", WhseDemoAccount.SalesDomestic(), WhseDemoAccount.PurchDomestic());
        InsertGeneralPostingSetup(WhseDemoDataSetup."L. Cust. Posting Group", WhseDemoDataSetup."Retail Code", WhseDemoAccount.SalesDomestic(), WhseDemoAccount.PurchDomestic());

        InsertGeneralPostingSetup(WhseDemoDataSetup."Domestic Code", WhseDemoDataSetup."Retail Code", WhseDemoAccount.SalesDomestic(), WhseDemoAccount.PurchDomestic());

        if WhseDemoDataSetup."Company Type" = WhseDemoDataSetup."Company Type"::VAT then
            InsertVATPostingSetup(WhseDemoDataSetup."Domestic Code", WhseDemoDataSetup."VAT Prod. Posting Group Code");
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
        GLAccount.Insert(DoInsertTriggers);
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
        GenProductPostingGroup.Insert(DoInsertTriggers);
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
        GenBusinessPostingGroup.Insert(DoInsertTriggers);
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
        GeneralPostingSetup.Insert(DoInsertTriggers);
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
        IsHandled: Boolean;
    begin
        if not InventorySetup.Get() then begin
            InventorySetup.Init();
            InventorySetup."Primary Key" := PrimaryKey;
            InventorySetup."Location Mandatory" := LocationMandatory;
            InventorySetup."Copy Item Descr. to Entries" := CopyItemDescrtoEntries;
            InventorySetup.Insert(DoInsertTriggers);
        end;
        OnBeforePopulateInventorySetupFields(InventorySetup, IsHandled);
        if IsHandled then
            exit;
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
        OnBeforeInsertInventoryPostingSetup(InventoryPostingSetup);
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
        IsHandled: Boolean;
    begin
        if not WarehouseSetup.Get() then begin
            WarehouseSetup.Init();
            WarehouseSetup.Insert(DoInsertTriggers);
        end;
        OnBeforePopulateWarehouseSetupFields(WarehouseSetup, IsHandled);
        if IsHandled then
            exit;
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

    local procedure CreateInventorySetups(ShouldRunInsertTriggers: Boolean)
    begin
        DoInsertTriggers := ShouldRunInsertTriggers;
        CreateInventoryPostingGroup(WhseDemoDataSetup."Resale Code", XResaleTxt);

        CreateInventorySetup('', false, XSeriesItemNosTok, false, XSeriesTransferOrderNosTok, XSeriesPostedTransferShptNosTok, XSeriesPostedTransferRcptNosTok,
            XSeriesInventoryPutAwayNosTok, XSeriesInventoryPickNosTok, XSeriesPostedInvtPutAwayNosTok, XSeriesPostedInvtPickNosTok,
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

    local procedure InsertVATBusPostingGroup(BusinessGroupCode: Code[10]; BusinessGroupDescription: Text[100])
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
    begin
        if VATBusinessPostingGroup.Get(BusinessGroupCode) then
            exit;

        VATBusinessPostingGroup.Init();
        VATBusinessPostingGroup.Code := BusinessGroupCode;
        VATBusinessPostingGroup.Description := BusinessGroupDescription;
        OnBeforeInsertVATBusPostingGroup(VATBusinessPostingGroup);
        VATBusinessPostingGroup.Insert(DoInsertTriggers);
    end;

    local procedure InsertVATProdPostingGroup(ProductGroupCode: Code[20]; ProductGroupDescriptionText: Text[100])
    var
        VATProductPostingGroup: Record "VAT Product Posting Group";
    begin
        if VATProductPostingGroup.Get(ProductGroupCode) then
            exit;

        VATProductPostingGroup.Init();
        VATProductPostingGroup.Code := ProductGroupCode;
        VATProductPostingGroup.Description := ProductGroupDescriptionText;
        OnBeforeInsertVATProdPostingGroup(VATProductPostingGroup);
        VATProductPostingGroup.Insert(DoInsertTriggers);
    end;

    local procedure InsertVATPostingSetup(VATBusinessGroupCode: Code[20]; VATProductGroupCode: Code[20])
    var
        VATPostingSetup: Record "VAT Posting Setup";
        IsHandled: Boolean;
    begin
        if VATPostingSetup.Get(VATBusinessGroupCode, VATProductGroupCode) then
            exit;

        OnBeforeCreateVATPostingSetup(VATBusinessGroupCode, VATProductGroupCode, IsHandled);
        if IsHandled then
            exit;

        VATPostingSetup.Init();
        VATPostingSetup."VAT Bus. Posting Group" := VATBusinessGroupCode;
        VATPostingSetup."VAT Prod. Posting Group" := VATProductGroupCode;
        VATPostingSetup.Description := StrSubstNo(XVATSetupDescTok, VATBusinessGroupCode, VATProductGroupCode);
        VATPostingSetup."Sales VAT Account" := WhseDemoAccount.SalesVAT();
        VATPostingSetup."Purchase VAT Account" := WhseDemoAccount.PurchaseVAT();
        VATPostingSetup."VAT Identifier" := XVATIdentifierTok;
        VATPostingSetup."VAT %" := 25;
        VATPostingSetup."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type"::"Normal VAT";
        OnBeforeInsertVATPostingSetup(VATPostingSetup);
        VATPostingSetup.Insert(DoInsertTriggers);
    end;

    local procedure CheckNoSeriesSetup(CurrentSetupField: Code[20]; NumberSeriesCode: Code[20]; SeriesDescription: Text[100]; StartNo: Code[20]; EndNo: Code[20]): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if CurrentSetupField <> '' then
            exit(CurrentSetupField);

        OnBeforeConfirmNoSeriesExists(NumberSeriesCode);
        if not NoSeries.Get(NumberSeriesCode) then begin
            NoSeries.Init();
            NoSeries.Code := NumberSeriesCode;
            NoSeries.Description := SeriesDescription;
            NoSeries.Validate("Default Nos.", true);
            OnBeforeInsertNoSeries(NoSeries);
            NoSeries.Insert(DoInsertTriggers);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := NumberSeriesCode;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine.Insert(DoInsertTriggers);
            NoSeriesLine.Validate("Starting No.", StartNo);
            NoSeriesLine.Validate("Ending No.", EndNo);
            NoSeriesLine.Validate("Increment-by No.", 1);
            NoSeriesLine.Validate("Allow Gaps in Nos.", true);
            OnBeforeModifyNoSeriesLine(NoSeries, NoSeriesLine);
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
    local procedure OnBeforeCustomerPostingGroupInsert(var CustomerPostingGroup: Record "Customer Posting Group")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeVendorPostingGroupInsert(var VendorPostingGroup: Record "Vendor Posting Group")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertVATBusPostingGroup(var VATBusinessPostingGroup: Record "VAT Business Posting Group")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertVATProdPostingGroup(var VATProductPostingGroup: Record "VAT Product Posting Group")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateVATPostingSetup(var BusinessGroupCode: Code[20]; ProductGroupCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmNoSeriesExists(var NumberSeriesCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertNoSeries(var NoSeries: Record "No. Series")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyNoSeriesLine(var NoSeries: Record "No. Series"; var NoSeriesLine: Record "No. Series Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePopulateWarehouseSetupFields(var WarehouseSetup: Record "Warehouse Setup"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePopulateInventorySetupFields(var InventorySetup: Record "Inventory Setup"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertInventoryPostingSetup(var InventoryPostingSetup: Record "Inventory Posting Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateInventorySetups()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatePostingSetups()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateGLAccounts()
    begin
    end;
}
