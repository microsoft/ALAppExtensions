// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

enum 1991 "Guided Experience Object Type"
{
    Access = Internal;

    value(0; Uninitialized)
    {
        Caption = 'Uninitialized';
    }
    value(1; Codeunit)
    {
        Caption = 'Codeunit';
    }
    value(2; Page)
    {
        Caption = 'Page';
    }
    value(3; Report)
    {
        Caption = 'Report';
    }
    value(4; XmlPort)
    {
        Caption = 'XmlPort';
    }
}