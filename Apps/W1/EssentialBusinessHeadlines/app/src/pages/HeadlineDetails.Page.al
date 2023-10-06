// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Visualization;

using Microsoft.Sales.Customer;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Sales.Document;
using Microsoft.Finance.GeneralLedger.Setup;

page 1439 "Headline Details"
{
    PageType = List;
    SourceTable = "Headline Details Per User";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(GroupName)
            {
                field(Name; Rec.Name)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name.';

                    trigger OnDrillDown()
                    var
                        Customer: Record Customer;
                        Item: Record Item;
                        Resource: Record Resource;
                        SalesLine: Record "Sales Line";
                    begin
                        if IsHeadlineCustomerRelatedWithAmount then begin
                            if Customer.Get(Rec."No.") then
                                Page.Run(Page::"Customer Card", Customer);
                            exit;
                        end;

                        case ProductType of
                            SalesLine.Type::Item.AsInteger():
                                if Item.Get(Rec."No.") then
                                    Page.Run(Page::"Item Card", Item);

                            SalesLine.Type::Resource.AsInteger():
                                if Resource.Get(Rec."No.") then
                                    Page.Run(Page::"Resource Card", Resource);
                        end;
                    end;
                }

                field(Quantity; Rec.Quantity)
                {
                    Editable = false;
                    Visible = (not IsHeadlineCustomerRelatedWithAmount);
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity.';
                }

                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    Editable = false;
                    Visible = (not IsHeadlineCustomerRelatedWithAmount);
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the unit of measure.';
                }

                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    Editable = false;
                    Visible = IsHeadlineCustomerRelatedWithAmount;
                    ApplicationArea = Basic, Suite;
                    CaptionClass = AmountCaptionToUse;
                    ToolTip = 'Specifies the amount in local currency.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if IsHeadlineCustomerRelatedWithAmount then begin
            PopulatePageDataCustomer();
            AmountCaptionToUse := StrSubstNo(AmountCaptionTxt, AmountCaptionLbl, GetLocalCurrencyCode());
        end else
            PopulatePageDataProduct();
    end;

    local procedure PopulatePageDataProduct()
    var
        SalesLine: Record "Sales Line";
    begin
        case ProductType of
            SalesLine.Type::Item.AsInteger():
                Rec.SetRange(Type, Rec.Type::Item);

            SalesLine.Type::Resource.AsInteger():
                Rec.SetRange(Type, Rec.Type::Resource);
        end;
        Rec.SetRange("User Id", UserSecurityId());
        Rec.SetCurrentKey(Quantity);
        Rec.Ascending(false);
        if Rec.FindFirst() then;
    end;

    local procedure PopulatePageDataCustomer()
    begin
        Rec.SetRange(Type, Rec.Type::Customer);
        Rec.SetRange("User Id", UserSecurityId());
        Rec.SetCurrentKey("Amount (LCY)");
        Rec.Ascending(false);
        if Rec.FindFirst() then;
    end;

    procedure InitProduct(ProductTypeToSet: Option)
    begin
        ProductType := ProductTypeToSet;
        IsHeadlineCustomerRelatedWithAmount := false;
    end;

    procedure InitCustomer(DaysSearchToSet: Integer)
    begin
        IsHeadlineCustomerRelatedWithAmount := true;
    end;

    local procedure GetLocalCurrencyCode(): Text
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if not GeneralLedgerSetup.Get() then
            exit('');

        if (GeneralLedgerSetup."Local Currency Symbol" <> '') then
            exit(StrSubstNo(LCYParenthesisTxt, GeneralLedgerSetup."Local Currency Symbol"));

        if (GeneralLedgerSetup."LCY Code" <> '') then
            exit(StrSubstNo(LCYParenthesisTxt, GeneralLedgerSetup."LCY Code"));

        exit('');
    end;

    var
        ProductType: Option;
        IsHeadlineCustomerRelatedWithAmount: Boolean;
        AmountCaptionToUse: Text;
        LCYParenthesisTxt: Label ' (%1)', Comment = '%1 is the local currency symbol or code if found', Locked = true;
        AmountCaptionLbl: Label 'Amount';
        AmountCaptionTxt: Label '%1%2', Comment = '%1 = Amount caption label, %2 = Local currency code', Locked = true;
}