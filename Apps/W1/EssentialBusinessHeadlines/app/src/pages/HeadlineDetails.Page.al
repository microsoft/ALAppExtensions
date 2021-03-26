// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
                field(Name; Name)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;

                    trigger OnDrillDown()
                    var
                        Customer: Record Customer;
                        Item: Record Item;
                        Resource: Record Resource;
                        SalesLine: Record "Sales Line";
                    begin
                        if IsHeadlineCustomerRelatedWithAmount then begin
                            if Customer.Get("No.") then
                                Page.Run(Page::"Customer Card", Customer);
                            exit;
                        end;

                        case ProductType of
                            SalesLine.Type::Item:
                                if Item.Get("No.") then
                                    Page.Run(Page::"Item Card", Item);

                            SalesLine.Type::Resource:
                                if Resource.Get("No.") then
                                    Page.Run(Page::"Resource Card", Resource);
                        end;
                    end;
                }

                field(Quantity; Quantity)
                {
                    Editable = false;
                    Visible = (not IsHeadlineCustomerRelatedWithAmount);
                    ApplicationArea = Basic, Suite;
                }

                field("Unit of Measure"; "Unit of Measure")
                {
                    Editable = false;
                    Visible = (not IsHeadlineCustomerRelatedWithAmount);
                    ApplicationArea = Basic, Suite;
                }

                field("Amount (LCY)"; "Amount (LCY)")
                {
                    Editable = false;
                    Visible = IsHeadlineCustomerRelatedWithAmount;
                    ApplicationArea = Basic, Suite;
                    CaptionClass = AmountCaptionToUse;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if IsHeadlineCustomerRelatedWithAmount then begin
            PopulatePageDataCustomer();
            AmountCaptionToUse := StrSubstNo('%1%2', AmountCaptionLbl, GetLocalCurrencyCode());
        end else
            PopulatePageDataProduct();
    end;

    local procedure PopulatePageDataProduct()
    var
        SalesLine: Record "Sales Line";
    begin
        case ProductType of
            SalesLine.Type::Item:
                SetRange(Type, Type::Item);

            SalesLine.Type::Resource:
                SetRange(Type, Type::Resource);
        end;
        SetRange("User Id", UserSecurityId());
        SetCurrentKey(Quantity);
        Ascending(false);
        if FindFirst() then;
    end;

    local procedure PopulatePageDataCustomer()
    begin
        SetRange(Type, Type::Customer);
        SetRange("User Id", UserSecurityId());
        SetCurrentKey("Amount (LCY)");
        Ascending(false);
        if FindFirst() then;
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
}