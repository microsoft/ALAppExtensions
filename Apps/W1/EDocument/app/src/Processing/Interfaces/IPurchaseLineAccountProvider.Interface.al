// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Interfaces;

using Microsoft.Purchases.Document;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;

/// <summary>
/// Interface for determining the account assignment for a purchase line in an E-Document.
/// </summary>
interface IPurchaseLineAccountProvider
{
    /// <summary>
    /// Determines the account type and account number for a given E-Document purchase line.
    /// </summary>
    /// <param name="EDocumentPurchaseLine">The purchase line record from the E-Document.</param>
    /// <param name="EDocumentLineMapping">The mapping record for the E-Document line.</param>
    /// <param name="AccountType">The output parameter for the determined purchase line account type.</param>
    /// <param name="AccountNo">The output parameter for the determined account number.</param>
    procedure GetPurchaseLineAccount(
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        EDocumentLineMapping: Record "E-Document Line Mapping";
        var AccountType: Enum "Purchase Line Type";
        var AccountNo: Code[20]
    );
}