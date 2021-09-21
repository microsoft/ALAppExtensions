// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies whether to return the list of committed blocks, the list of uncommitted blocks, or both lists together
/// </summary>
enum 9044 "ABS Block List Type"
{
    Access = Public;
    Extensible = false;

    value(0; Committed)
    {
        Caption = 'committed', Locked = true;
    }
    value(1; Uncommitted)
    {
        Caption = 'uncommitted', Locked = true;
    }
    value(2; All)
    {
        Caption = 'all', Locked = true;
    }
}