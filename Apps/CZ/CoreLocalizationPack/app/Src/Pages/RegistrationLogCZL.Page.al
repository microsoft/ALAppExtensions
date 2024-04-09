// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Registration;

using System.Security.User;

page 11756 "Registration Log CZL"
{
    Caption = 'Registration Log';
    DataCaptionFields = "Account Type", "Account No.";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Registration Log CZL";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = History;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the entry number that is assigned to the entry.';
                }
                field("Registration No."; Rec."Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the registration number of customer or vendor.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies typ of account';
                    Visible = false;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies No of account';
                    Visible = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the verification action.';
                }
                field("Verified Date"; Rec."Verified Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the date of verified.';
                }
                field("Verified Name"; Rec."Verified Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the name of customer or vendor was verified.';
                    Visible = false;
                }
                field("Verified Address"; Rec."Verified Address")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the address of customer or vendor was verified.';
                    Visible = false;
                }
                field("Verified City"; Rec."Verified City")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the city of customer or vendor was verified.';
                    Visible = false;
                }
                field("Verified Post Code"; Rec."Verified Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the post code of customer or vendor was verified.';
                    Visible = false;
                }
                field("Verified Country/Region Code"; Rec."Verified Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the country/region code of customer or vendor was verified.';
                    Visible = false;
                }
                field("Verified VAT Registration No."; Rec."Verified VAT Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the VAT registration number of customer or vendor was verified.';
                    Visible = false;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of the user associated with the entry.';

                    trigger OnDrillDown()
                    var
                        UserMgt: Codeunit "User Management";
                    begin
                        UserMgt.DisplayUserInformation(Rec."User ID");
                    end;
                }
                field("Verified Result"; Rec."Verified Result")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies verified result';
                    Visible = false;
                }
                field("Detail Status"; Rec."Detail Status")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the detail.';
                    Enabled = DetailExist;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Verify Registration No.")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Verify Registration No.';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = codeunit "Reg. Lookup Ext. Data CZL";
                ToolTip = 'Verify a Registration number. If the number is verified the Status field contains the value Valid.';
            }
            action(ValidationDetail)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Validation Detail';
                Enabled = DetailExist;
                Image = List;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Open the list of fields that have been processed by the registration number validation service.';

                trigger OnAction()
                begin
                    Rec.OpenModifyDetails();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if Rec.FindFirst() then;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        DetailExist := Rec."Detail Status" <> Rec."Detail Status"::"Not Verified";
    end;

    var
        DetailExist: Boolean;
}
