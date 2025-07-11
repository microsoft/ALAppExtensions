// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Attachment;

page 31140 "VIES Declarations CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'VIES Declarations';
    CardPageId = "VIES Declaration CZL";
    Editable = false;
    PageType = List;
    SourceTable = "VIES Declaration Header CZL";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the VIES Declaration.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which you created the document.';
                }
                field("Declaration Type"; Rec."Declaration Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies type of VIES Declaration (Normal, Corrective).';
                }
                field("Corrected Declaration No."; Rec."Corrected Declaration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the existing VIES declaration that needs to be corrected.';
                }
                field("Declaration Period"; Rec."Declaration Period")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies declaration Period (month, quarter).';
                }
                field("Period No."; Rec."Period No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT period.';
                }
                field(Year; Rec.Year)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the year of report.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the declaration. The field will display either a status of open or released.';
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies company VAT Registration No.';
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
                SubPageLink = "Table ID" = const(Database::"VIES Declaration Header CZL"), "No." = field("No.");
            }
#endif
            part("Attached Documents List"; "Doc. Attachment List Factbox")
            {
                ApplicationArea = All;
                Caption = 'Documents';
                SubPageLink = "Table ID" = const(Database::"VIES Declaration Header CZL"), "No." = field("No.");
            }
        }
    }
    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Re&lease")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    ShortcutKey = 'Ctrl+F9';
                    ToolTip = 'Release the document to the next stage of processing. When a document is released, it will be possible to print or export declaration. You must reopen the document before you can make changes to it.';

                    trigger OnAction()
                    begin
                        ReleaseVIESDeclarationCZL.Run(Rec);
                    end;
                }
                action("Re&open")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Re&open';
                    Image = Replan;
                    ToolTip = 'Reopen the document to change it after it has been approved. Approved documents have tha Released status and must be opened before they can be changed.';

                    trigger OnAction()
                    begin
                        ReleaseVIESDeclarationCZL.Reopen(Rec);
                    end;
                }
                action("&Export")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Export';
                    Image = CreateXMLFile;
                    ToolTip = 'This batch job is used for VIES declaration results export in XML format.';

                    trigger OnAction()
                    begin
                        Rec.Export();
                    end;
                }
            }
        }
        area(reporting)
        {
            action("Test Report")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Test Report';
                Ellipsis = true;
                Image = TestReport;
                ToolTip = 'View a test report so that you can find and correct any errors before you issue or export document.';

                trigger OnAction()
                begin
                    Rec.PrintTestReport();
                end;
            }
            action("&Declaration")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Declaration';
                Image = Report;
                Ellipsis = true;
                ToolTip = 'View a VIES declaration report.';

                trigger OnAction()
                begin
                    Rec.Print();
                end;
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
        area(Navigation)
        {
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
                actionref("&Export_Promoted"; "&Export")
                {
                }
            }
            group(Category_Report)
            {
                actionref("Test Report_Promoted"; "Test Report")
                {
                }
                actionref("&Declaration_Promoted"; "&Declaration")
                {
                }
                actionref(PrintToAttachment_Promoted; PrintToAttachment)
                {
                }
            }
        }
    }

    var
        ReleaseVIESDeclarationCZL: Codeunit "Release VIES Declaration CZL";
}
