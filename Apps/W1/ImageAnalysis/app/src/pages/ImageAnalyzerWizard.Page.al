namespace Microsoft.Utility.ImageAnalysis;

using System.Utilities;
using System.Environment;
using Microsoft.Inventory.Item;
#if not CLEAN25
using Microsoft.CRM.Contact;
#endif
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 2029 "Image Analyzer Wizard"
{
    PageType = NavigatePage;
    Caption = 'Image Analyzer assisted setup guide';
    layout
    {
        area(content)
        {
            group(MediaStandard)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible;
                field("MediaResourcesStandard Media Reference"; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }

            group(FirstPage)
            {

                Caption = '';
                Visible = FirstStepVisible;
                group("Welcome to the Wizard")
                {
                    Caption = 'Welcome';
                    Visible = FirstStepVisible;
                    group(TourGroup)
                    {
                        Caption = '';
                        InstructionalText = 'Image Analyzer uses the Computer Vision API from Microsoft Cognitive Services to detect attributes in the images you upload for items and contact persons, so it''s easy for you to assign them. For items, Image Analyzer finds attributes like type and color. For contact persons, it detects age and gender.';
                        Visible = FirstStepVisible;

                        group(LearnMoreLinkGroup)
                        {
                            Caption = '';

                            field(CanLearnMore; YouCanLearnMoreTxt)
                            {
                                ApplicationArea = Basic, Suite;
                                ShowCaption = false;
                                Editable = false;
                                MultiLine = true;
                            }

                            field(Link; LearnMoreStatementLinkTxt)
                            {
                                ApplicationArea = Basic, Suite;
                                ShowCaption = false;
                                Editable = false;

                                trigger OnDrillDown()
                                begin
                                    Hyperlink(LearnMoreLinkTxt);
                                end;
                            }

                            field(CognitiveServicesLink; CognitiveServicesLinkTxt)
                            {
                                ApplicationArea = Basic, Suite;
                                ShowCaption = false;
                                Editable = false;

                                trigger OnDrillDown()
                                begin
                                    Hyperlink(CognitiveServicesLinkLinkTxt);
                                end;
                            }

                            field(PrivacyStatementLink; PrivacyStatementLinkTxt)
                            {
                                ApplicationArea = Basic, Suite;
                                ShowCaption = false;
                                Editable = false;

                                trigger OnDrillDown()
                                begin
                                    Hyperlink(PrivacyStatementLinkLinkTxt);
                                end;
                            }

                        }
                    }
                }
            }

            group(SecondPage)
            {

                Caption = '';
                Visible = SecondStepVisible;
                group("Terms of use")
                {
                    Caption = 'Terms of Use';
                    Visible = SecondStepVisible;
                    field(ConsentPart; ConsentTxt)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;
                        MultiLine = true;
                    }

                    field(ImageAnalyzerDocumentation; ImageAnalyzerDocumentationTxt)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            Hyperlink(ImageAnalyzerDocumentationLinkTxt);
                        end;
                    }

                    field(TermsPart; TermsPartTxt)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;
                        MultiLine = true;
                    }

                    field(TermsPartLink; OnlineServicesTermLinkTxt)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            Hyperlink(OnlineServicesTermLinkLinkTxt);
                        end;
                    }

                    field(Space; ' ')
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;
                        MultiLine = true;
                    }

                    field(EnableFeature; IsFeatureEnabled)
                    {
                        ApplicationArea = Basic, Suite;
                        MultiLine = true;
                        Editable = true;
                        Caption = 'I understand and accept these terms';
                        ToolTip = 'Specifies if the feature is enabled.';

                        trigger OnValidate()
                        begin
                            ShowSecondStep();
                        end;
                    }
                }
            }

            group(FinalPage)
            {
                Caption = '';
                Visible = FinalStepVisible;

                group("That's it!")
                {
                    Caption = 'That''s it!';

                    group(ChooseFinishGroup)
                    {
                        Caption = '';
                        Visible = true;
                        field(ChooseFinish; ChooseFinishTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                            Editable = false;
                            MultiLine = true;
                        }
                    }

                    group(HowToGroup)
                    {
                        Caption = '';
                        Visible = true;

                        field(HowToPart1; HowToPart1Txt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                            Editable = false;
                            MultiLine = true;
                        }

                        field(HowToPart2; HowToPart2Txt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                            Editable = false;
                            MultiLine = true;
                        }
                    }

                    group(AnalyzePicture)
                    {
                        Caption = '';
                        Visible = HasPicture;

                        field(HowTo2; WantToAnalyzeTheCurrentPictureQst)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                            Editable = false;
                            MultiLine = true;
                        }

                        field(AnalyzePictureOnFinish; AnalyzePictureOnFinishSwitch)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = true;
                            Editable = true;
                            Caption = 'Analyze current picture';
                            ToolTip = 'Start analysis of the current picture.';
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Visible = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(false);
                end;
            }

            action(ActionFinishAndEnable)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Finish';
                Enabled = FinalStepVisible;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                begin
                    FinishAndEnableAction();
                end;
            }
        }
    }

    trigger OnInit()
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage()
    begin
        Step := Step::Start;
        EnableControls();

        if IsSetItemToFill then
            HasPicture := ItemToFill.Picture.Count() = 1;

#if not CLEAN25
        if IsSetContactToFill then
            HasPicture := (ContactToFill.Type = ContactToFill.Type::Person) and (ContactToFill.Image.HasValue());
