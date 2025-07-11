namespace Microsoft.Integration.Shopify;

using System.Environment;
using System.Environment.Configuration;
using System.Globalization;
using System.Reflection;
using System.Telemetry;
using Microsoft.Finance.RoleCenters;
using System.Media;

// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A codeunit for setting up Shopify guided experience.
/// </summary>
codeunit 30201 "Shpfy Guided Experience"
{
    Access = Internal;

    var
        ShopifyContextValueTxt: Label 'shopify', Locked = true;
        SignupContextKeyNameTxt: Label 'name', Locked = true;
        ShopifyShopKeyNameTxt: Label 'shop', Locked = true;
        ShopifyShopUrlMismatchErr: Label 'The Signup Context and shopify url don''t match.';
        BusinessCentralLovesShopifyShortTitleTxt: Label 'Business Central loves Shopify';
        BusinessCentralLovesShopifyTitleTxt: Label 'Grow your business with Business Central';
        BusinessCentralLovesShopifyDescriptionTxt: Label 'Business Central includes an integration to Shopify that will make your online trade a breeze. See this video to learn how.';
        BusinessCentralLovesShopifyVideoLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2198401', Locked = true;
        ConnectYourShopEvalTitleTxt: Label 'Connect to Shopify and import data';
        ConnectYourShopEvalShortTitleTxt: Label 'Connect your shop';
        ConnectYourShopEvalDescriptionTxt: Label 'Check out how easy it is to set up the connection to Shopify. Here we connect and import your shop data. Your live shop will be untouched. Try it out!';
        ConnectYourShopTitleTxt: Label 'Get started with Shopify';
        ConnectYourShopShortTitleTxt: Label 'Connect your shop';
        ConnectYourShopDescriptionTxt: Label 'Easily set basic connection and synchronization settings. You can control how data flows to and from your shop on Shopify.';
        ReadyToGoLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2198402', Locked = true;
        CompanyDetailsTitleTxt: Label 'Check your company details';
        CompanyDetailsShortTitleTxt: Label 'Company details';
        CompanyDetailsDescriptionTxt: Label 'Check that we got your company name and other basic information right.';
        LearnBusinessCentralTitleTxt: Label 'Learn Business Central on your own';
        LearnBusinessCentralShortTitleTxt: Label 'Learn Business Central';
        LearnBusinessCentralDescriptionTxt: Label 'We have gathered a lot of great resources for you to start learning Business Central. Start your learning journey here.';
        LearnBusinessCentralLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2198400', Locked = true;
        TakeTheNextStepTitleTxt: Label 'Ready to buy or need help?';
        TakeTheNextStepShortTitleTxt: Label 'Take the next step';
        TakeTheNextStepDescriptionTxt: Label 'If you are ready to buy, you can find a Business Central reseller here. If you have already licensed a subscription you can also find help for more setup here.';
        TakeTheNextStepLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2198403', Locked = true;
        ItemListShortTitleTxt: Label 'View imported products';
        ItemListTitleTxt: Label 'View imported data from your store';
        ItemListDescriptionTxt: Label 'Products you import from Shopify are called items in Business Central. You can find them on the Items page. When you''re using a demo company, you can import up to 25 items.';


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', false, false)]
    local procedure InitializeChecklistOnAfterLogIn()
    var
        Company: Record Company;
        SignupContextValues: Record "Signup Context Values";
        Checklist: Codeunit Checklist;
        SystemInitialization: Codeunit "System Initialization";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;

        if not Checklist.ShouldInitializeChecklist(false) then
            exit;

        if not Company.Get(CompanyName()) then
            exit;

        if not SystemInitialization.ShouldCheckSignupContext() then
            exit;

        if not SignupContextValues.Get() then
            exit;

        if not (SignupContextValues."Signup Context" = SignupContextValues."Signup Context"::Shopify) then
            exit;

        Checklist.InitializeGuidedExperienceItems();

        if Company."Evaluation Company" then
            InitializeChecklistForEvaluationCompanies()
        else
            InitializeChecklistForNonEvaluationCompanies();

        Checklist.MarkChecklistSetupAsDone();
    end;

    local procedure InitializeChecklistForEvaluationCompanies()
    var
        TempAllProfileBusinessManagerEval: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        TenantLicenseState: Codeunit "Tenant License State";
    begin
        // CRONUS
        GetRolesForEvaluationCompany(TempAllProfileBusinessManagerEval);
        Checklist.Insert("Guided Experience Type"::Video, BusinessCentralLovesShopifyVideoLinkTxt, 1000, TempAllProfileBusinessManagerEval, true);
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"Shpfy Connector Guide", 2000, TempAllProfileBusinessManagerEval, true);
        Checklist.Insert("Guided Experience Type"::"Application Feature", ObjectType::Codeunit, Codeunit::"Shpfy Checklist Item List", 3000, TempAllProfileBusinessManagerEval, true);
        if not TenantLicenseState.IsPaidMode() then
            Checklist.Insert("Guided Experience Type"::Learn, ReadyToGoLinkTxt, 4000, TempAllProfileBusinessManagerEval, true);
    end;

    local procedure InitializeChecklistForNonEvaluationCompanies()
    var
        TempAllProfileBusinessManager: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        TenantLicenseState: Codeunit "Tenant License State";
    begin
        // My Company   
        GetBussinesManagerRole(TempAllProfileBusinessManager);
        Checklist.Insert("Guided Experience Type"::Tour, ObjectType::Page, Page::"Business Manager Role Center", 1000, TempAllProfileBusinessManager, true);
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"Shpfy Connector Guide", 2000, TempAllProfileBusinessManager, true);
        Checklist.Insert("Guided Experience Type"::"Application Feature", ObjectType::Codeunit, Codeunit::"Company Details Checklist Item", 3000, TempAllProfileBusinessManager, false);
        Checklist.Insert("Guided Experience Type"::Learn, LearnBusinessCentralLinkTxt, 4000, TempAllProfileBusinessManager, true);
        if not TenantLicenseState.IsPaidMode() then
            Checklist.Insert("Guided Experience Type"::Learn, TakeTheNextStepLinkTxt, 5000, TempAllProfileBusinessManager, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', false, false)]
    local procedure OnRegisterAssistedSetup()
    begin
        OnRegisterGuidedExperienceItem();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterGuidedExperienceItem', '', false, false)]
    local procedure OnRegisterGuidedExperienceItem()
    var
        Company: Record Company;
        GuidedExperience: Codeunit "Guided Experience";
        Language: Codeunit Language;
        CurrentGlobalLanguage: Integer;
    begin
        Company.Get(CompanyName());
        GuidedExperience.InsertVideo(BusinessCentralLovesShopifyTitleTxt, BusinessCentralLovesShopifyShortTitleTxt,
            BusinessCentralLovesShopifyDescriptionTxt, 2, BusinessCentralLovesShopifyVideoLinkTxt, "Video Category"::GettingStarted);

        if Company."Evaluation Company" then begin
            GuidedExperience.InsertAssistedSetup(ConnectYourShopEvalTitleTxt, ConnectYourShopEvalShortTitleTxt, ConnectYourShopEvalDescriptionTxt, 0, ObjectType::Page, Page::"Shpfy Connector Guide", "Assisted Setup Group"::Connect, '', "Video Category"::Connect, '', true);
            CurrentGlobalLanguage := GlobalLanguage();
            GlobalLanguage(Language.GetDefaultApplicationLanguageId());
            GuidedExperience.AddTranslationForSetupObjectTitle("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"Shpfy Connector Guide", Language.GetDefaultApplicationLanguageId(), ConnectYourShopEvalTitleTxt);
            GuidedExperience.AddTranslationForSetupObjectDescription("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"Shpfy Connector Guide", Language.GetDefaultApplicationLanguageId(), ConnectYourShopEvalDescriptionTxt);
            GlobalLanguage(CurrentGlobalLanguage);
            GuidedExperience.InsertApplicationFeature(ItemListTitleTxt, ItemListShortTitleTxt, ItemListDescriptionTxt, 2, ObjectType::Codeunit, Codeunit::"Shpfy Checklist Item List");
        end else begin
            GuidedExperience.InsertAssistedSetup(ConnectYourShopTitleTxt, ConnectYourShopShortTitleTxt, ConnectYourShopDescriptionTxt, 0, ObjectType::Page, Page::"Shpfy Connector Guide", "Assisted Setup Group"::Connect, '', "Video Category"::Connect, '', true);
            CurrentGlobalLanguage := GlobalLanguage();
            GlobalLanguage(Language.GetDefaultApplicationLanguageId());
            GuidedExperience.AddTranslationForSetupObjectTitle("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"Shpfy Connector Guide", Language.GetDefaultApplicationLanguageId(), ConnectYourShopTitleTxt);
            GuidedExperience.AddTranslationForSetupObjectDescription("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"Shpfy Connector Guide", Language.GetDefaultApplicationLanguageId(), ConnectYourShopDescriptionTxt);
            GlobalLanguage(CurrentGlobalLanguage);
        end;

        GuidedExperience.InsertApplicationFeature(CompanyDetailsTitleTxt, CompanyDetailsShortTitleTxt, CompanyDetailsDescriptionTxt, 2, ObjectType::Codeunit, Codeunit::"Company Details Checklist Item");
        CurrentGlobalLanguage := GlobalLanguage();
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());
        GuidedExperience.AddTranslationForSetupObjectTitle("Guided Experience Type"::"Application Feature", ObjectType::Codeunit, Codeunit::"Company Details Checklist Item", Language.GetDefaultApplicationLanguageId(), CompanyDetailsTitleTxt);
        GuidedExperience.AddTranslationForSetupObjectDescription("Guided Experience Type"::"Application Feature", ObjectType::Codeunit, Codeunit::"Company Details Checklist Item", Language.GetDefaultApplicationLanguageId(), CompanyDetailsDescriptionTxt);
        GlobalLanguage(CurrentGlobalLanguage);

        GuidedExperience.InsertLearnLink(LearnBusinessCentralTitleTxt, LearnBusinessCentralShortTitleTxt, LearnBusinessCentralDescriptionTxt, 0, LearnBusinessCentralLinkTxt);
        GuidedExperience.InsertLearnLink(TakeTheNextStepTitleTxt, TakeTheNextStepShortTitleTxt, TakeTheNextStepDescriptionTxt, 0, TakeTheNextStepLinkTxt);
    end;

    local procedure GetRolesForEvaluationCompany(var TempAllProfile: Record "All Profile" temporary)
    begin
        AddRoleToList(TempAllProfile, 'Business Manager Evaluation');
    end;

    local procedure GetBussinesManagerRole(var TempAllProfile: Record "All Profile" temporary)
    begin
        AddRoleToList(TempAllProfile, Page::"Business Manager Role Center");
    end;

    local procedure AddRoleToList(var TempAllProfile: Record "All Profile" temporary; ProfileID: Code[30])
    var
        AllProfile: Record "All Profile";
    begin
        AllProfile.SetRange("Profile ID", ProfileID);
        AddRoleToList(AllProfile, TempAllProfile);
    end;

    local procedure AddRoleToList(var TempAllProfile: Record "All Profile" temporary; RoleCenterID: Integer)
    var
        AllProfile: Record "All Profile";
    begin
        AllProfile.SetRange("Role Center ID", RoleCenterID);
        AddRoleToList(AllProfile, TempAllProfile);
    end;

    local procedure AddRoleToList(var AllProfile: Record "All Profile"; var TempAllProfile: Record "All Profile" temporary)
    begin
        if AllProfile.FindFirst() then begin
            TempAllProfile.TransferFields(AllProfile);
            TempAllProfile.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnSetSignupContext', '', false, false)]
    local procedure SetShopifyContextOnSetSignupContext(SignupContext: Record "Signup Context"; var SignupContextValues: Record "Signup Context Values")
    var
        AuthenticationMgt: Codeunit "Shpfy Authentication Mgt.";
        ShopifyHostname: Text[250];
    begin
        if not SignupContext.Get(SignupContextKeyNameTxt) then
            exit;

        if not (LowerCase(SignupContext.Value) = ShopifyContextValueTxt) then
            exit;

        Clear(SignupContextValues);
        if not SignupContextValues.IsEmpty() then
            exit;

        SignupContextValues."Signup Context" := SignupContextValues."Signup Context"::Shopify;
        if SignupContext.Get(ShopifyShopKeyNameTxt) then begin
            ShopifyHostname := CopyStr(SignupContext.Value, 1, MaxStrLen(SignupContextValues."Shpfy Signup Shop Url"));
            if AuthenticationMgt.IsValidHostName(ShopifyHostname) then
                SignupContextValues."Shpfy Signup Shop Url" := ShopifyHostname;
        end;
        SignupContextValues.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Signup Context Values", 'OnAfterInsertEvent', '', false, false)]
    local procedure VerifyShopUrlOnAfterInsertSignupContext(var Rec: Record "Signup Context Values")
    var
        SignupContext: Record "Signup Context";
        Telemetry: Codeunit Telemetry;
    begin
        if Rec."Signup Context" = Rec."Signup Context"::Shopify then begin
            if SignupContext.Get(ShopifyShopKeyNameTxt) then;
            if Rec."Shpfy Signup Shop Url" <> CopyStr(SignupContext.Value, 1, MaxStrLen(Rec."Shpfy Signup Shop Url")) then begin
                Telemetry.LogMessage('0000HOH', ShopifyShopUrlMismatchErr, Verbosity::Error, DataClassification::SystemMetadata);
                Error(ShopifyShopUrlMismatchErr);
            end;
        end;
    end;
}