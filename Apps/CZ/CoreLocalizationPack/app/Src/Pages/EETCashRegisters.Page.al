// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

page 31144 "EET Cash Registers CZL"
{
    Caption = 'EET Cash Registers';
    DataCaptionFields = "Business Premises Code";
    PageType = List;
    SourceTable = "EET Cash Register CZL";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Business Premises Code"; Rec."Business Premises Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the premises.';
                    Visible = BusinessPremisesCodeVisibility;
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the cash register.';
                }
                field("Register Type"; Rec."Cash Register Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the cash register.';
                }
                field("Register No."; Rec."Cash Register No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the cash bank account.';
                }
                field("Register Name"; Rec."Cash Register Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the cash register.';
                }
                field("Certificate Code"; Rec."Certificate Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the certificate needed to register sales.';
                }
                field("Receipt Serial Nos."; Rec."Receipt Serial Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series for the receipt serial numbers.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(History)
            {
                Caption = 'History';
                Image = History;
                action("EET Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'EET Entries';
                    Image = LedgerEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    RunObject = page "EET Entries CZL";
                    RunPageLink = "Business Premises Code" = field("Business Premises Code"),
                                  "Cash Register Code" = field(Code);
                    RunPageView = sorting("Business Premises Code", "Cash Register Code");
                    ShortcutKey = 'Ctrl+F7';
                    ToolTip = 'Displays a list of EET entries for the selected cash register.';
                }
            }
        }
    }

    var
        BusinessPremisesCodeVisibility: Boolean;

    trigger OnOpenPage()
    begin
        BusinessPremisesCodeVisibility := Rec.GetFilter("Business Premises Code") = '';
    end;
}

