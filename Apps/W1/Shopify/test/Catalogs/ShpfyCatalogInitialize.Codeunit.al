// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;

codeunit 139639 "Shpfy Catalog Initialize"
{
    SingleInstance = true;

    var
        Any: Codeunit Any;

    internal procedure CreateCatalog(Company: Record "Shpfy Company"): Record "Shpfy Catalog"
    var
        Catalog: Record "Shpfy Catalog";
    begin

        Catalog.DeleteAll();
        Catalog.Init();
        Catalog.Id := Any.IntegerInRange(1, 99999);
        Catalog.Name := 'Name';
        Catalog."Company SystemId" := Company.SystemId;
        Catalog.Insert();
        exit(Catalog);
    end;

    internal procedure CopyParametersFromShop(var Catalog: Record "Shpfy Catalog"; var Shop: Record "Shpfy Shop")
    begin
        Catalog."Allow Line Disc." := Shop."Allow Line Disc.";
        Catalog."Customer Discount Group" := Shop."Customer Discount Group";
        Catalog."Customer Posting Group" := Shop."Customer Posting Group";
        Catalog."Customer Price Group" := Shop."Customer Price Group";
        Catalog."Gen. Bus. Posting Group" := Shop."Gen. Bus. Posting Group";
        Catalog."Prices Including VAT" := Shop."Prices Including VAT";
        Catalog."Tax Area Code" := Shop."Tax Area Code";
        Catalog."Tax Liable" := Shop."Tax Liable";
        Catalog."VAT Bus. Posting Group" := Shop."VAT Bus. Posting Group";
        Catalog."VAT Country/Region Code" := Shop."VAT Country/Region Code";
        Catalog.Modify();
    end;

    internal procedure CatalogResponse(): JsonObject
    var
        JResult: JsonObject;
        ResultTxt: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Catalogs/CatalogResponse.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(ResultTxt);
        JResult.ReadFrom(ResultTxt);
        exit(JResult);
    end;

    internal procedure CatalogPriceResponse(ProductId: Integer): JsonObject
    var
        JResult: JsonObject;
        ResultTxt: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Catalogs/CatalogPriceResponse.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(ResultTxt);
        JResult.ReadFrom(Format(ResultTxt).Replace('{{ProductId}}', Format(ProductId)));
        exit(JResult);
    end;
}