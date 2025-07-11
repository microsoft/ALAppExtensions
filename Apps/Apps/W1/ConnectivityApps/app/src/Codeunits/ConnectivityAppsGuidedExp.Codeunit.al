// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

codeunit 20356 "Connectivity Apps Guided Exp."
{
    Access = Internal;

    var
        BankingAppsShortTitleTxt: Label 'Connect to banks';
        BankingAppsTitleTxt: Label 'Streamline your bookkeeping';
        BankingAppsDescriptionTxt: Label 'These applications let you import bank transactions to easily reconcile bank accounts and transfer payments from Business Central.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterGuidedExperienceItem', '', false, false)]
    local procedure OnRegisterGuidedExperienceItem()
    var
        Company: Record Company;
        SignupContextValues: Record "Signup Context Values";
        ConnectivityApps: Codeunit "Connectivity Apps";
        GuidedExperience: Codeunit "Guided Experience";
        ConnectivityAppsCategory: Enum "Connectivity Apps Category";
    begin
        if SignupContextValues.Get() then
            if not (SignupContextValues."Signup Context" in [SignupContextValues."Signup Context"::" ", SignupContextValues."Signup Context"::"Viral Signup"]) then
                exit;

        Company.Get(CompanyName());
        if ConnectivityApps.IsConnectivityAppsAvailableForGeoAndCategory(ConnectivityAppsCategory::Banking) then begin
            GuidedExperience.InsertApplicationFeature(BankingAppsTitleTxt, BankingAppsShortTitleTxt, BankingAppsDescriptionTxt, 2, ObjectType::Page, Page::"Banking Apps");

            if Company."Evaluation Company" then
                InitializeChecklistForEvaluationCompanies()
        end;
    end;

    procedure InitializeChecklistForEvaluationCompanies()
    var
        TempAllProfileBusinessManagerEval: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperienceType: Enum "Guided Experience Type";
    begin
        // Business Manager
        GetRolesForEvaluationCompany(TempAllProfileBusinessManagerEval);
        Checklist.Insert(GuidedExperienceType::"Application Feature", ObjectType::Page, Page::"Banking Apps", 5000, TempAllProfileBusinessManagerEval, true);
    end;

    local procedure GetRolesForEvaluationCompany(var TempAllProfile: Record "All Profile" temporary)
    begin
        AddRoleToList(TempAllProfile, 'Business Manager Evaluation');
    end;

    local procedure AddRoleToList(var TempAllProfile: Record "All Profile" temporary; ProfileID: Code[30])
    var
        AllProfile: Record "All Profile";
    begin
        AllProfile.SetRange("Profile ID", ProfileID);
        AddRoleToList(AllProfile, TempAllProfile);
    end;

    local procedure AddRoleToList(var AllProfile: Record "All Profile"; var TempAllProfile: Record "All Profile" temporary)
    begin
        if AllProfile.FindFirst() then begin
            TempAllProfile.TransferFields(AllProfile);
            TempAllProfile.Insert();
        end;
    end;
}
