// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// A report to add customers as locations to a parent company.
/// </summary>
report 30121 "Shpfy Add Cust. As Locations"
{
    ApplicationArea = All;
    Caption = 'Add Customer as Shopify Location';
    ProcessingOnly = true;
    UsageCategory = Administration;

    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.";
            trigger OnPreDataItem()
            begin
                if IsNullGuid(ShopifyCompany.SystemId) then
                    Error(MissingCompanyErr);

                Clear(CompanyAPI);
                CompanyAPI.SetCompany(ShopifyCompany);
                CompanyAPI.SetShop(ShopifyShop);

                if GuiAllowed then begin
                    CurrCustomerNo := Customer."No.";
                    ProcessDialog.Open(ProcessMsg, CurrCustomerNo);
                    ProcessDialog.Update();
                end;
            end;

            trigger OnAfterGetRecord()
            begin
                if GuiAllowed then begin
                    CurrCustomerNo := Customer."No.";
                    ProcessDialog.Update();
                end;

                CompanyAPI.CreateCompanyLocation(Customer);
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
                group(CompanyFilter)
                {
                    Caption = 'Options';
                    field(Shop; ShopifyShop.Code)
                    {
                        ApplicationArea = All;
                        Caption = 'Shop Code';
                        Editable = false;
                        ToolTip = 'Specifies the Shopify Shop.';
                        ShowMandatory = true;
                    }
                    field(ParentCompanyName; CompanyName)
                    {
                        ApplicationArea = All;
                        Caption = 'Parent Company Name';
                        ToolTip = 'Specifies the parent company to which the customers will be added as locations.';
                        Editable = false;
                        ShowMandatory = true;
                    }
                }
            }
        }
    }

    var
        ShopifyCompany: Record "Shpfy Company";
        ShopifyShop: Record "Shpfy Shop";
        CompanyAPI: Codeunit "Shpfy Company API";
        CompanyName: Text[500];
        CurrCustomerNo: Code[20];
        ProcessDialog: Dialog;
        ProcessMsg: Label 'Adding customer #1####################', Comment = '#1 = Customer no.';
        MissingCompanyErr: Label 'You must select a parent company to add the customers as locations to.';

    /// <summary>
    /// Sets the parent company to which customers will be added as locations.
    /// </summary>
    /// <param name="CompanySystemId">The parent company system ID.</param>
    internal procedure SetParentCompany(CompanySystemId: Guid)
    begin
        this.ShopifyCompany.GetBySystemId(CompanySystemId);
        this.ShopifyShop.Get(ShopifyCompany."Shop Code");
        this.CompanyName := ShopifyCompany.Name;
    end;
}
