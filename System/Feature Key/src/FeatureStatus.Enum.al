// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Enum defines the feature statuses.
/// </summary>
enum 2610 "Feature Status"
{
    Extensible = false;
    value(0; Disabled)
    {
        Caption = 'Disabled';
    }
    value(1; Enabled)
    {
        Caption = 'Enabled';
    }
    value(2; Pending)
    {
        Caption = 'Pending Data Update';
    }
    value(3; Scheduled)
    {
        Caption = 'Scheduled Data Update';
    }
    value(4; Updating)
    {
        Caption = 'Updating Data';
    }
    value(5; Incomplete)
    {
        Caption = 'Incomplete Data Update';
    }
    value(6; Complete)
    {
        Caption = 'Completed Data Update';
    }
}