#endif
    end;

    var
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesStandard: Record "Media Resources";
        ItemToFill: Record Item;
#if not CLEAN25
        ContactToFill: Record Contact;
#endif
        Step: Option Start,Second,Finish;
        TopBannerVisible: Boolean;
        FirstStepVisible: Boolean;
        SecondStepVisible: Boolean;
        FinalStepVisible: Boolean;
        BackActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        LearnMoreStatementLinkTxt: Label 'Computer Vision API documentation';
        LearnMoreLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=848400';
        YouCanLearnMoreTxt: Label 'To learn more about Cognitive Services and the Computer Vision API, see the documentation.';
        ConsentTxt: Label 'By enabling the Image Analyzer extension you consent to sharing your data with an external system. For more information, see the documentation.';
        ImageAnalyzerDocumentationTxt: Label 'Image Analyzer technical documentation';
        ImageAnalyzerDocumentationLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=850308';
        PrivacyStatementLinkTxt: Label 'Privacy Statement';
        PrivacyStatementLinkLinkTxt: Label 'https://go.microsoft.com/fwlink/?LinkId=724009';
        ChooseFinishTxt: Label 'Choose ''Finish'' to enable Image Analyzer.';
        HowToPart1Txt: Label 'Image Analyzer automatically detects attributes when you add an image to an item or contact person.';
        HowToPart2Txt: Label 'To analyze images you''ve already uploaded, go to the item or contact person card, and choose the ''Analyze Picture'' action.';
        TermsPartTxt: Label 'Your use of the Image Analyzer may be subject to the additional licensing terms in the Microsoft Cognitive Services section of the Online Services Terms.';
        OnlineServicesTermLinkLinkTxt: Label 'https://www.microsoft.com/en-us/licensing/product-licensing/products.aspx', Locked = true;
        OnlineServicesTermLinkTxt: Label 'Online Services Terms (OST)';
        CognitiveServicesLinkLinkTxt: Label 'http://go.microsoft.com/fwlink/?LinkID=829046', Locked = true;
        CognitiveServicesLinkTxt: Label 'Microsoft Cognitive Services';
        WantToAnalyzeTheCurrentPictureQst: Label 'An image has been added to the chosen item or contact. Want to analyze the image, right after you enable Image Analyzer?';
#if not CLEAN25
        IsSetContactToFill: Boolean;
#endif
        IsSetItemToFill: Boolean;
        AnalyzePictureOnFinishSwitch: Boolean;
        HasPicture: Boolean;
        IsFeatureEnabled: Boolean;

    local procedure EnableControls()
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowStartStep();

            Step::Second:
                ShowSecondStep();

            Step::Finish:
                ShowFinalStep();
        END;
    end;

    local procedure NextStep(Backwards: Boolean)
    begin

        if Backwards then
            Step := Step - 1
        ELSE
            Step := Step + 1;

        EnableControls();
    end;

    local procedure FinishAndEnableAction()
    var
        ItemAttrPopulate: Codeunit "Item Attr Populate";
#if not CLEAN25
        ContactPictureAnalyze: Codeunit "Contact Picture Analyze";
#endif
        ItemAttrPopManagement: Codeunit "Image Analyzer Ext. Mgt.";
        ImageAnalyzerConsentProvidedLbl: Label 'Image Analyzer - consent provided by UserSecurityId %1.', Locked = true;
    begin
        ItemAttrPopManagement.HandleSetupAndEnable();

        if not AnalyzePictureOnFinishSwitch then begin
            CurrPage.Close();
            exit;
        end;

        if IsSetItemToFill then
            if ItemAttrPopulate.AnalyzePicture(ItemToFill) then
                CurrPage.Close();
#if not CLEAN25
        if IsSetContactToFill then
            if ContactPictureAnalyze.AnalyzePicture(ContactToFill) then
                CurrPage.Close();
#endif
        Session.LogAuditMessage(StrSubstNo(ImageAnalyzerConsentProvidedLbl, UserSecurityId()), SecurityOperationResult::Success, AuditCategory::ApplicationManagement, 4, 0);
    end;

    local procedure ShowStartStep()
    begin
        FirstStepVisible := true;
        SecondStepVisible := false;
        BackActionEnabled := false;
    end;

    local procedure ShowSecondStep()
    begin
        FirstStepVisible := false;
        SecondStepVisible := true;
        BackActionEnabled := true;
        NextActionEnabled := IsFeatureEnabled;
    end;

    local procedure ShowFinalStep()
    begin
        FinalStepVisible := true;
        BackActionEnabled := true;
        NextActionEnabled := false;
    end;

    local procedure ResetControls()
    begin
        BackActionEnabled := true;
        NextActionEnabled := true;

        FirstStepVisible := false;
        SecondStepVisible := false;
        FinalStepVisible := false;
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.Get('ImageAnalysis-Setup-NoText.png', Format(CurrentClientType())) then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") then
                TopBannerVisible := MediaResourcesStandard."Media Reference".HasValue();
    end;

    procedure SetItem(Item: Record Item)
    begin
        ItemToFill := Item;
        IsSetItemToFill := true;
    end;

#if not CLEAN25
    [Obsolete('Image analyzer for contacts is being removed.', '25.0')]
    procedure SetContact(Contact: Record Contact)
    begin
        ContactToFill := Contact;
        IsSetContactToFill := true;
    end;
#endif
}

