// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Group;

enum 4703 "VAT Group BC Version"
{
    value(0; BC)
    {
        Caption = 'Business Central';
    }
    value(1; NAV2018)
    {
        Caption = 'Dynamics NAV 2018';
    }
    value(2; NAV2017)
    {
        Caption = 'Dynamics NAV 2016-2017';
    }
}