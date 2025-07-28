// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;

codeunit 30260 "Shpfy Open PostedReturnReceipt" implements "Shpfy IOpenBCDocument"
{

    procedure OpenDocument(DocumentNo: Code[20])
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
    begin
        if ReturnReceiptHeader.Get(DocumentNo) then begin
            ReturnReceiptHeader.SetRecFilter();
            Page.Run(Page::"Posted Return Receipt", ReturnReceiptHeader);
        end;
    end;

}