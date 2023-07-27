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
    value(2; "2021-02-12")
    {
        Caption = '2021-02-12', Locked = true;
    }
    value(3; "2021-04-10")
    {
        Caption = '2021-04-10', Locked = true;
    }
    value(4; "2021-06-08")
    {
        Caption = '2021-06-08', Locked = true;
    }
    value(5; "2021-08-06")
    {
        Caption = '2021-08-06', Locked = true;
    }
    value(6; "2021-10-04")
    {
        Caption = '2021-10-04', Locked = true;
    }
    value(7; "2021-12-02")
    {
        Caption = '2021-12-02', Locked = true;
    }
    value(8; "2022-11-02")
    {
        Caption = '2022-11-02', Locked = true;
    }
}