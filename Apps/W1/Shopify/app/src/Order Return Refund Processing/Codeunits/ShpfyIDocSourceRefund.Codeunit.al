// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

codeunit 30249 "Shpfy IDocSource Refund" implements "Shpfy IDocument Source", "Shpfy Extended IDocument Source"
{
    procedure SetErrorInfo(SourceDocumentId: BigInteger; ErrorDescription: Text)
    var
        RefundHeader: Record "Shpfy Refund Header";
    begin
        if RefundHeader.Get(SourceDocumentId) then
            RefundHeader.SetLastErrorDescription(ErrorDescription);
    end;

    procedure SetErrorCallStack(SourceDocumentId: BigInteger; ErrorCallStack: Text)
    var
        RefundHeader: Record "Shpfy Refund Header";
    begin
        if RefundHeader.Get(SourceDocumentId) then
            RefundHeader.SetLastErrorCallStack(ErrorCallStack);
    end;
}