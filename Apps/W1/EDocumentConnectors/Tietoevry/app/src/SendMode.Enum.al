// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

enum 6390 "Send Mode"
{
    Extensible = false;

    value(0; Production)
    {
        Caption = 'Production';
    }
    value(1; Test)
    {
        Caption = 'Test';
    }
}