// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Payments;

using Microsoft.eServices.EDocument.Integration.Interfaces;

enum 6111 "Payment Integration" implements IDocumentPaymentHandler
{
    Extensible = true;
    Access = Public;

    value(0; "No Integration")
    {
        Caption = 'No Integration';
        Implementation = IDocumentPaymentHandler = "Empty Payment Handler";
    }
}