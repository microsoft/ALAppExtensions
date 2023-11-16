// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 31111 "VAT Ctrl. Report Sections CZL"
{
    ApplicationArea = VAT;
    Caption = 'VAT Control Report Sections';
    PageType = List;
    SourceTable = "VAT Ctrl. Report Section CZL";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the code of VAT Control Report sections.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the description of VAT Control Report sections.';
                }
                field("Group By"; Rec."Group By")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the setup the group by the VAT entries in the VAT Control Report.';
                }
                field("Simplified Tax Doc. Sect. Code"; Rec."Simplified Tax Doc. Sect. Code")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the code of simplified tax document.';
                }
            }
        }
    }
}
