// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

page 13688 "Imported SAF-T Files DK"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = ReportsAndAnalysis;
    SourceTable = "Imported SAF-T File DK";
    Caption = 'Import SAF-T Files';
    InsertAllowed = false;
    ModifyAllowed = false;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(Groupings)
            {
                field("No."; Rec."File No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the file.';
                }
                field(SAFTFileName; Rec."File Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name with which the file was uploaded.';

                    trigger OnDrillDown()
                    begin
                        Rec.DownloadSAFTFile();
                        CurrPage.Update(false);
                    end;
                }
                field(SAFTFileSize; Rec."File Size")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the size of the file.';
                }
                field(FileUploadDate; Rec."Upload Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which the file was uploaded.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UploadFile)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Import;
                Caption = 'Import SAF-T File';
                ToolTip = 'Upload the file in SAF-T format.';

                trigger OnAction()
                begin
                    Rec.UploadSAFTFile();
                end;
            }
        }
    }
}