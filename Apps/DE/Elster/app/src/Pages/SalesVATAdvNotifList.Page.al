// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 11017 "Sales VAT Adv. Notif. List"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Sales VAT Advance Notification List';
    CardPageID = "Sales VAT Adv. Notif. Card";
    Editable = false;
    PageType = List;
    SourceTable = "Sales VAT Advance Notif.";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sales VAT advance notification number.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the sales VAT advance notification.';
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the starting date of the period for which you want to create and transmit the sales VAT advance notification.';
                }
                field(Period; Period)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the length of the period for created and transmitted sales VAT advance notifications.';
                    Visible = false;
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
                    ToolTip = 'Create the XML file to be sent to the tax authorities.';

                    trigger OnAction()
                    var
                        SalesVATAdvNotif: Record "Sales VAT Advance Notif.";
                    begin
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
                    Caption = 'P&review statement';
                    Image = "Report";
                    RunObject = Page "VAT Statement Preview";
                    RunPageLink = "Statement Template Name" = field("Statement Template Name"),
                                  Name = field("Statement Name");
                    ToolTip = 'View a VAT statement as a preview of the sales VAT advance notification that you will send to the tax authorities.';
                }
                action(PreviewAmounts)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show amounts from XML file';
                    Image = PreviewChecks;
                    ToolTip = 'Show the amounts from the XML file that you will send to the tax authorities.';

                    trigger OnAction()
                    var
                        ElsterManagement: Codeunit "Elster Management";
                    begin
                        ElsterManagement.ShowElecVATDeclOverview(Rec);
                    end;
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
                    ToolTip = 'Print the information in the window. A print request window opens where you can specify what to include on the print-out.';

                    trigger OnAction()
                    begin
                        VATStmtName.Get("Statement Template Name", "Statement Name");
                        ReportPrint.PrintVATStmtName(VATStmtName);
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
                        VATStmtName.SetFilter(Name, "Statement Name");
                        VATStmtName.FindFirst();
                        VATStmtName.SetRecFilter();
                        Report.Run(Report::"G/L - VAT Reconciliation", true, false, VATStmtName);
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

    var
        VATStmtName: Record "VAT Statement Name";
        ReportPrint: Codeunit "Test Report-Print";
}

