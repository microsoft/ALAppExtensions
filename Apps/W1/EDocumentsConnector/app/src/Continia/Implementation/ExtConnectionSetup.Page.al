// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

page 6390 "Ext. Connection Setup"
{
    PageType = Card;
    ApplicationArea = Basic, Suite;
    SourceTable = "Connection Setup";
    UsageCategory = None;
    Caption = 'E-Document External Connection Setup';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {

                field(SubscriptionStatus; "Subscription Status")
                {
                    Caption = 'Subscription Status';
                    ToolTip = 'Specifies the status of the Continia subscription.';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowMandatory = true;
                }

                field(NoOfParticipations; "No. Of Participations")
                {
                    Caption = 'No. of Participations';
                    ToolTip = 'Specifies the number of participations in the Continia Delivery Network.';
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;

                    trigger OnDrillDown()
                    var
                        Participation: Record "Participation";
                        APIRequests: Codeunit "API Requests";
                        Participations: Page "Participations";
                        ProgressWindow: Dialog;
                    begin
                        ProgressWindow.Open(ProcessingWindowMsg);
                        if Participation.FindSet() then
                            repeat
                                APIRequests.GetParticipation(Participation);
                                APIRequests.GetAllParticipationProfiles(Participation);
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
            actionref(RegisterNewActionRef; RegisterNewParticipation)
            {
            }
            group(SubscriptionGroup)
            {
                Caption = 'Subscription';
                actionref(EditCompanyInformationActionRef; EditCompanyInformation)
                {
                }
                actionref(CancelSubscriptionActionRef; CancelSubscription)
                {
                }
            }
        }
        area(Processing)
        {
            action(RegisterNewParticipation)
            {
                ApplicationArea = All;
                Caption = 'Register new participation';
                ToolTip = 'Register a new participation in the Continia Delivery Network';
                Image = New;
                Enabled = CanEditParticipation;

                trigger OnAction()
                var
                    OnboardingWizard: Page "Onboarding Wizard";
                begin
                    OnboardingWizard.Run();
                    CurrPage.Update(false);
                end;
            }
            action(EditCompanyInformation)
            {
                ApplicationArea = All;
                Caption = 'Edit Company Information';
                ToolTip = 'Edit the company information for the Continia subscription';
                Image = Company;
                Enabled = ActionsEnabled and CanEditParticipation;

                trigger OnAction()
                var
                    ActivationMgt: Codeunit "Subscription Mgt.";
                    OnBoardingWizard: Page "Onboarding Wizard";
                    RunScenario: Enum "Wizard Scenario";
                begin
                    if ActivationMgt.HasOtherAppsInSubscription() then
                        Message(UseContiniaSolutionMgtMsg)
                    else begin
                        OnBoardingWizard.SetRunScenario(RunScenario::EditSubscriptionInfo);
                        OnBoardingWizard.Run();
                    end;
                end;
            }
            action(CancelSubscription)
            {
                ApplicationArea = All;
                Caption = 'Cancel Subscription';
                ToolTip = 'Cancels the Continia subscription. You will not be able to send or receive e-documents using the Continia Delivery Network anymore.';
                Image = Cancel;
                Enabled = ActionsEnabled and CanEditParticipation;

                trigger OnAction()
                var
                    Participation: Record "Participation";
                    APIRequests: Codeunit "API Requests";
                    ActivationMgt: Codeunit "Subscription Mgt.";
                begin
                    if Confirm(UnsubscribeQst) then begin
                        if Participation.FindSet() then
                            repeat
                                APIRequests.DeleteParticipation(Participation);
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
        OnboardingHelper: Codeunit "Onboarding Helper";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        IF NOT EnvironmentInformation.IsSaaSInfrastructure() THEN
            Error(NotSupportedOnPremisesErr);
        CanEditParticipation := OnboardingHelper.HasModifyPermisionOnParticipation();
    end;

    trigger OnAfterGetRecord()
    begin
        ActionsEnabled := true;
    end;

    var
        ActionsEnabled, CanEditParticipation : Boolean;
        UnsubscribeQst: Label 'Are you sure you want to cancel the subscription? You will not be able to send or received e-documents using the Continia Delivery Network anymore.';
        UseContiniaSolutionMgtMsg: Label 'There are other Continia apps in this subscription. In these cases you can only change the company information from the Continia Solution Management page.';
        ProcessingWindowMsg: Label 'Updating data from Continia Online';
        NotSupportedOnPremisesErr: Label 'The Continia E-Document Service is not supported in on-premises environments.';
}