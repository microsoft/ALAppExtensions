// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

enum 31301 "Intrastat Statement Type CZ"
{
    Extensible = true;

    value(0; Primary)
    {
        Caption = 'Primary';
    }
    value(1; Negative)
    {
        Caption = 'Negative';
    }
}