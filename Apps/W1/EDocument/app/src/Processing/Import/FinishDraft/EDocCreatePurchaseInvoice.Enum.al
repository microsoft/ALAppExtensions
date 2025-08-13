// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument.Processing.Interfaces;

/// <summary>
/// Enum for the implementations of the E-Doc. Create Purchase Invoice interface.
/// </summary>
enum 6105 "E-Doc. Create Purchase Invoice" implements IEDocumentCreatePurchaseInvoice
{
    Extensible = true;
    DefaultImplementation = IEDocumentCreatePurchaseInvoice = "E-Doc. Create Purchase Invoice";
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by enum 6110 "E-Doc. Proc. Customizations';

    value(0; "Default") { }
}