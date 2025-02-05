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
                field(RegistrationStatus; Rec."Registration Status") { }
                field(Network; Rec.Network) { }
                field(IdentifierType; Rec."Identifier Scheme Id") { }
                field(IdentifierValue; Rec."Identifier Value") { }
                field(Created; Rec.Created) { }
                field(Updated; Rec.Updated) { }
                field(Id; Rec.Id) { }
            }
        }
        area(FactBoxes)
        {
            part(ActiveProfiles; "Active Profiles")
            {
                SubPageLink = Network = field(Network), "Identifier Type Id" = field("Identifier Type Id"), "Identifier Value" = field("Identifier Value");
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(RegisterNewActionRef; RegisterNewParticipation) { }
            actionref(EditActioNRef; EditParticipation) { }
            actionref(DeleteActioNRef; DeleteParticipation) { }
        }
        area(Processing)
        {
            action(RegisterNewParticipation)
            {
                Caption = 'Register';
                ToolTip = 'Register a new participation in the Continia Delivery Network.';
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
                Caption = 'Edit';
                ToolTip = 'Edit the participation in the Continia Delivery Network.';
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
                Caption = 'Unregister';
                ToolTip = 'Unregister the participation in the Continia Delivery Network.';
                Image = Delete;
                Enabled = ActionsEnabled and CanEditParticipation;

                trigger OnAction()
                var
                    ApiRequests: Codeunit "Api Requests";
                begin
                    if Rec."Registration Status" = Rec."Registration Status"::Draft then
                        Rec.Delete()
                    else
                        ApiRequests.DeleteParticipation(Rec);
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
        CanEditParticipation := OnboardingHelper.HasModifyPermissionOnParticipation();
    end;

    trigger OnAfterGetRecord()
    begin
        ActionsEnabled := true;
    end;
}