// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

enum 1994 "Checklist Item Status"
{
    Access = Internal;

    value(0; "Not Started")
    {
        Caption = 'Not Started';
    }
    value(1; Started)
    {
        Caption = 'Started';
    }
    value(2; Skipped)
    {
        Caption = 'Skipped';
    }
    value(3; Completed)
    {
        Caption = 'Completed';
    }
}