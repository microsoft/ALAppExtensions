// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18020 "GST Customer Type"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Registered)
    {
        Caption = 'Registered';
    }
    value(2; Unregistered)
    {
        Caption = 'Unregistered';
    }
    value(3; Export)
    {
        Caption = 'Export';
    }
    value(4; "Deemed Export")
    {
        Caption = 'Deemed Export';
    }
    value(5; Exempted)
    {
        Caption = 'Exempted';
    }
    value(6; "SEZ Development")
    {
        Caption = 'SEZ Development';
    }
    value(7; "SEZ Unit")
    {
        Caption = 'SEZ Unit';
    }
}
