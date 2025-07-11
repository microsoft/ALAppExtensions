// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

page 10685 "SAF-T Source Codes"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "SAF-T Source Code";
    Caption = 'SAF-T Source Codes';

    layout
    {
        area(Content)
        {
            repeater(SAFTSourceCodes)
            {
                field(Code; Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the SAF-T source code.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the SAF-T source code description.';
                }
                field(IncludesNoSourceCode; "Includes No Source Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if G/L entries with no source codes must be exported with this SAF-T source code.';
                }
            }
        }
    }
}
