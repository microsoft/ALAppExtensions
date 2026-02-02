// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Certificate;

enum 6220 "Sust. Carbon Tracking Method"
{
    Extensible = true;

    value(0; "Average")
    {
        Caption = 'Average';
    }
    value(1; "Specific")
    {
        Caption = 'Specific';
    }
}