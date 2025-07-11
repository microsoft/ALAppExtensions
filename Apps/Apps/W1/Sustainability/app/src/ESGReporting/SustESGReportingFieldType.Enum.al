// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

enum 6221 "Sust. ESG Reporting Field Type"
{
    Caption = 'ESG Reporting Field Type';
    Extensible = true;

    value(0; "Table Field")
    {
        Caption = 'Table Field';
    }
    value(1; Formula)
    {
        Caption = 'Formula';
    }
    value(2; "Text")
    {
        Caption = 'Text';
    }
    value(3; Title)
    {
        Caption = 'Title';
    }
}