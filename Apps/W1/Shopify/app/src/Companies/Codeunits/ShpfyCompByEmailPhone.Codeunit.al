namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit ShoShpfypify Comp. By Email/Phone (ID 30304) implements Interface Shpfy ICompany Mapping.
/// </summary>
codeunit 30304 "Shpfy Comp. By Email/Phone" implements "Shpfy ICompany Mapping"
{
    Access = Internal;

    internal procedure DoMapping(CompanyId: BigInteger; ShopCode: Code[20]; TemplateCode: Code[20]; AllowCreate: Boolean): Code[20]
    var
        ShopifyCompany: Record "Shpfy Company";
    begin
        ShopifyCompany.SetAutoCalcFields("Customer No.");
        if ShopifyCompany.Get(CompanyId) then begin
            if not IsNullGuid(ShopifyCompany."Customer SystemId") then begin
                ShopifyCompany.CalcFields("Customer No.");
                if ShopifyCompany."Customer No." = '' then begin
                    Clear(ShopifyCompany."Customer SystemId");
                    ShopifyCompany.Modify();
                end else
                    exit(ShopifyCompany."Customer No.");
            end;
            exit(CreateCompany(CompanyId, ShopCode, TemplateCode, AllowCreate));
        end else
            exit(CreateCompany(CompanyId, ShopCode, TemplateCode, AllowCreate));
        exit('');
    end;

    local procedure CreateCompany(CompanyId: BigInteger; ShopCode: Code[20]; TemplateCode: Code[20]; AllowCreate: Boolean): Code[20]
    var
        ShopifyCompany: Record "Shpfy Company";
        TempCompany: Record "Shpfy Company" temporary;
        CompanyImport: Codeunit "Shpfy Company Import";
    begin
        CompanyImport.SetShop(ShopCode);
        CompanyImport.SetAllowCreate(AllowCreate);
        CompanyImport.SetTemplateCode(TemplateCode);
        TempCompany.Id := CompanyId;
        TempCompany.Insert();
        CompanyImport.Run(TempCompany);
        CompanyImport.GetCompany(ShopifyCompany);
        if ShopifyCompany.Find() then
            ShopifyCompany.CalcFields("Customer No.");
        exit(ShopifyCompany."Customer No.");
    end;
}