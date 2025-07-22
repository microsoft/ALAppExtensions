// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
        Customer: Record Customer;
        ShpfyProductPriceCalc: Codeunit "Shpfy Product Price Calc.";
    begin
        if Customer.Get(PriceSource."Source No.") then
            exit;

        PriceSource."Currency Code" := ShpfyProductPriceCalc.GetCurrencyCode();
        PriceSource."Allow Line Disc." := ShpfyProductPriceCalc.GetAllowLineDisc();
        PriceSource."Price Includes VAT" := ShpfyProductPriceCalc.GetPricesIncludingVAT();
        PriceSource."VAT Bus. Posting Gr. (Price)" := ShpfyProductPriceCalc.GetVATBusPostingGroup();
        IsHandled := true;
    end;
}

