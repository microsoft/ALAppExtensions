// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Comment;
using Microsoft.Utilities;
using System.Security.User;

page 31151 "Cash Desk Card CZP"
{
    Caption = 'Cash Desk Card';
    PageType = Card;
    SourceTable = "Cash Desk CZP";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the number of the cash desk.';
                    Visible = NoFieldVisible;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of cash desk.';
                }
                field("Name 2"; Rec."Name 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the another line for name if name is longer.';
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the address of cash desk.';
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the another line for address if address is longer.';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the city of cash desk.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code.';
                }
                field(Contact; Rec.Contact)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the employee contacted with cash desk.';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the postal code.';
                }
                field("Search Name"; Rec."Search Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a search name for the cash desk.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies to block the cash desk by placing a check mark in the check box.';
                }
            }
            group(Communication)
            {
                Caption = 'Communication';
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the phone number associated with the cash desk card.';
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the e-mail address associated with the cash desk card.';
                }
            }
            group(Responsibility)
            {
                Caption = 'Responsibility';
                field("Cashier No."; Rec."Cashier No.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the cashier number from employee list.';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the responsibility center which works with this cash desk.';
                }
                field("Payed To/By Checking"; Rec."Payed To/By Checking")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies to check for filling payed to/by checking in the cash desk document.';
                }
                field("Responsibility ID (Release)"; Rec."Responsibility ID (Release)")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the responsibility ID for release from employee list.';

                    trigger OnDrillDown()
                    var
                        UserMgt: Codeunit "User Management";
                    begin
                        UserMgt.DisplayUserInformation(Rec."Responsibility ID (Release)");
                    end;
                }
                field("Responsibility ID (Post)"; Rec."Responsibility ID (Post)")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the responsibility ID for posting from employee list.';

                    trigger OnDrillDown()
                    var
                        UserMgt: Codeunit "User Management";
                    begin
                        UserMgt.DisplayUserInformation(Rec."Responsibility ID (Post)");
                    end;
                }
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the currency of amounts on the document.';
                }
                field("Confirm Inserting of Document"; Rec."Confirm Inserting of Document")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies confirming inserting of document automaticaly or with message.';
                }
                field("Amounts Including VAT"; Rec."Amounts Including VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the unit price on the line should be displayed including or excluding VAT.';
                }
                field("Bank Acc. Posting Group"; Rec."Bank Acc. Posting Group")
                {
                    Caption = 'Cash Desk Posting Group';
                    ShowMandatory = true;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting group for cash desk.';
                }
                field("Debit Rounding Account"; Rec."Debit Rounding Account")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the account for debit rounding.';
                }
                field("Credit Rounding Account"; Rec."Credit Rounding Account")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the account for credit rounding.';
                }
                field("Rounding Method Code"; Rec."Rounding Method Code")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the code of rounding method in the cash desk document.';
                }
                field("Allow VAT Difference"; Rec."Allow VAT Difference")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether to allow the manual adjustment of VAT amounts in cash documents.';
                }
                field("Exclude from Exch. Rate Adj."; Rec."Exclude from Exch. Rate Adj.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether entries will be excluded from exchange rates adjustment.';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the dimension value code associated with the cash desk.';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the dimension value code associated with the cash desk.';
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reason code on the entry.';
                }
            }
            group(Limits)
            {
                Caption = 'Limits';
                field("Cash Receipt Limit"; Rec."Cash Receipt Limit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the maximum limit for cash receipt.';
                }
                field("Max. Balance Checking"; Rec."Max. Balance Checking")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the setup possibility to maximum balance check.';
                }
                field("Max. Balance"; Rec."Max. Balance")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of maximum balance.';
                }
                field("Cash Withdrawal Limit"; Rec."Cash Withdrawal Limit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the maximum limit for cash withdrawal.';
                }
                field("Min. Balance Checking"; Rec."Min. Balance Checking")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the setup possibility to minimum balance check.';
                }
                field("Min. Balance"; Rec."Min. Balance")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of minimun balance.';
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Cash Document Receipt Nos."; Rec."Cash Document Receipt Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the receipt number series in cash document.';
                }
                field("Cash Document Withdrawal Nos."; Rec."Cash Document Withdrawal Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the withdrawal number series in cash document.';
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
                action(Dimensions)
                {
                    ApplicationArea = Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = const(11744), "No." = field("No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to cash documents to distribute costs and analyze transaction history.';
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
                    ToolTip = 'Show the total receipts and withdrawals in cash desk.';
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
                    ToolTip = 'Show the cash desk ledger entries.';
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

                actionref(Dimensions_Promoted; Dimensions)
                {
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
    begin
        SetNoFieldVisible();
    end;

    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
        NoFieldVisible: Boolean;

    local procedure SetNoFieldVisible()
    begin
        NoFieldVisible := DocumentNoVisibility.ForceShowNoSeriesForDocNo(DetermineCashDeskCZPSeriesNo());
    end;

    local procedure DetermineCashDeskCZPSeriesNo(): Code[20]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CashDeskCZP: Record "Cash Desk CZP";
    begin
        GeneralLedgerSetup.Get();
        DocumentNoVisibility.CheckNumberSeries(CashDeskCZP, GeneralLedgerSetup."Cash Desk Nos. CZP", CashDeskCZP.FieldNo("No."));
        exit(GeneralLedgerSetup."Cash Desk Nos. CZP");
    end;
}
