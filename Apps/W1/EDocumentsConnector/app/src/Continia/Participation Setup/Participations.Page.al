// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

page 6391 "Participations"
{
    PageType = List;
    SourceTable = "Participation";
    ApplicationArea = Basic, Suite;
    UsageCategory = None;
    Caption = 'Continia Participations';
    Editable = false;

    layout
    {

        area(Content)
        {

            repeater(ParticipationsGroup)
            {
                field(RegistrationStatus; "Registration Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the registration status of the participation.';
                }
                field(Network; Network)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the network name where the participation is registered in.';
                }
                field(IdentifierType; "Identifier Scheme ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of identifier used for the participation.';
                }
                field(IdentifierValue; "Identifier Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the identifier used for the participation.';
                }
                field(Created; Created)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time when the participation was created.';
                }
                field(Updated; Updated)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time when the participation was last updated.';
                }
                field("CDN GUID"; "CDN GUID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier of the participation in the Continia Delivery Network.';
                }
            }
        }
        area(FactBoxes)
        {
            part(ActiveProfiles; "Active Profiles")
            {
                ApplicationArea = All;
                SubPageLink = Network = field(Network), "Identifier Type ID" = field("Identifier Type ID"), "Identifier Value" = field("Identifier Value");
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

            actionref(EditActioNRef; EditParticipation)
            {
            }
            actionref(DeleteActioNRef; DeleteParticipation)
            {
            }

        }
        area(Processing)
        {
            action(RegisterNewParticipation)
            {
                ApplicationArea = All;
                Caption = 'Register';
                ToolTip = 'Register a new participation in the Continia Delivery Network';
                Image = New;
                Enabled = CanEditParticipation;

                trigger OnAction()
                var
                    OnboardingWizard: Page "Onboarding Wizard";
                begin
                    OnboardingWizard.Run();
                end;
            }
            action(EditParticipation)
            {
                ApplicationArea = All;
                Caption = 'Edit';
                ToolTip = 'Edit the participation in the Continia Delivery Network';
                Image = Edit;
                Enabled = ActionsEnabled and CanEditParticipation;

                trigger OnAction()
                var
                    OnBoardingWizard: Page "Onboarding Wizard";
                    RunScenario: Enum "Wizard Scenario";
                begin
                    OnBoardingWizard.SetRunScenario(RunScenario::EditParticipation); //Update Participation and profiles 
                    OnBoardingWizard.SetParticipation(Rec);
                    OnBoardingWizard.Run();
                    CurrPage.Update(false);
                end;

            }
            action(DeleteParticipation)
            {
                ApplicationArea = All;
                Caption = 'Unregister';
                ToolTip = 'Unregister the participation in the Continia Delivery Network';
                Image = Delete;
                Enabled = ActionsEnabled and CanEditParticipation;

                trigger OnAction()
                var
                    APIRequests: Codeunit "API Requests";
                begin
                    if Rec."Registration Status" = Rec."Registration Status"::Draft then
                        Rec.Delete()
                    else
                        APIRequests.DeleteParticipation(Rec);
                end;
            }

        }
    }

    var
        ActionsEnabled: Boolean;
        CanEditParticipation: Boolean;

    trigger OnOpenPage()
    var
        OnboardingHelper: Codeunit "Onboarding Helper";
    begin
        CanEditParticipation := OnboardingHelper.HasModifyPermisionOnParticipation();
    end;

    trigger OnAfterGetRecord()
    begin
        ActionsEnabled := true;
    end;
}