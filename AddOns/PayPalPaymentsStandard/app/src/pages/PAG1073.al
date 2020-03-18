page 1073 "MS - PayPal Standard Accounts"
{
    Caption = 'PayPal Payments Standard Accounts';
    CardPageID = "MS - PayPal Standard Setup";
    Editable = false;
    InsertAllowed = false;
    UsageCategory = Administration;
    PageType = List;
    SourceTable = 1070;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Always Include on Documents"; "Always Include on Documents")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account ID"; "Account ID")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(NewAction)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'New';
                Image = NewDocument;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    TempPaymentServiceSetup: Record 1060 temporary;
                    MSPayPalStandardMgt: Codeunit 1070;
                begin
                    MSPayPalStandardMgt.RegisterPayPalStandardTemplate(TempPaymentServiceSetup);
                    TempPaymentServiceSetup.OnCreatePaymentService(TempPaymentServiceSetup);
                end;
            }
        }
    }
}

