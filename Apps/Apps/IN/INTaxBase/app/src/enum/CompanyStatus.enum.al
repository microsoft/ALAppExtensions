// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

enum 18548 "Company Status"
{
    Extensible = true;

    value(0; "Private Limited Co.")
    {
        Caption = 'Private Limited Co';
    }
    value(1; Others)
    {
        Caption = 'Others';
    }
    value(2; Government)
    {
        Caption = 'Government';
    }
    value(3; "Individual/Proprietary")
    {
        Caption = 'Individual/Proprietary';
    }
    value(4; "Registered Trust")
    {
        Caption = 'Registered Trust';
    }
    value(5; Partnership)
    {
        Caption = 'Partnership';
    }
    value(6; "Society/Co-op Society")
    {
        Caption = 'Society/Co-op Society';
    }
}
