// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using Microsoft.Sales.Customer;
using Microsoft.Inventory.Item;
using System.TestLibraries.Utilities;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.VAT.Setup;
using Microsoft.CRM.Contact;
using Microsoft.CRM.BusinessRelation;
using Microsoft.Foundation.Enums;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.Address;

/// <summary>
/// Codeunit Shpfy Initialize Test (ID 139561).
/// </summary>
codeunit 139561 "Shpfy Initialize Test"
{
    EventSubscriberInstance = Manual;

    var
        DummyCustomer: Record Customer;
        DummyItem: Record Item;
        TempShop: Record "Shpfy Shop" temporary;
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        ShopifyAccessToken: Text;
#pragma warning disable AA0240
        DummyCustomerEmailLbl: Label 'dummy@customer.com';
#pragma warning restore AA0240
        DummyItemDescriptionLbl: Label 'Dummy Item Description';

    trigger OnRun()
    begin
        CreateShop();
    end;

    internal procedure CreateShop(): Record "Shpfy Shop"
    var
        RefundGLAccount: Record "G/L Account";
        Shop: Record "Shpfy Shop";
        VATPostingSetup: Record "VAT Posting Setup";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        Code: Code[10];
        CustomerTemplateCode: Code[20];
        ItemTemplateCode: Code[20];
        PostingGroupCode: Code[20];
        GenPostingType: Enum "General Posting Type";
        UrlTxt: Label 'https://%1.myshopify.com', Comment = '%1 = Shop name', Locked = true;
    begin
        BindSubscription(ShpfyInitializeTest);
        if not TempShop.IsEmpty() then
            if Shop.Get(TempShop.Code) then
                exit(Shop);

        Code := CopyStr(Any.AlphabeticText(MaxStrLen(Code)), 1, MaxStrLen(Code));

        LibraryERM.CreateVATPostingSetupWithAccounts(VATPostingSetup,
           VATPostingSetup."VAT Calculation Type"::"Normal VAT", LibraryRandom.RandDecInDecimalRange(10, 25, 0));

        RefundGLAccount.Get(LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, GenPostingType::Sale));
        RefundGLAccount."Direct Posting" := true;
        RefundGLAccount.Modify();

        Shop.Init();
        Shop.Code := Code;
        Shop."Shopify URL" := StrSubstNo(UrlTxt, Any.AlphabeticText(20));
        Shop.Enabled := true;
        PostingGroupCode := CopyStr(Any.AlphabeticText(10), 1, MaxStrLen(PostingGroupCode));
        CustomerTemplateCode := CreateCustomerTemplate(PostingGroupCode);
        ItemTemplateCode := CreateItemTemplate(PostingGroupCode);
        Shop."Customer Templ. Code" := CreateCustomerTemplate(PostingGroupCode);
        Shop."Item Templ. Code" := CreateItemTemplate(PostingGroupCode);
        CreateVATPostingSetup(PostingGroupCode, PostingGroupCode);
        CreateVATPostingSetup(PostingGroupCode, '');
        CreateVATPostingSetup(PostingGroupCode, RefundGLAccount."VAT Prod. Posting Group");
        Shop."Shipping Charges Account" := CreateShippingChargesGLAcc(VATPostingSetup, GenPostingType, PostingGroupCode);
        Shop."Customer Posting Group" := PostingGroupCode;
        Shop."Gen. Bus. Posting Group" := PostingGroupCode;
        Shop."VAT Bus. Posting Group" := PostingGroupCode;
        CreateCountryRegionCode(CustomerTemplateCode);
        Shop."VAT Country/Region Code" := CopyStr(CustomerTemplateCode, 1, MaxStrLen(Shop."VAT Country/Region Code"));
        Shop."Refund Account" := RefundGLAccount."No.";
        if Shop.Insert() then;
        Commit();
        CommunicationMgt.SetShop(Shop);
        CommunicationMgt.SetTestInProgress(true);
        CreateDummyCustomer(CustomerTemplateCode);
        CreateDummyItem(ItemTemplateCode);
        if not TempShop.Get(Code) then begin
            TempShop := Shop;
            TempShop.Insert();
            Commit();
        end;
        UnbindSubscription(ShpfyInitializeTest);
        exit(Shop);
    end;

    local procedure CreateDummyCustomer(CurrentTemplateCode: Code[20])
    var
        Contact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        CreateDummyCustomerFromCustomerTempl(CurrentTemplateCode);
        DummyCustomer.Name := 'Dummy Customer Name';
        DummyCustomer."E-Mail" := DummyCustomerEmailLbl;
        DummyCustomer.Modify();
        DummyCustomer.SetRecFilter();

        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
        ContactBusinessRelation.SetRange("No.", DummyCustomer."No.");
        if ContactBusinessRelation.FindFirst() then
            if Contact.Get(ContactBusinessRelation."Contact No.") then begin
                Contact."E-Mail" := DummyCustomer."E-Mail";
                Contact.Modify();
            end;
    end;

    local procedure CreateDummyCustomerFromCustomerTempl(CustomerTemplCode: Code[20])
    var
        CustomerTempl: Record "Customer Templ.";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        IsHandled: Boolean;
    begin
        if CustomerTemplCode = '' then
            exit;
        if not CustomerTempl.Get(CustomerTemplCode) then
            exit;
        CustomerTemplMgt.CreateCustomerFromTemplate(DummyCustomer, IsHandled, CustomerTemplCode);
    end;

    local procedure CreateDummyItem(CurrentTemplateCode: Code[20])
    begin
        CreateDummyItemFromTempl(CurrentTemplateCode);
        DummyItem.Description := 'Dummy Item Description';
        DummyItem.Modify();
        DummyItem.SetRecFilter();
    end;

    local procedure CreateDummyItemFromTempl(ItemTemplCode: Code[20])
    var
        ItemTempl: Record "Item Templ.";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        IsHandled: Boolean;
    begin
        if ItemTemplCode = '' then
            exit;
        if not ItemTempl.Get(ItemTemplCode) then
            exit;
        ItemTemplMgt.CreateItemFromTemplate(DummyItem, IsHandled, ItemTemplCode);
    end;

    internal procedure GetDummyCustomer() Customer: Record Customer;
    begin
        Customer.SetRange("E-Mail", DummyCustomerEmailLbl);
        Customer.FindFirst();
    end;

    internal procedure GetDummyItem() Item: Record Item;
    begin
        Item.SetRange(Description, DummyItemDescriptionLbl);
        Item.FindFirst();
    end;

    local procedure CreateItemTemplate(PostingGroupCode: Code[20]) Code: Code[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        InventoryPostingGroup: Record "Inventory Posting Group";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        VatProductPostingGroup: Record "VAT Product Posting Group";
        NoSeries: Record "No. Series";
    begin
        Code := CopyStr(Any.AlphabeticText(10), 1, MaxStrLen(Code));
        InventoryPostingGroup := CreateInventoryPostingGroup(PostingGroupCode);
        GenProductPostingGroup := CreateGenProdPostingGroup(PostingGroupCode);
        VatProductPostingGroup := CreateVatProdPostingGroup(PostingGroupCode);
        NoSeries := CreateNoSeries('SHPFY');
        CreateItemTempl(Code, InventoryPostingGroup.Code, GenProductPostingGroup.Code, VatProductPostingGroup.Code, NoSeries.Code);

        Clear(VatPostingSetup);
        VatPostingSetup."VAT Bus. Posting Group" := PostingGroupCode;
        VatPostingSetup."VAT Prod. Posting Group" := PostingGroupCode;
        VatPostingSetup."VAT Calculation Type" := "Tax Calculation Type"::"Normal VAT";
        if not VatPostingSetup.Insert() then
            VatPostingSetup.Modify();

        Clear(GeneralPostingSetup);
        GeneralPostingSetup."Gen. Bus. Posting Group" := PostingGroupCode;
        GeneralPostingSetup."Gen. Prod. Posting Group" := PostingGroupCode;
        if not GeneralPostingSetup.Insert() then
            GeneralPostingSetup.Modify();
    end;

    local procedure CreateItemTempl(ItemTemplCode: Code[20]; InventoryPostingGroupCode: Code[20]; GenProductPostingGroupCode: Code[20]; VatProductPostingGroupCode: Code[20]; NoSeriesCode: Code[20]): Code[20]
    var
        ItemTempl: Record "Item Templ.";
    begin
        ItemTempl.Code := ItemTemplCode;
        ItemTempl."Inventory Posting Group" := InventoryPostingGroupCode;
        ItemTempl."Gen. Prod. Posting Group" := GenProductPostingGroupCode;
        ItemTempl."VAT Prod. Posting Group" := VatProductPostingGroupCode;
        ItemTempl."No. Series" := NoSeriesCode;
        if not ItemTempl.Insert() then
            ItemTempl.Modify();
    end;

    local procedure CreateInventoryPostingGroup(Code: Code[20]) InvPostingGroup: Record "Inventory Posting Group"
    begin
        InvPostingGroup.SetRange(Code);
        if not InvPostingGroup.Get(Code) then begin
            Clear(InvPostingGroup);
            InvPostingGroup.Code := Code;
            InvPostingGroup.Insert();
        end;
    end;

    local procedure CreateGenProdPostingGroup(Code: Code[20]) GenProdPostingGroup: Record "Gen. Product Posting Group";
    begin
        GenProdPostingGroup.SetRange(Code);
        if not GenProdPostingGroup.Get(Code) then begin
            Clear(GenProdPostingGroup);
            GenProdPostingGroup.Code := Code;
            GenProdPostingGroup."Def. VAT Prod. Posting Group" := CreateVatProdPostingGroup(Code).Code;
            GenProdPostingGroup.Insert();
        end;
    end;

    local procedure CreateVatProdPostingGroup(Code: Code[20]) VatProdPostingGroup: Record "VAT Product Posting Group"
    begin
        VatProdPostingGroup.SetRange(Code);
        if not VatProdPostingGroup.Get(Code) then begin
            Clear(VatProdPostingGroup);
            VatProdPostingGroup.Code := Code;
            VatProdPostingGroup.Insert();
        end;
    end;

    local procedure CreateCountryRegionCode(Code: code[20]) CountryRegion: Record "Country/Region"
    begin
        CountryRegion.Reset();
        if not CountryRegion.Get(code) then begin
            Clear(CountryRegion);
            CountryRegion.Code := CopyStr(Code, 1, MaxStrLen(CountryRegion.Code));
            CountryRegion.Insert();
        end;
    end;

    local procedure CreateNoSeries(Code: Code[20]) NoSeries: Record "No. Series"
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        if not NoSeries.Get(Code) then begin
            NoSeries.Code := Code;
            NoSeries."Default Nos." := true;
            NoSeries.Insert();
            NoSeriesLine."Series Code" := Code;
            NoSeriesLine."Starting No." := '90000';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine."Ending No." := '100000';
            NoSeriesLine.Open := true;
            NoSeriesLine.Insert();
        end;
    end;

    local procedure CreateCustomerTemplate(PostingGroupCode: Code[20]) Code: Code[20]
    var
        CustomerPostingGroup: Record "Customer Posting Group";
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        VatBusinessPostingGroup: Record "VAT Business Posting Group";
        GeneralPostingSetup: Record "General Posting Setup";
        VatPostingSetup: Record "VAT Posting Setup";
    begin
        Code := CopyStr(Any.AlphabeticText(10), 1, MaxStrLen(Code));
        CustomerPostingGroup := CreateCustomerPostingGroup(PostingGroupCode);
        GenBusinessPostingGroup := CreateGenBusPostingGroup(PostingGroupCode);
        VatBusinessPostingGroup := CreateVatBusPostingGroup(PostingGroupCode);

        CreateCustomerTempl(Code, CustomerPostingGroup.Code, GenBusinessPostingGroup.Code, VatBusinessPostingGroup.Code);

        Clear(VatPostingSetup);
        VatPostingSetup."VAT Bus. Posting Group" := PostingGroupCode;
        VatPostingSetup."VAT Prod. Posting Group" := PostingGroupCode;
        VatPostingSetup."VAT Calculation Type" := "Tax Calculation Type"::"Normal VAT";
        if not VatPostingSetup.Insert() then
            VatPostingSetup.Modify();

        Clear(GeneralPostingSetup);
        GeneralPostingSetup."Gen. Bus. Posting Group" := PostingGroupCode;
        GeneralPostingSetup."Gen. Prod. Posting Group" := PostingGroupCode;
        if not GeneralPostingSetup.Insert() then
            GeneralPostingSetup.Modify();
    end;

    local procedure CreateCustomerTempl(CustomerTemplCode: Code[20]; CustomerPostingGroupCode: Code[20]; GenBusinessPostingGroupCode: Code[20]; VATBusinessPostingGroupCode: Code[20])
    var
        CustomerTempl: Record "Customer Templ.";
    begin
        CustomerTempl.Code := CustomerTemplCode;
        CustomerTempl."Customer Posting Group" := CustomerPostingGroupCode;
        CustomerTempl."Gen. Bus. Posting Group" := GenBusinessPostingGroupCode;
        CustomerTempl."VAT Bus. Posting Group" := VATBusinessPostingGroupCode;
        if not CustomerTempl.Insert() then
            CustomerTempl.Modify();
    end;

    local procedure CreateCustomerPostingGroup(Code: Code[20]) CustPostingGroup: Record "Customer Posting Group"
    begin
        CustPostingGroup.SetRange(Code);
        if not CustPostingGroup.Get(Code) then begin
            Clear(CustPostingGroup);
            CustPostingGroup.Code := Code;
            CustPostingGroup.Insert();
        end;
    end;

    local procedure CreateGenBusPostingGroup(Code: Code[20]) GenBusPostingGroup: Record "Gen. Business Posting Group";
    begin
        GenBusPostingGroup.SetRange(Code);
        if not GenBusPostingGroup.Get(Code) then begin
            Clear(GenBusPostingGroup);
            GenBusPostingGroup.Code := Code;
            GenBusPostingGroup."Def. VAT Bus. Posting Group" := CreateVatBusPostingGroup(Code).Code;
            GenBusPostingGroup.Insert();
        end;
    end;

    local procedure CreateVatBusPostingGroup(Code: Code[20]) VatBusPostingGroup: Record "VAT Business Posting Group"
    begin
        VatBusPostingGroup.SetRange(Code);
        if not VatBusPostingGroup.Get(Code) then begin
            Clear(VatBusPostingGroup);
            VatBusPostingGroup.Code := Code;
            VatBusPostingGroup.Insert();
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnGetAccessToken', '', true, false)]
    local procedure OnGetAccessToken(var AccessToken: Text)
    begin
        if ShopifyAccessToken = '' then
            ShopifyAccessToken := Any.AlphanumericText(50);
        AccessToken := ShopifyAccessToken;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnClientSend', '', true, false)]
    local procedure OnClientSend(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    begin
        TestRequestHeaderContainsAccessToken(HttpRequestMessage);
    end;

    local procedure TestRequestHeaderContainsAccessToken(HttpRequestMessage: HttpRequestMessage)
    var
        Headers: HttpHeaders;
        ShopifyAccessTokenTxt: Label 'X-Shopify-Access-Token', Locked = true;
        Values: array[1] of Text;
    begin
        HttpRequestMessage.GetHeaders(Headers);
        LibraryAssert.IsTrue(Headers.Contains(ShopifyAccessTokenTxt), 'access token doesn''t exist');
        Headers.GetValues(ShopifyAccessTokenTxt, Values);
        LibraryAssert.IsTrue(Values[1] = ShopifyAccessToken, 'invalid access token');
    end;

    internal procedure CreateVATPostingSetup(BusinessPostingGroup: Code[20]; ProductPostingGroup: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
        VatPostingSetup: Record "VAT Posting Setup";
    begin
        if not VatPostingSetup.Get(BusinessPostingGroup, ProductPostingGroup) then begin
            Clear(VatPostingSetup);
            VatPostingSetup."VAT Bus. Posting Group" := BusinessPostingGroup;
            VatPostingSetup."VAT Prod. Posting Group" := ProductPostingGroup;
            VatPostingSetup."VAT Identifier" := CopyStr(Any.AlphabeticText(MaxStrLen(VatPostingSetup."VAT Identifier")), 1, MaxStrLen(VatPostingSetup."VAT Identifier"));
            VatPostingSetup."VAT Calculation Type" := "Tax Calculation Type"::"Normal VAT";
            VatPostingSetup."VAT %" := 10;
            VatPostingSetup.Insert();
        end;

        if not GeneralPostingSetup.Get(BusinessPostingGroup, ProductPostingGroup) then begin
            Clear(GeneralPostingSetup);
            GeneralPostingSetup."Gen. Bus. Posting Group" := BusinessPostingGroup;
            GeneralPostingSetup."Gen. Prod. Posting Group" := ProductPostingGroup;
            GeneralPostingSetup.Insert();
        end;
    end;

    internal procedure RegisterAccessTokenForShop(Store: Text; AccessToken: SecretText)
    var
        RegisteredStoreNew: Record "Shpfy Registered Store New";
        ScopeTxt: Label 'write_orders,read_all_orders,write_assigned_fulfillment_orders,read_checkouts,write_customers,read_discounts,write_files,write_merchant_managed_fulfillment_orders,write_fulfillments,write_inventory,read_locations,write_products,write_shipping,read_shopify_payments_disputes,read_shopify_payments_payouts,write_returns,write_translations,write_third_party_fulfillment_orders,write_order_edits,write_companies,write_publications,write_payment_terms,write_draft_orders,read_locales,read_shopify_payments_accounts,read_users', Locked = true;
    begin
        Store := Store.ToLower();
        if not RegisteredStoreNew.Get(Store) then begin
            RegisteredStoreNew.Init();
            RegisteredStoreNew.Store := CopyStr(Store, 1, MaxStrLen(RegisteredStoreNew.Store));
            RegisteredStoreNew.Insert(false);
        end;
        RegisteredStoreNew."Requested Scope" := ScopeTxt;
        RegisteredStoreNew."Actual Scope" := ScopeTxt;
        RegisteredStoreNew.Modify(false);
        RegisteredStoreNew.SetAccessToken(AccessToken);
    end;

    local procedure CreateShippingChargesGLAcc(var VATPostingSetup: Record "VAT Posting Setup"; GenPostingType: Enum "General Posting Type"; PostingGroupCode: Code[20]): Code[20]
    var
        ShippingChargesGLAccount: Record "G/L Account";
    begin
        ShippingChargesGLAccount.Get(LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, GenPostingType::Sale));
        ShippingChargesGLAccount."Direct Posting" := true;
        ShippingChargesGLAccount.Modify(false);
        CreateVATPostingSetup(PostingGroupCode, ShippingChargesGLAccount."VAT Prod. Posting Group");
        exit(ShippingChargesGLAccount."No.");
    end;
}