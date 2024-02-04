namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Company Import (ID 30301).
/// </summary>
codeunit 30301 "Shpfy Company Import"
{
    Access = Internal;
    TableNo = "Shpfy Company";

    trigger OnRun()
    begin
        if Rec.Id = 0 then
            exit;

        SetCompany(Rec.Id);

        if not CompanyApi.RetrieveShopifyCompany(ShopifyCompany, TempShopifyCustomer) then begin
            ShopifyCompany.Delete();
            exit;
        end;

        Commit();
        if CompanyMapping.FindMapping(ShopifyCompany, TempShopifyCustomer) then begin
            if Shop."Shopify Can Update Companies" then begin
                UpdateCustomer.SetShop(Shop);
                UpdateCustomer.UpdateCustomerFromCompany(ShopifyCompany);
            end;
        end else
            if Shop."Auto Create Unknown Companies" or AllowCreate then begin
                CreateCustomer.SetShop(Shop);
                CreateCustomer.SetTemplateCode(TemplateCode);
                CreateCustomer.CreateCustomerFromCompany(ShopifyCompany, TempShopifyCustomer);
            end;
    end;

    var
        Shop: Record "Shpfy Shop";
        ShopifyCompany: Record "Shpfy Company";
        TempShopifyCustomer: Record "Shpfy Customer" temporary;
        CompanyApi: Codeunit "Shpfy Company API";
        CreateCustomer: Codeunit "Shpfy Create Customer";
        UpdateCustomer: Codeunit "Shpfy Update Customer";
        CompanyMapping: Codeunit "Shpfy Company Mapping";
        TemplateCode: Code[20];
        AllowCreate: Boolean;

    local procedure SetCompany(Id: BigInteger)
    begin
        if Id <> 0 then begin
            Clear(ShopifyCompany);
            ShopifyCompany.SetRange(Id, Id);
            if not ShopifyCompany.FindFirst() then begin
                ShopifyCompany.Id := Id;
                ShopifyCompany."Shop Id" := Shop."Shop Id";
                ShopifyCompany."Shop Code" := Shop.Code;
                ShopifyCompany.Insert(false);
            end;
        end;
    end;

    internal procedure GetCompany(var Company: Record "Shpfy Company")
    begin
        Company := ShopifyCompany;
    end;

    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        CompanyApi.SetShop(Shop);
    end;

    internal procedure SetShop(ShopCode: Code[20])
    var
        ShopifyShop: Record "Shpfy Shop";
    begin
        ShopifyShop.Get(ShopCode);
        SetShop(ShopifyShop);
    end;

    internal procedure SetAllowCreate(AllowCreateCompany: Boolean)
    begin
        AllowCreate := AllowCreateCompany;
    end;

    internal procedure SetTemplateCode(CustomerTemplateCode: Code[20])
    begin
        TemplateCode := CustomerTemplateCode;
    end;
}