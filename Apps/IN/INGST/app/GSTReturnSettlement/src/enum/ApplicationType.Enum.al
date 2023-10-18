// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

enum 18319 "Application Type"
{
    Extensible = true;
    value(0; Online)
    {
        Caption = 'Online';
    }
    value(1; "Offline")
    {
        Caption = 'Offline';
    }
}
