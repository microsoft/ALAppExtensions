// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

enum 1995 "Checklist Status"
{
    Access = Internal;

    value(0; "Not Started")
    {
        Caption = 'Not Started';
    }
    value(1; "In progress")
    {
        Caption = 'In progress';
    }
    value(2; Completed)
    {
        Caption = 'Completed';
    }
    value(3; Skipped)
    {
        Caption = 'Skipped';
    }
}