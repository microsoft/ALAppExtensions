// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Interfaces;

using Microsoft.Purchases.Document;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;

/// <summary>
/// Interface for determining the account assignment for a purchase line in an E-Document.
/// </summary>

interface IPurchaseLineAccountProvider
{
    ObsoleteReason = 'Replaced by IPurchaseLineProvider';
    ObsoleteState = Pending;
    ObsoleteTag = '27.0';

    /// <summary>
    /// Determines the purchase line fields for a given E-Document purchase line.
    /// </summary>
    /// <param name="EDocumentPurchaseLine">The purchase line record from the E-Document.</param>
    /// <param name="AccountType">The output parameter for the determined purchase line account type.</param>
    /// <param name="AccountNo">The output parameter for the determined account number.</param>
    procedure GetPurchaseLineAccount(
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        var AccountType: Enum "Purchase Line Type";
        var AccountNo: Code[20]
    );
}