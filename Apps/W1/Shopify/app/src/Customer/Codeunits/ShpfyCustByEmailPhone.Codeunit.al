/// <summary>
/// Codeunit ShoShpfypify Cust. By Email/Phone (ID 30113) implements Interface Shpfy ICustomer Mapping.
/// </summary>
codeunit 30113 "Shpfy Cust. By Email/Phone" implements "Shpfy ICustomer Mapping"
{
    Access = Internal;

    /// <summary>
    /// DoMapping.
    /// </summary>
    /// <param name="CustomerId">BigInteger.</param>
    /// <param name="JCustomerInfo">JsonObject: {"Name": "", "Name2": "", "Address": "", "Address2": "", "PostCode": "", "City": "", "County": "", "CountryCode": ""}.</param>
    /// <param name="ShopCode">Code[20].</param>
    /// <returns>Return value of type Code[20].</returns>
    internal procedure DoMapping(CustomerId: BigInteger; JCustomerInfo: JsonObject; ShopCode: Code[20]): Code[20];
    begin
        exit(DoMapping(CustomerId, JCustomerInfo, ShopCode, '', false));
    end;

    /// <summary>
    /// DoMapping.
    /// </summary>
    /// <param name="CustomerId">BigInteger.</param>
    /// <param name="JCustomerInfo">JsonObject: {"Name": "", "Name2": "", "Address": "", "Address2": "", "PostCode": "", "City": "", "County": "", "CountryCode": ""}.</param>
    /// <param name="ShopCode">Code[20].</param>
    /// <param name="TemplateCode">Code[10].</param>
    /// <param name="AllowCreate">Boolean.</param>
    /// <returns>Return value of type Code[20].</returns>
    internal procedure DoMapping(CustomerId: BigInteger; JCustomerInfo: JsonObject; ShopCode: Code[20]; TemplateCode: Code[20]; AllowCreate: Boolean): Code[20];
    var
        Customer: Record "Shpfy Customer";
        CustomerAddress: Record "Shpfy Customer Address";
        CustomerImport: Codeunit "Shpfy Customer Import";
        CreateCustomer: Codeunit "Shpfy Create Customer";
    begin
        Customer.SetAutoCalcFields("Customer No.");
        if Customer.Get(CustomerId) then begin
            if not IsNullGuid(Customer."Customer SystemId") then begin
                Customer.CalcFields("Customer No.");
                if Customer."Customer No." = '' then begin
                    Clear(Customer."Customer SystemId");
                    Customer.Modify();
                end else
                    exit(Customer."Customer No.");
            end;
            if AllowCreate then begin
                CustomerAddress.SetRange("Customer Id", CustomerId);
                CustomerAddress.SetRange(Default, true);
                if CustomerAddress.FindFirst() then begin
                    CreateCustomer.SetShop(ShopCode);
                    CreateCustomer.SetTemplateCode(TemplateCode);
                    CustomerAddress.SetRecFilter();
                    CreateCustomer.Run(CustomerAddress);
                    Customer.CalcFields("Customer No.");
                    exit(Customer."Customer No.");
                end;
            end;

        end else begin
            CustomerImport.SetShop(ShopCode);
            CustomerImport.SetTemplateCode(TemplateCode);
            CustomerImport.SetCustomer(CustomerId);
            CustomerImport.SetAllowCreate(AllowCreate);
            CustomerImport.Run();
            CustomerImport.GetCustomer(Customer);
            if Customer.Find() then
                Customer.CalcFields("Customer No.");
            exit(Customer."Customer No.");
        end;
        exit('');
    end;
}