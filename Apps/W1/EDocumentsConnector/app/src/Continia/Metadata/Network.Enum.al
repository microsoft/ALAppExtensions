// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

enum 6390 "Network"
{
    Extensible = false;

    value(0; peppol)
    {
        Caption = 'Peppol';
    }
    value(1; nemhandel)
    {
        Caption = 'NemHandel';
    }
}