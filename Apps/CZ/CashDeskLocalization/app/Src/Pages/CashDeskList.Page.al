// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.Comment;

page 31150 "Cash Desk List CZP"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Cash Desks';
    CardPageID = "Cash Desk Card CZP";
    DataCaptionFields = "No.";
    Editable = false;
    PageType = List;
    SourceTable = "Cash Desk CZP";
    UsageCategory = Lists;

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
                    ToolTip = 'Specifies the number of the cash desk.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of cash desk.';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the phone number associated with the cash desk card.';
                    Visible = false;
                }
                field(Contact; Rec.Contact)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the employee contacted with cash desk.';
                    Visible = false;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency of amounts on the document.';
                }
                field("Cashier No."; Rec."Cashier No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the cashier number from employee list.';
                }
                field("Search Name"; Rec."Search Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a search name for the cash desk.';
                }
            }
        }
        area(FactBoxes)
        {
            part(CashDeskFB; "Cash Desk FactBox CZP")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("No.");
            }
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Responsibility Hand Over")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Responsibility Hand Over';
                Ellipsis = true;
                Image = Responsibility;
                ToolTip = 'Opens the cash desk hand overe page';

                trigger OnAction()
                var
                    HandOver: Report "Cash Desk Hand Over CZP";
                begin
                    HandOver.SetupCashDesk(Rec."No.");
                    HandOver.RunModal();
                    CurrPage.Update(false);
                end;
            }
        }
        area(navigation)
        {
            group("&Cash Desk")
            {
                Caption = '&Cash Desk';
                group(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    action("Dimensions-Single")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Dimensions-Single';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID" = const(11744), "No." = field("No.");
                        ShortCutKey = 'Shift+Ctrl+D';
                        ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to cash documents to distribute costs and analyze transaction history.';
                    }
                    action("Dimensions-&Multiple")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;
                        ToolTip = 'View or edit dimensions for a group of records. You can assign dimension codes to transactions to distribute costs and analyze historical information.';

                        trigger OnAction()
                        var
                            CashDeskCZP: Record "Cash Desk CZP";
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SetSelectionFilter(CashDeskCZP);
                            DefaultDimMultiple.SetMultiRecord(CashDeskCZP, Rec.FieldNo("No."));
                            DefaultDimMultiple.RunModal();
                        end;
                    }
                }
                action(Statistics)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Statistics';
                    Image = Statistics;
                    RunObject = Page "Cash Desk Statistics CZP";
                    RunPageLink = "No." = field("No."),
                                  "Date Filter" = field("Date Filter"),
                                  "Global Dimension 1 Filter" = field("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = field("Global Dimension 2 Filter");
                    ShortCutKey = 'F7';
                    ToolTip = 'View the statistics on the selected cash desk.';
                }
                action("Co&mments")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = const("Cash Desk CZP"), "No." = field("No.");
                    ToolTip = 'Specifies cash desk comments.';
                }
                action(Balance)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Balance';
                    Image = Balance;
                    RunObject = Page "Bank Account Balance";
                    RunPageLink = "No." = field("No."),
                                  "Date Filter" = field("Date Filter"),
                                  "Global Dimension 1 Filter" = field("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = field("Global Dimension 2 Filter");
                    ToolTip = 'Show the cash desk balance during the period.';
                }
                action("Ledger E&ntries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ledger E&ntries';
                    Image = LedgerEntries;
                    RunObject = Page "Bank Account Ledger Entries";
                    RunPageLink = "Bank Account No." = field("No.");
                    RunPageView = sorting("Bank Account No.");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'Open the page with bank account ledger entries of this cash desk.';
                }
            }
            group(Setup)
            {
                Caption = 'Setup';
                action("Cash Desk Users")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cash Desk Users';
                    Image = Users;
                    RunObject = Page "Cash Desk Users CZP";
                    RunPageLink = "Cash Desk No." = field("No.");
                    RunPageMode = Edit;
                    ToolTip = 'Edit users authorized to issue or post cash documents for defined cash desk.';
                }
                action("Cash Desk Events")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cash Desk Events';
                    Image = "Event";
                    ToolTip = 'Shows cash desk events available in cash documents for defined cash desk.';
                    trigger OnAction()
                    var
                        CashDeskEventCZP: Record "Cash Desk Event CZP";
                    begin
                        CashDeskEventCZP.FilterGroup(2);
                        CashDeskEventCZP.SetFilter("Cash Desk No.", '%1|%2', '', Rec."No.");
                        CashDeskEventCZP.FilterGroup(0);
                        Page.RunModal(0, CashDeskEventCZP);
                    end;
                }
            }
            group(Documents)
            {
                Caption = 'Documents';
                Image = Documents;
                action("Opened Cash Documents")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Opened Cash Documents';
                    Image = Document;
                    RunObject = Page "Cash Document List CZP";
                    RunPageLink = "Cash Desk No." = field("No.");
                    RunPageView = where(Status = const(Open));
                    ToolTip = 'Show the overview of opened cash documents.';
                }
                action("Released Cash Documents")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Released Cash Documents';
                    Image = Confirm;
                    RunObject = Page "Cash Document List CZP";
                    RunPageLink = "Cash Desk No." = field("No.");
                    RunPageView = where(Status = const(Released));
                    ToolTip = 'Show the overview of released cash documents.';
                }
                action("Posted Cash Documents")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Cash Documents';
                    Image = PostDocument;
                    RunObject = Page "Posted Cash Document List CZP";
                    RunPageLink = "Cash Desk No." = field("No.");
                    ToolTip = 'Show the overview of posted cash documents.';
                }
            }
        }
        area(creation)
        {
            action("Cash &Document")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cash &Document';
                Image = Document;
                RunObject = Page "Cash Document CZP";
                RunPageLink = "Cash Desk No." = field("No.");
                RunPageMode = Create;
                ToolTip = 'Create a new cash document.';
            }
        }
        area(reporting)
        {
            action(CashDeskBook)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cash Desk Book';
                Ellipsis = true;
                Image = PrintReport;
                ToolTip = 'Open the report for cash desk entries during the period.';

                trigger OnAction()
                var
                    CashDeskCZP: Record "Cash Desk CZP";
                begin
                    CashDeskCZP := Rec;
                    CashDeskCZP.SetRecFilter();
                    Report.RunModal(Report::"Cash Desk Book CZP", true, false, CashDeskCZP);
                end;
            }
            action(CashDeskAccountBook)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cash Desk Account Book';
                Ellipsis = true;
                Image = PrintReport;
                ToolTip = 'Open the report for cash desk account book.';

                trigger OnAction()
                var
                    CashDeskCZP: Record "Cash Desk CZP";
                begin
                    CashDeskCZP := Rec;
                    CashDeskCZP.SetRecFilter();
                    Report.RunModal(Report::"Cash Desk Account Book CZP", true, false, CashDeskCZP);
                end;
            }
            action(CashDeskInventory)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cash Desk Inventory';
                Ellipsis = true;
                Image = Currencies;
                ToolTip = 'Open the report for cash desk inventory.';

                trigger OnAction()
                var
                    CashDeskCZP: Record "Cash Desk CZP";
                begin
                    CashDeskCZP := Rec;
                    CashDeskCZP.SetRecFilter();
                    Report.RunModal(Report::"Cash Desk Inventory CZP", true, false, CashDeskCZP);
                end;
            }
        }
        area(Promoted)
        {
#if not CLEAN22
            group(Category_New)
            {
                Caption = 'New';
                ObsoleteTag = '22.0';
                ObsoleteState = Pending;
                ObsoleteReason = 'This group has been removed.';
                Visible = false;
                actionref(CashDocumentPromoted; "Cash &Document")
                {
#pragma warning disable AS0072
                    ObsoleteTag = '22.0';
#pragma warning restore AS0072
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This group has been removed.';
                }
            }
#endif
            group(Category_Process)
            {
                Caption = 'Process';

#if not CLEAN22
                actionref(StatisticsPromoted; Statistics)
                {
                    ObsoleteTag = '22.0';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This actionref has been removed.';
                    Visible = false;
                }
#endif
                actionref(ResponsibilityHandOver_Promoted; "Responsibility Hand Over")
                {
                }
            }
            group(Category_Category4)
            {
                Caption = 'New Document';

                actionref(CashDocument_Promoted; "Cash &Document")
                {
                }
            }
            group(Category_Category6)
            {
                Caption = 'Print';
                actionref(CashDeskBook_Promoted; CashDeskBook)
                {
                }
            }
            group(Category_Category7)
            {
                Caption = 'Cash Desk';

                group(Category_Dimensions)
                {
                    Caption = 'Dimensions';
                    ShowAs = SplitButton;
                    actionref(DimensionMultiple_Promoted; "Dimensions-&Multiple")
                    {
                    }
                    actionref(DimensionsSingle_Promoted; "Dimensions-Single")
                    {
                    }
                }
                actionref(Statistics_Promoted; Statistics)
                {
                }
                actionref(Balance_Promoted; Balance)
                {
                }
                actionref(LedgerEntires_Promoted; "Ledger E&ntries")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        CashDesksFilter: Text;
    begin
        CashDesksFilter := CashDeskManagementCZP.GetCashDesksFilter();

        Rec.FilterGroup(2);
        if CashDesksFilter <> '' then
            Rec.SetFilter("No.", CashDesksFilter);
        Rec.FilterGroup(0);
    end;

    var
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";
}
