namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Page Shpfy Company Card (ID 30157).
/// </summary>
page 30157 "Shpfy Company Card"
{
    Caption = 'Shopify Company Card';
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Shpfy Company";
    UsageCategory = None;
    PromotedActionCategories = 'New,Process,Related,Company';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier for the company in Shopify.';
                    Visible = false;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the company''s name.';
                }
                field(Note; Rec.GetNote())
                {
                    ApplicationArea = All;
                    Caption = 'Note';
                    ToolTip = 'Specifies a note about the customer in Shopify.';
                }
            }

            group(Mapping)
            {
                Caption = 'Mapping';
                Editable = false;

                field(CustomerSystemId; Rec."Customer SystemId")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier for the customer in D365BC.';
                    Visible = false;
                }
                field(CustomerNo; CustomerNo)
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    Caption = 'Customer No.';
                    TableRelation = Customer;
                    ToolTip = 'Specifies the mapped customer number.';

                    trigger OnValidate()
                    begin
                        if CustomerNo <> '' then begin
                            Customer.Get(CustomerNo);
                            Rec."Customer SystemId" := Customer.SystemId;
                            GetMappedCustomer();
                        end;
                    end;

                    trigger OnAssistEdit()
                    var
                        CustomerList: Page "Customer List";
                    begin
                        CustomerList.LookupMode := true;
                        CustomerList.SetRecord(Customer);
                        if CustomerList.RunModal() = Action::LookupOK then begin
                            CustomerList.GetRecord(Customer);
                            Rec."Customer SystemId" := Customer.SystemId;
                            CustomerNo := Customer."No.";
                            Rec.Modify();
                        end;
                    end;
                }
                field(CustomerName; Customer."Name")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Name';
                    ToolTip = 'Specifies the customer''s name.';
                }
                field(Address; Customer.Address)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Address';
                    ToolTip = 'Specifies the customer''s address.';
                }
            }

        }
        area(FactBoxes)
        {
            part(MainContact; "Shpfy Main Contact Factbox")
            {
                ApplicationArea = All;
                SubPageLink = Id = field("Main Contact Customer Id");
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(CustomerCard)
            {
                ApplicationArea = All;
                Caption = 'Customer Card';
                Image = Customer;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                ToolTip = 'View or edit detailed information about the customer.';

                trigger OnAction()
                var
                    Customer: Record Customer;
                begin
                    if Customer.GetBySystemId(Rec."Customer SystemId") then begin
                        Customer.SetRecFilter();
                        Page.Run(Page::"Customer Card", Customer);
                    end;
                end;
            }
            action(ShopifyOrders)
            {
                ApplicationArea = All;
                Caption = 'Shopify Orders';
                Image = OrderList;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                RunObject = Page "Shpfy Orders";
                RunPageLink = "Customer Id" = field(Id);
                ToolTip = 'View a list of Shopify orders for the company.';
            }
            action(ShopifyCatalogs)
            {
                ApplicationArea = All;
                Caption = 'Shopify Catalogs';
                Image = ItemGroup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                RunObject = Page "Shpfy Catalogs";
                RunPageLink = "Company SystemId" = field(SystemId);
                ToolTip = 'View a list of Shopify catalogs for the company.';
            }
        }

    }

    var
        Customer: Record Customer;
        CustomerNo: Code[20];

    trigger OnAfterGetCurrRecord()
    begin
        GetMappedCustomer();
    end;

    /// <summary> 
    /// Get Mapped Customer.
    /// </summary>
    local procedure GetMappedCustomer()
    begin
        if IsNullGuid(Rec."Customer SystemId") then begin
            Clear(Customer);
            Clear(CustomerNo);
        end else
            if Customer.GetBySystemId(Rec."Customer SystemId") then
                CustomerNo := Customer."No."
            else begin
                Clear(Customer);
                Clear(CustomerNo);
            end;
    end;
}
