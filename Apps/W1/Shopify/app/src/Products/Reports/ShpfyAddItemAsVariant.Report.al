// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

/// <summary>
/// A report to add items as variants to a parent product.
/// </summary>
report 30117 "Shpfy Add Item As Variant"
{
    ApplicationArea = All;
    Caption = 'Add Item as Shopify Variant';
    ProcessingOnly = true;
    UsageCategory = Administration;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";
            trigger OnPreDataItem()
            begin
                if ParentProductNo = 0 then
                    Error(MissingProductErr);

                Clear(CreateItemAsVariant);
                CreateItemAsVariant.SetParentProduct(ParentProductNo);
                CreateItemAsVariant.CheckProductAndShopSettings();

                if GuiAllowed then begin
                    CurrItemNo := Item."No.";
                    ProcessDialog.Open(ProcessMsg, CurrItemNo);
                    ProcessDialog.Update();
                end;
            end;

            trigger OnAfterGetRecord()
            begin
                if GuiAllowed then begin
                    CurrItemNo := Item."No.";
                    ProcessDialog.Update();
                end;

                CreateItemAsVariant.Run(Item);
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
                        Editable = false;
                        ToolTip = 'Specifies the Shopify Shop.';
                        ShowMandatory = true;
                    }
                    field(ParentItemNo; ParentProductNo)
                    {
                        ApplicationArea = All;
                        TableRelation = "Shpfy Product";
                        LookupPageId = "Shpfy Products";
                        Lookup = true;
                        Caption = 'Parent Item No.';
                        ToolTip = 'Specifies the parent item number to which the variants will be added.';
                        ShowMandatory = true;

                        trigger OnValidate()
                        begin
                            SetParentProduct(ParentProductNo);
                        end;
                    }
                }
            }
        }
    }

    var
        CreateItemAsVariant: Codeunit "Shpfy Create Item As Variant";
        ShopCode: Code[20];
        ParentProductNo: BigInteger;
        CurrItemNo: Code[20];
        ProcessDialog: Dialog;
        ProcessMsg: Label 'Adding item #1####################', Comment = '#1 = Item no.';
        MissingProductErr: Label 'You must select a parent product to add the items as variants to.';

    /// <summary>
    /// Sets the parent product to which items will be added as variants.
    /// </summary>
    /// <param name="NewParentProductNo">The parent product number.</param>
    internal procedure SetParentProduct(NewParentProductNo: BigInteger)
    var
        ShopifyProduct: Record "Shpfy Product";
    begin
        ParentProductNo := NewParentProductNo;
        ShopifyProduct.Get(ParentProductNo);
        ShopCode := ShopifyProduct."Shop Code";
    end;
}