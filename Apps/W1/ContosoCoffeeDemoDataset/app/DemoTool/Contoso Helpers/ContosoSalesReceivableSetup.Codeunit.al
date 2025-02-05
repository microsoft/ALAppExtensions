codeunit 5269 "Contoso Sales Receivable Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Sales & Receivables Setup" = rim;

    var

    procedure InsertSalesReceivablesSetup(DiscountPosting: Integer; ShipmentonInvoice: Boolean; InvoiceRounding: Boolean; CustomerNos: Code[20]; QuoteNos: Code[20]; OrderNos: Code[20]; InvoiceNos: Code[20]; PostedInvoiceNos: Code[20]; CreditMemoNos: Code[20]; PostedCreditMemoNos: Code[20]; PostedShipmentNos: Code[20]; ReminderNos: Code[20]; IssuedReminderNos: Code[20]; FinChrgMemoNos: Code[20]; IssuedFinChrgMNos: Code[20]; BlanketOrderNos: Code[20]; ApplnbetweenCurrencies: Integer; CopyCommentsBlankettoOrder: Boolean; CopyCommentsOrdertoInvoice: Boolean; CopyCommentsOrdertoShpt: Boolean; DefaultPostingDate: Enum "Default Posting Date"; JobQueueCategoryCode: Code[10]; JobQueuePriorityforPost: Integer; JobQPrioforPostPrint: Integer; VATBusPostingGrPrice: Code[20]; ReportOutputType: Enum "Setup Report Output Type"; DocumentDefaultLineType: Enum "Sales Line Type"; AllowMultiplePostingGroups: Boolean; CheckMultiplePostingGroups: enum "Posting Group Change Method"; AutoPostNonInvtviaWhse: Enum "Non-Invt. Item Whse. Policy"; PostedReturnReceiptNos: Code[20]; CopyCmtsRetOrdtoRetRcpt: Boolean; CopyCmtsRetOrdtoCrMemo: Boolean; ReturnOrderNos: Code[20]; PriceCalculationMethod: Enum "Price Calculation Method"; PriceListNos: Code[20]; LinkDocDateToPostingDate: Boolean; CopyCustomerNametoEntries: Boolean)
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if not SalesReceivablesSetup.Get() then
            SalesReceivablesSetup.Insert();

        SalesReceivablesSetup.Validate("Discount Posting", DiscountPosting);
        SalesReceivablesSetup.Validate("Shipment on Invoice", ShipmentonInvoice);
        SalesReceivablesSetup.Validate("Invoice Rounding", InvoiceRounding);
        SalesReceivablesSetup.Validate("Customer Nos.", CustomerNos);
        SalesReceivablesSetup.Validate("Quote Nos.", QuoteNos);
        SalesReceivablesSetup.Validate("Order Nos.", OrderNos);
        SalesReceivablesSetup.Validate("Invoice Nos.", InvoiceNos);
        SalesReceivablesSetup.Validate("Posted Invoice Nos.", PostedInvoiceNos);
        SalesReceivablesSetup.Validate("Credit Memo Nos.", CreditMemoNos);
        SalesReceivablesSetup.Validate("Posted Credit Memo Nos.", PostedCreditMemoNos);
        SalesReceivablesSetup.Validate("Posted Shipment Nos.", PostedShipmentNos);
        SalesReceivablesSetup.Validate("Reminder Nos.", ReminderNos);
        SalesReceivablesSetup.Validate("Issued Reminder Nos.", IssuedReminderNos);
        SalesReceivablesSetup.Validate("Fin. Chrg. Memo Nos.", FinChrgMemoNos);
        SalesReceivablesSetup.Validate("Issued Fin. Chrg. M. Nos.", IssuedFinChrgMNos);
        SalesReceivablesSetup.Validate("Blanket Order Nos.", BlanketOrderNos);
        SalesReceivablesSetup.Validate("Appln. between Currencies", ApplnbetweenCurrencies);
        SalesReceivablesSetup.Validate("Copy Comments Blanket to Order", CopyCommentsBlankettoOrder);
        SalesReceivablesSetup.Validate("Copy Comments Order to Invoice", CopyCommentsOrdertoInvoice);
        SalesReceivablesSetup.Validate("Copy Comments Order to Shpt.", CopyCommentsOrdertoShpt);
        SalesReceivablesSetup.Validate("Default Posting Date", DefaultPostingDate);
        SalesReceivablesSetup.Validate("Job Queue Category Code", JobQueueCategoryCode);
        SalesReceivablesSetup.Validate("Job Queue Priority for Post", JobQueuePriorityforPost);
        SalesReceivablesSetup.Validate("Job Q. Prio. for Post & Print", JobQPrioforPostPrint);
        if ContosoCoffeeDemoDataSetup."Company Type" <> ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            SalesReceivablesSetup.Validate("VAT Bus. Posting Gr. (Price)", VATBusPostingGrPrice);
        SalesReceivablesSetup.Validate("Report Output Type", ReportOutputType);
        SalesReceivablesSetup.Validate("Document Default Line Type", DocumentDefaultLineType);
        SalesReceivablesSetup.Validate("Check Multiple Posting Groups", CheckMultiplePostingGroups);
        SalesReceivablesSetup.Validate("Auto Post Non-Invt. via Whse.", AutoPostNonInvtviaWhse);
        SalesReceivablesSetup.Validate("Posted Return Receipt Nos.", PostedReturnReceiptNos);
        SalesReceivablesSetup.Validate("Copy Cmts Ret.Ord. to Ret.Rcpt", CopyCmtsRetOrdtoRetRcpt);
        SalesReceivablesSetup.Validate("Copy Cmts Ret.Ord. to Cr. Memo", CopyCmtsRetOrdtoCrMemo);
        SalesReceivablesSetup.Validate("Return Order Nos.", ReturnOrderNos);
        SalesReceivablesSetup."Price Calculation Method" := PriceCalculationMethod;
        SalesReceivablesSetup.Validate("Price List Nos.", PriceListNos);
        SalesReceivablesSetup.Validate("Link Doc. Date To Posting Date", LinkDocDateToPostingDate);
        SalesReceivablesSetup.Validate("Copy Customer Name to Entries", CopyCustomerNametoEntries);
        SalesReceivablesSetup.Modify(true);
    end;
}