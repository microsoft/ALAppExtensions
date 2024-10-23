namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;

/// <summary>
/// Report Shpfy Sync Invoices to Shpfy (ID 30117).
/// </summary>
report 30119 "Shpfy Sync Invoices to Shpfy"
{
    ApplicationArea = All;
    Caption = 'Sync Invoices to Shopify';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {
            RequestFilterFields = "No.", "Posting Date";
            trigger OnPreDataItem()
            var
                ShopifyPaymentTerms: Record "Shpfy Payment Terms";
                ShopCodeNotSetErr: Label 'Shopify Shop Code is empty.';
                PostedInvoiceSyncNotSetErr: Label 'Posted Invoice Sync is not enabled for this shop.';
            begin
                if ShopCode = '' then
                    Error(ShopCodeNotSetErr);

                Shop.Get(ShopCode);

                if not Shop."Posted Invoice Sync" then
                    Error(PostedInvoiceSyncNotSetErr);

                ShopifyPaymentTerms.SetRange("Shop Code", ShopCode);
                if ShopifyPaymentTerms.IsEmpty() then
                    PaymentTermsMappingNotConfiguredError();
                ShopifyPaymentTerms.SetFilter("Payment Terms Code", '<>%1', '');
                if ShopifyPaymentTerms.IsEmpty() then begin
                    ShopifyPaymentTerms.SetRange("Payment Terms Code");
                    ShopifyPaymentTerms.SetRange("Is Primary", true);
                    if ShopifyPaymentTerms.IsEmpty() then
                        PaymentTermsMappingNotConfiguredError();
                end;


                PostedInvoiceExport.SetShop(ShopCode);
                SetRange("Shpfy Order Id", 0);

                if GuiAllowed then begin
                    CurrSalesInvoiceHeaderNo := SalesInvoiceHeader."No.";
                    ProcessDialog.Open(ProcessMsg, CurrSalesInvoiceHeaderNo);
                    ProcessDialog.Update();
                end;
            end;

            trigger OnAfterGetRecord()
            begin
                if GuiAllowed then begin
                    CurrSalesInvoiceHeaderNo := SalesInvoiceHeader."No.";
                    ProcessDialog.Update();
                end;

                PostedInvoiceExport.Run(SalesInvoiceHeader);
            end;

            trigger OnPostDataItem()
            begin
                if GuiAllowed then
                    ProcessDialog.Close();
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(ShopFilter)
                {
                    Caption = 'Options';
                    field(Shop; ShopCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Shop Code';
                        Lookup = true;
                        LookupPageId = "Shpfy Shops";
                        TableRelation = "Shpfy Shop";
                        ToolTip = 'Specifies the Shopify Shop to which the invoice will be exported.';
                        ShowMandatory = true;
                    }
                }
            }
        }
    }

    var
        Shop: Record "Shpfy Shop";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        ShopCode: Code[20];
        CurrSalesInvoiceHeaderNo: Code[20];
        ProcessDialog: Dialog;
        ProcessMsg: Label 'Synchronizing Posted Sales Invoice #1####################', Comment = '#1 = Posted Sales Invoice No.';
        NoPaymentTermsErr: Label 'You need to configure the payment terms mapping.';
        ConfigurePaymentTermsMappingLbl: Label 'Configure Payment Terms Mapping';

    /// <summary> 
    /// Sets a global shopify shop code to be used.
    /// </summary>
    /// <param name="NewShopCode">Shopify shop code to be set.</param>
    internal procedure SetShop(NewShopCode: Code[20])
    begin
        ShopCode := NewShopCode;
    end;

    local procedure PaymentTermsMappingNotConfiguredError()
    var
        PaymentTermsMappingErrorInfo: ErrorInfo;
    begin
        PaymentTermsMappingErrorInfo.DataClassification := PaymentTermsMappingErrorInfo.DataClassification::SystemMetadata;
        PaymentTermsMappingErrorInfo.ErrorType := PaymentTermsMappingErrorInfo.ErrorType::Client;
        PaymentTermsMappingErrorInfo.Verbosity := PaymentTermsMappingErrorInfo.Verbosity::Error;
        PaymentTermsMappingErrorInfo.Message := NoPaymentTermsErr;
        PaymentTermsMappingErrorInfo.RecordId(Shop.RecordId());
        PaymentTermsMappingErrorInfo.AddAction(ConfigurePaymentTermsMappingLbl, Codeunit::"Shpfy Posted Invoice Export", 'ConfigurePaymentTermsMapping');
        Error(PaymentTermsMappingErrorInfo);
    end;
}