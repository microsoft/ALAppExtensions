// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 27033 "DIOT Country/Region Data"
{
    PageType = List;
    ApplicationArea = BasicMX;
    UsageCategory = Lists;
    SourceTable = "DIOT Country/Region Data";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = BasicMX;
                    Caption = 'Country/Region Code';
                    ToolTip = 'Specifies the DIOT specific country/region code.';
                }
                field(Nationality; Nationality)
                {
                    ApplicationArea = BasicMX;
                    Caption = 'Nationality';
                    ToolTip = 'Specifies the DIOT specific nationality.';
                }
                field("BC Country/Region Code"; "BC Country/Region Code")
                {
                    ApplicationArea = BasicMX;
                    Caption = 'BC Country Code';
                    ToolTip = 'Specifies the Business Central country/region code.';
                }
            }
        }
    }
}
