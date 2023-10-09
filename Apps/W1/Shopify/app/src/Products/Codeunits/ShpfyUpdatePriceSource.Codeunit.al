namespace Microsoft.Integration.Shopify;

using Microsoft.Pricing.Source;
using Microsoft.Sales.Customer;

codeunit 30272 "Shpfy Update Price Source"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Price Source - Customer", 'OnBeforeGetId', '', true, false)]
    local procedure GetId(var PriceSource: Record "Price Source"; var IsHandled: Boolean)
    var
        ShpfyShop: Record "Shpfy Shop";
        Customer: Record Customer;
        ShpfyProductPriceCalc: Codeunit "Shpfy Product Price Calc.";
        ShpfyShopCode: Code[20];
    begin
        if Customer.get(PriceSource."Source No.") then
            exit;
        ShpfyProductPriceCalc.GetShop(ShpfyShopCode);
        ShpfyShop.get(ShpfyShopCode);

        PriceSource."Currency Code" := ShpfyShop."Currency Code";
        PriceSource."Allow Line Disc." := ShpfyShop."Allow Line Disc.";
        PriceSource."Price Includes VAT" := ShpfyShop."Prices Including VAT";
        PriceSource."VAT Bus. Posting Gr. (Price)" := ShpfyShop."VAT Bus. Posting Group";

        IsHandled := true;
    end;
}

