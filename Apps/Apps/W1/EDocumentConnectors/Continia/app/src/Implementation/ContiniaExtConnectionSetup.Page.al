// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using System.Environment;

page 6390 "Continia Ext. Connection Setup"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Continia E-Document External Connection Setup';
    DeleteAllowed = false;
    Editable = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SourceTable = "Continia Connection Setup";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(SubscriptionStatus; Rec."Subscription Status")
                {
                    Editable = false;
                    ShowMandatory = true;
                }
                field(NoOfParticipations; Rec."No. Of Participations")
                {
                    ShowMandatory = true;

                    trigger OnDrillDown()
                    var
                        Participation: Record "Continia Participation";
                        ApiRequests: Codeunit "Continia Api Requests";
                        Participations: Page "Continia Participations";
                        ProgressWindow: Dialog;
                    begin
                        ProgressWindow.Open(ProcessingWindowMsg);
                        if Participation.FindSet() then
                            repeat
                                ApiRequests.GetParticipation(Participation);
                                ApiRequests.GetAllParticipationProfiles(Participation);
                            until Participation.Next() = 0;

                        ProgressWindow.Close();
                        Participations.Run();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(RegisterNewActionRef; RegisterNewParticipation) { }
            group(SubscriptionGroup)
            {
                Caption = 'Subscription';
                actionref(EditCompanyInformationActionRef; EditCompanyInformation) { }
                actionref(CancelSubscriptionActionRef; CancelSubscription) { }
            }
        }
        area(Processing)
        {
            action(RegisterNewParticipation)
            {
                Caption = 'Register new participation';
                Enabled = CanEditParticipation;
                Image = New;
                ToolTip = 'Register a new participation in the Continia Delivery Network.';

                trigger OnAction()
                var
                    OnboardingGuide: Page "Continia Onboarding Guide";
                begin
                    OnboardingGuide.Run();
                    CurrPage.Update(false);
                end;
            }
            action(EditCompanyInformation)
            {
                Caption = 'Edit Company Information';
                Enabled = ActionsEnabled and CanEditParticipation;
                Image = Company;
                ToolTip = 'Edit the company information for the Continia subscription.';

                trigger OnAction()
                var
                    ActivationMgt: Codeunit "Continia Subscription Mgt.";
                    OnboardingGuide: Page "Continia Onboarding Guide";
                    RunScenario: Enum "Continia Wizard Scenario";
                begin
                    if ActivationMgt.HasOtherAppsInSubscription() then
                        Message(UseContiniaSolutionMgtMsg)
                    else begin
                        OnboardingGuide.SetRunScenario(RunScenario::EditSubscriptionInfo);
                        OnboardingGuide.Run();
                    end;
                end;
            }
            action(CancelSubscription)
            {
                Caption = 'Cancel Subscription';
                Enabled = ActionsEnabled and CanEditParticipation;
                Image = Cancel;
                Ellipsis = true;
                ToolTip = 'Cancels the Continia subscription. You will not be able to send or receive e-documents using the Continia Delivery Network anymore.';

                trigger OnAction()
                var
                    Participation: Record "Continia Participation";
                    ApiRequests: Codeunit "Continia Api Requests";
                    ActivationMgt: Codeunit "Continia Subscription Mgt.";
                begin
                    if Confirm(UnsubscribeQst) then begin
                        if Participation.FindSet() then
                            repeat
                                ApiRequests.DeleteParticipation(Participation);
                            until Participation.Next() = 0;

                        ActivationMgt.Unsubscribe(true);
                        CurrPage.Update(false);
                    end
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        OnboardingHelper: Codeunit "Continia Onboarding Helper";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            Error(NotSupportedOnPremisesErr);

        CanEditParticipation := OnboardingHelper.HasModifyPermissionOnParticipation();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert()
        end;
    end;

    trigger OnAfterGetRecord()
    begin
        ActionsEnabled := true;
    end;

    var
        ActionsEnabled, CanEditParticipation : Boolean;
        UnsubscribeQst: Label 'Are you sure you want to cancel the subscription? You will not be able to send or receive e-documents using the Continia Delivery Network anymore.';
        UseContiniaSolutionMgtMsg: Label 'There are other Continia apps in this subscription. In these cases you can only change the company information from the Continia Solution Management page.';
        ProcessingWindowMsg: Label 'Updating data from Continia Online';
        NotSupportedOnPremisesErr: Label 'The Continia E-Document Service is not supported in on-premises environments.';
}