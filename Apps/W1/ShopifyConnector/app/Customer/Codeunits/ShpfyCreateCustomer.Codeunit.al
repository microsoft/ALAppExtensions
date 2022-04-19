/// <summary>
/// Codeunit Shpfy Create Customer (ID 30110).
/// </summary>
codeunit 30110 "Shpfy Create Customer"
{
    Access = Internal;
    Permissions =
        tabledata "Config. Template Header" = r,
        tabledata "Config. Template Line" = r,
        tabledata "Country/Region" = r,
        tabledata Customer = rim,
        tabledata "Dimensions Template" = r;
    TableNo = "Shpfy Customer Address";

    var
        Shop: Record "Shpfy Shop";
        CustomerEvents: Codeunit "Shpfy Customer Events";
        TemplateCode: Code[10];

    trigger OnRun()
    var
        Customer: Record Customer;
        Handled: Boolean;
    begin
        CustomerEvents.OnBeforeCreateCustomer(Shop, Rec, Customer, Handled);
        if not Handled then begin
            DoCreateCustomer(Shop, Rec, Customer);
            CustomerEvents.OnAfterCreateCustomer(Shop, Rec, Customer);
        end;
    end;

    /// <summary> 
    /// Do Create Customer.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyAddress">Parameter of type Record "Shopify Customer Address".</param>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    local procedure DoCreateCustomer(Shop: Record "Shpfy Shop"; var ShopifyAddress: Record "Shpfy Customer Address"; var Customer: Record Customer);
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigConfigTemplateLine: Record "Config. Template Line";
        DimensionsTemplate: Record "Dimensions Template";
        ShopifyCustomer: Record "Shpfy Customer";
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        CustCont: Codeunit "CustCont-Update";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        UpdateCustomer: Codeunit "Shpfy Update Customer";
        CustRecRef: RecordRef;
        CurrentTemplateCode: Code[10];
    begin

        ShopifyCustomer.Get(ShopifyAddress."Customer Id");

        if TemplateCode = '' then
            CurrentTemplateCode := FindCustomerTemplate(Shop, ShopifyAddress."Country/Region Code")
        else
            CurrentTemplateCode := TemplateCode;
        if (CurrentTemplateCode <> '') and ConfigTemplateHeader.Get(CurrentTemplateCode) then begin
            Clear(Customer);
            ConfigConfigTemplateLine.SetRange("Data Template Code", ConfigTemplateHeader.Code);
            ConfigConfigTemplateLine.SetRange(Type, ConfigConfigTemplateLine.Type::Field);
            ConfigConfigTemplateLine.SetRange("Table ID", Database::Customer);
            ConfigConfigTemplateLine.SetRange("Field ID", Customer.FieldNo("No. Series"));
            if ConfigConfigTemplateLine.FindFirst() and (ConfigConfigTemplateLine."Default Value" <> '') then
                NoSeriesMgt.InitSeries(CopyStr(ConfigConfigTemplateLine."Default Value", 1, 20), CopyStr(ConfigConfigTemplateLine."Default Value", 1, 20), 0D, Customer."No.", Customer."No. Series");
            Customer.Insert(true);
            CustRecRef.GetTable(Customer);
            ConfigTemplateManagement.UpdateRecord(ConfigTemplateHeader, CustRecRef);
            DimensionsTemplate.InsertDimensionsFromTemplates(ConfigTemplateHeader, Customer."No.", Database::Customer);
            CustRecRef.SetTable(Customer);
            UpdateCustomer.FillInCustomerFields(Customer, Shop, ShopifyCustomer, ShopifyAddress);
            Customer.Modify();
            ShopifyAddress.CustomerSystemId := Customer.SystemId;
            ShopifyAddress.Modify();
            if IsNullGuid(ShopifyCustomer."Customer SystemId") then begin
                ShopifyCustomer."Customer SystemId" := Customer.SystemId;
                ShopifyCustomer.Modify();
            end;
            CustCont.OnModify(Customer);
        end;
    end;

    /// <summary> 
    /// Find Customer Template.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="CountryCode">Parameter of type code[20].</param>
    /// <returns>Return variable "Result" of type Code[20].</returns>
    local procedure FindCustomerTemplate(Shop: Record "Shpfy Shop"; CountryCode: code[20]) Result: Code[10]
    var
        CustomerTemplate: Record "Shpfy Customer Template";
        IsHandled: Boolean;
    begin
        CustomerEvents.OnBeforeFindCustomerTemplate(Shop, CountryCode, Result, IsHandled);
        if not IsHandled then begin
            if CustomerTemplate.Get(SHop.Code, CountryCode) then begin
                if CustomerTemplate."Customer Template Code" <> '' then
                    Result := CustomerTemplate."Customer Template Code";
            end else begin
                Clear(CustomerTemplate);
                CustomerTemplate."Shop Code" := Shop.Code;
                CustomerTemplate."Country/Region Code" := CountryCode;
                CustomerTemplate.Insert();
            end;
            if Result = '' then begin
                Shop.TestField("Customer Template Code");
                Result := Shop."Customer Template Code";
            end;
            CustomerEvents.OnAfterFindCustomerTemplate(Shop, CountryCode, Result);
        end;
        exit(Result);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="Code">Parameter of type Code[20].</param>
    internal procedure SetShop(Code: Code[20])
    begin
        Clear(Shop);
        Shop.Get(Code);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
    end;

    /// <summary> 
    /// Set Template Code.
    /// </summary>
    /// <param name="Code">Parameter of type Code[10].</param>
    internal procedure SetTemplateCode(Code: Code[10])
    begin
        TemplateCode := Code;
    end;
}