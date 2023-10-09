// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

enum 18011 "Nature of Supply"
{
    Extensible = true;
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; B2B)
    {
        Caption = 'B2B';
    }
    value(2; B2CL)
    {
        Caption = 'B2CL';
    }
    value(3; B2CS)
    {
        Caption = 'B2CS';
    }
    value(4; AT)
    {
        Caption = 'AT';
    }
    value(5; ATADJ)
    {
        Caption = 'ATADJ';
    }
    value(7; CDNR)
    {
        Caption = 'CDNR';
    }
    value(8; CDNUR)
    {
        Caption = 'CDNUR';
    }
    value(9; EXP)
    {
        Caption = 'EXP';
    }
    value(10; HSN)
    {
        Caption = 'HSN';
    }
    value(11; EXEMP)
    {
        Caption = 'EXEMP';
    }
}

