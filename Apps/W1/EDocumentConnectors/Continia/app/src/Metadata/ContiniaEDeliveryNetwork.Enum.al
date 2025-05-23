// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

enum 6390 "Continia E-Delivery Network"
{
    Access = Internal;
    Extensible = false;

    value(0; Peppol)
    {
        Caption = 'Peppol';
    }
    value(1; Nemhandel)
    {
        Caption = 'NemHandel';
    }
}