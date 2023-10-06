// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

page 10670 "SAF-T Mapping Setup Card"
{
    PageType = Document;
    SourceTable = "SAF-T Mapping Range";
    Caption = 'SAF-T Mapping Setup';
    PromotedActionCategories = 'New, Process';
    DataCaptionExpression = '';

    layout
    {
        area(Content)
        {
            group(MappingSetup)
            {
                Caption = 'Mapping Range';
                field(Code; Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the mapping range code that represents the SAF-T reporting period.';
                }
                field("Mapping Type"; "Mapping Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of mapping.';
                }
                field(RangeType; "Range Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the range type for an accounting period or custom period with a flexible start date/time.';
                }
                field(AccountingPeriod; "Accounting Period")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the starting date of the accounting period that will be used as SAF-T reporting period.';
                }
                field(StartingDate; "Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the starting date of the SAF-T reporting period.';
                }
                field(EndingDate; "Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ending date of the SAF-T reporting period.';
                }
                field(MappingCategoryNo; "Mapping Category No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the category of the SAF-T standard account or grouping code that is used for mapping.';
                }
                field(MappingNo; "Mapping No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the SAF-T standard account or grouping code that is used for mapping.';
                }
                field(IncludeIncomingBalance; "Include Incoming Balance")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the incoming balance of G/L account of type "Balance Account" needs to be considered for mapping instead of the reporting period''s net change.';
                }
            }
            part(SAFTGLAccMappingSubform; "SAF-T G/L Mapping Subpage")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Mapping Range Code" = FIELD (Code);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(InitMappingSource)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Initialize Source for Mapping';
                ToolTip = 'Generate lines on the G/L Account Mapping page based on an existing chart of accounts.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = GetSourceDoc;

                trigger OnAction()
                var
                    SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
                begin
                    SAFTMappingHelper.Run(Rec);
                    CurrPage.Update();
                end;
            }
            action(CopyMapping)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Copy Mapping from Another Range';
                ToolTip = 'Copy the G/L account mapping from another mapping code.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Copy;

                trigger OnAction()
                var
                    SAFTCopyMapping: Report "SAF-T Copy Mapping";
                begin
                    clear(SAFTCopyMapping);
                    SAFTCopyMapping.InitializeRequest(Rec.Code);
                    SAFTCopyMapping.Run();
                    CurrPage.Update();
                end;
            }
        }
    }
}
