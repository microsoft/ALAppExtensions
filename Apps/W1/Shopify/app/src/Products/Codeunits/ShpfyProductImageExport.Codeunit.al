/// <summary>
/// Codeunit Shpfy Product Image Export (ID 30179).
/// </summary>
codeunit 30179 "Shpfy Product Image Export"
{
    Access = Internal;
    Permissions = tabledata Item = r;
    TableNo = "Shpfy Product";

    trigger OnRun()
    var
        Item: Record Item;
        HashCalc: Codeunit "Shpfy Hash";
        NewImageId: BigInteger;
        Hash: Integer;
    begin
        if Shop."Sync Item Images" <> Shop."Sync Item Images"::"To Shopify" then
            exit;

        if Rec."Item SystemId" <> NullGuid then
            if Item.GetBySystemId(Rec."Item SystemId") then
                Hash := HashCalc.CalcItemImageHash(Item);
        if Hash <> Rec."Image Hash" then begin
            NewImageId := ProductApi.CreateShopifyProductImage(Rec, Item);
            if NewImageId <> Rec."Image Id" then
                Rec."Image Id" := Rec."Image Id";
            Rec."Image Hash" := Hash;
            Rec.Modify();
        end;
    end;

    var
        Shop: Record "Shpfy Shop";
        ProductApi: Codeunit "Shpfy Product API";
        NullGuid: Guid;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="Code">Parameter of type Code[20].</param>
    internal procedure SetShop(Code: Code[20])
    begin
        if (Shop.Code <> Code) then begin
            Clear(Shop);
            Shop.Get(Code);
            SetShop(Shop);
        end;
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        ProductApi.SetShop(Shop);
    end;
}