// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18036 "GST Vendor Type"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Registered)
    {
        Caption = 'Registered';
    }
    value(2; Composite)
    {
        Caption = 'Composite';
    }
    value(3; Unregistered)
    {
        Caption = 'Unregistered';
    }
    value(4; Import)
    {
        Caption = 'Import';
    }
    value(5; Exempted)
    {
        Caption = 'Exempted';
    }
    value(6; SEZ)
    {
        Caption = 'SEZ';
    }
}
