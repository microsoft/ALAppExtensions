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
    internal procedure DoMapping(CustomerId: BigInteger; JCustomerInfo: JsonObject; ShopCode: Code[20]; TemplateCode: Code[10]; AllowCreate: Boolean): Code[20];
    var
        ShpfyCustomer: Record "Shpfy Customer";
        CustomerImport: Codeunit "Shpfy Customer Import";
    begin
        ShpfyCustomer.SetAutoCalcFields("Customer No.");
        if ShpfyCustomer.Get(CustomerId) then begin
            if not IsNullGuid(ShpfyCustomer."Customer SystemId") then begin
                ShpfyCustomer.CalcFields("Customer No.");
                if ShpfyCustomer."Customer No." = '' then begin
                    Clear(ShpfyCustomer."Customer SystemId");
                    ShpfyCustomer.Modify();
                end else
                    exit(ShpfyCustomer."Customer No.");
            end;
        end else begin
            CustomerImport.SetShop(ShopCode);
            CustomerImport.SetTemplateCode(TemplateCode);
            CustomerImport.SetCustomer(CustomerId);
            CustomerImport.SetAllowCreate(AllowCreate);
            CustomerImport.Run();
            CustomerImport.GetCustomer(ShpfyCustomer);
            ShpfyCustomer.Find();
            ShpfyCustomer.CalcFields("Customer No.");
        end;
        exit(ShpfyCustomer."Customer No.");
    end;
}