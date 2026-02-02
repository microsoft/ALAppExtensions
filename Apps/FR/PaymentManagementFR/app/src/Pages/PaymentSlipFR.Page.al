// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.Currency;
using Microsoft.Foundation.Navigate;
using Microsoft.Sales.Customer;
using System.Telemetry;

page 10843 "Payment Slip FR"
{
    Caption = 'Payment Slip';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Payment Header FR";

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
                    AssistEdit = false;
                    ToolTip = 'Specifies the number of the payment header.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Payment Class"; Rec."Payment Class")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Lookup = false;
                    ToolTip = 'Specifies the payment class used when creating this payment slip.';
                }
                field("Payment Class Name"; Rec."Payment Class Name")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the name of the payment class used.';
                }
                field("Status Name"; Rec."Status Name")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the status the payment is in.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency code to be used on the payment lines.';

                    trigger OnAssistEdit()
                    begin
                        ChangeExchangeRate.SetParameter(Rec."Currency Code", Rec."Currency Factor", Rec."Posting Date");
                        if ChangeExchangeRate.RunModal() = ACTION::OK then begin
                            Rec.Validate("Currency Factor", ChangeExchangeRate.GetParameter());
                            CurrPage.Update();
                        end;
                        Clear(ChangeExchangeRate);
                    end;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the date when the payment slip should be posted.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when you create the payment slip.';

                    trigger OnValidate()
                    begin
                        DocumentDateOnAfterValidate();
                    end;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    AutoFormatType = 1;
                    ToolTip = 'Specifies the sum of the amounts in the Amount (LCY) fields on the associated lines.';
                }
                field("Partner Type"; Rec."Partner Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the payment slip is a person or company.';
                }
            }
            part(Lines; "Payment Slip Subform FR")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("No.");
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the source of the payment slip.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the dimension value code that the payment header will be associated with.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the dimension value code associated with the payment header.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the type of account that payments will be transferred to/from.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the number of the account that the payments will be transferred to/from.';
                }
            }
        }
        area(factboxes)
        {
            part("Payment Journal Errors"; "Payment Journal Errors Part")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'File Export Errors';
                Provider = Lines;
                SubPageLink = "Document No." = field("No."),
                              "Journal Line No." = field("Line No."),
                              "Journal Template Name" = const(''),
                              "Journal Batch Name" = const('10865');
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Header")
            {
                Caption = '&Header';
                Image = DepositSlip;
                action(Dimensions)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ToolTip = 'View or change the dimension settings for this payment slip. If you change the dimension, you can update all lines on the payment slip.';

                    trigger OnAction()
                    begin
                        Rec.ShowDocDim();
                        CurrPage.SaveRecord();
                    end;
                }
                action("Header RIB")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Header RIB';
                    Image = Check;
                    RunObject = Page "Payment Bank FR";
                    RunPageLink = "No." = field("No.");
                    ToolTip = 'View the RIB key that is associated with the bank account.';
                }
            }
            group("&Navigate")
            {
                Caption = '&Navigate';
                action(Header)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Header';
                    Image = DepositSlip;
                    ToolTip = 'View general information about payments or collections, for example, to and from customers and vendors. A payment header has one or more payment lines assigned to it. The lines contain information such as the amount, the bank details, and the due date.';

                    trigger OnAction()
                    begin
                        Navigate.SetDoc(Rec."Posting Date", Rec."No.");
                        Navigate.Run();
                    end;
                }
                action(Line)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Line';
                    Image = Line;
                    ToolTip = 'Create a new payment line for the payment slip.';

                    trigger OnAction()
                    begin
                        CurrPage.Lines.PAGE.NavigateLine(Rec."Posting Date");
                    end;
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(SuggestVendorPayments)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Suggest &Vendor Payments';
                    Image = SuggestVendorPayments;
                    ToolTip = 'Process open vendor ledger entries (entries that result from posting invoices, finance charge memos, credit memos, and payments) to create a payment suggestion as lines in a payment slip. ';

                    trigger OnAction()
                    var
                        PaymentClass: Record "Payment Class FR";
                        CreateVendorPmtSuggestion: Report "Suggest Vend. Payments";
                    begin
                        if Rec."Status No." <> 0 then
                            Message(Text003Lbl)
                        else
                            if PaymentClass.Get(Rec."Payment Class") then
                                if PaymentClass.Suggestions = PaymentClass.Suggestions::Vendor then begin
                                    CreateVendorPmtSuggestion.SetGenPayLine(Rec);
                                    CreateVendorPmtSuggestion.RunModal();
                                    Clear(CreateVendorPmtSuggestion);
                                end else
                                    Message(Text001Lbl);
                    end;
                }
                action(SuggestCustomerPayments)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Suggest &Customer Payments';
                    Image = SuggestCustomerPayments;
                    ToolTip = 'Process open customer ledger entries (entries that result from posting invoices, finance charge memos, credit memos, and payments) to create a payment suggestion as lines in a payment slip.';

                    trigger OnAction()
                    var
                        Customer: Record Customer;
                        PaymentClass: Record "Payment Class FR";
                        CreateCustomerPmtSuggestion: Report "Suggest Cust. Payments";
                    begin
                        if Rec."Status No." <> 0 then
                            Message(Text003Lbl)
                        else
                            if PaymentClass.Get(Rec."Payment Class") then
                                if PaymentClass.Suggestions = PaymentClass.Suggestions::Customer then begin
                                    CreateCustomerPmtSuggestion.SetGenPayLine(Rec);
                                    Customer.SetRange("Partner Type", Rec."Partner Type");
                                    CreateCustomerPmtSuggestion.SetTableView(Customer);
                                    CreateCustomerPmtSuggestion.RunModal();
                                    Clear(CreateCustomerPmtSuggestion);
                                end else
                                    Message(Text002Lbl);
                    end;
                }
                separator(Action1120052)
                {
                }
                action(Archive)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Archive';
                    Image = Archive;
                    ToolTip = 'Archive the payment slip to separate it from active entries.';

                    trigger OnAction()
                    var
                        PaymentMgt: Codeunit "Payment Management FR";
                    begin
                        if Rec."No." = '' then
                            exit;
                        if not Confirm(Text009Lbl) then
                            exit;
                        PaymentMgt.ArchiveDocument(Rec);
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action(GenerateFile)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Generate file';
                    Image = CreateDocument;
                    ToolTip = 'Generate an XML or an XMLport file that you can send to your bank. This requires that File is chosen in the Action Type field for the payment slip setup. ';

                    trigger OnAction()
                    var
                        PaymentMgt: Codeunit "Payment Management FR";
                    begin
                        FeatureTelemetry.LogUptake('1000HP2', FRPaymentSlipTok, Enum::"Feature Uptake Status"::"Used");
                        PaymentStep.SetRange("Action Type", PaymentStep."Action Type"::File);
                        PaymentMgt.ProcessPaymentSteps(Rec, PaymentStep);
                        FeatureTelemetry.LogUsage('1000HP3', FRPaymentSlipTok, 'FR Payment Slips File Created');
                    end;
                }
                action(Post)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post';
                    Image = Post;
                    ToolTip = 'Post the payment.';

                    trigger OnAction()
                    var
                        PaymentMgt: Codeunit "Payment Management FR";
                    begin
                        PaymentStep.SetFilter(
                          "Action Type",
                          '%1|%2|%3',
                          PaymentStep."Action Type"::None, PaymentStep."Action Type"::Ledger, PaymentStep."Action Type"::"Cancel File");
                        PaymentMgt.ProcessPaymentSteps(Rec, PaymentStep);
                    end;
                }
                action(Print)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Print';
                    Image = Print;
                    ToolTip = 'Print the payment slip.';

                    trigger OnAction()
                    var
                        PaymentMgt: Codeunit "Payment Management FR";
                    begin
                        CurrPage.Lines.PAGE.MarkLines(true);
                        PaymentStep.SetRange("Action Type", PaymentStep."Action Type"::Report);
                        PaymentMgt.ProcessPaymentSteps(Rec, PaymentStep);
                        CurrPage.Lines.PAGE.MarkLines(false);
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Post_Promoted; Post)
                {
                }
                actionref(SuggestVendorPayments_Promoted; SuggestVendorPayments)
                {
                }
                actionref(SuggestCustomerPayments_Promoted; SuggestCustomerPayments)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CurrPage.Lines.PAGE.Editable(true);
    end;

    var
        PaymentStep: Record "Payment Step FR";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ChangeExchangeRate: Page "Change Exchange Rate";
        Navigate: Page Navigate;
        Text001Lbl: Label 'This payment class does not authorize vendor suggestions.';
        Text002Lbl: Label 'This payment class does not authorize customer suggestions.';
        Text003Lbl: Label 'You cannot suggest payments on a posted header.';
        Text009Lbl: Label 'Do you want to archive this document?';
        FRPaymentSlipTok: Label 'FR Create Payment Slips', Locked = true;

    local procedure DocumentDateOnAfterValidate()
    begin
        CurrPage.Update();
    end;
}

