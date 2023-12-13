// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Attachment;
using Microsoft.Foundation.Company;
using Microsoft.Utilities;

page 31110 "VAT Ctrl. Report Card CZL"
{
    Caption = 'VAT Control Report Card';
    PageType = Card;
    SourceTable = "VAT Ctrl. Report Header CZL";
    PromotedActionCategories = 'New,Process,Report,Related';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = VAT;
                    Importance = Promoted;
                    ToolTip = 'Specifies the number of VAT Control Report.';
                    Visible = NoFieldVisible;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the description of VAT Control Report.';
                }
                field("Report Period"; Rec."Report Period")
                {
                    ApplicationArea = VAT;
                    Importance = Promoted;
                    ToolTip = 'Specifies the VAT period (month or quarter).';
                }
                field("Period No."; Rec."Period No.")
                {
                    ApplicationArea = VAT;
                    BlankZero = true;
                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the VAT period.';
                }
                field(Year; Rec.Year)
                {
                    ApplicationArea = VAT;
                    BlankZero = true;
                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the year of report';
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies date of creating VAT Control Report.';
                }
                field("VAT Statement Template Name"; Rec."VAT Statement Template Name")
                {
                    ApplicationArea = VAT;
                    Importance = Additional;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the VAT statement template name for VAT Control Report creation.';
                }
                field("VAT Statement Name"; Rec."VAT Statement Name")
                {
                    ApplicationArea = VAT;
                    Importance = Additional;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the VAT statement name for VAT Control Report creation.';
                }
                field("VAT Control Report Xml Format"; Rec."VAT Control Report Xml Format")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the export xml format for VAT Control Report.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = VAT;
                    Editable = false;
                    ToolTip = 'Specifies first date for the declaration, which is calculated based of the values of the Period No. a Year fields.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = VAT;
                    Editable = false;
                    ToolTip = 'Specifies end date for the declaration, which is calculated based of the values of the Period No. a Year fields.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the status of VAT Control Report.';
                }
            }
            part(Lines; "VAT Ctrl. Report Subform CZL")
            {
                ApplicationArea = VAT;
                SubPageLink = "VAT Ctrl. Report No." = field("No."), "Closed by Document No." = field("Closed by Document No. Filter");
                SubPageView = sorting("VAT Ctrl. Report No.", "Line No.");
            }
        }
        area(FactBoxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(31106), "No." = field("No.");
            }
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
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
                action(Statistics)
                {
                    ApplicationArea = VAT;
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ShortcutKey = 'F7';
                    ToolTip = 'View the statistics on the selected VAT Control Report.';

                    trigger OnAction()
                    begin
                        Page.RunModal(Page::"VAT Ctrl. Report Stat. CZL", Rec);
                    end;
                }
                action(PrintToAttachment)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Attach as PDF';
                    Image = PrintAttachment;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedOnly = true;
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
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    PromotedIsBig = true;
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
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    PromotedIsBig = true;
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
                    ToolTip = 'This batch job exports the VAT Control Report in XML format.';

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
                    Promoted = true;
                    PromotedCategory = Process;
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
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedOnly = true;
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
    }

    trigger OnOpenPage()
    begin
        SetNoFieldVisible();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        StatutoryReportingSetupCZL.Get();
        Rec.Validate("VAT Statement Template Name", StatutoryReportingSetupCZL."VAT Statement Template Name");
        Rec.Validate("VAT Statement Name", StatutoryReportingSetupCZL."VAT Statement Name");
        Rec.Validate("VAT Control Report Xml Format", StatutoryReportingSetupCZL."VAT Control Report XML Format");
    end;

    var
        VATCtrlReportMgtCZL: Codeunit "VAT Ctrl. Report Mgt. CZL";
        VATCtrlReportReleaseCZL: Codeunit "VAT Ctrl. Report Release CZL";
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
        NoFieldVisible: Boolean;

    local procedure SetNoFieldVisible()
    begin
        if Rec."No." <> '' then
            NoFieldVisible := false
        else
            NoFieldVisible := DocumentNoVisibility.ForceShowNoSeriesForDocNo(DetermineVATCtrlReportCZLSeriesNo());
    end;

    local procedure DetermineVATCtrlReportCZLSeriesNo(): Code[20]
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
    begin
        StatutoryReportingSetupCZL.Get();
        DocumentNoVisibility.CheckNumberSeries(VATCtrlReportHeaderCZL, StatutoryReportingSetupCZL."VAT Control Report Nos.", VATCtrlReportHeaderCZL.FieldNo("No."));
        exit(StatutoryReportingSetupCZL."VAT Control Report Nos.");
    end;
}
