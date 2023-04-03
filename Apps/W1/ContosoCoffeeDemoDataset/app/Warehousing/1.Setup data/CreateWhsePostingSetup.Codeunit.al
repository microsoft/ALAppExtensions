codeunit 4788 "Create Whse Posting Setup"
{
    Permissions = tabledata "G/L Account" = ri,
        tabledata "Customer Posting Group" = ri,
        tabledata "General Posting Setup" = ri,
        tabledata "Gen. Business Posting Group" = ri,
        tabledata "Gen. Product Posting Group" = ri,
        tabledata "Inventory Posting Group" = ri,
        tabledata "Inventory Setup" = rim,
        tabledata "Inventory Posting Setup" = ri,
        tabledata "No. Series" = rim,
        tabledata "No. Series Line" = rim,
        tabledata "Vendor Posting Group" = ri,
        tabledata "VAT Business Posting Group" = ri,
        tabledata "VAT Product Posting Group" = ri,
        tabledata "VAT Posting Setup" = ri,
        tabledata "Warehouse Setup" = rim;

    var
        WhseDemoAccount: Record "Whse. Demo Account";
        WhseDemoDataSetup: Record "Whse Demo Data Setup";
        WhseDemoAccounts: Codeunit "Whse. Demo Accounts";
        RunTrigger: Boolean;
        DomesticTxt: Label 'Domestic customers and vendors', MaxLength = 50;
        RetailTxt: Label 'Retail Items', MaxLength = 50;
        ResaleTxt: Label 'Resale Items', MaxLength = 50;
        SeriesInventoryMovementNosDescTok: Label 'Inventory Movement', MaxLength = 100;
        SeriesInventoryMovementNosEndTok: Label 'IM999999', MaxLength = 20;
        SeriesInventoryMovementNosStartTok: Label 'IM000001', MaxLength = 20;
        SeriesInventoryMovementNosTok: Label 'I-MOVE', MaxLength = 20;
        SeriesInventoryPickNosDescTok: Label 'Inventory Pick', MaxLength = 100;
        SeriesInventoryPickNosEndTok: Label 'IPI999999', MaxLength = 20;
        SeriesInventoryPickNosStartTok: Label 'IPI000001', MaxLength = 20;
        SeriesInventoryPickNosTok: Label 'I-PICK', MaxLength = 20;
        SeriesInventoryPutAwayNosDescTok: Label 'Inventory Put-Away', MaxLength = 100;
        SeriesInventoryPutAwayNosEndTok: Label 'IPU999999', MaxLength = 20;
        SeriesInventoryPutAwayNosStartTok: Label 'IPI000001', MaxLength = 20;
        SeriesInventoryPutAwayNosTok: Label 'I-PUT', MaxLength = 20;
        SeriesItemNosDescTok: Label 'Items', MaxLength = 100;
        SeriesItemNosEndTok: Label '9999', MaxLength = 20;
        SeriesItemNosStartTok: Label '1000', MaxLength = 20;
        SeriesItemNosTok: Label 'ITEM1', MaxLength = 20;
        SeriesPostedInvtPickNosDescTok: Label 'Posted Invt. Pick', MaxLength = 100;
        SeriesPostedInvtPickNosEndTok: Label 'PPI999999', MaxLength = 20;
        SeriesPostedInvtPickNosStartTok: Label 'PPI000001', MaxLength = 20;
        SeriesPostedInvtPickNosTok: Label 'I-PICK+', MaxLength = 20;
        SeriesPostedInvtPutAwayNosDescTok: Label 'Posted Invt. Put-Away', MaxLength = 100;
        SeriesPostedInvtPutAwayNosEndTok: Label 'PPI999999', MaxLength = 20;
        SeriesPostedInvtPutAwayNosStartTok: Label 'PPU000001', MaxLength = 20;
        SeriesPostedInvtPutAwayNosTok: Label 'I-PUT+', MaxLength = 20;
        SeriesPostedTransferRcptNosDescTok: Label 'Transfer Receipt', MaxLength = 100;
        SeriesPostedTransferRcptNosEndTok: Label '109999', MaxLength = 20;
        SeriesPostedTransferRcptNosStartTok: Label '109000', MaxLength = 20;
        SeriesPostedTransferRcptNosTok: Label 'T-RCPT', MaxLength = 20;
        SeriesPostedTransferShptNosDescTok: Label 'Transfer Shipment', MaxLength = 100;
        SeriesPostedTransferShptNosEndTok: Label '108999', MaxLength = 20;
        SeriesPostedTransferShptNosStartTok: Label '108001', MaxLength = 20;
        SeriesPostedTransferShptNosTok: Label 'T-SHIP', MaxLength = 20;
        SeriesRegisteredInvtMovementNosDescTok: Label 'Reg. Inventory Movement', MaxLength = 100;
        SeriesRegisteredInvtMovementNosEndTok: Label 'RIM999999', MaxLength = 20;
        SeriesRegisteredInvtMovementNosStartTok: Label 'RIM000001', MaxLength = 20;
        SeriesRegisteredInvtMovementNosTok: Label 'I-MOVE+', MaxLength = 20;
        SeriesTransferOrderNosDescTok: Label 'Transfer Order', MaxLength = 100;
        SeriesTransferOrderNosEndTok: Label '9999', MaxLength = 20;
        SeriesTransferOrderNosStartTok: Label '1001', MaxLength = 20;
        SeriesTransferOrderNosTok: Label 'T-ORD', MaxLength = 20;
        SeriesWhseMovementNosDescTok: Label 'Whse. Movement', MaxLength = 100;
        SeriesWhseMovementNosEndTok: Label 'WM999999', MaxLength = 20;
        SeriesWhseMovementNosStartTok: Label 'WM000001', MaxLength = 20;
        SeriesWhseMovementNosTok: Label 'WMS-MOV', MaxLength = 20;
        SeriesWhsePickNosDescTok: Label 'Whse. Pick', MaxLength = 100;
        SeriesWhsePickNosEndTok: Label 'PI999999', MaxLength = 20;
        SeriesWhsePickNosStartTok: Label 'PI000001', MaxLength = 20;
        SeriesWhsePickNosTok: Label 'WMS-PICK', MaxLength = 20;
        SeriesWhsePostedReceiptNosDescTok: Label 'Posted Whse. Receipt', MaxLength = 100;
        SeriesWhsePostedReceiptNosEndTok: Label 'R_999999', MaxLength = 20;
        SeriesWhsePostedReceiptNosStartTok: Label 'R_000001', MaxLength = 20;
        SeriesWhsePostedReceiptNosTok: Label 'WMS-RCPT+', MaxLength = 20;
        SeriesWhsePostedShipNosDescTok: Label 'Posted Whse. Shpt.', MaxLength = 100;
        SeriesWhsePostedShipNosEndTok: Label 'S_999999', MaxLength = 20;
        SeriesWhsePostedShipNosStartTok: Label 'S_000001', MaxLength = 20;
        SeriesWhsePostedShipNosTok: Label 'WMS-SHIP+', MaxLength = 20;
        SeriesWhsePutAwayNosDescTok: Label 'Whse. Put-away', MaxLength = 100;
        SeriesWhsePutAwayNosEndTok: Label 'PU999999', MaxLength = 20;
        SeriesWhsePutAwayNosStartTok: Label 'PU000001', MaxLength = 20;
        SeriesWhsePutAwayNosTok: Label 'WMS-PUT', MaxLength = 20;
        SeriesWhseReceiptNosDescTok: Label 'Whse. Receipt', MaxLength = 100;
        SeriesWhseReceiptNosEndTok: Label 'RE999999', MaxLength = 20;
        SeriesWhseReceiptNosStartTok: Label 'RE000001', MaxLength = 20;
        SeriesWhseReceiptNosTok: Label 'WMS-RCPT', MaxLength = 20;
        SeriesWhseRegMovementNosDescTok: Label 'Registered Whse. Movement', MaxLength = 100;
        SeriesWhseRegMovementNosEndTok: Label 'WM_999999', MaxLength = 20;
        SeriesWhseRegMovementNosStartTok: Label 'WM_000001', MaxLength = 20;
        SeriesWhseRegMovementNosTok: Label 'WMS-MOVE+', MaxLength = 20;
        SeriesWhseRegPickNosDescTok: Label 'Registered Whse. Put-away', MaxLength = 100;
        SeriesWhseRegPickNosEndTok: Label 'P_999999', MaxLength = 20;
        SeriesWhseRegPickNosStartTok: Label 'P_000001', MaxLength = 20;
        SeriesWhseRegPickNosTok: Label 'WMS-PICK+', MaxLength = 20;
        SeriesWhseRegPutAwayNosDescTok: Label 'Registered Whse. Put-away', MaxLength = 100;
        SeriesWhseRegPutAwayNosEndTok: Label 'PU_999999', MaxLength = 20;
        SeriesWhseRegPutAwayNosStartTok: Label 'PU_000001', MaxLength = 20;
        SeriesWhseRegPutAwayNosTok: Label 'WMS-PUT-+', MaxLength = 20;
        SeriesWhseShipNosDescTok: Label 'Whse. Ship', MaxLength = 100;
        SeriesWhseShipNosEndTok: Label 'SH999999', MaxLength = 20;
        SeriesWhseShipNosStartTok: Label 'SH000001', MaxLength = 20;
        SeriesWhseShipNosTok: Label 'WMS-SHIP', MaxLength = 20;
        VATIdentifierTok: Label 'VAT25', MaxLength = 20;
        VATIdentifierDescTok: Label 'Standard VAT (25%)', MaxLength = 20;
        VATSetupDescTok: Label 'Setup for %1 / %2', MaxLength = 100, Comment = '%1 is the VAT Bus. Posting Group Code, %2 is the VAT Prod. Posting Group Code';


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

        InsertGLAccount(WhseDemoAccount.Resale(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Balance Sheet");
        InsertGLAccount(WhseDemoAccount.ResaleInterim(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Balance Sheet");
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
        if WhseDemoDataSetup."Company Type" = WhseDemoDataSetup."Company Type"::VAT then begin
            InsertVATBusPostingGroup(WhseDemoDataSetup."Domestic Code", DomesticTxt);
            if WhseDemoDataSetup."Customer VAT Bus. Code" <> '' then
                InsertVATBusPostingGroup(WhseDemoDataSetup."Customer VAT Bus. Code", DomesticTxt);
            if WhseDemoDataSetup."Vendor VAT Bus. Code" <> '' then
                InsertVATBusPostingGroup(WhseDemoDataSetup."Vendor VAT Bus. Code", DomesticTxt);
        end;

        InsertGenBusPostingGroup(WhseDemoDataSetup."Cust. Gen. Bus. Posting Group", DomesticTxt, WhseDemoDataSetup."Domestic Code");
        InsertGenBusPostingGroup(WhseDemoDataSetup."Vend. Gen. Bus. Posting Group", DomesticTxt, WhseDemoDataSetup."Domestic Code");

        if WhseDemoDataSetup."Company Type" = WhseDemoDataSetup."Company Type"::VAT then
            InsertVATProdPostingGroup(WhseDemoDataSetup."VAT Prod. Posting Group Code", VATIdentifierDescTok);
        InsertGenProdPostingGroup(WhseDemoDataSetup."Retail Code", RetailTxt, WhseDemoDataSetup."VAT Prod. Posting Group Code");

        InsertCustomerPostingGroup(WhseDemoDataSetup."Cust. Posting Group", WhseDemoAccount.CustDomestic());
        InsertVendorPostingGroup(WhseDemoDataSetup."Vendor Posting Group", WhseDemoAccount.VendDomestic());
    end;

    local procedure CreatePostingSetups()
    begin
        InsertGeneralPostingSetup('', WhseDemoDataSetup."Retail Code", WhseDemoAccount.SalesDomestic(), WhseDemoAccount.PurchDomestic());

        InsertGeneralPostingSetup(WhseDemoDataSetup."Cust. Posting Group", WhseDemoDataSetup."Retail Code", WhseDemoAccount.SalesDomestic(), WhseDemoAccount.PurchDomestic());

        if WhseDemoDataSetup."Company Type" = WhseDemoDataSetup."Company Type"::VAT then begin
            InsertVATPostingSetup(WhseDemoDataSetup."Domestic Code", WhseDemoDataSetup."VAT Prod. Posting Group Code");

            if WhseDemoDataSetup."Customer VAT Bus. Code" <> '' then
                InsertVATPostingSetup(WhseDemoDataSetup."Customer VAT Bus. Code", WhseDemoDataSetup."VAT Prod. Posting Group Code");
            if WhseDemoDataSetup."Vendor VAT Bus. Code" <> '' then
                InsertVATPostingSetup(WhseDemoDataSetup."Vendor VAT Bus. Code", WhseDemoDataSetup."VAT Prod. Posting Group Code");
        end;
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
        GLAccount.Insert(RunTrigger);
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
        GenProductPostingGroup.Insert(RunTrigger);
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
        if WhseDemoDataSetup."Company Type" = WhseDemoDataSetup."Company Type"::VAT then begin
            GenBusinessPostingGroup."Def. VAT Bus. Posting Group" := DefVATBusPostingGroup;
            if DefVATBusPostingGroup <> '' then
                GenBusinessPostingGroup."Auto Insert Default" := true;
        end;

        OnBeforeGenBusinessPostingGroupInsert(GenBusinessPostingGroup);
        GenBusinessPostingGroup.Insert(RunTrigger);
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
        GeneralPostingSetup.Insert(RunTrigger);
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
        InventoryPostingGroup.Insert(RunTrigger);
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
        RegisteredInvtMovementNos: Code[20])
    var
        InventorySetup: Record "Inventory Setup";
        IsHandled: Boolean;
    begin
        if not InventorySetup.Get() then begin
            InventorySetup.Init();
            InventorySetup."Primary Key" := PrimaryKey;
            InventorySetup."Location Mandatory" := LocationMandatory;
            InventorySetup."Copy Item Descr. to Entries" := CopyItemDescrtoEntries;
            InventorySetup.Insert(RunTrigger);
        end;
        OnBeforePopulateInventorySetupFields(InventorySetup, IsHandled);
        if IsHandled then
            exit;
        // Validate that key Number Series fields are populated, often required in CRONUS SaaS Eval Data
        InventorySetup."Item Nos." := CheckNoSeriesSetup(InventorySetup."Item Nos.", ItemNos, SeriesItemNosDescTok, SeriesItemNosStartTok, SeriesItemNosEndTok);
        InventorySetup."Transfer Order Nos." := CheckNoSeriesSetup(InventorySetup."Transfer Order Nos.", TransferOrderNos, SeriesTransferOrderNosDescTok, SeriesTransferOrderNosStartTok, SeriesTransferOrderNosEndTok);
        InventorySetup."Posted Transfer Shpt. Nos." := CheckNoSeriesSetup(InventorySetup."Posted Transfer Shpt. Nos.", PostedTransferShptNos, SeriesPostedTransferShptNosDescTok, SeriesPostedTransferShptNosStartTok, SeriesPostedTransferShptNosEndTok);
        InventorySetup."Posted Transfer Rcpt. Nos." := CheckNoSeriesSetup(InventorySetup."Posted Transfer Rcpt. Nos.", PostedTransferRcptNos, SeriesPostedTransferRcptNosDescTok, SeriesPostedTransferRcptNosStartTok, SeriesPostedTransferRcptNosEndTok);
        InventorySetup."Inventory Pick Nos." := CheckNoSeriesSetup(InventorySetup."Inventory Pick Nos.", InventoryPickNos, SeriesInventoryPickNosDescTok, SeriesInventoryPickNosStartTok, SeriesInventoryPickNosEndTok);
        InventorySetup."Posted Invt. Pick Nos." := CheckNoSeriesSetup(InventorySetup."Posted Invt. Pick Nos.", PostedInvtPickNos, SeriesPostedInvtPickNosDescTok, SeriesPostedInvtPickNosStartTok, SeriesPostedInvtPickNosEndTok);
        InventorySetup."Inventory Put-Away Nos." := CheckNoSeriesSetup(InventorySetup."Inventory Put-Away Nos.", InventoryPutAwayNos, SeriesInventoryPutAwayNosDescTok, SeriesInventoryPutAwayNosStartTok, SeriesInventoryPutAwayNosEndTok);
        InventorySetup."Posted Invt. Put-Away Nos." := CheckNoSeriesSetup(InventorySetup."Posted Invt. Put-Away Nos.", PostedInvtPutAwayNos, SeriesPostedInvtPutAwayNosDescTok, SeriesPostedInvtPutAwayNosStartTok, SeriesPostedInvtPutAwayNosEndTok);
        InventorySetup."Inventory Movement Nos." := CheckNoSeriesSetup(InventorySetup."Inventory Movement Nos.", InventoryMovementNos, SeriesInventoryMovementNosDescTok, SeriesInventoryMovementNosStartTok, SeriesInventoryMovementNosEndTok);
        InventorySetup."Registered Invt. Movement Nos." := CheckNoSeriesSetup(InventorySetup."Registered Invt. Movement Nos.", RegisteredInvtMovementNos, SeriesRegisteredInvtMovementNosDescTok, SeriesRegisteredInvtMovementNosStartTok, SeriesRegisteredInvtMovementNosEndTok);
        InventorySetup.Modify(RunTrigger);
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
        InventoryPostingSetup.Insert(RunTrigger);
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
            WarehouseSetup.Insert(RunTrigger);
        end;
        OnBeforePopulateWarehouseSetupFields(WarehouseSetup, IsHandled);
        if IsHandled then
            exit;
        WarehouseSetup."Whse. Receipt Nos." := CheckNoSeriesSetup(WarehouseSetup."Whse. Receipt Nos.", WhseReceiptNos, SeriesWhseReceiptNosDescTok, SeriesWhseReceiptNosStartTok, SeriesWhseReceiptNosEndTok);
        WarehouseSetup."Posted Whse. Receipt Nos." := CheckNoSeriesSetup(WarehouseSetup."Posted Whse. Receipt Nos.", WhsePostedReceiptNos, SeriesWhsePostedReceiptNosDescTok, SeriesWhsePostedReceiptNosStartTok, SeriesWhsePostedReceiptNosEndTok);
        WarehouseSetup."Whse. Ship Nos." := CheckNoSeriesSetup(WarehouseSetup."Whse. Ship Nos.", WhseShipNos, SeriesWhseShipNosDescTok, SeriesWhseShipNosStartTok, SeriesWhseShipNosEndTok);
        WarehouseSetup."Posted Whse. Shipment Nos." := CheckNoSeriesSetup(WarehouseSetup."Posted Whse. Shipment Nos.", WhsePostedShipNos, SeriesWhsePostedShipNosDescTok, SeriesWhsePostedShipNosStartTok, SeriesWhsePostedShipNosEndTok);
        WarehouseSetup."Whse. Put-away Nos." := CheckNoSeriesSetup(WarehouseSetup."Whse. Put-away Nos.", WhsePutAwayNos, SeriesWhsePutAwayNosDescTok, SeriesWhsePutAwayNosStartTok, SeriesWhsePutAwayNosEndTok);
        WarehouseSetup."Registered Whse. Put-away Nos." := CheckNoSeriesSetup(WarehouseSetup."Registered Whse. Put-away Nos.", WhseRegPutAwayNos, SeriesWhseRegPutAwayNosDescTok, SeriesWhseRegPutAwayNosStartTok, SeriesWhseRegPutAwayNosEndTok);
        WarehouseSetup."Whse. Pick Nos." := CheckNoSeriesSetup(WarehouseSetup."Whse. Pick Nos.", WhsePickNos, SeriesWhsePickNosDescTok, SeriesWhsePickNosStartTok, SeriesWhsePickNosEndTok);
        WarehouseSetup."Registered Whse. Pick Nos." := CheckNoSeriesSetup(WarehouseSetup."Registered Whse. Pick Nos.", WhseRegPickNos, SeriesWhseRegPickNosDescTok, SeriesWhseRegPickNosStartTok, SeriesWhseRegPickNosEndTok);
        WarehouseSetup."Whse. Movement Nos." := CheckNoSeriesSetup(WarehouseSetup."Whse. Movement Nos.", WhseMovementNos, SeriesWhseMovementNosDescTok, SeriesWhseMovementNosStartTok, SeriesWhseMovementNosEndTok);
        WarehouseSetup."Registered Whse. Movement Nos." := CheckNoSeriesSetup(WarehouseSetup."Registered Whse. Movement Nos.", WhseRegMovementNos, SeriesWhseRegMovementNosDescTok, SeriesWhseRegMovementNosStartTok, SeriesWhseRegMovementNosEndTok);
        WarehouseSetup.Modify(RunTrigger);
    end;

    local procedure CreateInventorySetups(ShouldRunInsertTriggers: Boolean)
    begin
        RunTrigger := ShouldRunInsertTriggers;
        CreateInventoryPostingGroup(WhseDemoDataSetup."Resale Code", ResaleTxt);

        CreateInventorySetup('', false, SeriesItemNosTok, false, SeriesTransferOrderNosTok, SeriesPostedTransferShptNosTok, SeriesPostedTransferRcptNosTok,
            SeriesInventoryPutAwayNosTok, SeriesInventoryPickNosTok, SeriesPostedInvtPutAwayNosTok, SeriesPostedInvtPickNosTok,
            SeriesInventoryMovementNosTok, SeriesRegisteredInvtMovementNosTok);

        CreateInventoryPostingSetup('', WhseDemoDataSetup."Resale Code", WhseDemoAccount.Resale(), '', false, WhseDemoAccount.ResaleInterim());
        CreateInventoryPostingSetup(WhseDemoDataSetup."Location Bin", WhseDemoDataSetup."Resale Code", WhseDemoAccount.Resale(), '', false, WhseDemoAccount.ResaleInterim());
        CreateInventoryPostingSetup(WhseDemoDataSetup."Location Adv Logistics", WhseDemoDataSetup."Resale Code", WhseDemoAccount.Resale(), '', false, WhseDemoAccount.ResaleInterim());
        CreateInventoryPostingSetup(WhseDemoDataSetup."Location Directed Pick", WhseDemoDataSetup."Resale Code", WhseDemoAccount.Resale(), '', false, WhseDemoAccount.ResaleInterim());
        CreateInventoryPostingSetup(WhseDemoDataSetup."Location In-Transit", WhseDemoDataSetup."Resale Code", WhseDemoAccount.Resale(), '', false, WhseDemoAccount.ResaleInterim());

        CreateWarehouseSetup(SeriesWhseReceiptNosTok, SeriesWhsePostedReceiptNosTok, SeriesWhseShipNosTok, SeriesWhsePostedShipNosTok,
            SeriesWhsePutAwayNosTok, SeriesWhseRegPutAwayNosTok, SeriesWhsePickNosTok, SeriesWhseRegPickNosTok, SeriesWhseMovementNosTok, SeriesWhseRegMovementNosTok);
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
        CustomerPostingGroup.Insert(RunTrigger);
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
        VendorPostingGroup.Insert(RunTrigger);
    end;

    local procedure InsertVATBusPostingGroup(BusinessGroupCode: Code[20]; BusinessGroupDescription: Text[100])
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
    begin
        if VATBusinessPostingGroup.Get(BusinessGroupCode) then
            exit;

        VATBusinessPostingGroup.Init();
        VATBusinessPostingGroup.Code := BusinessGroupCode;
        VATBusinessPostingGroup.Description := BusinessGroupDescription;
        OnBeforeInsertVATBusPostingGroup(VATBusinessPostingGroup);
        VATBusinessPostingGroup.Insert(RunTrigger);
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
        VATProductPostingGroup.Insert(RunTrigger);
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
        VATPostingSetup.Description := StrSubstNo(VATSetupDescTok, VATBusinessGroupCode, VATProductGroupCode);
        VATPostingSetup."Sales VAT Account" := WhseDemoAccount.SalesVAT();
        VATPostingSetup."Purchase VAT Account" := WhseDemoAccount.PurchaseVAT();
        VATPostingSetup."VAT Identifier" := VATIdentifierTok;
        VATPostingSetup."VAT %" := 25;
        VATPostingSetup."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type"::"Normal VAT";
        OnBeforeInsertVATPostingSetup(VATPostingSetup);
        VATPostingSetup.Insert(RunTrigger);
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
            NoSeries.Insert(RunTrigger);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := NumberSeriesCode;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine.Insert(RunTrigger);
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
