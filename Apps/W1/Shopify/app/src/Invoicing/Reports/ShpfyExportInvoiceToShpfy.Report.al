namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;

/// <summary>
/// Report Shpfy Export Invoice to Shpfy (ID 30117).
/// </summary>
report 30117 "Shpfy Export Invoice to Shpfy"
{
    ApplicationArea = All;
    Caption = 'Export Invoice to Shopify';
    ProcessingOnly = true;
    UsageCategory = Administration;

    dataset
    {
        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {
            RequestFilterFields = "No.", "Posting Date";
            trigger OnPreDataItem()
            begin
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

                ShpfyPostedInvoiceExport.SetShop(ShopCode);
                ShpfyPostedInvoiceExport.Run(SalesInvoiceHeader);
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
                        ToolTip = 'Specifies the Shopify Shop.';
                        ShowMandatory = true;
                    }
                }
            }
        }
    }

    var
        ShpfyPostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        ShopCode: Code[20];
        CurrSalesInvoiceHeaderNo: Code[20];
        ProcessDialog: Dialog;
        ProcessMsg: Label 'Synchronizing Posted Sales Invoice #1####################', Comment = '#1 = Posted Sales Invoice No.';

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="NewShopCode">Parameter of type Code[20].</param>
    internal procedure SetShop(NewShopCode: Code[20])
    begin
        ShopCode := NewShopCode;
    end;
}