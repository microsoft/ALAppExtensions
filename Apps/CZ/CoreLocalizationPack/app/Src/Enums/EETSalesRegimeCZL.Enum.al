// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

enum 11743 "EET Sales Regime CZL"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; "Regular")
    {
        Caption = 'Regular';
    }
    value(1; "Simplified")
    {
        Caption = 'Simplified';
    }
}
