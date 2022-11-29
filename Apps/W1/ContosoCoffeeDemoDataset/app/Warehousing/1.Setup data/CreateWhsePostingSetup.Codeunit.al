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
        XDomesticTxt: Label 'Domestic customers and vendors', MaxLength = 50;
        XRetailTxt: Label 'Retail Items', MaxLength = 50;
        XVATSetupDescTok: Label 'Setup for %1 / %2', MaxLength = 100, Comment = '%1 is the VAT Bus. Posting Group Code, %2 is the VAT Prod. Posting Group Code';
        XVATIdentifierTok: Label 'VAT25', MaxLength = 50;

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

        InsertGLAccount(WhseDemoAccount.Finished(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Balance Sheet", 0, '', 0, '', '', false);
        InsertGLAccount(WhseDemoAccount.FinishedInterim(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Balance Sheet", 0, '', 0, '', '', false);
        InsertGLAccount(WhseDemoAccount.FinishedWIP(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Balance Sheet", 0, '', 0, '', '', false);
        InsertGLAccount(WhseDemoAccount.CustDomestic(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Balance Sheet", 0, '', 0, '', '', false);
        InsertGLAccount(WhseDemoAccount.VendDomestic(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Balance Sheet", 0, '', 0, '', '', false);
        InsertGLAccount(WhseDemoAccount.SalesDomestic(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);
        InsertGLAccount(WhseDemoAccount.PurchDomestic(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);
        InsertGLAccount(WhseDemoAccount.CostOfRetailSold(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);
        InsertGLAccount(WhseDemoAccount.SalesVAT(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Balance Sheet", 0, '', 0, '', '', false);
        InsertGLAccount(WhseDemoAccount.PurchaseVAT(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Balance Sheet", 0, '', 0, '', '', false);

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
        InsertGenBusPostingGroup(WhseDemoDataSetup."Domestic Code", XDomesticTxt, WhseDemoDataSetup."Domestic Code");

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

    local procedure InsertGLAccount("No.": Code[20]; AccountType: Enum "G/L Account Type"; "Income/Balance": Enum "G/L Account Income/Balance"; NoOfBlankLines: Integer; Totaling: Text[30]; GenPostingType: Option; GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; "Direct Posting": Boolean)
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
        if GLAccount."Account Type" = GLAccount."Account Type"::Posting then
            GLAccount.Validate("Direct Posting", "Direct Posting");
        GLAccount.Validate("Income/Balance", "Income/Balance");
        GLAccount.Validate("No. of Blank Lines", NoOfBlankLines);
        if Totaling <> '' then
            GLAccount.Validate(Totaling, Totaling);
        GLAccount.Validate("Gen. Posting Type", GenPostingType);
        GLAccount.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        GLAccount.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);
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

    local procedure TextAsDateFormula(InputText: Text) OutputDateFormula: DateFormula
    begin
        Evaluate(OutputDateFormula, InputText);
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
        AutomaticCostAdjustment: Enum "Automatic Cost Adjustment Type";
        PreventNegativeInventory: Boolean;
        VariantMandatoryifExists: Boolean;
        SkipPrompttoCreateItem: Boolean;
        CopyItemDescrtoEntries: Boolean;
        InvtCostJnlTemplateName: Code[10];
        InvtCostJnlBatchName: Code[10];
        TransferOrderNos: Code[20];
        PostedTransferShptNos: Code[20];
        PostedTransferRcptNos: Code[20];
        CopyCommentsOrdertoShpt: Boolean;
        CopyCommentsOrdertoRcpt: Boolean;
        NonstockItemNos: Code[20];
        OutboundWhseHandlingTime: DateFormula;
        InboundWhseHandlingTime: DateFormula;
        ExpectedCostPostingtoGL: Boolean;
        DefaultCostingMethod: Enum "Costing Method";
        AverageCostCalcType: Enum "Average Cost Calculation Type";
        AverageCostPeriod: Option;
        AllowInvtDocReservation: Boolean;
        InvtReceiptNos: Code[20];
        PostedInvtReceiptNos: Code[20];
        InvtShipmentNos: Code[20];
        PostedInvtShipmentNos: Code[20];
        CopyCommentstoInvtDoc: Boolean;
        DirectTransferPosting: Option;
        PostedDirectTransNos: Code[20];
        PackageNos: Code[20];
        PhysInvtOrderNos: Code[20];
        PostedPhysInvtOrderNos: Code[20];
        PackageCaption: Text[30];
        ItemGroupDimensionCode: Code[20];
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
        if InventorySetup.Get() then begin
            // Validate that key Number Series fields are populated, often required in CRONUS SaaS Eval Data
            InventorySetup."Inventory Pick Nos." := CheckNoSeriesSetup(InventorySetup."Inventory Pick Nos.", InventoryPickNos, 'Inventory Pick', 'IPI000001', 'IPI999999');
            InventorySetup."Posted Invt. Pick Nos." := CheckNoSeriesSetup(InventorySetup."Posted Invt. Pick Nos.", PostedInvtPickNos, 'Posted Invt. Pick', 'PPI000001', 'PPI999999');
            InventorySetup."Inventory Put-Away Nos." := CheckNoSeriesSetup(InventorySetup."Inventory Put-Away Nos.", InventoryPutAwayNos, 'Inventory Put-Away', 'IPI000001', 'IPU999999');
            InventorySetup."Posted Invt. Put-Away Nos." := CheckNoSeriesSetup(InventorySetup."Posted Invt. Put-Away Nos.", PostedInvtPutAwayNos, 'Posted Invt. Put-Away', 'PPU000001', 'PPI999999');
            InventorySetup."Inventory Movement Nos." := CheckNoSeriesSetup(InventorySetup."Inventory Movement Nos.", InventoryMovementNos, 'Inventory Movement', 'IM000001', 'IM999999');
            InventorySetup."Registered Invt. Movement Nos." := CheckNoSeriesSetup(InventorySetup."Registered Invt. Movement Nos.", RegisteredInvtMovementNos, 'Reg. Inventory Movement', 'RIM000001', 'RIM999999');
            InventorySetup."Internal Movement Nos." := CheckNoSeriesSetup(InventorySetup."Internal Movement Nos.", InternalMovementNos, 'Internal Movement', 'RINTM000001', 'RINTM999999');
            InventorySetup.Modify(true);
        end else begin
            InventorySetup.Init();
            InventorySetup."Primary Key" := PrimaryKey;
            InventorySetup."Automatic Cost Posting" := AutomaticCostPosting;
            InventorySetup."Location Mandatory" := LocationMandatory;
            InventorySetup."Item Nos." := ItemNos;
            InventorySetup."Automatic Cost Adjustment" := AutomaticCostAdjustment;
            InventorySetup."Prevent Negative Inventory" := PreventNegativeInventory;
            InventorySetup."Variant Mandatory if Exists" := VariantMandatoryifExists;
            InventorySetup."Skip Prompt to Create Item" := SkipPrompttoCreateItem;
            InventorySetup."Copy Item Descr. to Entries" := CopyItemDescrtoEntries;
            InventorySetup."Invt. Cost Jnl. Template Name" := InvtCostJnlTemplateName;
            InventorySetup."Invt. Cost Jnl. Batch Name" := InvtCostJnlBatchName;
            InventorySetup."Transfer Order Nos." := TransferOrderNos;
            InventorySetup."Posted Transfer Shpt. Nos." := PostedTransferShptNos;
            InventorySetup."Posted Transfer Rcpt. Nos." := PostedTransferRcptNos;
            InventorySetup."Copy Comments Order to Shpt." := CopyCommentsOrdertoShpt;
            InventorySetup."Copy Comments Order to Rcpt." := CopyCommentsOrdertoRcpt;
            InventorySetup."Nonstock Item Nos." := NonstockItemNos;
            InventorySetup."Outbound Whse. Handling Time" := OutboundWhseHandlingTime;
            InventorySetup."Inbound Whse. Handling Time" := InboundWhseHandlingTime;
            InventorySetup."Expected Cost Posting to G/L" := ExpectedCostPostingtoGL;
            InventorySetup."Default Costing Method" := DefaultCostingMethod;
            InventorySetup."Average Cost Calc. Type" := AverageCostCalcType;
            InventorySetup."Average Cost Period" := AverageCostPeriod;
            InventorySetup."Allow Invt. Doc. Reservation" := AllowInvtDocReservation;
            InventorySetup."Invt. Receipt Nos." := InvtReceiptNos;
            InventorySetup."Posted Invt. Receipt Nos." := PostedInvtReceiptNos;
            InventorySetup."Invt. Shipment Nos." := InvtShipmentNos;
            InventorySetup."Posted Invt. Shipment Nos." := PostedInvtShipmentNos;
            InventorySetup."Copy Comments to Invt. Doc." := CopyCommentstoInvtDoc;
            InventorySetup."Direct Transfer Posting" := DirectTransferPosting;
            InventorySetup."Posted Direct Trans. Nos." := PostedDirectTransNos;
            InventorySetup."Package Nos." := PackageNos;
            InventorySetup."Phys. Invt. Order Nos." := PhysInvtOrderNos;
            InventorySetup."Posted Phys. Invt. Order Nos." := PostedPhysInvtOrderNos;
            InventorySetup."Package Caption" := PackageCaption;
            InventorySetup."Item Group Dimension Code" := ItemGroupDimensionCode;
            InventorySetup."Inventory Put-away Nos." := InventoryPutawayNos;
            InventorySetup."Inventory Pick Nos." := InventoryPickNos;
            InventorySetup."Posted Invt. Put-away Nos." := PostedInvtPutawayNos;
            InventorySetup."Posted Invt. Pick Nos." := PostedInvtPickNos;
            InventorySetup."Inventory Movement Nos." := InventoryMovementNos;
            InventorySetup."Registered Invt. Movement Nos." := RegisteredInvtMovementNos;
            InventorySetup."Internal Movement Nos." := InternalMovementNos;
            InventorySetup.Insert(DoInsertTriggers);
        end;
    end;

    local procedure CreateInventoryPostingSetup(
        LocationCode: Code[10];
        InvtPostingGroupCode: Code[20];
        InventoryAccount: Code[20];
        Description: Text[100];
        ViewAllAccountsonLookup: Boolean;
        InventoryAccountInterim: Code[20];
        WIPAccount: Code[20];
        MaterialVarianceAccount: Code[20];
        CapacityVarianceAccount: Code[20];
        MfgOverheadVarianceAccount: Code[20];
        CapOverheadVarianceAccount: Code[20];
        SubcontractedVarianceAccount: Code[20]
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
        InventoryPostingSetup."WIP Account" := WIPAccount;
        InventoryPostingSetup."Material Variance Account" := MaterialVarianceAccount;
        InventoryPostingSetup."Capacity Variance Account" := CapacityVarianceAccount;
        InventoryPostingSetup."Mfg. Overhead Variance Account" := MfgOverheadVarianceAccount;
        InventoryPostingSetup."Cap. Overhead Variance Account" := CapOverheadVarianceAccount;
        InventoryPostingSetup."Subcontracted Variance Account" := SubcontractedVarianceAccount;
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
        if WarehouseSetup.Get() then begin
            WarehouseSetup."Whse. Receipt Nos." := CheckNoSeriesSetup(WarehouseSetup."Whse. Receipt Nos.", WhseReceiptNos, 'Whse. Receipt', 'RE000001', 'RE999999');
            WarehouseSetup."Posted Whse. Receipt Nos." := CheckNoSeriesSetup(WarehouseSetup."Posted Whse. Receipt Nos.", WhsePostedReceiptNos, 'Posted Whse. Receipt', 'R_000001', 'R_999999');
            WarehouseSetup."Whse. Ship Nos." := CheckNoSeriesSetup(WarehouseSetup."Whse. Ship Nos.", WhseShipNos, 'Whse. Ship', 'SH000001', 'SH999999');
            WarehouseSetup."Posted Whse. Shipment Nos." := CheckNoSeriesSetup(WarehouseSetup."Posted Whse. Shipment Nos.", WhsePostedShipNos, 'Posted Whse. Shpt.', 'S_000001', 'S_999999');
            WarehouseSetup."Whse. Put-away Nos." := CheckNoSeriesSetup(WarehouseSetup."Whse. Put-away Nos.", WhsePutAwayNos, 'Whse. Put-away', 'PU000001', 'PU999999');
            WarehouseSetup."Registered Whse. Put-away Nos." := CheckNoSeriesSetup(WarehouseSetup."Registered Whse. Put-away Nos.", WhseRegPutAwayNos, 'Registered Whse. Put-away', 'PU_000001', 'PU_999999');
            WarehouseSetup."Whse. Pick Nos." := CheckNoSeriesSetup(WarehouseSetup."Whse. Pick Nos.", WhsePickNos, 'Whse. Pick', 'PI000001', 'PI999999');
            WarehouseSetup."Registered Whse. Pick Nos." := CheckNoSeriesSetup(WarehouseSetup."Registered Whse. Pick Nos.", WhseRegPickNos, 'Registered Whse. Put-away', 'P_000001', 'P_999999');
            WarehouseSetup."Whse. Movement Nos." := CheckNoSeriesSetup(WarehouseSetup."Whse. Movement Nos.", WhseMovementNos, 'Whse. Movement', 'WM000001', 'WM999999');
            WarehouseSetup."Registered Whse. Movement Nos." := CheckNoSeriesSetup(WarehouseSetup."Registered Whse. Movement Nos.", WhseRegMovementNos, 'Registered Whse. Movement', 'WM_000001', 'WM_999999');
            WarehouseSetup.Modify(true);
        end else begin
            WarehouseSetup.Init();
            WarehouseSetup."Whse. Receipt Nos." := WhseReceiptNos;
            WarehouseSetup."Posted Whse. Receipt Nos." := WhsePostedReceiptNos;
            WarehouseSetup."Whse. Ship Nos." := WhseShipNos;
            WarehouseSetup."Posted Whse. Shipment Nos." := WhsePostedShipNos;
            WarehouseSetup."Whse. Put-away Nos." := WhsePutAwayNos;
            WarehouseSetup."Registered Whse. Put-away Nos." := WhseRegPutAwayNos;
            WarehouseSetup."Whse. Pick Nos." := WhsePickNos;
            WarehouseSetup."Registered Whse. Pick Nos." := WhseRegPickNos;
            WarehouseSetup."Whse. Movement Nos." := WhseMovementNos;
            WarehouseSetup."Registered Whse. Movement Nos." := WhseRegMovementNos;
            WarehouseSetup.Insert(true);
        end;
    end;

    local procedure CreateCollection(ShouldRunInsertTriggers: Boolean)
    begin
        DoInsertTriggers := ShouldRunInsertTriggers;
        CreateInventoryPostingGroup('FINISHED', 'Finished items');
        CreateInventoryPostingGroup('RAW MAT', 'Raw materials');
        CreateInventoryPostingGroup('RESALE', 'Resale items');

        CreateInventorySetup('', false, false, 'ITEM1', Enum::"Automatic Cost Adjustment Type"::Never, false, false, false, false, '', '', 'T-ORD', 'T-SHPT', 'T-RCPT', true, true, 'NS-ITEM', TextAsDateFormula(''), TextAsDateFormula(''), false, Enum::"Costing Method"::FIFO, Enum::"Average Cost Calculation Type"::"Item & Location & Variant", 1, false, 'I-RCPT', 'I-RCPT+', 'I-SHPT', 'I-SHPT+', false, 0, 'PDIRTRANS', '', 'PHYS-INV', 'PHYS-INV+', '', '', 'I-PUT', 'I-PICK', 'I-PUT+', 'I-PICK+', 'I-MOVEMENT', 'I-MOVE+', 'INT-MOVE');

        CreateInventoryPostingSetup('', 'FINISHED', '2120', '', false, '2121', '2140', '7890', '7891', '7894', '7893', '7892');
        CreateInventoryPostingSetup('', 'RAW MAT', '2130', '', false, '2131', '2140', '7890', '7891', '7894', '7893', '7892');
        CreateInventoryPostingSetup('', 'RESALE', '2110', '', false, '2111', '2140', '7890', '7891', '7894', '7893', '7892');
        CreateInventoryPostingSetup('SILVER', 'FINISHED', '2120', '', false, '2121', '2140', '7890', '7891', '7894', '7893', '7892');
        CreateInventoryPostingSetup('SILVER', 'RAW MAT', '2130', '', false, '2131', '2140', '7890', '7891', '7894', '7893', '7892');
        CreateInventoryPostingSetup('SILVER', 'RESALE', '2110', '', false, '2111', '2140', '7890', '7891', '7894', '7893', '7892');
        CreateInventoryPostingSetup('WHITE', 'FINISHED', '2120', '', false, '2121', '2140', '7890', '7891', '7894', '7893', '7892');
        CreateInventoryPostingSetup('WHITE', 'RAW MAT', '2130', '', false, '2131', '2140', '7890', '7891', '7894', '7893', '7892');
        CreateInventoryPostingSetup('WHITE', 'RESALE', '2110', '', false, '2111', '2140', '7890', '7891', '7894', '7893', '7892');
        CreateInventoryPostingSetup('YELLOW', 'FINISHED', '2120', '', false, '2121', '2140', '7890', '7891', '7894', '7893', '7892');
        CreateInventoryPostingSetup('YELLOW', 'RAW MAT', '2130', '', false, '2131', '2140', '7890', '7891', '7894', '7893', '7892');
        CreateInventoryPostingSetup('YELLOW', 'RESALE', '2110', '', false, '2111', '2140', '7890', '7891', '7894', '7893', '7892');

        CreateWarehouseSetup('WMS-RCPT', 'WMS-RCPT+', 'WMS-SHIP', 'WMS-SHIP+', 'WMS-PUT', 'WMS-PUT+', 'WMS-PICK', 'WMS-PICK+', 'WMS-MOV', 'WMS-MOV+');
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
        CustomerPostingGroup.Insert(true);
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
        VendorPostingGroup.Insert(true);
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
        VATBusPostingGroup.Insert(true);
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
        VATProdPostingGroup.Insert(true);
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
        VATPostingSetup.Insert(true);
    end;

    local procedure CheckNoSeriesSetup(CurrentSetupField: Code[20]; NumberSeriesCode: Code[20]; SeriesDescription: Text; StartNo: Text; EndNo: Text) NewSetupValue: Code[20]
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
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := NumberSeriesCode;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine.Insert(true);
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
