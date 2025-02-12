// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

enum 6391 "Continia Profile Direction"
{
    Access = Internal;
    Extensible = false;

    value(0; Outbound)
    {
        Caption = 'Outbound';
    }
    value(1; Inbound)
    {
        Caption = 'Inbound';
    }
    value(2; Both)
    {
        Caption = 'Both';
    }
}