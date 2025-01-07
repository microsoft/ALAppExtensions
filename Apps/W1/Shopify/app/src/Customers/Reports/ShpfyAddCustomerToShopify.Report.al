namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Report Shpfy Add Customer to Shopify (ID 30112).
/// </summary>
report 30112 "Shpfy Add Customer to Shopify"
{
    ApplicationArea = All;
    Caption = 'Add Customer to Shopify';
    ProcessingOnly = true;
    UsageCategory = Administration;

    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.";
            trigger OnPreDataItem()
            begin
                if ShopCode = '' then
                    Error(NoShopSellectedErr);

                Clear(CustomerExport);
                CustomerExport.SetShop(ShopCode);
                CustomerExport.SetCreateCustomers(true);

                if GuiAllowed then begin
                    CurrCustomerNo := Customer."No.";
                    ProcessDialog.Open(ProcessMsg, CurrCustomerNo);
                    ProcessDialog.Update();
                end;
            end;

            trigger OnAfterGetRecord()
            var
                SyncCustomer: Record Customer;
            begin
                if GuiAllowed then begin
                    CurrCustomerNo := Customer."No.";
                    ProcessDialog.Update();
                end;

                SyncCustomer.SetRange("No.", Customer."No.");
                CustomerExport.Run(SyncCustomer);
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
        CustomerExport: Codeunit "Shpfy Customer Export";
        ShopCode: Code[20];
        CurrCustomerNo: Code[20];
        ProcessMsg: Label 'Adding customer #1####################', Comment = '#1 = Customer no.';
        NoShopSellectedErr: Label 'You must select a shop to add the customers to.';
        ProcessDialog: Dialog;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="Shop">Parameter of type Code[20].</param>
    internal procedure SetShop(Shop: Code[20])
    begin
        ShopCode := Shop;
    end;
}