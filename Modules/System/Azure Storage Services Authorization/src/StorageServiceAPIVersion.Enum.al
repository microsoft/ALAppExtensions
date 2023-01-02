// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Defines the available API versions for Azure Storage Services.
/// See: https://go.microsoft.com/fwlink/?linkid=2210598
/// </summary>
enum 9060 "Storage Service API Version"
{
    Access = Public;
    Extensible = false;

    value(0; "2020-10-02")
    {
        Caption = '2020-10-02', Locked = true;
    }
    value(1; "2020-12-06")
    {
        Caption = '2020-12-06', Locked = true;
    }
}