namespace Microsoft.Integration.Shopify;

using Microsoft.Integration.Shopify;
using Microsoft.Sales.Customer;

/// <summary>
/// A report to add customers as locations to a parent company.
/// </summary>
report 30121 "Shpfy Add Cust. as Locations"
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
                if IsNullGuid(this.ShpfyCompany.SystemId) then
                    Error(MissingCompanyErr);

                Clear(CompanyAPI);
                CompanyAPI.SetCompany(ShpfyCompany);

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
                    field(Shop; ShopCode)
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
        ShpfyCompany: Record "Shpfy Company";
        CompanyAPI: Codeunit "Shpfy Company API";
        ShopCode: Code[20];
        CompanyName: Text[100];
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
        this.ShpfyCompany.GetBySystemId(CompanySystemId);
        this.ShopCode := ShpfyCompany."Shop Code";
        this.CompanyName := ShpfyCompany.Name;
    end;
}
