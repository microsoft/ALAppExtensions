// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.Purchases.Document;

interface IPurchaseLineAccountProvider
{
    procedure GetPurchaseLineAccount(EDocumentPurchaseLine: Record "E-Document Purchase Line"; EDocumentLineMapping: Record "E-Document Line Mapping"; var AccountType: Enum "Purchase Line Type"; var AccountNo: Code[20]);

}