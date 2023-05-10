// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// See https://go.microsoft.com/fwlink/?linkid=2211406
/// </summary>
enum 9045 "ABS Blob Expiry Option"
{
    Access = Public;
    Extensible = false;

    value(0; RelativeToCreation)
    {
        Caption = 'RelativeToCreation', Locked = true;
    }
    value(1; RelativeToNow)
    {
        Caption = 'RelativeToNow', Locked = true;
    }
    value(2; Absolute)
    {
        Caption = 'Absolute', Locked = true;
    }
    value(3; NeverExpire)
    {
        Caption = 'NeverExpire', Locked = true;
    }
}