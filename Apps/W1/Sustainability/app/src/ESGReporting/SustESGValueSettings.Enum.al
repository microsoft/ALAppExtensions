// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

enum 6222 "Sust. ESG Value Settings"
{
    Caption = 'ESG Value Settings';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Sum")
    {
        Caption = 'Sum';
    }
    value(2; "Count")
    {
        Caption = 'Count';
    }
}