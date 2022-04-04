page 40027 "Hybrid DA Approval"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Hybrid DA Approval";
    Permissions = tabledata "Hybrid DA Approval" = r;
    Extensible = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    InsertAllowed = false;
    Caption = 'Delegated admin consent for cloud migration';
    DataCaptionExpression = '';
    AdditionalSearchTerms = 'Delegated admin approval cloud migration consent';

    layout
    {
        area(Content)
        {
            group(InstructionalText)
            {
                ShowCaption = false;
                InstructionalText = 'Your external partner admin requires your consent to run the cloud migration on your behalf. To grant the consent, choose the Grant Consent action. You can revoke the consent at any time by choosing the Revoke Consent action. If you revoke consent, the cloud migration stops.';
            }

            group(General)
            {
                ShowCaption = false;
                group(StatusGroup)
                {
                    ShowCaption = false;
                    field(Status; Rec.Status)
                    {
                        ApplicationArea = All;
                        Caption = 'Status';
                        ToolTip = 'Specifies if the consent is granted or not.';
                    }
                }
                group(AdditionalInfoGroup)
                {
                    ShowCaption = false;

                    group(GrantedGroup)
                    {
                        ShowCaption = false;

                        field(GrantedByUserEmail; Rec."Granted By User Email")
                        {
                            ApplicationArea = All;
                            Caption = 'Granted by';
                            ToolTip = 'Specifies the email address of the user that granted permission to run the cloud migration tool to the delegated admin.';
                        }
                        field("Granted Date"; Rec."Granted Date")
                        {
                            ApplicationArea = All;
                            Caption = 'Granted date';
                            ToolTip = 'Specifies the date that the permission to run the cloud migration was granted on.';
                        }
                    }

                    group(RevokedGroup)
                    {
                        ShowCaption = false;

                        field("Revoked By User Email"; Rec."Revoked By User Email")
                        {
                            ApplicationArea = All;
                            Caption = 'Revoked by';
                            ToolTip = 'Specifies the email address of the user that revoked the permission.';
                        }
                        field("Revoked Date"; Rec."Revoked Date")
                        {
                            ApplicationArea = All;
                            Caption = 'Revoked date';
                            ToolTip = 'Specifies the date that the permission to run the cloud migration was revoked on.';
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GrantConsent)
            {
                ApplicationArea = All;
                Caption = 'Grant Consent';
                ToolTip = 'Specifies if you accept that the delegated admin runs the cloud migration of your data.';
                Image = Approve;
                InFooterBar = true;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    HybridCloudManagement.GrantConsentToDelegatedAdmin(Rec);
                end;
            }

            action(RevokeConsent)
            {
                ApplicationArea = All;
                Caption = 'Revoke Consent';
                ToolTip = 'Specifies if you want to revoke the consent that the delegated admin can run the cloud migration. If you revoke consent, the cloud migration stops.';
                Image = Cancel;
                InFooterBar = true;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    HybridCloudManagement.RevokeConsentFromDelegatedAdmin();
                    Rec.FindLast();
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        Clear(Rec);
        HybridCloudManagement.GetOrInsertDelegatedAdminApprovalRecord(Rec);
    end;

    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
}