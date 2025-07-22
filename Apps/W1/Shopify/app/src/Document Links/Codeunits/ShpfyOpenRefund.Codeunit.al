// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

codeunit 30266 "Shpfy Open Refund" implements "Shpfy IOpenShopifyDocument"
{

    procedure OpenDocument(DocumentId: BigInteger)
    var
        RefundHeader: Record "Shpfy Refund Header";
    begin
        if RefundHeader.Get(DocumentId) then begin
            RefundHeader.SetRecFilter();
            Page.Run(Page::"Shpfy Refund", RefundHeader);
        end;
    end;

}