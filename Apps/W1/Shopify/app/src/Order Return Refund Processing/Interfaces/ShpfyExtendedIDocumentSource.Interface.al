// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

interface "Shpfy Extended IDocument Source" extends "Shpfy IDocument Source"
{
    procedure SetErrorCallStack(SourceDocumentId: BigInteger; ErrorCallStack: Text)
}