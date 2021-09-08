// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

enum 1990 "Guided Experience Type"
{
    Caption = 'Guided Experience Type';
    Access = Public;

    value(0; "Assisted Setup")
    {
        Caption = 'Assisted Setup', Locked = true;
    }
    value(1; "Manual Setup")
    {
        Caption = 'Manual Setup', Locked = true;
    }
    value(2; "Learn")
    {
        Caption = 'Learn', Locked = true;
    }
}