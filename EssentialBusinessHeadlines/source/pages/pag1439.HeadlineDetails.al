// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 1439 "Headline Details"
{
    PageType = List;
    SourceTable = "Headline Details";
    SourceTableTemporary = true;
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
        Item: Record Item;
        Resource: Record Resource;
        BestSoldItemQuery: Query "Best Sold Item Headline";
    begin
        BestSoldItemQuery.SetFilter(PostDate, '>=%1&<=%2', CalcDate(StrSubstNo('<-%1D>', DaysSearch), WorkDate()), WorkDate());
        BestSoldItemQuery.SetRange(ProductType, ProductType);
        BestSoldItemQuery.Open();
        while BestSoldItemQuery.Read() do begin
            Init();
            case BestSoldItemQuery.ProductType of
                SalesLine.Type::Item:
                    begin
                        Item.get(BestSoldItemQuery.ProductNo);
                        Validate("Unit of Measure", Item."Base Unit of Measure");
                        Validate(Name, Item.Description);
                    end;

                SalesLine.Type::Resource:
                    begin
                        Resource.Get(BestSoldItemQuery.ProductNo);
                        "Unit of Measure" := Resource."Base Unit of Measure";
                        Validate(Name, Resource.Name);
                    end;
            end;

            Validate("No.", BestSoldItemQuery.ProductNo);
            Validate(Quantity, BestSoldItemQuery.SumQuantity);
            Insert();
        end;
        BestSoldItemQuery.Close();
        SetCurrentKey(Quantity);
        Ascending(false);
        if FindFirst() then;
    end;

    local procedure PopulatePageDataCustomer()
    var
        TopCustomerQuery: Query "Top Customer Headline";
    begin
        TopCustomerQuery.SetFilter(PostDate, '>=%1&<=%2', CalcDate(StrSubstNo('<-%1D>', DaysSearch), WorkDate()), WorkDate());
        TopCustomerQuery.Open();
        while TopCustomerQuery.Read() do begin
            Init();
            Validate(Name, TopCustomerQuery.CustomerName);
            Validate("No.", TopCustomerQuery.No);
            Validate("Amount (LCY)", TopCustomerQuery.SumAmountLcy);
            Insert();
        end;
        TopCustomerQuery.Close();
        SetCurrentKey("Amount (LCY)");
        Ascending(false);
        if FindFirst() then;
    end;

    procedure InitProduct(ProductTypeToSet: Option; DaysSearchToSet: Integer)
    begin
        DaysSearch := DaysSearchToSet;
        ProductType := ProductTypeToSet;
        IsHeadlineCustomerRelatedWithAmount := false;
    end;

    procedure InitCustomer(DaysSearchToSet: Integer)
    begin
        DaysSearch := DaysSearchToSet;
        IsHeadlineCustomerRelatedWithAmount := true;
    end;

    local procedure GetLocalCurrencyCode(): Text
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if not GeneralLedgerSetup.Get() then
            exit('');

        if (GeneralLedgerSetup."Local Currency Symbol" <> '') then
            exit(StrSubstNo(LCYParenthesis, GeneralLedgerSetup."Local Currency Symbol"));

        if (GeneralLedgerSetup."LCY Code" <> '') then
            exit(StrSubstNo(LCYParenthesis, GeneralLedgerSetup."LCY Code"));

        exit('');
    end;

    var
        SalesLine: Record "Sales Line";
        DaysSearch: Integer;
        ProductType: Option;
        IsHeadlineCustomerRelatedWithAmount: Boolean;
        AmountCaptionToUse: Text;
        LCYParenthesis: Label ' (%1)', Comment = '%1 is the local currency symbol or code if found', Locked = true;
        AmountCaptionLbl: Label 'Amount';
}