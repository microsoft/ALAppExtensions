// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument.Processing.Interfaces;

/// <summary>
///  Enum for the implementations of the E-Doc. Create Purchase Credit Memo interface.
/// </summary>
enum 6118 "E-Doc. Create Purch. Cr. Memo" implements IEDocumentCreatePurchaseCreditMemo
{
    Extensible = true;
    DefaultImplementation = IEDocumentCreatePurchaseCreditMemo = "E-Doc. Create Purch. Cr. Memo";
    value(0; "Default") { }
}
