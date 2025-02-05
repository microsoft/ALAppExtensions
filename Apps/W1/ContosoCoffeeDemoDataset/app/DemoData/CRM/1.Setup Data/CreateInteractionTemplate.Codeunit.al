codeunit 5385 "Create Interaction Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        CreateInteractionTemplates();
        CreateInteractionTemplateLanguages();

        ContosoCRM.InsertInteractionTemplateSetup(SInvoice(), SCMemo(), SOrderCf(), SQuote(), PInvoice(), PCMemo(), POrder(), PQuote(), Email(), Coversh(), Outgoing(), SBOrder(), '', SShip(), SStatm(), SRemind(), '', PBOrder(), PReceipt(), SRetOrd(), SRetRcp(), SFinChg(), PRtShip(), PRtOrdC(), Meetinv(), EmailD(), SDraftIn());
    end;

    local procedure CreateInteractionTemplates()
    var
        ContosoCRM: Codeunit "Contoso CRM";
        CreateInteractionGroup: Codeunit "Create Interaction Group";
    begin
        ContosoCRM.InsertInteractionTemplate(Abstract(), CreateInteractionGroup.Letter(), AbstractsOfMeetingLbl, 8, 90, 1, 0, Enum::"Correspondence Type"::"Hard Copy", Enum::"Interaction Template Wizard Action"::" ", true);
        ContosoCRM.InsertInteractionTemplate(Bus(), CreateInteractionGroup.Letter(), BusinessLetterLbl, 8, 30, 1, 1, Enum::"Correspondence Type"::"Hard Copy", Enum::"Interaction Template Wizard Action"::" ", true);
        ContosoCRM.InsertInteractionTemplate(Coversh(), CreateInteractionGroup.System(), CoversheetLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(Email(), CreateInteractionGroup.System(), EmailsLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(EmailD(), CreateInteractionGroup.System(), EmailDraftLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(Golf(), CreateInteractionGroup.Letter(), GolfEventLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::Email, Enum::"Interaction Template Wizard Action"::Merge, true);
        ContosoCRM.InsertInteractionTemplate(Income(), CreateInteractionGroup.Phone(), IncomingPhoneCallLbl, 0, 15, 2, 2, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", true);
        ContosoCRM.InsertInteractionTemplate(Inhouse(), CreateInteractionGroup.Meeting(), MeetingHeldAtCronusLbl, 25, 120, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(Meetinv(), CreateInteractionGroup.System(), MeetingInvitationLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(Onsite(), CreateInteractionGroup.Meeting(), MeetingAtCustomersSiteLbl, 45, 180, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(Outgoing(), CreateInteractionGroup.Phone(), OutgoingPhoneCallLbl, 1, 15, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", true);
        ContosoCRM.InsertInteractionTemplate(PBOrder(), CreateInteractionGroup.Purchase(), PurchaseBlanketOrderLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(PCMemo(), CreateInteractionGroup.Purchase(), PurchaseCreditMemoLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(PInvoice(), CreateInteractionGroup.Purchase(), PurchaseInvoiceLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(POrder(), CreateInteractionGroup.Purchase(), PurchaseOrderLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(PQuote(), CreateInteractionGroup.Purchase(), PurchaseQuoteLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(PReceipt(), CreateInteractionGroup.Purchase(), PurchaseReceiptLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(PRtOrdC(), CreateInteractionGroup.Purchase(), PurchaseReturnOrderConfirmationLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(PRtShip(), CreateInteractionGroup.Purchase(), PurchaseReturnShipmentLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(SBOrder(), CreateInteractionGroup.Sales(), SalesBlanketOrderLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(SCMemo(), CreateInteractionGroup.Sales(), SalesCreditMemoLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(SDraftIn(), CreateInteractionGroup.Sales(), SalesDraftInvoiceLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(SFinChg(), CreateInteractionGroup.Sales(), FinanceChargeLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(SInvoice(), CreateInteractionGroup.Sales(), SalesInvoiceLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(SOrderCf(), CreateInteractionGroup.Sales(), SalesOrderConfirmationLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(SQuote(), CreateInteractionGroup.Sales(), SalesQuoteLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(SRemind(), CreateInteractionGroup.Sales(), SalesReminderLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(SRetOrd(), CreateInteractionGroup.Sales(), SalesReturnOrderLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(SRetRcp(), CreateInteractionGroup.Sales(), SalesReturnReceiptLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(SShip(), CreateInteractionGroup.Sales(), SalesShipmentLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
        ContosoCRM.InsertInteractionTemplate(SStatm(), CreateInteractionGroup.Sales(), SalesStatementLbl, 8, 1, 1, 1, Enum::"Correspondence Type"::" ", Enum::"Interaction Template Wizard Action"::" ", false);
    end;

    local procedure CreateInteractionTemplateLanguages()
    var
        ContosoCRM: Codeunit "Contoso CRM";
        CreateLanguage: Codeunit "Create Language";
    begin
        ContosoCRM.InsertInteractionTmplLanguage(Abstract(), CreateLanguage.ENU());
        ContosoCRM.InsertInteractionTmplLanguage(Bus(), CreateLanguage.ENU());
    end;

    procedure Abstract(): Code[10]
    begin
        exit(AbstractTok);
    end;

    procedure Bus(): Code[10]
    begin
        exit(BusTok);
    end;

    procedure Coversh(): Code[10]
    begin
        exit(CovershTok);
    end;

    procedure Email(): Code[10]
    begin
        exit(EmailTok);
    end;

    procedure EmailD(): Code[10]
    begin
        exit(EmailDTok);
    end;

    procedure Golf(): Code[10]
    begin
        exit(GolfTok);
    end;

    procedure Income(): Code[10]
    begin
        exit(IncomeTok);
    end;

    procedure Inhouse(): Code[10]
    begin
        exit(InhouseTok);
    end;

    procedure Meetinv(): Code[10]
    begin
        exit(MeetinvTok);
    end;

    procedure Onsite(): Code[10]
    begin
        exit(OnsiteTok);
    end;

    procedure Outgoing(): Code[10]
    begin
        exit(OutgoingTok);
    end;

    procedure PBOrder(): Code[10]
    begin
        exit(PBOrderTok);
    end;

    procedure PCMemo(): Code[10]
    begin
        exit(PCMemoTok);
    end;

    procedure PInvoice(): Code[10]
    begin
        exit(PInvoiceTok);
    end;

    procedure POrder(): Code[10]
    begin
        exit(POrderTok);
    end;

    procedure PQuote(): Code[10]
    begin
        exit(PQuoteTok);
    end;

    procedure PReceipt(): Code[10]
    begin
        exit(PReceiptTok);
    end;

    procedure PRtOrdC(): Code[10]
    begin
        exit(PRtOrdCTok);
    end;

    procedure PRtShip(): Code[10]
    begin
        exit(PRtShipTok);
    end;

    procedure SBOrder(): Code[10]
    begin
        exit(SBOrderTok);
    end;

    procedure SCMemo(): Code[10]
    begin
        exit(SCMemoTok);
    end;

    procedure SDraftIn(): Code[10]
    begin
        exit(SDraftInTok);
    end;

    procedure SFinChg(): Code[10]
    begin
        exit(SFinChgTok);
    end;

    procedure SInvoice(): Code[10]
    begin
        exit(SInvoiceTok);
    end;

    procedure SOrderCf(): Code[10]
    begin
        exit(SOrderCfTok);
    end;

    procedure SQuote(): Code[10]
    begin
        exit(SQuoteTok);
    end;

    procedure SRemind(): Code[10]
    begin
        exit(SRemindTok);
    end;

    procedure SRetOrd(): Code[10]
    begin
        exit(SRetOrdTok);
    end;

    procedure SRetRcp(): Code[10]
    begin
        exit(SRetRcpTok);
    end;

    procedure SShip(): Code[10]
    begin
        exit(SShipTok);
    end;

    procedure SStatm(): Code[10]
    begin
        exit(SStatmTok);
    end;

    var
        AbstractTok: Label 'ABSTRACT', MaxLength = 10;
        BusTok: Label 'BUS', MaxLength = 10;
        CovershTok: Label 'COVERSH', MaxLength = 10;
        EmailTok: Label 'EMAIL', MaxLength = 10;
        EmailDTok: Label 'EMAIL_D', MaxLength = 10;
        GolfTok: Label 'GOLF', MaxLength = 10;
        IncomeTok: Label 'INCOME', MaxLength = 10;
        InhouseTok: Label 'INHOUSE', MaxLength = 10;
        MeetinvTok: Label 'MEETINV', MaxLength = 10;
        OnsiteTok: Label 'ONSITE', MaxLength = 10;
        OutgoingTok: Label 'OUTGOING', MaxLength = 10;
        PBOrderTok: Label 'P_B_ORDER', MaxLength = 10;
        PCMemoTok: Label 'P_C_MEMO', MaxLength = 10;
        PInvoiceTok: Label 'P_INVOICE', MaxLength = 10;
        POrderTok: Label 'P_ORDER', MaxLength = 10;
        PQuoteTok: Label 'P_QUOTE', MaxLength = 10;
        PReceiptTok: Label 'P_RECEIPT', MaxLength = 10;
        PRtOrdCTok: Label 'P_RT_ORD_C', MaxLength = 10;
        PRtShipTok: Label 'P_RT_SHIP', MaxLength = 10;
        SBOrderTok: Label 'S_B_ORDER', MaxLength = 10;
        SCMemoTok: Label 'S_C_MEMO', MaxLength = 10;
        SDraftInTok: Label 'S_DRAFT_IN', MaxLength = 10;
        SFinChgTok: Label 'S_FIN_CHG', MaxLength = 10;
        SInvoiceTok: Label 'S_INVOICE', MaxLength = 10;
        SOrderCfTok: Label 'S_ORDER_CF', MaxLength = 10;
        SQuoteTok: Label 'S_QUOTE', MaxLength = 10;
        SRemindTok: Label 'S_REMIND', MaxLength = 10;
        SRetOrdTok: Label 'S_RET_ORD', MaxLength = 10;
        SRetRcpTok: Label 'S_RET_RCP', MaxLength = 10;
        SShipTok: Label 'S_SHIP', MaxLength = 10;
        SStatmTok: Label 'S_STATM', MaxLength = 10;
        AbstractsOfMeetingLbl: Label 'Abstracts of meeting', MaxLength = 100;
        BusinessLetterLbl: Label 'Business letter', MaxLength = 100;
        CoversheetLbl: Label 'Coversheet', MaxLength = 100;
        EmailsLbl: Label 'Emails', MaxLength = 100;
        EmailDraftLbl: Label 'Email Draft', MaxLength = 100;
        GolfEventLbl: Label 'Golf event', MaxLength = 100;
        IncomingPhoneCallLbl: Label 'Incoming phone call', MaxLength = 100;
        MeetingHeldAtCronusLbl: Label 'Meeting held at CRONUS', MaxLength = 100;
        MeetingInvitationLbl: Label 'Meeting Invitation', MaxLength = 100;
        MeetingAtCustomersSiteLbl: Label 'Meeting at the customers site', MaxLength = 100;
        OutgoingPhoneCallLbl: Label 'Outgoing phone call', MaxLength = 100;
        PurchaseBlanketOrderLbl: Label 'Purchase Blanket Order', MaxLength = 100;
        PurchaseCreditMemoLbl: Label 'Purchase Credit Memo', MaxLength = 100;
        PurchaseInvoiceLbl: Label 'Purchase Invoice', MaxLength = 100;
        PurchaseOrderLbl: Label 'Purchase Order', MaxLength = 100;
        PurchaseQuoteLbl: Label 'Purchase Quote', MaxLength = 100;
        PurchaseReceiptLbl: Label 'Purchase Receipt', MaxLength = 100;
        PurchaseReturnOrderConfirmationLbl: Label 'Purchase Return Order Confirmation', MaxLength = 100;
        PurchaseReturnShipmentLbl: Label 'Purchase Return Shipment', MaxLength = 100;
        SalesBlanketOrderLbl: Label 'Sales Blanket Order', MaxLength = 100;
        SalesCreditMemoLbl: Label 'Sales Credit Memo', MaxLength = 100;
        SalesDraftInvoiceLbl: Label 'Sales Draft Invoice', MaxLength = 100;
        FinanceChargeLbl: Label 'Finance Charge', MaxLength = 100;
        SalesInvoiceLbl: Label 'Sales Invoice', MaxLength = 100;
        SalesOrderConfirmationLbl: Label 'Sales Order Confirmation', MaxLength = 100;
        SalesQuoteLbl: Label 'Sales Quote', MaxLength = 100;
        SalesReminderLbl: Label 'Sales Reminder', MaxLength = 100;
        SalesReturnOrderLbl: Label 'Sales Return Order', MaxLength = 100;
        SalesReturnReceiptLbl: Label 'Sales Return Receipt', MaxLength = 100;
        SalesShipmentLbl: Label 'Sales Shipment', MaxLength = 100;
        SalesStatementLbl: Label 'Sales Statement', MaxLength = 100;
}