// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

page 5282 "Source Codes SAF-T"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Source Code SAF-T";
    Caption = 'SAF-T Source Codes';

    layout
    {
        area(Content)
        {
            repeater(SourceCodesSAFT)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the SAF-T source code.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the SAF-T source code description.';
                }
                field(IncludesNoSourceCode; Rec."Includes No Source Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if G/L entries with no source codes must be exported with this SAF-T source code.';
                }
            }
        }
    }
}
