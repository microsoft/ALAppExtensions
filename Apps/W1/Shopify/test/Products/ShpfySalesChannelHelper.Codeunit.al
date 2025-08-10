// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

codeunit 139699 "Shpfy Sales Channel Helper"
{
    internal procedure GetDefaultShopifySalesChannelResponse(OnlineStoreId: BigInteger; POSId: BigInteger): JsonArray
    var
        JPublications: JsonArray;
        NodesTxt: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Products/DefaultSalesChannelResponse.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(NodesTxt);
        JPublications.ReadFrom(StrSubstNo(NodesTxt, OnlineStoreId, POSId));
        exit(JPublications);
    end;
}