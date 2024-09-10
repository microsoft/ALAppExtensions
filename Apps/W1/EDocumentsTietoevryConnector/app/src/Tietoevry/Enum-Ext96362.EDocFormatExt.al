// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using Microsoft.EServices.EDocument;
using Microsoft.eServices.EDocument.IO.PEPPOL;

enumextension 96362 "E-Doc. Format Ext." extends "E-Document Format"
{
    value(96361; "TE PEPPOL BIS 3.0")
    {
        Implementation = "E-Document" = "EDoc TE PEPPOL BIS 3.0";
    }
}