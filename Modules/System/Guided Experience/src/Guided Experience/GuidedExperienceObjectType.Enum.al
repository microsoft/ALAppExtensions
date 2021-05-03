// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

enum 1991 "Guided Experience Object Type"
{
    Access = Internal;

    value(0; Uninitialized)
    {
        Caption = 'Uninitialized', Locked = true;
    }
    value(1; Codeunit)
    {
        Caption = 'Codeunit', Locked = true;
    }
    value(2; Page)
    {
        Caption = 'Page', Locked = true;
    }
    value(3; Report)
    {
        Caption = 'Report', Locked = true;
    }
    value(4; XmlPort)
    {
        Caption = 'XmlPort', Locked = true;
    }
}