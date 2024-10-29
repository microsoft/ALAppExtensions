// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using Microsoft.EServices.EDocument;
using Microsoft.eServices.EDocument.IO.PEPPOL;

enumextension 6380 "E-Doc. Format Ext." extends "E-Document Format"
{
    value(6381; "TE PEPPOL BIS 3.0")
    {
        Implementation = "E-Document" = "EDoc TE PEPPOL BIS 3.0";
    }
}