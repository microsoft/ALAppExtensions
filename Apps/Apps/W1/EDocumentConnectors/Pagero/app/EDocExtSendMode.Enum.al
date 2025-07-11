// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

enum 6361 "E-Doc. Ext. Send Mode"
{
    Extensible = true;

    value(0; Production)
    {
        Caption = 'Production';
    }
    value(1; Test)
    {
        Caption = 'Test';
    }
    value(2; Certification)
    {
        Caption = 'Certification';
    }
}