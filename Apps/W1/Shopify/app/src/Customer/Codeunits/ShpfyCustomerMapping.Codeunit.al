/// <summary>
/// Codeunit Shpfy Customer Mapping (ID 3018).
/// </summary>
codeunit 30118 "Shpfy Customer Mapping"
{
    Access = Internal;
    Permissions = tabledata Customer = rim;

    var
        Shop: Record "Shpfy Shop";
        CustomerApi: Codeunit "Shpfy Customer API";
        SyncCustomers: Codeunit "Shpfy Sync Customers";
        JsonHelper: Codeunit "Shpfy Json Helper";
        CustomerEvents: Codeunit "Shpfy Customer Events";

    internal procedure DoMapping(CustomerId: BigInteger; JCustomerInfo: JsonObject; ShopCode: Code[20]; TemplateCode: Code[10]; AllowCreate: Boolean): Code[20]
    var
        LocalShop: Record "Shpfy Shop";
        IMapping: Interface "Shpfy ICustomer Mapping";
        Name: Text;
        Name2: Text;
    begin
        Name := Format(JsonHelper.GetValueAsText(JCustomerInfo, 'Name'));
        Name2 := Format(JsonHelper.GetValueAsText(JCustomerInfo, 'Name2'));
        if (Name = '') and (Name2 = '') then
            IMapping := "Shpfy Customer Mapping"::"By EMail/Phone"
        else begin
            LocalShop.Get(ShopCode);
            IMapping := LocalShop."Customer Mapping Type";
        end;
        exit(IMapping.DoMapping(CustomerId, JCustomerInfo, ShopCode, TemplateCode, AllowCreate));
    end;

    /// <summary> 
    /// Find Mapping.
    /// </summary>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure FindMapping(var ShopifyCustomer: Record "Shpfy Customer"): Boolean;
    var
        Customer: Record Customer;
        Handled: Boolean;
        Direction: enum "Shpfy Mapping Direction";
    begin
        if not IsNullGuid(ShopifyCustomer."Customer SystemId") then
            if Customer.GetBySystemId(ShopifyCustomer."Customer SystemId") then
                exit(true)
            else begin
                Clear(ShopifyCustomer."Customer SystemId");
                ShopifyCustomer.Modify();
            end;

        Direction := Direction::ShopifyToBC;
        CustomerEvents.OnBeforeFindMapping(Direction, ShopifyCustomer, Customer, Handled);
        if Handled then
            exit(not IsNullGuid(ShopifyCustomer."Customer SystemId"));
        if IsNullGuid(ShopifyCustomer."Customer SystemId") then
            if DoFindMapping(Direction, ShopifyCustomer, Customer) then begin
                CustomerEvents.OnAfterFindMapping(Direction, ShopifyCustomer, Customer);
                if Customer.Get() then begin
                    ShopifyCustomer."Customer SystemId" := Customer.SystemId;
                    ShopifyCustomer.Modify();
                    exit(true);
                end;
            end;
    end;

    /// <summary> 
    /// Find Mapping.
    /// </summary>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    /// <returns>Return value of type BigInteger.</returns>
    internal procedure FindMapping(Customer: Record Customer): BigInteger
    var
        ShopifyCustomer: Record "Shpfy Customer";
        Handled: Boolean;
        Direction: enum "Shpfy Mapping Direction";
    begin
        Direction := Direction::BCToShopify;
        CustomerEvents.OnBeforeFindMapping(Direction, ShopifyCustomer, Customer, Handled);
        if Handled then
            exit(ShopifyCustomer.Id);
        if DoFindMapping(Direction, ShopifyCustomer, Customer) then
            exit(ShopifyCustomer.Id);
    end;

    /// <summary> 
    /// Do Find Mapping.
    /// </summary>
    /// <param name="Direction">Parameter of type enum "Shopify Mapping Direction".</param>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    /// <returns>Return value of type Boolean.</returns>
    local procedure DoFindMapping(Direction: enum "Shpfy Mapping Direction"; var ShopifyCustomer: Record "Shpfy Customer"; var Customer: Record Customer): Boolean;
    var
        FindCustomer: Record Customer;
        FindShopifyCustomer: Record "Shpfy Customer";
        ShopifyCustomerId: BigInteger;
        PhoneFilter: Text;
    begin
        case Direction of
            Direction::ShopifyToBC:
                begin
                    if ShopifyCustomer.Email <> '' then begin
                        FindCustomer.SetFilter("E-Mail", '@' + ShopifyCustomer.Email);
                        if FindCustomer.FindFirst() then begin
                            Customer := FindCustomer;
                            exit(true);
                        end;
                    end;
                    if ShopifyCustomer."Phone No." <> '' then begin
                        PhoneFilter := CreatePhoneFilter(ShopifyCustomer."Phone No.");
                        if PhoneFilter <> '' then begin
                            Clear(FindCustomer);
                            FindCustomer.SetFilter("Phone No.", PhoneFilter);
                            if FindCustomer.FindFirst() then begin
                                Customer := FindCustomer;
                                exit(true);
                            end;
                        end;
                    end;
                end;
            Direction::BCToShopify:
                begin
                    FindShopifyCustomer.SetRange("Customer SystemId", Customer.SystemId);
                    if FindShopifyCustomer.FindFirst() then begin
                        ShopifyCustomer := FindShopifyCustomer;
                        exit(true);
                    end;

                    Clear(ShopifyCustomer);
                    ShopifyCustomerId := CustomerApi.FindIdByEmail(Customer."E-Mail");
                    if ShopifyCustomerId = 0 then
                        ShopifyCustomerId := CustomerApi.FindIdByPhone(Customer."Phone No.");
                    if ShopifyCustomer.Get(ShopifyCustomerId) then
                        exit(true)
                    else begin
                        Clear(ShopifyCustomer);
                        ShopifyCustomer.Id := ShopifyCustomerId;
                        ShopifyCustomer.Insert(false);
                        if CustomerApi.RetrieveShopifyCustomer(ShopifyCustomer) then begin
                            ShopifyCustomer."Customer SystemId" := Customer.SystemId;
                            ShopifyCustomer.Modify(false);
                            exit(true);
                        end else begin
                            ShopifyCustomer.Delete(false);
                            exit(false);
                        end;
                    end;
                end;
        end;
    end;

    /// <summary> 
    /// Description for CreatePhoneFilter.
    /// </summary>
    /// <param name="PhoneNo">Parameter of type Text.</param>
    /// <returns>Return variable "Text".</returns>
    local procedure CreatePhoneFilter(PhoneNo: Text): Text
    var
        FilterBuilder: TextBuilder;
        I: Integer;
    begin
        PhoneNo := DelChr(PhoneNo, '=', DelChr(PhoneNo, '=', '0123456789'));
        PhoneNo := PhoneNo.TrimStart('0');
        For I := 1 to StrLen(PhoneNo) do begin
            FilterBuilder.Append('*');
            FilterBuilder.Append(PhoneNo[I]);
        end;
        exit(FilterBuilder.ToText());
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="Code">Parameter of type Code[20].</param>
    internal procedure SetShop(Code: Code[20])
    begin
        Clear(Shop);
        Shop.Get(Code);
        SetShop(Shop);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        SyncCustomers.SetShop(Shop);
        CustomerApi.SetShop(Shop);
    end;
}