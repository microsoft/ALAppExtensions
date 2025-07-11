// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.IO.Peppol;

enum 6101 "E-Document Format" implements "E-Document"
{
    Extensible = true;
    value(0; "Data Exchange")
    {
        Caption = 'Data Exchange';
        Implementation = "E-Document" = "E-Doc. Data Exchange Impl.";
    }
    value(1; "PEPPOL BIS 3.0")
    {
        Caption = 'PEPPOL BIS 3.0';
        Implementation = "E-Document" = "EDoc PEPPOL BIS 3.0";
    }
}
