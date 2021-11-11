// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Environment type
/// </summary>
enum 1888 "Environment Type"
{
    Access = Public;
    Extensible = false;

    value(0; Sandbox)
    {
        Caption = 'Sandbox', Locked = true;
    }
    value(1; Production)
    {
        Caption = 'Production', Locked = true;
    }
}