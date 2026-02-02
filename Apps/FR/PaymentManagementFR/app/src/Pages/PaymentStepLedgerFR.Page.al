// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

page 10852 "Payment Step Ledger FR"
{
    Caption = 'Payment Step Ledger';
    PageType = Card;
    SourceTable = "Payment Step Ledger FR";

    layout
    {
        area(content)
        {
            group(Control1)
            {
                ShowCaption = false;
                field("Payment Class"; Rec."Payment Class")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = false;
                    ToolTip = 'Specifies the payment class.';
                }
                field(Line; Rec.Line)
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = false;
                    ToolTip = 'Specifies the ledger line''s entry number.';
                }
                field(Sign; Rec.Sign)
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = SignEnable;
                    ToolTip = 'Specifies if the posting will result in a debit or credit entry.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description to be used on the general ledger entry.';
                }
                field("Accounting Type"; Rec."Accounting Type")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = AccountingTypeEnable;
                    ToolTip = 'Specifies the type of account to post the entry to.';

                    trigger OnValidate()
                    begin
                        DisableFields();
                    end;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = AccountTypeEnable;
                    ToolTip = 'Specifies the type of account to post the entry to.';

                    trigger OnValidate()
                    begin
                        DisableFields();
                    end;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = AccountNoEnable;
                    ToolTip = 'Specifies the account number to post the entry to.';

                    trigger OnValidate()
                    begin
                        DisableFields();
                    end;
                }
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = CustomerPostingGroupEnable;
                    ToolTip = 'Specifies a code for the customer posting group used when the entry is posted.';

                    trigger OnValidate()
                    begin
                        DisableFields();
                    end;
                }
                field("Vendor Posting Group"; Rec."Vendor Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = VendorPostingGroupEnable;
                    ToolTip = 'Specifies a code for the vendor posting group used when the entry is posted.';

                    trigger OnValidate()
                    begin
                        DisableFields();
                    end;
                }
                field(Root; Rec.Root)
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = RootEnable;
                    ToolTip = 'Specifies the root for the G/L accounts group used, when you have selected either G/L Account / Month, or G/L Account / Week.';

                    trigger OnValidate()
                    begin
                        DisableFields();
                    end;
                }
                field("Memorize Entry"; Rec."Memorize Entry")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that entries created in this step will be memorized, so the next application can be performed against newly posted entries.';

                    trigger OnValidate()
                    begin
                        DisableFields();
                    end;
                }
                field(Application; Rec.Application)
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = ApplicationEnable;
                    ToolTip = 'Specifies how to apply entries.';

                    trigger OnValidate()
                    begin
                        DisableFields();
                    end;
                }
                field("Detail Level"; Rec."Detail Level")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = DetailLevelEnable;
                    ToolTip = 'Specifies how payment lines will be posted.';

                    trigger OnValidate()
                    begin
                        DisableFields();
                    end;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of document that will be assigned to the ledger entry.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the method to assign a document number to the ledger entry.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        DisableFields();
    end;

    trigger OnInit()
    begin
        DetailLevelEnable := true;
        RootEnable := true;
        VendorPostingGroupEnable := true;
        CustomerPostingGroupEnable := true;
        AccountNoEnable := true;
        AccountTypeEnable := true;
        ApplicationEnable := true;
        SignEnable := true;
        AccountingTypeEnable := true;
    end;

    var
        AccountingTypeEnable: Boolean;
        SignEnable: Boolean;
        ApplicationEnable: Boolean;
        AccountTypeEnable: Boolean;
        AccountNoEnable: Boolean;
        CustomerPostingGroupEnable: Boolean;
        VendorPostingGroupEnable: Boolean;
        RootEnable: Boolean;
        DetailLevelEnable: Boolean;


    procedure DisableFields()
    begin
        AccountingTypeEnable := true;
        SignEnable := true;
        ApplicationEnable := true;

        case Rec."Accounting Type" of
            Rec."Accounting Type"::"Setup Account":
                begin
                    AccountTypeEnable := true;
                    AccountNoEnable := true;
                    RootEnable := false;

                    case Rec."Account Type" of
                        Rec."Account Type"::Customer:
                            begin
                                CustomerPostingGroupEnable := true;
                                VendorPostingGroupEnable := false;
                            end;
                        Rec."Account Type"::Vendor:
                            begin
                                CustomerPostingGroupEnable := false;
                                VendorPostingGroupEnable := true;
                            end;
                        else begin
                            CustomerPostingGroupEnable := false;
                            VendorPostingGroupEnable := false;
                        end;
                    end;
                end;

            Rec."Accounting Type"::"G/L Account / Month",
            Rec."Accounting Type"::"G/L Account / Week":
                begin
                    AccountTypeEnable := false;
                    AccountNoEnable := false;
                    RootEnable := true;
                    CustomerPostingGroupEnable := false;
                    VendorPostingGroupEnable := false;
                end;

            Rec."Accounting Type"::"Bal. Account Previous Entry":
                begin
                    AccountTypeEnable := false;
                    AccountNoEnable := false;
                    RootEnable := false;
                    CustomerPostingGroupEnable := false;
                    VendorPostingGroupEnable := false;
                end;

            else begin
                AccountTypeEnable := false;
                AccountNoEnable := false;
                RootEnable := false;
                CustomerPostingGroupEnable := true;
                VendorPostingGroupEnable := true;
            end;
        end;

        if Rec."Memorize Entry" or (Rec.Application <> Rec.Application::None) then begin
            Rec."Detail Level" := Rec."Detail Level"::Line;
            DetailLevelEnable := false;
        end else
            DetailLevelEnable := true;
    end;
}

