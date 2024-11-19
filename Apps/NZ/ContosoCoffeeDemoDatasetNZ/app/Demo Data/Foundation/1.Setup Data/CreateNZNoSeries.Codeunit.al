codeunit 17116 "Create NZ No. Series"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: codeunit "Contoso No Series";
    begin
        ContosoNoSeries.SetOverwriteData(true);
        ContosoNoSeries.InsertNoSeries(PostedPurchaseTaxCreditMemo(), PostedPurchaseTaxCreditMemoLbl, '108001', '109999', '109995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(PostedPurchaseTaxInvoice(), PostedPurchaseTaxInvoiceLbl, '108001', '109999', '109995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(PostedSalesTaxCreditMemo(), PostedSalesTaxCreditMemoLbl, '103001', '104999', '104995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(PostedSalesTaxInvoice(), PostedSalesTaxInvoiceLbl, '103001', '104999', '104995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.SetOverwriteData(false);
    end;

    procedure PostedPurchaseTaxCreditMemo(): Code[20]
    begin
        exit(PostedPurchaseTaxCreditMemoTok);
    end;

    procedure PostedPurchaseTaxInvoice(): Code[20]
    begin
        exit(PostedPurchaseTaxInvoiceTok);
    end;

    procedure PostedSalesTaxCreditMemo(): Code[20]
    begin
        exit(PostedSalesTaxCreditMemoTok);
    end;

    procedure PostedSalesTaxInvoice(): Code[20]
    begin
        exit(PostedSalesTaxInvoiceTok);
    end;

    var
        PostedPurchaseTaxCreditMemoTok: Label 'P-TAXCR+', MaxLength = 20;
        PostedPurchaseTaxCreditMemoLbl: Label 'Posted Purchase Tax Cr. Memo', MaxLength = 100;
        PostedPurchaseTaxInvoiceTok: Label 'P-TAXINV+', MaxLength = 20;
        PostedPurchaseTaxInvoiceLbl: Label 'Posted Purchase Tax Invoice', MaxLength = 100;
        PostedSalesTaxCreditMemoTok: Label 'S-TAXCR+', MaxLength = 20;
        PostedSalesTaxCreditMemoLbl: Label 'Posted Sales Tax Credit Memo', MaxLength = 100;
        PostedSalesTaxInvoiceTok: Label 'S-TAXINV+', MaxLength = 20;
        PostedSalesTaxInvoiceLbl: Label 'Posted Sales Tax Invoice', MaxLength = 100;
}