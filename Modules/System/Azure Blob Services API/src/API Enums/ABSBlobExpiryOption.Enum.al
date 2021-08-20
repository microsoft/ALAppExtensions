// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// See https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-expiry#expiryoption
/// </summary>
enum 9045 "ABS Blob Expiry Option"
{
    Access = Internal;
    Extensible = false;

    value(0; RelativeToCreation)
    {
        Caption = 'RelativeToCreation';
    }
    value(1; RelativeToNow)
    {
        Caption = 'RelativeToNow';
    }
    value(2; Absolute)
    {
        Caption = 'Absolute';
    }
    value(3; NeverExpire)
    {
        Caption = 'NeverExpire';
    }
}