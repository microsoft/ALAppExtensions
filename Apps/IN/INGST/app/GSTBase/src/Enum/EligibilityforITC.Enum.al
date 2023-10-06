// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18016 "Eligibility for ITC"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Ineligible)
    {
        Caption = 'Ineligible';
    }
    value(2; "Input Services")
    {
        Caption = 'Input Services';
    }
    value(3; "Capital goods")
    {
        Caption = 'Capital goods';
    }
    value(4; Inputs)
    {
        Caption = 'Inputs';
    }
}
