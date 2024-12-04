// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument.Integration.Interfaces;

enumextension 6431 "E-Document Integration" extends "Service Integration"
{
    value(6430; "Logiq")
    {
        Caption = 'Logiq';
        Implementation = IDocumentSender = "E-Document Integration", IDocumentReceiver = "E-Document Integration";
    }
}