// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

enum 6220 "Sust ESG Reporting Std. Type"
{
    Caption = 'ESG Reporting Standard Type';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; CSRD)
    {
        Caption = 'CSRD';
    }
    value(2; ISRS)
    {
        Caption = 'ISRS';
    }
}