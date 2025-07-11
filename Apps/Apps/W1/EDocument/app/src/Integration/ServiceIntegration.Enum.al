// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration;

using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument;

enum 6151 "Service Integration" implements IDocumentSender, IDocumentReceiver, IConsentManager
{
    Extensible = true;
    Access = Public;
    DefaultImplementation = IConsentManager = "Consent Manager Default Impl.";

    value(0; "No Integration")
    {
        Caption = '';
        Implementation = IDocumentSender = "E-Document No Integration", IDocumentReceiver = "E-Document No Integration", IConsentManager = "E-Document No Integration";
    }
}