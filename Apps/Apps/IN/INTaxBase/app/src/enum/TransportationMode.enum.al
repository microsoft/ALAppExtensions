// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

enum 18547 "Transportation Mode"
{
    Extensible = true;

    value(0; Road)
    {
        Caption = 'Road';
    }
    value(1; Rail)
    {
        Caption = 'Rail';
    }
    value(2; Air)
    {
        Caption = 'Air';
    }
    value(3; Ship)
    {
        Caption = 'Ship';
    }
}
