codeunit 5278 "Create No. Series"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: codeunit "Contoso No Series";
    begin
        ContosoNoSeries.InsertNoSeries(AssemblyBlanketOrders(), AssemblyBlanketOrdersLbl, 'A00001', 'A01000', 'A00995', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(AssemblyOrders(), AssemblyOrdersLbl, 'A00001', 'A01000', 'A00995', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(PostedAssemblyOrders(), PostedAssemblyOrdersLbl, 'A00001', 'A01000', 'A00995', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(AssemblyQuote(), AssemblyQuoteLbl, 'A00001', 'A01000', 'A00995', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(Bank(), BANKLbl, 'B010', 'B990', '', '', 10, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(Campaign(), CampaignLbl, 'CP0001', 'CP9999', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(CashFlow(), CashFlowLbl, 'CF100001', 'CF200000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(Contact(), ContactLbl, 'CT000001', 'CT100000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(DraftInvoice(), DraftInvoiceLbl, 'D-00001', 'D-99999', 'D-99899', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(PostedInvoice(), PostedInvoiceLbl, '00001', '99999', '99899', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(Estimate(), EstimateLbl, 'E-00001', 'E-99999', 'E-99899', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(ECSL(), ECSLLbl, 'ECSL-0001', 'ECSL-9999', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(GeneralJournal(), GeneralJournalLbl, 'G00001', 'G01000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(PaymentJournal(), PaymentJournalLbl, 'G04001', 'G05000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(CashReceiptsJournal(), CashReceiptsJournalLbl, 'G02001', 'G03000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(InterCompanyGenJnl(), InterCompanyGenJnlLbl, 'IC0010', 'IC9999', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(Item(), ItemsLbl, '1000', '9999', '9995', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(ItemJournal(), ItemJournalLbl, 'T00001', 'T01000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(InventoryReceipt(), InventoryReceiptLbl, 'IR000001', 'IR999999', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(PostedInventoryReceipt(), PostedInventoryReceiptLbl, 'IR000001', 'IR999999', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(InventoryShipment(), InventoryShipmentLbl, 'IS000001', 'IS999999', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(PostedInventoryShipment(), PostedInventoryShipmentLbl, 'IS000001', 'IS999999', '', '', 1, Enum::"No. Series Implementation"::Normal, true);

        ContosoNoSeries.InsertNoSeries(JobJournal(), JobJournalLbl, 'J00001', 'J01000', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);

        ContosoNoSeries.InsertNoSeries(RecurringJobJournal(), RecurringJobJournalLbl, 'J01001', 'J02000', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(JobWIP(), JobWIPLbl, 'WIP0000001', 'WIP9999999', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(JobPriceList(), JobPriceListLbl, 'J00001', 'J99999', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(LotNumbering(), LotNumberingLbl, 'LOT0001', 'LOT9999', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(CatalogItems(), CatalogItemsLbl, 'NS0001', 'NS0100', 'NS0095', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(Opportunity(), OpportunityLbl, 'OP000001', 'OP999999', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(OrderPromising(), OrderPromisingLbl, 'OP101001', 'OP199999', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(BlanketPurchaseOrder(), BlanketPurchaseOrderLbl, '1001', '2999', '2995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(PurchaseCreditMemo(), PurchaseCreditMemoLbl, '1001', '2999', '2995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(PostedPurchaseCreditMemo(), PostedPurchaseCreditMemoLbl, '109001', '1010999', '1010995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(PostedDirectTransfer(), PostedDirectTransferLbl, 'PDT000001', 'PDT999999', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(PhysicalInventoryOrder(), PhysicalInventoryOrderLbl, 'PHIO00001', 'PHIO99999', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(PostedPhysInventOrder(), PostedPhysInventOrderLbl, 'PPHI00001', 'PPHI99999', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(PurchasePriceList(), PurchasePriceListLbl, 'P00001', 'P99999', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(Vendor(), VendorLbl, 'V00010', 'V99990', '', '', 10, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(PurchaseQuote(), PurchaseQuoteLbl, '1001', '2999', '2995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(PurchaseOrder(), PurchaseOrderLbl, '106001', '107999', '107995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(PurchaseInvoice(), PurchaseInvoiceLbl, '107001', '108999', '108995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(PostedPurchaseInvoice(), PostedPurchaseInvoiceLbl, '108001', '109999', '109995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(PurchaseReceipt(), PurchaseReceiptLbl, '107001', '108999', '108995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(PaymentReconciliationJournals(), PaymentReconciliationJournalsLbl, 'PREC000', 'PREC999', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(PurchaseReturnOrder(), PurchaseReturnOrderLbl, '1001', '2999', '2995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(PostedPurchaseShipment(), PostedPurchaseShipmentLbl, '105001', '106999', '106995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(Resource(), ResourceLbl, 'R0010', 'R9990', '', '', 10, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(BlanketSalesOrder(), BlanketSalesOrderLbl, '1001', '2999', '2995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(SalesCreditMemo(), SalesCreditMemoLbl, '1001', '2999', '2995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(PostedSalesCreditMemo(), PostedSalesCreditMemoLbl, '104001', '105999', '105995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(Segment(), SegmentLbl, 'SM00001', 'SM99999', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(FinanceChargeMemo(), FinanceChargeMemoLbl, '1001', '2999', '2995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(IssuedFinanceChargeMemo(), IssuedFinanceChargeMemoLbl, '106001', '107999', '107995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(SNNumbering1(), SNNumbering1Lbl, 'SN00001', 'SN99999', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(SNNumbering2(), SNNumbering2Lbl, 'XYZ00001', 'XYZ99999', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(SalesPriceList(), SalesPriceListLbl, 'S00001', 'S99999', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(SalesQuote(), SalesQuoteLbl, '1001', '2999', '2995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(PostedSalesReceipt(), PostedSalesReceiptLbl, '107001', '108999', '108995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(Reminder(), ReminderLbl, '1001', '2999', '2995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(IssuedReminder(), IssuedReminderLbl, '105001', '106999', '106995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(SalesReturnOrder(), SalesReturnOrderLbl, '1001', '2999', '2995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(SalesShipment(), SalesShipmentLbl, '102001', '103999', '103995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(Task(), TaskLbl, 'TD000001', 'TD999999', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(TimeSheet(), TimeSheetLbl, 'TS00001', 'TS99999', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(VATReturnPeriods(), VATReturnPeriodsLbl, 'VATPER-0001', 'VATPER-9999', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(VATReturnsReports(), VATReturnsReportsLbl, 'VATRET-0001', 'VATRET-9999', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(Customer(), CustomerLbl, 'C00010', 'C99990', '', '', 10, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(SalesOrder(), SalesOrderLbl, '101001', '102999', '102995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(SalesInvoice(), SalesInvoiceLbl, '102001', '103999', '103995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(PostedSalesInvoice(), PostedSalesInvoiceLbl, '103001', '104999', '104995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(TransferOrder(), TransferOrderLbl, '1001', '2999', '2995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(TransferShipment(), TransferShipmentLbl, '108001', '109999', '109995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(TransferReceipt(), TransferReceiptLbl, '109001', '1010999', '1010995', '', 1, Enum::"No. Series Implementation"::Normal, false);
    end;

    procedure AssemblyBlanketOrders(): Code[20]
    begin
        exit('A-BLK');
    end;

    procedure AssemblyOrders(): Code[20]
    begin
        exit('A-ORD');
    end;

    procedure PostedAssemblyOrders(): Code[20]
    begin
        exit('A-ORD+');
    end;

    procedure AssemblyQuote(): Code[20]
    begin
        exit('A-QUO');
    end;

    procedure Bank(): Code[20]
    begin
        exit('BANK');
    end;

    procedure Campaign(): Code[20]
    begin
        exit('CAMP');
    end;

    procedure CashFlow(): Code[20]
    begin
        exit('CASHFLOW');
    end;

    procedure Contact(): Code[20]
    begin
        exit('CONT');
    end;

    procedure DraftInvoice(): Code[20]
    begin
        exit('D-INV');
    end;

    procedure PostedInvoice(): Code[20]
    begin
        exit('D-INV+');
    end;

    procedure Estimate(): Code[20]
    begin
        exit('D-QUO');
    end;

    procedure ECSL(): Code[20]
    begin
        exit('ECSL');
    end;

    procedure GeneralJournal(): Code[20]
    begin
        exit('GJNL-GEN');
    end;

    procedure PaymentJournal(): Code[20]
    begin
        exit('GJNL-PMT');
    end;

    procedure CashReceiptsJournal(): Code[20]
    begin
        exit('GJNL-RCPT');
    end;

    procedure InterCompanyGenJnl(): Code[20]
    begin
        exit('IC_GJNL');
    end;

    procedure Item(): Code[20]
    begin
        exit(ItemTok);
    end;

    procedure ItemJournal(): Code[20]
    begin
        exit('IJNL-GEN');
    end;

    procedure InventoryReceipt(): Code[20]
    begin
        exit('I-RCPT');
    end;

    procedure PostedInventoryReceipt(): Code[20]
    begin
        exit('I-RCPT+');
    end;

    procedure InventoryShipment(): Code[20]
    begin
        exit('I-SHPT');
    end;

    procedure PostedInventoryShipment(): Code[20]
    begin
        exit('I-SHPT+');
    end;

    procedure JobJournal(): Code[20]
    begin
        exit('JJNL-GEN');
    end;

    procedure RecurringJobJournal(): Code[20]
    begin
        exit('JJNL-REC');
    end;

    procedure JobWIP(): Code[20]
    begin
        exit('JOB-WIP');
    end;

    procedure JobPriceList(): Code[20]
    begin
        exit('J-PL');
    end;

    procedure LotNumbering(): Code[20]
    begin
        exit('LOT');
    end;

    procedure CatalogItems(): Code[20]
    begin
        exit('NS-ITEM');
    end;

    procedure Opportunity(): Code[20]
    begin
        exit('OPP');
    end;

    procedure OrderPromising(): Code[20]
    begin
        exit('O-PROM');
    end;

    procedure BlanketPurchaseOrder(): Code[20]
    begin
        exit('P-BLK');
    end;

    procedure PurchaseCreditMemo(): Code[20]
    begin
        exit('P-CR');
    end;

    procedure PostedPurchaseCreditMemo(): Code[20]
    begin
        exit('P-CR+');
    end;

    procedure PostedDirectTransfer(): Code[20]
    begin
        exit('PDIRTRANS');
    end;

    procedure PhysicalInventoryOrder(): Code[20]
    begin
        exit('PHYS-INV');
    end;

    procedure PostedPhysInventOrder(): Code[20]
    begin
        exit('PHYS-INV+');
    end;

    procedure PurchasePriceList(): Code[20]
    begin
        exit('P-PL');
    end;

    procedure Vendor(): Code[20]
    begin
        exit(VendorTok);
    end;

    procedure PurchaseQuote(): Code[20]
    begin
        exit('P-QUO');
    end;

    procedure PurchaseOrder(): Code[20]
    begin
        exit('P-ORD');
    end;

    procedure PurchaseInvoice(): Code[20]
    begin
        exit('P-INV');
    end;

    procedure PostedPurchaseInvoice(): Code[20]
    begin
        exit('P-INV+');
    end;

    procedure PurchaseReceipt(): Code[20]
    begin
        exit('P-RCPT');
    end;

    procedure PaymentReconciliationJournals(): Code[20]
    begin
        exit('PREC');
    end;

    procedure PurchaseReturnOrder(): Code[20]
    begin
        exit('P-RETORD');
    end;

    procedure PostedPurchaseShipment(): Code[20]
    begin
        exit('P-SHPT');
    end;

    procedure Resource(): Code[20]
    begin
        exit('RES');
    end;

    procedure BlanketSalesOrder(): Code[20]
    begin
        exit('S-BLK');
    end;

    procedure SalesCreditMemo(): Code[20]
    begin
        exit('S-CR');
    end;

    procedure PostedSalesCreditMemo(): Code[20]
    begin
        exit('S-CR+');
    end;

    procedure Segment(): Code[20]
    begin
        exit('SEGM');
    end;

    procedure FinanceChargeMemo(): Code[20]
    begin
        exit('S-FIN');
    end;

    procedure IssuedFinanceChargeMemo(): Code[20]
    begin
        exit('S-FIN+');
    end;

    procedure SNNumbering1(): Code[20]
    begin
        exit('SN1');
    end;

    procedure SNNumbering2(): Code[20]
    begin
        exit('SN2');
    end;

    procedure SalesPriceList(): Code[20]
    begin
        exit('S-PL');
    end;

    procedure SalesQuote(): Code[20]
    begin
        exit('S-QUO');
    end;

    procedure PostedSalesReceipt(): Code[20]
    begin
        exit('S-RCPT');
    end;

    procedure Reminder(): Code[20]
    begin
        exit('S-REM');
    end;

    procedure IssuedReminder(): Code[20]
    begin
        exit('S-REM+');
    end;

    procedure SalesReturnOrder(): Code[20]
    begin
        exit('S-RETORD');
    end;

    procedure SalesShipment(): Code[20]
    begin
        exit('S-SHPT');
    end;

    procedure Task(): Code[20]
    begin
        exit('TASK');
    end;

    procedure TimeSheet(): Code[20]
    begin
        exit('TS');
    end;

    procedure VATReturnPeriods(): Code[20]
    begin
        exit('VATPERIODS');
    end;

    procedure VATReturnsReports(): Code[20]
    begin
        exit('VATREPORTS');
    end;

    procedure Customer(): Code[20]
    begin
        exit(CustTok);
    end;

    procedure SalesOrder(): Code[20]
    begin
        exit(SalesOrderTok);
    end;

    procedure SalesInvoice(): Code[20]
    begin
        exit(SalesInvoiceTok);
    end;

    procedure PostedSalesInvoice(): Code[20]
    begin
        exit(PostedInvTok);
    end;

    procedure TransferOrder(): Code[20]
    begin
        exit(TransferOrderTok);
    end;

    procedure TransferShipment(): Text[20]
    begin
        exit(TransferShipmentTok);
    end;

    procedure TransferReceipt(): Text[20]
    begin
        exit(TransferReceiptTok);
    end;

    var
        AssemblyBlanketOrdersLbl: Label 'Assembly Blanket Orders', MaxLength = 100;
        AssemblyOrdersLbl: Label 'Assembly Orders', MaxLength = 100;
        PostedAssemblyOrdersLbl: Label 'Posted Assembly Orders', MaxLength = 100;
        AssemblyQuoteLbl: Label 'Assembly Quote', MaxLength = 100;
        BANKLbl: Label 'BANK', MaxLength = 100;
        CampaignLbl: Label 'Campaign', MaxLength = 100;
        CashFlowLbl: Label 'CashFlow', MaxLength = 100;
        ContactLbl: Label 'Contact', MaxLength = 100;
        DraftInvoiceLbl: Label 'Draft Invoice', MaxLength = 100;
        PostedInvoiceLbl: Label 'Posted Invoice', MaxLength = 100;
        EstimateLbl: Label 'Estimate', MaxLength = 100;
        ECSLLbl: Label 'EC Sales List reports.', MaxLength = 100;
        GeneralJournalLbl: Label 'General Journal', MaxLength = 100;
        PaymentJournalLbl: Label 'Payment Journal', MaxLength = 100;
        CashReceiptsJournalLbl: Label 'Cash Receipts Journal', MaxLength = 100;
        InterCompanyGenJnlLbl: Label 'InterCompany Gen. Jnl', MaxLength = 100;
        ItemTok: Label 'ITEM', MaxLength = 20;
        ItemsLbl: Label 'Items', MaxLength = 100;
        ItemJournalLbl: Label 'Item Journal', MaxLength = 100;
        InventoryReceiptLbl: Label 'Inventory Receipt', MaxLength = 100;
        PostedInventoryReceiptLbl: Label 'Posted Inventory Receipt', MaxLength = 100;
        InventoryShipmentLbl: Label 'Inventory Shipment', MaxLength = 100;
        PostedInventoryShipmentLbl: Label 'Posted Inventory Shipment', MaxLength = 100;
        JobJournalLbl: Label 'Job Journal', MaxLength = 100;
        RecurringJobJournalLbl: Label 'Recurring Job Journal', MaxLength = 100;
        JobWIPLbl: Label 'Job-WIP', MaxLength = 100;
        JobPriceListLbl: Label 'Job Price List', MaxLength = 100;
        LotNumberingLbl: Label 'Lot Numbering', MaxLength = 100;
        CatalogItemsLbl: Label 'Catalog Items', MaxLength = 100;
        OpportunityLbl: Label 'Opportunity', MaxLength = 100;
        OrderPromisingLbl: Label 'Order Promising', MaxLength = 100;
        BlanketPurchaseOrderLbl: Label 'Blanket Purchase Order', MaxLength = 100;
        PurchaseCreditMemoLbl: Label 'Purchase Credit Memo', MaxLength = 100;
        PostedPurchaseCreditMemoLbl: Label 'Posted Purchase Credit Memo', MaxLength = 100;
        PostedDirectTransferLbl: Label 'Posted Direct Transfer', MaxLength = 100;
        PhysicalInventoryOrderLbl: Label 'Physical Inventory Order', MaxLength = 100;
        PostedPhysInventOrderLbl: Label 'Posted Phys. Invent. Order', MaxLength = 100;
        PurchasePriceListLbl: Label 'Purchase Price List', MaxLength = 100;
        PurchaseQuoteLbl: Label 'Purchase Quote', MaxLength = 100;
        PurchaseOrderLbl: Label 'Purchase Order', MaxLength = 100;
        PurchaseInvoiceLbl: Label 'Purchase Invoice', MaxLength = 100;
        PostedPurchaseInvoiceLbl: Label 'Posted Purchase Invoice', MaxLength = 100;
        PurchaseReceiptLbl: Label 'Purchase Receipt', MaxLength = 100;
        PaymentReconciliationJournalsLbl: Label 'Payment Reconciliation Journals', MaxLength = 100;
        PurchaseReturnOrderLbl: Label 'Purchase Return Order', MaxLength = 100;
        PostedPurchaseShipmentLbl: Label 'Posted Purchase Shipment', MaxLength = 100;
        ResourceLbl: Label 'Resource', MaxLength = 100;
        BlanketSalesOrderLbl: Label 'Blanket Sales Order', MaxLength = 100;
        SalesCreditMemoLbl: Label 'Sales Credit Memo', MaxLength = 100;
        PostedSalesCreditMemoLbl: Label 'Posted Sales Credit Memo', MaxLength = 100;
        SegmentLbl: Label 'Segment', MaxLength = 100;
        FinanceChargeMemoLbl: Label 'Finance Charge Memo', MaxLength = 100;
        IssuedFinanceChargeMemoLbl: Label 'Issued Finance Charge Memo', MaxLength = 100;
        SNNumbering1Lbl: Label 'SN Numbering', MaxLength = 100;
        SNNumbering2Lbl: Label 'SN Numbering', MaxLength = 100;
        SalesPriceListLbl: Label 'Sales Price List', MaxLength = 100;
        SalesQuoteLbl: Label 'Sales Quote', MaxLength = 100;
        PostedSalesReceiptLbl: Label 'Posted Sales Receipt', MaxLength = 100;
        ReminderLbl: Label 'Reminder', MaxLength = 100;
        IssuedReminderLbl: Label 'Issued Reminder', MaxLength = 100;
        SalesReturnOrderLbl: Label 'Sales Return Order', MaxLength = 100;
        SalesShipmentLbl: Label 'Sales Shipment', MaxLength = 100;
        TaskLbl: Label 'Task', MaxLength = 100;
        TimeSheetLbl: Label 'Time Sheet', MaxLength = 100;
        VATReturnPeriodsLbl: Label 'VAT Return Periods', MaxLength = 100;
        VATReturnsReportsLbl: Label 'VAT Returns reports.', MaxLength = 100;
        VendorLbl: Label 'Vendor', MaxLength = 100;
        VendorTok: Label 'VEND', MaxLength = 20;
        CustTok: Label 'CUST', MaxLength = 20;
        SalesOrderTok: Label 'S-ORD', MaxLength = 20;
        SalesInvoiceTok: Label 'S-INV', MaxLength = 20;
        PostedInvTok: Label 'S-INV+', MaxLength = 20;
        CustomerLbl: Label 'Customer', MaxLength = 100;
        SalesOrderLbl: Label 'Sales Order', MaxLength = 100;
        SalesInvoiceLbl: Label 'Sales Invoice', MaxLength = 100;
        PostedSalesInvoiceLbl: Label 'Posted Sales Invoice', MaxLength = 100;
        TransferOrderTok: Label 'T-ORD', MaxLength = 20;
        TransferOrderLbl: Label 'Transfer Order', MaxLength = 100;
        TransferShipmentTok: Label 'T-SHPT', MaxLength = 20;
        TransferShipmentLbl: Label 'Transfer Shipment', MaxLength = 100;
        TransferReceiptTok: Label 'T-RCPT', MaxLength = 20;
        TransferReceiptLbl: Label 'Transfer Receipt', MaxLength = 100;

}
