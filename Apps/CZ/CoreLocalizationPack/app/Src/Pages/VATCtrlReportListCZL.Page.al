﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Attachment;

page 31109 "VAT Ctrl. Report List CZL"
{
    ApplicationArea = VAT;
    Caption = 'VAT Control Reports';
    CardPageId = "VAT Ctrl. Report Card CZL";
    Editable = false;
    PageType = List;
    SourceTable = "VAT Ctrl. Report Header CZL";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the number of VAT Control Report.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the description of VAT Control Report.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies first date for the declaration, which is calculated based of the values of the Period No. a Year fields.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies last date for the declaration, which is calculated based of the values of the Period No. a Year fields.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the status of VAT Control Report.';
                }
                field("VAT Statement Template Name"; Rec."VAT Statement Template Name")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the VAT statement template name for VAT Control Report creation.';
                }
                field("VAT Statement Name"; Rec."VAT Statement Name")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the VAT statement name for VAT Control Report creation.';
                }
            }
        }
        area(FactBoxes)
        {
#if not CLEAN25
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ObsoleteTag = '25.0';
                ObsoleteState = Pending;
                ObsoleteReason = 'The "Document Attachment FactBox" has been replaced by "Doc. Attachment List Factbox", which supports multiple files upload.';
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(Database::"VAT Ctrl. Report Header CZL"), "No." = field("No.");
            }
#endif
            part("Attached Documents List"; "Doc. Attachment List Factbox")
            {
                ApplicationArea = All;
                Caption = 'Documents';
                SubPageLink = "Table ID" = const(Database::"VAT Ctrl. Report Header CZL"), "No." = field("No.");
            }
        }
    }
    actions
    {
        area(processing)
        {
            group("&Report")
            {
                Caption = '&Report';
#if not CLEAN27
                action(Statistics)
                {
                    ApplicationArea = VAT;
                    Caption = 'Statistics';
                    Image = Statistics;
                    ShortcutKey = 'F7';
                    ToolTip = 'View the statistics on the selected VAT Control Report.';
                    ObsoleteReason = 'The statistics action will be replaced with the VATCtrlReportStatistics action. The new action uses RunObject and does not run the action trigger. Use a page extension to modify the behaviour.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '27.0';

                    trigger OnAction()
                    begin
                        Page.RunModal(Page::"VAT Ctrl. Report Stat. CZL", Rec);
                    end;
                }
#endif
                action(VATCtrlReportStatistics)
                {
                    ApplicationArea = VAT;
                    Caption = 'Statistics';
                    Image = Statistics;
                    ShortcutKey = 'F7';
                    Enabled = Rec."No." <> '';
                    ToolTip = 'View statistical information, such as the value of posted entries, for the record.';
#if CLEAN27
                    Visible = true;
#else
                    Visible = false;
#endif
                    RunObject = Page "VAT Ctrl. Report Stat. CZL";
                    RunPageOnRec = true;
                }
                action(PrintToAttachment)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Attach as PDF';
                    Image = PrintAttachment;
                    ToolTip = 'Create a PDF file and attach it to the document.';

                    trigger OnAction()
                    begin
                        Rec.PrintToDocumentAttachment();
                    end;
                }
            }
            group(Release)
            {
                Caption = 'Release';
                Image = ReleaseDoc;
                action("Re&lease")
                {
                    ApplicationArea = VAT;
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    ShortcutKey = 'Ctrl+F9';
                    ToolTip = 'Release VAT Control Report.';

                    trigger OnAction()
                    begin
                        VATCtrlReportReleaseCZL.Run(Rec);
                    end;
                }
                action("Re&open")
                {
                    ApplicationArea = VAT;
                    Caption = 'Re&open';
                    Image = ReOpen;
                    ToolTip = 'Opens VAT Control Report.';

                    trigger OnAction()
                    begin
                        VATCtrlReportReleaseCZL.Reopen(Rec);
                    end;
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("&Export")
                {
                    ApplicationArea = VAT;
                    Caption = '&Export';
                    Image = Export;
                    ToolTip = 'This batch job exports VAT Control Report in XML format.';

                    trigger OnAction()
                    begin
                        Rec.ExportToFileCZL();
                    end;
                }
                action("C&lose Lines")
                {
                    ApplicationArea = VAT;
                    Caption = 'C&lose Lines';
                    Image = Close;
                    ToolTip = 'This batch job closes the lines of VAT Control Report.';

                    trigger OnAction()
                    begin
                        Rec.CloseLines();
                    end;
                }
                action("&Check - Internal Doc.")
                {
                    ApplicationArea = VAT;
                    Caption = '&Check - Internal Document';
                    Image = Check;
                    ToolTip = 'This batch job opens the report for checking of internal document.';

                    trigger OnAction()
                    begin
                        VATCtrlReportMgtCZL.ExportInternalDocCheckToExcel(Rec, true);
                    end;
                }
                action("&Suggest Lines")
                {
                    ApplicationArea = VAT;
                    Caption = '&Suggest Lines';
                    Ellipsis = true;
                    Image = SuggestLines;
                    ToolTip = 'This batch job suggests lines in VAT Control Report.';

                    trigger OnAction()
                    begin
                        Rec.SuggestLines();
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action("Test Report")
                {
                    ApplicationArea = VAT;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;
                    ToolTip = 'Specifies test report.';

                    trigger OnAction()
                    begin
                        Rec.PrintTestReport();
                    end;
                }
            }
        }
        area(Navigation)
        {
            action("Show Lines")
            {
                ApplicationArea = VAT;
                Caption = 'Show Lines';
                Image = AllLines;
                ToolTip = 'Shows related VAT Control Report lines.';
                RunObject = page "VAT Ctrl. Report Lines CZL";
                RunPageLink = "VAT Ctrl. Report No." = field("No.");
            }
            action(DocAttach)
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                Image = Attach;
                ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                trigger OnAction()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);
                    DocumentAttachmentDetails.OpenForRecRef(RecRef);
                    DocumentAttachmentDetails.RunModal();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref("Re&lease_Promoted"; "Re&lease")
                {
                }
                actionref("Re&open_Promoted"; "Re&open")
                {
                }
#if not CLEAN27
                actionref(Statistics_Promoted; Statistics)
                {
                    ObsoleteReason = 'The statistics action will be replaced with the VATCtrlReportStatistics action. The new action uses RunObject and does not run the action trigger. Use a page extension to modify the behaviour.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '27.0';
                }
#else
                actionref(VATCtrlReportStatistics_Promoted; VATCtrlReportStatistics)
                {
                }
#endif
                actionref("&Suggest Lines_Promoted"; "&Suggest Lines")
                {
                }
            }
            group(Category_Report)
            {
                actionref(PrintToAttachment_Promoted; PrintToAttachment)
                {
                }
                actionref("Test Report_Promoted"; "Test Report")
                {
                }
            }
        }
    }
    var
        VATCtrlReportMgtCZL: Codeunit "VAT Ctrl. Report Mgt. CZL";
        VATCtrlReportReleaseCZL: Codeunit "VAT Ctrl. Report Release CZL";
}
