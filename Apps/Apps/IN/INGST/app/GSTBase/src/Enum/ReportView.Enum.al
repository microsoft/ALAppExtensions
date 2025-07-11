// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18044 "Report View"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; CGST)
    {
        Caption = 'CGST';
    }
    value(2; "SGST / UTGST")
    {
        Caption = 'SGST / UTGST';
    }
    value(3; IGST)
    {
        Caption = 'IGST';
    }
    value(4; CESS)
    {
        Caption = 'CESS';
    }
}
