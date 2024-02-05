namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Comp. By Default Comp. (ID 30305) implements Interface Shpfy ICompany Mapping.
/// </summary>
codeunit 30305 "Shpfy Comp. By Default Comp." implements "Shpfy ICompany Mapping"
{
    Access = Internal;

    var
        Shop: Record "Shpfy Shop";

    internal procedure DoMapping(CompanyId: BigInteger; ShopCode: Code[20]; TemplateCode: Code[20]; AllowCreate: Boolean): Code[20]
    begin
        Shop.Get(ShopCode);
        exit(Shop."Default Company No.");
    end;
}