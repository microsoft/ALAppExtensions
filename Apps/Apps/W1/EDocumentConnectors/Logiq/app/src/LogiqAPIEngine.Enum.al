// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

enum 6430 "Logiq API Engine"
{
    Extensible = false;
    Access = Internal;

    value(0; " ")
    {
        Caption = '', Locked = true;
    }
    value(1; "Engine 1")
    {
        Caption = 'Engine 1';
    }
    value(2; "Engine 3")
    {
        Caption = 'Engine 3';
    }
}
