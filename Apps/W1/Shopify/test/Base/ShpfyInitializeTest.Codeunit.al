/// <summary>
/// Codeunit Shpfy Initialize Test (ID 139561).
/// </summary>
codeunit 139561 "Shpfy Initialize Test"
{
    //EventSubscriberInstance = Manual;
    SingleInstance = true;

    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";
        ShpfyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        _AccessToken: Text;

    trigger OnRun()
    begin
        if ShpfyCommunicationMgt.GetShopRecord()."Shopify URL" = '' then
            CreateShop();
        Commit();
    end;

    internal procedure CreateShop(): Record "Shpfy Shop"
    var
        ShpfyShop: Record "Shpfy Shop";
        Code: Code[10];
        UrlTxt: Label 'https://%1.myshopify.com', Comment = '%1 = Shop name', Locked = true;
    begin
        Code := Any.AlphabeticText(MaxStrLen(Code));

        ShpfyShop.Init();
        ShpfyShop.Code := Code;
        ShpfyShop."Shopify URL" := StrSubstNo(UrlTxt, Any.AlphabeticText(20));
        ShpfyShop.Enabled := true;
        ShpfyShop."Customer Template Code" := CreateCustomerTemplate();
        ShpfyShop."Item Template Code" := CreateItemTemplate();
        CreateVATPostingSetup(ShpfyShop."Customer Template Code", ShpfyShop."Item Template Code");

        ShpfyShop.Insert();
        ShpfyCommunicationMgt.SetShop(ShpfyShop);
        ShpfyCommunicationMgt.SetTestInProgress(true);
        exit(ShpfyShop);
    end;


    local procedure CreateItemTemplate() Code: Code[10]
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        InventoryPostingGroup: Record "Inventory Posting Group";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        VatProductPostingGroup: Record "VAT Product Posting Group";
        Item: Record Item;
    begin
        Code := Any.AlphabeticText(MaxStrLen(Code));
        ConfigTemplateHeader.Init();
        ConfigTemplateHeader.Code := Code;
        ConfigTemplateHeader.Validate("Table ID", Database::Item);
        ConfigTemplateHeader.Enabled := true;
        ConfigTemplateHeader.Insert();

        InventoryPostingGroup := CreateInventoryPostingGroup(Code);
        AddFieldTemplate(ConfigTemplateHeader.Code, 10000, Database::Item, Item.FieldNo("Inventory Posting Group"), InventoryPostingGroup.Code);
        GenProductPostingGroup := CreateGenProdPostingGroup(Code);
        AddFieldTemplate(ConfigTemplateHeader.Code, 20000, Database::Item, Item.FieldNo("Gen. Prod. Posting Group"), GenProductPostingGroup.Code);
        VatProductPostingGroup := CreateVatProdPostingGroup(Code);
        AddFieldTemplate(ConfigTemplateHeader.Code, 30000, Database::Item, Item.FieldNo("VAT Prod. Posting Group"), VatProductPostingGroup.Code);
    end;

    local procedure AddFieldTemplate(Code: code[10]; LineNo: Integer; TableId: Integer; FieldId: Integer; Value: Text)
    var
        ConfigTemplateLine: Record "Config. Template Line";
    begin
        ConfigTemplateLine.Init();
        ConfigTemplateLine."Data Template Code" := Code;
        ConfigTemplateLine.Validate("Table ID", TableId);
        ConfigTemplateLine."Line No." := LineNo;
        ConfigTemplateLine.Validate("Field ID", FieldId);
        ConfigTemplateLine.Validate("Default Value", CopyStr(Value, 1, MaxStrLen(ConfigTemplateLine."Default Value")));
        ConfigTemplateLine.Insert();
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

    local procedure CreateCustomerTemplate() Code: Code[10]
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        CustomerPostingGroup: Record "Customer Posting Group";
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        VatBusinessPostingGroup: Record "VAT Business Posting Group";
        GeneralPostingSetup: Record "General Posting Setup";
        VatPostingSetup: Record "VAT Posting Setup";
        Customer: Record Customer;
    begin
        Code := Any.AlphabeticText(MaxStrLen(Code));
        ConfigTemplateHeader.Init();
        ConfigTemplateHeader.Code := Code;
        ConfigTemplateHeader.Validate("Table ID", Database::Customer);
        ConfigTemplateHeader.Enabled := true;
        ConfigTemplateHeader.Insert();

        CustomerPostingGroup := CreateCustomerPostingGroup(Code);
        AddFieldTemplate(ConfigTemplateHeader.Code, 10000, Database::CUstomer, Customer.FieldNo("Customer Posting Group"), CustomerPostingGroup.Code);
        GenBusinessPostingGroup := CreateGenBusPostingGroup(Code);
        AddFieldTemplate(ConfigTemplateHeader.Code, 20000, Database::CUstomer, Customer.FieldNo("Gen. Bus. Posting Group"), GenBusinessPostingGroup.Code);
        VatBusinessPostingGroup := CreateVatBusPostingGroup(Code);
        AddFieldTemplate(ConfigTemplateHeader.Code, 30000, Database::CUstomer, Customer.FieldNo("VAT Bus. Posting Group"), VatBusinessPostingGroup.Code);

        if not VatPostingSetup.Get(Code, Code) then begin
            Clear(VatPostingSetup);
            VatPostingSetup."VAT Bus. Posting Group" := Code;
            VatPostingSetup."VAT Prod. Posting Group" := Code;
            VatPostingSetup."VAT Calculation Type" := "Tax Calculation Type"::"Normal VAT";
            VatPostingSetup.Insert();
        end;

        if not GeneralPostingSetup.Get(Code, Code) then begin
            Clear(GeneralPostingSetup);
            GeneralPostingSetup."Gen. Bus. Posting Group" := Code;
            GeneralPostingSetup."Gen. Prod. Posting Group" := Code;
            GeneralPostingSetup.Insert();
        end;
    end;

    local procedure CreateCustomerPostingGroup(Code: Code[10]) CustPostingGroup: Record "Customer Posting Group"
    begin
        CustPostingGroup.SetRange(Code);
        if not CustPostingGroup.Get(Code) then begin
            Clear(CustPostingGroup);
            CustPostingGroup.Code := Code;
            CustPostingGroup.Insert();
        end;
    end;

    local procedure CreateGenBusPostingGroup(Code: Code[10]) GenBusPostingGroup: Record "Gen. Business Posting Group";
    begin
        GenBusPostingGroup.SetRange(Code);
        if not GenBusPostingGroup.Get(Code) then begin
            Clear(GenBusPostingGroup);
            GenBusPostingGroup.Code := Code;
            GenBusPostingGroup."Def. VAT Bus. Posting Group" := CreateVatBusPostingGroup(Code).Code;
            GenBusPostingGroup.Insert();
        end;
    end;

    local procedure CreateVatBusPostingGroup(Code: Code[10]) VatBusPostingGroup: Record "VAT Business Posting Group"
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
        if _AccessToken = '' then
            _AccessToken := Any.AlphanumericText(50);
        AccessToken := _AccessToken;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnClientSend', '', true, false)]
    local procedure OnClientSend(HttpRequestMsg: HttpRequestMessage; var HttpResponseMsg: HttpResponseMessage)
    begin
        TestRequestHeaderContainsAccessToken(HttpRequestMsg);
    end;

    local procedure TestRequestHeaderContainsAccessToken(HttpRequestMessage: HttpRequestMessage)
    var
        Headers: HttpHeaders;
        ShopifyAccessTokenTxt: Label 'X-Shopify-Access-Token', Locked = true;
        Values: Array[1] of Text;
    begin
        HttpRequestMessage.GetHeaders(Headers);
        LibraryAssert.IsTrue(Headers.Contains(ShopifyAccessTokenTxt), 'access token doesn''t exist');
        Headers.GetValues(ShopifyAccessTokenTxt, Values);
        LibraryAssert.IsTrue(Values[1] = _AccessToken, 'invalid access token');
    end;

    local procedure CreateVATPostingSetup(BusinessPostingGroup: Code[10]; ProductPostingGroup: Code[10])
    var
        GeneralPostingSetup: Record "General Posting Setup";
        VatPostingSetup: Record "VAT Posting Setup";
    begin
        if not VatPostingSetup.Get(BusinessPostingGroup, ProductPostingGroup) then begin
            Clear(VatPostingSetup);
            VatPostingSetup."VAT Bus. Posting Group" := BusinessPostingGroup;
            VatPostingSetup."VAT Prod. Posting Group" := ProductPostingGroup;
            VatPostingSetup."VAT Calculation Type" := "Tax Calculation Type"::"Normal VAT";
            VatPostingSetup.Insert();
        end;

        if not GeneralPostingSetup.Get(BusinessPostingGroup, ProductPostingGroup) then begin
            Clear(GeneralPostingSetup);
            GeneralPostingSetup."Gen. Bus. Posting Group" := BusinessPostingGroup;
            GeneralPostingSetup."Gen. Prod. Posting Group" := ProductPostingGroup;
            GeneralPostingSetup.Insert();
        end;
    end;

}
