// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

enum 18031 "Type of Supply"
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
    value(2; B2BUR)
    {
        Caption = 'B2BUR';
    }
    value(3; IMPS)
    {
        Caption = 'IMPS';
    }
    value(4; IMPG)
    {
        Caption = 'IMPG';
    }
    value(5; CDNR)
    {
        Caption = 'CDNR';
    }
    value(7; CDNUR)
    {
        Caption = 'CDNUR';
    }
    value(8; ATADJ)
    {
        Caption = 'ATADJ';
    }
    value(9; AT)
    {
        Caption = 'AT';
    }
    value(10; EXEMP)
    {
        Caption = 'EXEMP';
    }
    value(11; HSNSUM)
    {
        Caption = 'HSNSUM';
    }
}

