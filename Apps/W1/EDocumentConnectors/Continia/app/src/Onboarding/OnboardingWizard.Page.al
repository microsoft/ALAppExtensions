// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using System.Email;
using Microsoft.Foundation.Address;

page 6393 "Onboarding Wizard"
{
    ApplicationArea = All;
    Caption = 'Continia Delivery Network Onboarding';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = NavigatePage;

    layout
    {
        area(Content)
        {
            group(FirstPage)
            {
                Caption = '';
                Visible = FirstStepVisible;
                group(IntroductionGroup)
                {
                    Caption = 'Welcome to the Continia Delivery Network onboarding guide.';
                    Visible = FirstStepVisible;
                    group(Start1)
                    {
                        InstructionalText = 'Continia Delivery Network integrates seamlessly with various electronic data exchange networks, such as the PEPPOL eDelivery Network. This allows you to send and receive documents directly from Business Central if your vendors and customers are also connected to these networks.';
                        ShowCaption = false;
                    }
                    group(Start2)
                    {
                        InstructionalText = 'This guide will help you register your company as a participant in the Continia Delivery Network.';
                        ShowCaption = false;
                    }
                }
                group(IntroductionGroup2)
                {
                    Caption = 'Let''s go!';
                    group(Start3)
                    {
                        Caption = '';
                        InstructionalText = 'Choose Next to get started.';
                    }
                }
            }
            group(PartnerDetailsPage)
            {
                Caption = '';
                Visible = PartnerDetailsStepVisible;
                group(PartnerDetails)
                {
                    Caption = 'Partner details';
                    Visible = PartnerDetailsStepVisible;
                    group(PartnerDetails1)
                    {
                        InstructionalText = 'To continue, you will need the assistance of your partner. Please have your partner enter their Continia PartnerZone credentials:';
                        ShowCaption = false;
                    }
                }
                field(PartnerUserName; PartnerUserName)
                {
                    Caption = 'PartnerZone Username';
                    ShowMandatory = true;
                    ToolTip = 'Please enter the email used when logging in to Continia PartnerZone.';

                    trigger OnValidate()
                    var
                        MailManagement: Codeunit "Mail Management";
                    begin
                        if PartnerUserName <> '' then
                            MailManagement.CheckValidEmailAddress(PartnerUserName);
                    end;
                }
                field(PartnerPassword; PartnerPassword)
                {
                    Caption = 'PartnerZone Password';
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;
                    ToolTip = 'Please enter the password used when logging in to Continia PartnerZone. If you do not have a PartnerZone login, please contact Continia.';

                    trigger OnValidate()
                    begin
                        if PartnerPassword = '' then
                            Error(NoPasswordErr);
                    end;
                }
                field(PartnerPwdLinkLabel; PartnerReqPwdTxt)
                {
                    Editable = false;
                    ShowCaption = false;

                    trigger OnDrillDown()
                    begin
                        Hyperlink('https://partnerzone.continia.com/request-reset-password');
                    end;
                }
                field(PartnerNewRegLabel; PartnerRegAsNewTxt)
                {
                    Editable = false;
                    ShowCaption = false;

                    trigger OnDrillDown()
                    begin
                        Hyperlink('https://pz.continia.com/partner-application-form/');
                    end;
                }
            }
            group(LegalCompanyInformationPage)
            {
                Caption = '';
                Visible = LegalCompanyInformationStepVisible;
                group(LegalCompanyInformation)
                {
                    Caption = 'Legal company information';
                    Visible = LegalCompanyInformationStepVisible;
                    group(LegalCompanyInformation1)
                    {
                        InstructionalText = 'Please provide the legal information of the company you want to register in the network.';
                        ShowCaption = false;
                        field("Company Name"; TempParticipation."Company Name")
                        {
                            ShowMandatory = true;

                            trigger OnValidate()
                            begin
                                NextActionEnabled := LicenseTermsAccepted and OnboardingHelper.IsParticipationInfoValid(TempParticipation);
                            end;
                        }
                        field("VAT Registration No."; TempParticipation."VAT Registration No.")
                        {
                            ShowMandatory = true;

                            trigger OnValidate()
                            begin
                                NextActionEnabled := LicenseTermsAccepted and OnboardingHelper.IsParticipationInfoValid(TempParticipation);
                            end;
                        }
                        field(Address; TempParticipation.Address)
                        {
                            ShowMandatory = true;

                            trigger OnValidate()
                            begin
                                NextActionEnabled := LicenseTermsAccepted and OnboardingHelper.IsParticipationInfoValid(TempParticipation);
                            end;
                        }
                        field("Post Code"; TempParticipation."Post Code")
                        {
                            ShowMandatory = true;

                            trigger OnValidate()
                            begin
                                NextActionEnabled := LicenseTermsAccepted and OnboardingHelper.IsParticipationInfoValid(TempParticipation);
                            end;
                        }
                        group(CountyGroup)
                        {
                            ShowCaption = false;
                            Visible = CountyVisible;
                            field(County; TempParticipation.County)
                            {
                            }
                        }
                        field("Country/Region Code"; TempParticipation."Country/Region Code")
                        {
                            ShowMandatory = true;

                            trigger OnValidate()
                            var
                                FormatAddress: Codeunit "Format Address";
                            begin
                                CountyVisible := FormatAddress.UseCounty(TempParticipation."Country/Region Code");
                                NextActionEnabled := LicenseTermsAccepted and OnboardingHelper.IsParticipationInfoValid(TempParticipation);
                            end;
                        }
                        group(CompanySignatory)
                        {
                            Caption = 'Company Signatory (e.g. CEO)';
                            field("Signatory Name"; TempParticipation."Signatory Name")
                            {
                                ShowMandatory = true;

                                trigger OnValidate()
                                begin
                                    NextActionEnabled := LicenseTermsAccepted and OnboardingHelper.IsParticipationInfoValid(TempParticipation);
                                end;
                            }
                            field("Signatory Email"; TempParticipation."Signatory Email")
                            {
                                ShowMandatory = true;

                                trigger OnValidate()
                                begin
                                    NextActionEnabled := LicenseTermsAccepted and OnboardingHelper.IsParticipationInfoValid(TempParticipation);
                                end;
                            }
                        }
                    }
                    group(LegalCompanyInformation2)
                    {
                        InstructionalText = 'Please verify that all the company details you provided are accurate. This information is essential for Continia to meet its legal obligations, perform its KYC processes and data processing requirements. Inaccurate or insufficient information can delay our verification processes or result in account suspension. If any details change, update the information promptly to avoid service disruptions.';
                        ShowCaption = false;
                    }
                    group(LegalCompanyInformation3)
                    {
                        InstructionalText = 'By continuing, you confirm the accuracy of the above information and accept Continia Software License Terms and Terms of Service.';
                        ShowCaption = false;

                        field(LicenseTerms; LicenseTermsAccepted)
                        {
                            Caption = 'I confirm';
                            ToolTip = 'Specifies your confirmation to the license terms.';

                            trigger OnValidate()
                            begin
                                NextActionEnabled := LicenseTermsAccepted and OnboardingHelper.IsParticipationInfoValid(TempParticipation);
                            end;
                        }
                    }
                }
            }
            group(CompanyContactInformationPage)
            {
                Caption = '';
                Visible = CompanyContactInformationStepVisible;
                group(CompanyContactInformation)
                {
                    Caption = 'Company contact information';
                    Visible = CompanyContactInformationStepVisible;
                    group(CompanyContactInformation1)
                    {
                        InstructionalText = 'Please provide the company contact information.';
                        ShowCaption = false;
                        field(CompanyContactName; TempCompanyContact."Company Name")
                        {
                            ShowMandatory = true;

                            trigger OnValidate()
                            begin
                                SetButtonBehaviourCompanyContactInformation();
                            end;
                        }
                        field(CompanyContactVAT; TempCompanyContact."VAT Registration No.")
                        {
                            ShowMandatory = true;

                            trigger OnValidate()
                            begin
                                TempCompanyContact.Validate("VAT Registration No.");
                                SetButtonBehaviourCompanyContactInformation();
                            end;
                        }
                        field(CompanyContactAddress; TempCompanyContact.Address)
                        {
                            ShowMandatory = true;

                            trigger OnValidate()
                            begin
                                SetButtonBehaviourCompanyContactInformation();
                            end;
                        }
                        field(CompanyContactPostCode; TempCompanyContact."Post Code")
                        {
                            ShowMandatory = true;

                            trigger OnValidate()
                            begin
                                SetButtonBehaviourCompanyContactInformation();
                            end;
                        }
                        group(CompanyContactCountyGroup)
                        {
                            ShowCaption = false;
                            Visible = ContactCountyVisible;
                            field(CompanyContactCounty; TempCompanyContact.County)
                            {
                            }
                        }
                        field(CompanyContactCountryRegion; TempCompanyContact."Country/Region Code")
                        {
                            ShowMandatory = true;

                            trigger OnLookup(var Text: Text): Boolean
                            var
                                FormatAddress: Codeunit "Format Address";
                            begin
                                TempCompanyContact.LookupCountryRegion();
                                TempCompanyContact.Validate("Country/Region Code");
                                ContactCountyVisible := FormatAddress.UseCounty(TempCompanyContact."Country/Region Code");
                            end;

                            trigger OnValidate()
                            var
                                FormatAddress: Codeunit "Format Address";
                            begin
                                TempCompanyContact.Validate("Country/Region Code");
                                ContactCountyVisible := FormatAddress.UseCounty(TempCompanyContact."Country/Region Code");
                                SetButtonBehaviourCompanyContactInformation();
                            end;
                        }
                        group(CompanyContactPerson)
                        {
                            Caption = 'Company Contact Person';
                            field(CompanyContactPersonName; TempCompanyContact."Contact Name")
                            {
                                ShowMandatory = true;

                                trigger OnValidate()
                                begin
                                    SetButtonBehaviourCompanyContactInformation();
                                end;
                            }
                            field(CompanyContactPersonEmail; TempCompanyContact."Contact Email")
                            {
                                ShowMandatory = true;

                                trigger OnValidate()
                                begin
                                    TempCompanyContact.Validate("Contact Email");
                                    SetButtonBehaviourCompanyContactInformation();
                                end;
                            }
                            field(CompanyContactPersonPhoneNo; TempCompanyContact."Contact Phone No.")
                            {
                                ShowMandatory = true;

                                trigger OnValidate()
                                begin
                                    TempCompanyContact.Validate("Contact Phone No.");
                                    SetButtonBehaviourCompanyContactInformation();
                                end;
                            }
                        }
                    }
                }
            }
            group(NetworkDetailsPage)
            {
                Caption = '';
                Visible = NetworkDetailsStepVisible;
                group(NetworkDetails)
                {
                    Caption = 'To register the company in an electronic document network, please provide the following information:';
                    Visible = NetworkDetailsStepVisible;
                    group(NetworkDetails1)
                    {
                        InstructionalText = 'Specify the network you want to be registered as a participant in.';
                        ShowCaption = false;
                    }
                    field(Network; TempParticipation.Network)
                    {
                        trigger OnValidate()
                        begin
                            OnboardingHelper.SetDefaultIdentifierData(TempParticipation, IdentifierTypeDesc);
                        end;
                    }
                    group(NetworkDetails2)
                    {
                        InstructionalText = 'Specify how the company should be identified in the network.';
                        ShowCaption = false;
                    }
                    field(IdentifierTypeDesc; IdentifierTypeDesc)
                    {
                        Caption = 'Identifier Type';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the type of identifier used to identify the company in the network.';

                        trigger OnValidate()
                        begin
                            OnboardingHelper.ValidateIdentifierType(TempParticipation, IdentifierTypeDesc);
                        end;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            exit(OnboardingHelper.LookupIdentifierType(TempParticipation, Text));
                        end;
                    }
                    field(CompanyIdentifierValue; TempParticipation."Identifier Value")
                    {
                        ShowMandatory = true;

                        trigger OnValidate()
                        begin
                            OnboardingHelper.ValidateIdentifierValue(TempParticipation);
                        end;
                    }
                }
                group(NextDocumentTypes)
                {
                    InstructionalText = 'Choose Next to set up the document types you would like to exchange within the network.';
                    ShowCaption = false;
                    Visible = NetworkDetailsStepVisible;
                }
            }
            group(DocumentTypesPage)
            {
                Caption = '';
                Visible = DocumentTypesStepVisible;
                group(DocumentTypes)
                {
                    Caption = 'What types of documents would you like to exchange within the network?';
                    Visible = DocumentTypesStepVisible;
                    group(SalesServiceDocuments)
                    {
                        Caption = 'Sales/Service Documents';
                        field(SendInvoiceCreditMemo; SendInvoiceCreditMemo)
                        {
                            Caption = 'Send Invoice / Credit Memo';
                            ToolTip = 'Specifies whether the company can send invoices and credit memos to other companies in the network.';
                        }
                        field(ReceiveInvoiceResponse; ReceiveInvoiceResponse)
                        {
                            Caption = 'Receive Invoice Response';
                            ToolTip = 'Specifies whether the company can receive invoice responses from other companies in the network.';
                        }
                        field(ReceiveOrder; ReceiveOrder)
                        {
                            Caption = 'Receive Order';
                            ToolTip = 'Specifies whether the company can receive orders from other companies in the network.';
                        }
                        field(SendOrderResponse; SendOrderResponse)
                        {
                            Caption = 'Send Order Response';
                            ToolTip = 'Specifies whether the company can send order responses to other companies in the network.';
                        }
                    }
                    group(PurchaseDocuments)
                    {
                        Caption = 'Purchase Documents';
                        field(ReceiveInvoiceCreditMemo; ReceiveInvoiceCreditMemo)
                        {
                            Caption = 'Receive Invoice / Credit Memo';
                            ToolTip = 'Specifies whether the company can receive invoices and credit memos from other companies in the network.';
                        }
                        field(SendInvoiceResponse; SendInvoiceResponse)
                        {
                            Caption = 'Send Invoice Response';
                            ToolTip = 'Specifies whether the company can send invoice responses to other companies in the network.';
                        }
                        field(SendOrder; SendOrder)
                        {
                            Caption = 'Send Order';
                            ToolTip = 'Specifies whether the company can send orders to other companies in the network.';
                        }
                        field(ReceiveOrderResponse; ReceiveOrderResponse)
                        {
                            Caption = 'Receive Order Response';
                            ToolTip = 'Specifies whether the company can receive order responses from other companies in the network.';
                        }
                    }

                }
            }
            group(AdvancedSetupPage)
            {
                Caption = '';
                Visible = AdvancedSetupStepVisible;
                group(AdvancedSetup)
                {
                    Caption = 'Advanced Setup';
                    Visible = AdvancedSetupStepVisible;
                    group(AdvancedSetup1)
                    {
                        InstructionalText = 'Use the list below to configure the network profiles you want to register.';
                        ShowCaption = false;
                    }
                    part(SelectProfilesPeppol; "Profile Selection") { }
                }
            }
            group(FinalPage)
            {
                Caption = '';
                Visible = FinalStepVisible;
                group("That's it!")
                {
                    Caption = 'That''s it!';
                    Visible = FinalStepVisible and (RunScenario = RunScenario::General);
                    group(FinalPage1)
                    {
                        InstructionalText = 'Choose Finish to submit your registration to join the Continia Delivery Network.';
                        ShowCaption = false;
                    }
                    group(FinalPage2)
                    {
                        InstructionalText = 'Continia will validate the information you have provided and notify you once your registration has been approved. Please note that this is a manual process, which may take 1–2 working days to complete.';
                        ShowCaption = false;
                    }
                    group(FinalPage3)
                    {
                        InstructionalText = 'You can always check the status of your registration on the E-Document External Connection Setup page.';
                        ShowCaption = false;
                    }
                }
                group(ThatsItEdit)
                {
                    Caption = 'That''s it!';
                    Visible = FinalStepVisible and (RunScenario = RunScenario::EditParticipation);
                    group(EditFinalPage1)
                    {
                        InstructionalText = 'Choose Finish to send the new registration information to Continia Delivery Network.';
                        ShowCaption = false;
                    }
                    group(EditFinalPage2)
                    {
                        InstructionalText = 'You can always check the status of your registration on the E-Document External Connection Setup page.';
                        ShowCaption = false;
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionBack)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                ToolTip = 'Go back to the previous page.';
                Visible = BackActionVisible;

                trigger OnAction()
                begin
                    MoveBack(false);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Go to the next page.';
                Visible = NextActionVisible;

                trigger OnAction()
                begin
                    MoveNext(false);
                end;
            }
            action(ActionAdvancedSetup)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advanced Setup';
                Enabled = AdvancedSetupActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Open the list of network profiles to register.';
                Visible = AdvancedSetupActionEnabled;

                trigger OnAction()
                begin
                    MoveStep(false, 1, false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;
                ToolTip = 'Complete the onboarding.';

                trigger OnAction()
                begin
                    FinishAction();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not OnboardingHelper.HasModifyPermissionOnParticipation() then
            Error(MissingSetupPermissionErr);

        case RunScenario of
            RunScenario::General:
                OnboardingHelper.InitializeGeneralScenario(TempCompanyContact, TempParticipation, CountyVisible, ContactCountyVisible, SkipCompanyInformation, IdentifierTypeDesc);
            RunScenario::EditSubscriptionInfo:
                begin
                    OnboardingHelper.GetContactInformation(TempCompanyContact, true);
                    Step := Step::CompanyContactInformation;
                    CurrPage.Caption := EditSubscriptionPageCaptionLbl;
                end;
            RunScenario::EditParticipation:
                begin
                    SetActivatedProfiles();
                    Step := Step::LegalCompanyInformation;
                end;
            else
                Step := Step::Start;
        end;
        EnableControls();
    end;

    local procedure FinishAction()
    begin
        case RunScenario of
            RunScenario::EditSubscriptionInfo:
                if OnboardingHelper.IsCompanyInfoValid(TempCompanyContact) then begin
                    OnboardingHelper.UpdateSubscriptionInfo(TempCompanyContact);
                    CurrPage.Close();
                end;
            RunScenario::EditParticipation:
                begin
                    if not OnboardingHelper.IsSubscribed() then
                        OnboardingHelper.CreateSubscription(TempCompanyContact);

                    OnboardingHelper.UpdateParticipation(TempParticipation);
                    UpdateProfiles();
                    CurrPage.Close();
                end;
            RunScenario::General:
                begin
                    if not SkipCompanyInformation then begin
                        if TempCompanyContact."Partner Id" = '' then
                            TempCompanyContact."Partner Id" := PartnerId;
                        OnboardingHelper.CreateSubscription(TempCompanyContact);
                    end;
                    RegisterParticipation();
                    CurrPage.Close();
                end;
            else
                CurrPage.Close();
        end;
    end;

    local procedure MoveNext(CurrentStepSkipped: Boolean)
    begin
        case RunScenario of
            RunScenario::EditParticipation:
                case Step of
                    Step::LegalCompanyInformation:
                        if not OnboardingHelper.IsSubscribed() then
                            MoveStep(true, 1, CurrentStepSkipped)
                        else
                            MoveStep(false, 4, CurrentStepSkipped);
                    Step::CompanyContactInformation:
                        if not OnboardingHelper.IsSubscribed() then
                            MoveStep(true, 2, CurrentStepSkipped)
                        else
                            MoveStep(false, 3, CurrentStepSkipped);
                    else
                        if (Step = Step::DocumentTypes) and not CurrentStepSkipped then
                            MoveStep(false, 2, CurrentStepSkipped)
                        else
                            MoveStep(false, 1, CurrentStepSkipped);
                end;
            else
                if (Step = Step::DocumentTypes) and not CurrentStepSkipped then
                    MoveStep(false, 2, CurrentStepSkipped)
                else
                    MoveStep(false, 1, CurrentStepSkipped);
        end;
    end;

    local procedure MoveBack(CurrentStepSkipped: Boolean)
    begin
        case RunScenario of
            RunScenario::EditParticipation:
                case Step of
                    Step::LegalCompanyInformation:
                        exit;
                    Step::AdvancedSetup:
                        if not OnboardingHelper.IsSubscribed() then
                            MoveStep(true, 2, CurrentStepSkipped)
                        else
                            MoveStep(true, 4, CurrentStepSkipped);
                    else
                        MoveStep(true, 1, CurrentStepSkipped);
                end;
            else
                MoveStep(true, LastStepsForward, CurrentStepSkipped);
        end;
    end;

    local procedure MoveStep(Backwards: Boolean; Steps: Integer; CurrentStepSkipped: Boolean)
    begin
        OnBeforeMoveStep(Backwards, Steps, CurrentStepSkipped);
        if Backwards then begin
            LastStepsForward := 1;
            Step -= Steps;
        end else begin
            LastStepsForward := Steps;
            Step += Steps;
        end;

        EnableControls();
        OnAfterMoveStep(Backwards);
    end;

    local procedure OnBeforeMoveStep(Backwards: Boolean; Steps: Integer; CurrentStepSkipped: Boolean)
    begin
        if (Step = Step::PartnerDetails) and not Backwards and not CurrentStepSkipped then
            PartnerId := OnboardingHelper.InitializeClient(PartnerUserName, PartnerPassword);

        if (Step = Step::NetworkDetails) then
            if not Backwards and not CurrentStepSkipped then begin
                ValidateIdentifierData();
                InitializeNetworkProfiles();
            end;

        if (Step = Step::AdvancedSetup) and not Backwards and not CurrentStepSkipped then
            ValidateParticipationProfiles();
        if (Step = Step::DocumentTypes) and not Backwards and (Steps = 2) then
            ValidateParticipationProfiles();
        if (Step = Step::DocumentTypes) and (not Backwards) and (not CurrentStepSkipped) then
            PopulateNetworkProfilesByUserSelection();
    end;

    local procedure OnAfterMoveStep(Backwards: Boolean)
    begin
        if Step = Step::PartnerDetails then begin
            if not OnboardingHelper.AreClientCredentialsValid() then
                exit;
            // Skip Step
            if Backwards then
                MoveBack(true)
            else
                MoveNext(true);
        end;

        if Step = Step::NetworkDetails then begin
            ParticipationNetwork := TempParticipation.Network;
            ParticipationIdentifierValue := TempParticipation."Identifier Value";
            if IsNullGuid(TempParticipation."Identifier Type Id") then
                OnboardingHelper.SetDefaultIdentifierData(TempParticipation, IdentifierTypeDesc);
        end;

        if (Step = Step::LegalCompanyInformation) then
            OnboardingHelper.GetNetworkMetadata(true);

        if (Step = Step::CompanyContactInformation) then begin
            if not SkipCompanyInformation then
                exit;

            if Backwards then
                MoveBack(true)
            else
                MoveNext(true);
        end;
    end;

    local procedure EnableControls()
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowStartStep();
            Step::PartnerDetails:
                ShowPartnerDetailsStep();
            Step::LegalCompanyInformation:
                ShowLegalCompanyInformationStep();
            Step::CompanyContactInformation:
                ShowCompanyContactInformationStep();
            Step::NetworkDetails:
                ShowNetworkDetailsStep();
            Step::DocumentTypes:
                ShowDocumentTypesStep();
            Step::AdvancedSetup:
                ShowAdvancedSetupStep();
            Step::Finish:
                ShowFinalStep();
        end;
    end;

    local procedure ShowStartStep()
    begin
        FirstStepVisible := true;
        PartnerDetailsStepVisible := false;
        LegalCompanyInformationStepVisible := false;
        CompanyContactInformationStepVisible := false;
        NetworkDetailsStepVisible := false;
        DocumentTypesStepVisible := false;
        AdvancedSetupStepVisible := false;
        FinalStepVisible := false;

        BackActionEnabled := false;
        NextActionEnabled := true;
        FinishActionEnabled := false;
        AdvancedSetupActionEnabled := false;
    end;

    local procedure ShowPartnerDetailsStep()
    begin
        FirstStepVisible := false;
        PartnerDetailsStepVisible := true;
        LegalCompanyInformationStepVisible := false;
        CompanyContactInformationStepVisible := false;
        NetworkDetailsStepVisible := false;
        DocumentTypesStepVisible := false;
        AdvancedSetupStepVisible := false;
        FinalStepVisible := false;

        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
        AdvancedSetupActionEnabled := false;
    end;

    local procedure ShowLegalCompanyInformationStep()
    begin
        FirstStepVisible := false;
        PartnerDetailsStepVisible := false;
        LegalCompanyInformationStepVisible := true;
        CompanyContactInformationStepVisible := false;
        NetworkDetailsStepVisible := false;
        DocumentTypesStepVisible := false;
        AdvancedSetupStepVisible := false;
        FinalStepVisible := false;

        BackActionEnabled := RunScenario <> RunScenario::EditParticipation;
        NextActionEnabled := LicenseTermsAccepted and OnboardingHelper.IsParticipationInfoValid(TempParticipation);
        FinishActionEnabled := false;
        AdvancedSetupActionEnabled := false;
    end;

    local procedure ShowCompanyContactInformationStep()
    begin
        FirstStepVisible := false;
        PartnerDetailsStepVisible := false;
        LegalCompanyInformationStepVisible := false;
        CompanyContactInformationStepVisible := true;
        NetworkDetailsStepVisible := false;
        DocumentTypesStepVisible := false;
        AdvancedSetupStepVisible := false;
        FinalStepVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := OnboardingHelper.IsCompanyInfoValid(TempCompanyContact);
        FinishActionEnabled := false;
        AdvancedSetupActionEnabled := false;

        if RunScenario = RunScenario::EditSubscriptionInfo then begin
            BackActionVisible := false;
            NextActionVisible := false;
            FinishActionEnabled := OnboardingHelper.IsCompanyInfoValid(TempCompanyContact);
        end
    end;

    local procedure ShowNetworkDetailsStep()
    begin
        FirstStepVisible := false;
        PartnerDetailsStepVisible := false;
        LegalCompanyInformationStepVisible := false;
        CompanyContactInformationStepVisible := false;
        NetworkDetailsStepVisible := true;
        DocumentTypesStepVisible := false;
        AdvancedSetupStepVisible := false;
        FinalStepVisible := false;

        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
        AdvancedSetupActionEnabled := false;
    end;

    local procedure ShowDocumentTypesStep()
    begin
        FirstStepVisible := false;
        PartnerDetailsStepVisible := false;
        LegalCompanyInformationStepVisible := false;
        CompanyContactInformationStepVisible := false;
        NetworkDetailsStepVisible := false;
        DocumentTypesStepVisible := true;
        AdvancedSetupStepVisible := false;
        FinalStepVisible := false;

        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
        AdvancedSetupActionEnabled := true;
    end;

    local procedure ShowAdvancedSetupStep()
    begin
        FirstStepVisible := false;
        PartnerDetailsStepVisible := false;
        LegalCompanyInformationStepVisible := false;
        CompanyContactInformationStepVisible := false;
        NetworkDetailsStepVisible := false;
        DocumentTypesStepVisible := false;
        AdvancedSetupStepVisible := true;
        FinalStepVisible := false;

        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
        AdvancedSetupActionEnabled := false;
    end;

    local procedure ShowFinalStep()
    begin
        FirstStepVisible := false;
        PartnerDetailsStepVisible := false;
        LegalCompanyInformationStepVisible := false;
        CompanyContactInformationStepVisible := false;
        NetworkDetailsStepVisible := false;
        DocumentTypesStepVisible := false;
        AdvancedSetupStepVisible := false;
        FinalStepVisible := true;

        BackActionEnabled := true;
        NextActionEnabled := false;
        FinishActionEnabled := true;
        AdvancedSetupActionEnabled := false;
    end;

    local procedure ResetControls()
    begin
        BackActionEnabled := true;
        NextActionEnabled := true;
        BackActionVisible := true;
        NextActionVisible := true;
        AdvancedSetupActionEnabled := false;

        FirstStepVisible := false;
        PartnerDetailsStepVisible := false;
        LegalCompanyInformationStepVisible := false;
        CompanyContactInformationStepVisible := false;
        NetworkDetailsStepVisible := false;
        DocumentTypesStepVisible := false;
        AdvancedSetupStepVisible := false;
        FinalStepVisible := false;
    end;

    local procedure UpdateProfiles()
    var
        TempActivatedProfiles: Record "Activated Net. Prof." temporary;
    begin
        CurrPage.SelectProfilesPeppol.Page.GetProfileSelection(TempActivatedProfiles);
        OnboardingHelper.UpdateProfiles(TempParticipation, TempActivatedProfiles);
    end;

    local procedure RegisterParticipation()
    var
        TempActivatedProfiles: Record "Activated Net. Prof." temporary;
    begin
        CurrPage.SelectProfilesPeppol.Page.GetProfileSelection(TempActivatedProfiles);
        OnboardingHelper.RegisterParticipation(TempParticipation, TempActivatedProfiles);
    end;

    local procedure InitializeNetworkProfiles()
    var
        TempActivatedProfiles: Record "Activated Net. Prof." temporary;
    begin
        OnboardingHelper.InitializeNetworkProfiles(TempParticipation, TempActivatedProfiles);

        CurrPage.SelectProfilesPeppol.Page.ClearProfileSelections();
        CurrPage.SelectProfilesPeppol.Page.SetProfileSelection(TempActivatedProfiles);
    end;

    local procedure SetActivatedProfiles()
    var
        TempActivatedProfiles: Record "Activated Net. Prof." temporary;
    begin
        OnboardingHelper.GetCurrentActivatedProfiles(TempParticipation, TempActivatedProfiles);

        CurrPage.SelectProfilesPeppol.Page.ClearProfileSelections();
        CurrPage.SelectProfilesPeppol.Page.SetCurrentNetwork(TempParticipation.Network);
        CurrPage.SelectProfilesPeppol.Page.SetProfileSelection(TempActivatedProfiles);
    end;

    local procedure ValidateIdentifierData()
    begin
        TempParticipation.TestField("Identifier Type Id");
        TempParticipation.TestField("Identifier Value");
        OnboardingHelper.ValidateIdentifierValue(TempParticipation);
    end;

    local procedure ValidateParticipationProfiles()
    var
        TempActivatedProfiles: Record "Activated Net. Prof." temporary;
        ApiRequests: Codeunit "Api Requests";
    begin
        CurrPage.SelectProfilesPeppol.Page.GetProfileSelection(TempActivatedProfiles);

        if TempActivatedProfiles.Count = 0 then
            Error(MustChooseAProfileErr);

        // Check if the profiles are not already registered, the function will thrown an error if any profiles are already registered
        ApiRequests.CheckProfilesNotRegistered(TempParticipation);
    end;

    internal procedure SetRunScenario(ParamRunScenario: Enum "Wizard Scenario")
    begin
        RunScenario := ParamRunScenario;
    end;

    internal procedure SetParticipation(ParamParticipation: Record Participation)
    begin
        TempParticipation := ParamParticipation;
        if TempParticipation."Registration Status" in [TempParticipation."Registration Status"::Disabled, TempParticipation."Registration Status"::Rejected, TempParticipation."Registration Status"::Draft] then
            TempParticipation."Registration Status" := TempParticipation."Registration Status"::InProcess; // Reactivate the participation
        TempParticipation.Insert();
    end;

    local procedure SetButtonBehaviourCompanyContactInformation()
    begin
        if RunScenario = RunScenario::EditSubscriptionInfo then begin
            NextActionVisible := false;
            BackActionVisible := false;
            FinishActionEnabled := OnboardingHelper.IsCompanyInfoValid(TempCompanyContact);
        end else
            NextActionEnabled := OnboardingHelper.IsCompanyInfoValid(TempCompanyContact);
    end;

    local procedure PopulateNetworkProfilesByUserSelection()
    var
        TempActivatedProfiles: Record "Activated Net. Prof." temporary;
    begin
        TempActivatedProfiles.DeleteAll();

        GetSelectedNetworksProfiles(TempActivatedProfiles);
        CurrPage.SelectProfilesPeppol.Page.SetCurrentNetwork(TempParticipation.Network);
        CurrPage.SelectProfilesPeppol.Page.ClearProfileSelections();
        CurrPage.SelectProfilesPeppol.Page.SetProfileSelection(TempActivatedProfiles);
    end;

    local procedure GetSelectedNetworksProfiles(var ActivatedProfiles: Record "Activated Net. Prof." temporary)
    var
        ProfileDirection: Enum "Profile Direction";
    begin
        if SendInvoiceCreditMemo or ReceiveInvoiceCreditMemo then
            OnboardingHelper.AddInvoiceCreditMemoProfiles(TempParticipation, GetNetworkProfileDirection(SendInvoiceCreditMemo, ReceiveInvoiceCreditMemo), ActivatedProfiles);

        if SendInvoiceResponse or ReceiveInvoiceResponse then begin
            case TempParticipation.Network of
                TempParticipation.Network::Peppol:
                    ProfileDirection := GetNetworkProfileDirection(SendInvoiceResponse, ReceiveInvoiceResponse);
                TempParticipation.Network::Nemhandel:
                    ProfileDirection := GetNetworkProfileDirection(SendInvoiceCreditMemo, ReceiveInvoiceCreditMemo);
            end;
            OnboardingHelper.AddInvoiceResponseProfiles(TempParticipation, ProfileDirection, ActivatedProfiles);
        end;

        if (SendOrder or ReceiveOrder) and (not (SendOrderResponse or ReceiveOrderResponse)) then
            OnboardingHelper.AddOrderOnlyProfiles(TempParticipation, GetNetworkProfileDirection(SendOrder, ReceiveOrder), ActivatedProfiles);

        if (SendOrder or ReceiveOrder) and (SendOrderResponse or ReceiveInvoiceResponse) then
            OnboardingHelper.AddOrderProfiles(TempParticipation, GetNetworkProfileDirection(SendOrder, ReceiveOrder), ActivatedProfiles);

        if SendOrderResponse or ReceiveOrderResponse then
            OnboardingHelper.AddOrderResponseProfiles(TempParticipation, GetNetworkProfileDirection(SendOrderResponse, ReceiveOrderResponse), ActivatedProfiles);

        if (SendInvoiceCreditMemo or ReceiveInvoiceCreditMemo) and (SendOrder or ReceiveOrder) then
            OnboardingHelper.AddInvoiceAndOrderProfiles(TempParticipation, GetNetworkProfileDirection(SendInvoiceCreditMemo or SendOrder, ReceiveInvoiceCreditMemo or ReceiveOrder), ActivatedProfiles);
    end;

    local procedure GetNetworkProfileDirection(Send: Boolean; Receive: Boolean): Enum "Profile Direction"
    begin
        case true of
            Receive and Send:
                exit("Profile Direction"::Both);
            Receive and (not Send):
                exit("Profile Direction"::Inbound);
            Send and (not Receive):
                exit("Profile Direction"::Outbound);
        end;
    end;

    var
        TempCompanyContact: Record Participation temporary;
        TempParticipation: Record Participation temporary;
        OnboardingHelper: Codeunit "Onboarding Helper";
        AdvancedSetupActionEnabled, BackActionEnabled, FinishActionEnabled, NextActionEnabled : Boolean;
        AdvancedSetupStepVisible, BackActionVisible, CompanyContactInformationStepVisible, DocumentTypesStepVisible, FinalStepVisible, FirstStepVisible, LegalCompanyInformationStepVisible, NetworkDetailsStepVisible, NextActionVisible, PartnerDetailsStepVisible : Boolean;
        ContactCountyVisible, CountyVisible : Boolean;
        LicenseTermsAccepted: Boolean;
        ReceiveInvoiceCreditMemo, ReceiveInvoiceResponse, ReceiveOrder, ReceiveOrderResponse, SendInvoiceCreditMemo, SendInvoiceResponse, SendOrder, SendOrderResponse : Boolean;
        SkipCompanyInformation: Boolean;
        ParticipationNetwork: Enum "E-Delivery Network";
        RunScenario: Enum "Wizard Scenario";
        LastStepsForward: Integer;
        EditSubscriptionPageCaptionLbl: Label 'Company Contact Information';
        MustChooseAProfileErr: Label 'You must select one or more network profiles.';
        NoPasswordErr: Label 'Please enter a password.';
        PartnerRegAsNewTxt: Label 'Not a partner?';
        PartnerReqPwdTxt: Label 'Forgot the password?';
        MissingSetupPermissionErr: Label 'You do not have permissions to modify or create a participation';
        Step: Option Start,PartnerDetails,LegalCompanyInformation,CompanyContactInformation,NetworkDetails,DocumentTypes,AdvancedSetup,Finish;
        IdentifierTypeDesc: Text;
        ParticipationIdentifierValue: Text;
        [NonDebuggable]
        PartnerPassword: Text;
        [NonDebuggable]
        PartnerUserName: Text;
        [NonDebuggable]
        PartnerId: Code[20];

}