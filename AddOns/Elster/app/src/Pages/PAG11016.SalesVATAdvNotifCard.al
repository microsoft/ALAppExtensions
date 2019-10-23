// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 11016 "Sales VAT Adv. Notif. Card"
{
    PageType = Card;
    Caption = 'Sales VAT Adv. Notif. Card';
    SourceTable = "Sales VAT Advance Notif.";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sales VAT advance notification number.';
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the sales VAT advance notification.';
                }
                field("XSL-Filename Desktop"; "XSL-Filename")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'XSL-Filename';
                    ToolTip = 'Specifies the path and the file name of the style sheet for the VAT advance notification that you submit to and receive from the tax authorities.';
                    Visible = IsWindowsClient;

                    trigger OnAssistEdit()
                    var
                        FileMgt: Codeunit "File Management";
                    begin
                        "XSL-Filename" := CopyStr(FileMgt.OpenFileDialog(CopyStr(Text1140000Lbl, 1, 50), "XSL-Filename", Text1140001Lbl), 1, MaxStrLen("XSL-Filename"));
                    end;
                }
                field("XSL-Filename"; "XSL-Filename")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the path and the file name of the style sheet for the VAT advance notification that you submit to and receive from the tax authorities.';
                    Visible = NOT IsWindowsClient;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the starting date of the period for which you want to create and transmit the sales VAT advance notification.';
                }
                field(Period; Period)
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the length of the period for created and transmitted sales VAT advance notifications.';
                }
                field(Testversion; Testversion)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the submission of the sales VAT advance notification will be in test mode.';
                }
                field("Additional Information"; "Additional Information")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies additional text explanations to submit to the tax authority.';
                }
                field("Documents Submitted Separately"; "Documents Submitted Separately")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you intend to submit documents besides the VAT Statement to the tax authorities.';
                }
                field("Incl. VAT Entries (Closing)"; "Incl. VAT Entries (Closing)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the calculation of the tax and base amounts should include only closed, open, or closed and open VAT entries.';
                }
                field("Incl. VAT Entries (Period)"; "Incl. VAT Entries (Period)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the tax and base amounts calculation should include VAT entries with posting dates within the period, or earlier than the period starting date.';
                }
                field("Corrected Notification"; "Corrected Notification")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if it is a corrected notification.';
                }
                field("Offset Amount of Refund"; "Offset Amount of Refund")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether to include a potential amount of refund with the payment charge on this sales VAT advance notification.';
                }
                field("Cancel Order for Direct Debit"; "Cancel Order for Direct Debit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether to cancel the standing order for direct debit of the responsible tax office for the current sales VAT advance notification.';
                }
                field("XML-File Creation Date"; "XML-File Creation Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the creation date of the XML document to be submitted to the tax authorities.';
                }
                field("Statement Name"; "Statement Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT statement template name used to calculate the amounts and assign them to the key figures required by the tax authorities.';
                }
                field("Use Authentication"; "Use Authentication")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether to submit signed data to the tax authorities.';
                }
            }
            group(Communication)
            {
                Caption = 'Communication';
                field("Contact for Tax Office"; "Contact for Tax Office")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of a contact person in your company for callbacks from the tax office.';
                }
                field("Contact Phone No."; "Contact Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the phone number of the person who creates the VAT statement.';
                }
                field("Contact E-Mail"; "Contact E-Mail")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the email address of the person who creates the VAT statement.';
                }
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
                Image = "Action";
                action(CreateXMLFile)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Create XML-File';
                    Ellipsis = true;
                    Image = ElectronicDoc;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Create the XML file to be sent to the tax authorities.';

                    trigger OnAction()
                    var
                        SalesVATAdvNotif: Record "Sales VAT Advance Notif.";
                    begin
                        TestField("No.");
                        SalesVATAdvNotif.SetRange("No.", "No.");
                        Report.RunModal(Report::"Create XML-File VAT Adv.Notif.", true, false, SalesVATAdvNotif);
                    end;
                }
                action(DeleteXMLFile)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Delete XML-File';
                    Ellipsis = true;
                    ToolTip = 'Create the XML file to be sent to the tax authorities.';
                    Image = DeleteXML;

                    trigger OnAction()
                    begin
                        DeleteXMLSubDoc();
                    end;
                }
                separator("1")
                {
                }
                action("P&review")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'P&review';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "VAT Statement Preview";
                    RunPageLink = "Statement Template Name" = field("Statement Template Name"),
                                  Name = field("Statement Name");
                    ToolTip = 'Preview the sales VAT advance notification that you will send to the tax authorities.';
                }
                separator("2")
                {
                }
                action(Print)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Print';
                    Ellipsis = true;
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Print the information in the window. A print request window opens where you can specify what to include on the print-out.';

                    trigger OnAction()
                    begin
                        VATStatementName.GET("Statement Template Name", "Statement Name");
                        ReportPrint.PrintVATStmtName(VATStatementName);
                    end;
                }
                action("Calc. and Post &VAT Settlement")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Calc. and Post &VAT Settlement';
                    Ellipsis = true;
                    Image = SettleOpenTransactions;
                    RunObject = Report "Calc. and Post VAT Settlement";
                    ToolTip = 'Close open VAT entries and transfers purchase and sales VAT amounts to the VAT settlement account. For every VAT posting group, the batch job finds all the VAT entries in the VAT Entry table that are included in the filters in the definition window.';
                }
                action(GLVATReconciliation)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'G/L - VAT Reconciliation';
                    Ellipsis = true;
                    ToolTip = 'Verify the VAT on the sales VAT advance notification to be sent to the tax authorities. If you selected G/L accounts in the rows, then only the amount column will be filled. If you selected VAT Totals as the type, then both the taxable bases and the tax amounts will be shown independently of the selected amount type.';
                    Image = VATStatement;

                    trigger OnAction()
                    begin
                        VATStatementName.SetFilter(Name, "Statement Name");
                        VATStatementName.FindFirst();
                        VATStatementName.SetRecFilter();
                        Report.Run(Report::"G/L - VAT Reconciliation", true, false, VATStatementName);
                    end;
                }
            }
            action(Export)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Export';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Export the XML file that you can send to the tax authorities. ';

                trigger OnAction()
                begin
                    Export();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        ClientTypeManagement: Codeunit "Client Type Management";
    begin
        IsWindowsClient := ClientTypeManagement.GetCurrentClientType() = ClientType::Windows;
    end;

    var
        VATStatementName: Record "VAT Statement Name";
        ReportPrint: Codeunit "Test Report-Print";
        Text1140000Lbl: Label 'Selection of the XSL-File';
        Text1140001Lbl: Label 'Extensible Stylesheet-Files|*.xsl|All Files|*.*';
        IsWindowsClient: Boolean;
}

