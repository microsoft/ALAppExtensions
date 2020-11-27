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
                }
                field("Verified Address"; Rec."Verified Address")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the address of customer or vendor was verified.';
                }
                field("Verified City"; Rec."Verified City")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the city of customer or vendor was verified.';
                }
                field("Verified Post Code"; Rec."Verified Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the post code of customer or vendor was verified.';
                }
                field("Verified VAT Registration No."; Rec."Verified VAT Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the VAT registration number of customer or vendor was verified.';
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
                RunObject = Codeunit "Reg. Lookup Ext. Data CZL";
                ToolTip = 'Verify a Registration number. If the number is verified the Status field contains the value Valid.';
            }
            action("Update Card")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Update Card';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Update verified data to card.';

                trigger OnAction()
                begin
                    Rec.UpdateCard();
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        if Rec.FindFirst() then;
    end;
}
