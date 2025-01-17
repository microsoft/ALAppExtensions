// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Registration;

page 31208 "Registration Log Details CZL"
{
    PageType = List;
    SourceTable = "Registration Log Detail CZL";
    Caption = 'Validation Details';
    DataCaptionFields = "Account Type", "Account No.";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Details)
            {
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the field that has been validated by the registration no. validation service.';
                }
                field("Current Value"; Rec."Current Value")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the current value.';
                }
                field(Response; Rec.Response)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value that was returned by the service.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the field validation.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Accept)
            {
                ApplicationArea = Basic, Suite;
                Image = Approve;
                Enabled = AcceptEnabled;
                Caption = 'Accept';
                ToolTip = 'Apply the value that the service returned to the account.';

                trigger OnAction()
                begin
                    Rec.Status := Rec.Status::Accepted;
                    Rec.Modify();

                    UpdateControls();
                end;
            }
            action(AcceptAll)
            {
                ApplicationArea = Basic, Suite;
                Image = Approve;
                Enabled = AcceptAllEnabled;
                Caption = 'Accept All';
                ToolTip = 'Accept all returned values and update the account.';

                trigger OnAction()
                begin
                    UpdateAllDetailsStatus(Rec.Status::"Not Valid", Rec.Status::Accepted);
                end;

            }
            action(Reset)
            {
                ApplicationArea = Basic, Suite;
                Image = ResetStatus;
                Enabled = ResetEnabled;
                Caption = 'Reset';
                ToolTip = 'Reset the value that was applied to the account.';

                trigger OnAction()
                begin
                    Rec.Status := Rec.Status::"Not Valid";
                    Rec.Modify();

                    UpdateControls();
                end;
            }
            action(ResetAll)
            {
                ApplicationArea = Basic, Suite;
                Image = ResetStatus;
                Enabled = ResetAllEnabled;
                Caption = 'Reset All';
                ToolTip = 'Reset the values that were applied to the account.';

                trigger OnAction()
                begin
                    UpdateAllDetailsStatus(Rec.Status::Accepted, Rec.Status::"Not Valid");
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(Accept_Promoted; Accept)
                {
                }
                actionref(AcceptAll_Promoted; AcceptAll)
                {
                }
                actionref(Reset_Promoted; Reset)
                {
                }
                actionref(ResetAll_Promoted; ResetAll)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        UpdateControls();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        AcceptEnabled := Rec.Status = Rec.Status::"Not Valid";
        ResetEnabled := Rec.Status = Rec.Status::Accepted;
    end;

    var
        AcceptEnabled: Boolean;
        AcceptAllEnabled: Boolean;
        ResetEnabled: Boolean;
        ResetAllEnabled: Boolean;

    local procedure UpdateAllDetailsStatus(Before: Enum "Reg. Log Detailed Field Status CZL"; After: Enum "Reg. Log Detailed Field Status CZL")
    var
        RegistrationLogDetail: Record "Registration Log Detail CZL";
    begin
        RegistrationLogDetail.Copy(Rec);
        RegistrationLogDetail.SetRange(Status, Before);
        RegistrationLogDetail.ModifyAll(Status, After);

        UpdateControls();
    end;

    local procedure UpdateControls()
    var
        RegistrationLogDetail: Record "Registration Log Detail CZL";
    begin
        RegistrationLogDetail.CopyFilters(Rec);
        RegistrationLogDetail.SetRange(Status, RegistrationLogDetail.Status::"Not Valid");
        AcceptAllEnabled := not RegistrationLogDetail.IsEmpty();

        RegistrationLogDetail.SetRange(Status, RegistrationLogDetail.Status::Accepted);
        ResetAllEnabled := not RegistrationLogDetail.IsEmpty();
    end;
}
