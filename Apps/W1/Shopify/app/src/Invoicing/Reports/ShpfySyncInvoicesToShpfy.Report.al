namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;

/// <summary>
/// Report Shpfy Sync Invoices to Shpfy (ID 30119).
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
                ShopCodeNotSetErr: Label 'Shopify Shop Code is empty.';
                PostedInvoiceSyncNotSetErr: Label 'Posted Invoice Sync is not enabled for this shop.';
            begin
                if ShopCode = '' then
                    Error(ShopCodeNotSetErr);

                ShpfyShop.Get(ShopCode);

                if not ShpfyShop."Posted Invoice Sync" then
                    Error(PostedInvoiceSyncNotSetErr);

                ShpfyPostedInvoiceExport.SetShop(ShopCode);
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

                ShpfyPostedInvoiceExport.Run(SalesInvoiceHeader);
            end;

            trigger OnPostDataItem()
            var
                ShpfyBackgroundSyncs: Codeunit "Shpfy Background Syncs";
            begin
                if GuiAllowed then
                    ProcessDialog.Close();

                ShpfyBackgroundSyncs.InventorySync(ShopCode);
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
        ShpfyShop: Record "Shpfy Shop";
        ShpfyPostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        ShopCode: Code[20];
        CurrSalesInvoiceHeaderNo: Code[20];
        ProcessDialog: Dialog;
        ProcessMsg: Label 'Synchronizing Posted Sales Invoice #1####################', Comment = '#1 = Posted Sales Invoice No.';

    /// <summary> 
    /// Sets a global shopify shop code to be used.
    /// </summary>
    /// <param name="NewShopCode">Shopify shop code to be set.</param>
    internal procedure SetShop(NewShopCode: Code[20])
    begin
        ShopCode := NewShopCode;
    end;
}