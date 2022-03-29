// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 2028 "Contact Picture Analyze"
{
    var
        ImageAnalyzerExtMgt: Codeunit "Image Analyzer Ext. Mgt.";
        ImageAnalyzerContactQuestionnaireDescriptionTxt: Label 'Attributes detected by Image Analyzer.', Comment = 'Should be less than or equal to 50 characters.', MaxLength = 50;
        GenderProfileQuestionTxt: Label 'Detected gender', MaxLength = 250;
        AgeProfileQuestionTxt: Label 'Detected age', MaxLength = 250;
        MaleTok: Label 'Male', MaxLength = 250;
        FemaleTok: Label 'Female', MaxLength = 250;
        ImageAnalyzerQuestionnaireCodeTxt: Label 'IMAGE ANALYZER', Comment = 'Should be less than or equal to 20 characters.', MaxLength = 20;
        ProfileQuestionnairePopulatedTxt: Label 'Good work! You can view the results of the image analysis on the Profile Questionnaire FastTab.';

    [EventSubscriber(ObjectType::Page, PAGE::"Contact Picture", 'OnAfterActionEvent', 'ImportPicture', false, false)]
    procedure OnAfterImportPictureAnalyzePicture(var Rec: Record Contact)
    begin
        AnalyzePicture(Rec);
    end;

    procedure AnalyzePicture(var ContactRec: Record Contact): Boolean
    var
        ImageAnalysisResult: Codeunit "Image Analysis Result";
        AnalysisType: Option Tags,Faces,Color;
    begin
        if ImageAnalyzerExtMgt.IsSaasAndCannotUseRelationshipMgmt() then
            exit(false);

        if not (ContactRec.Type = ContactRec.Type::Person) then
            exit(false);

        if not ContactRec.Image.HasValue() then
            exit(false);

        if not ImageAnalyzerExtMgt.AnalyzePicture(ContactRec.Image.MediaId(), ImageAnalysisResult, AnalysisType::Faces) then
            exit(false);

        PopulateContact(ContactRec, ImageAnalysisResult);
        exit(true);
    end;

    procedure PopulateContact(var Contact: Record Contact; ImageAnalysisResult: Codeunit "Image Analysis Result")
    var
        CortanaProfileQuestionnaireHeader: Record "Profile Questionnaire Header";
        ContactProfileAnswerToDelete: Record "Contact Profile Answer";
    begin
        GetAndCreateCortanaQuestionnaireIfNeeded(CortanaProfileQuestionnaireHeader);

        //clear existing cortana answers for this contact
        ContactProfileAnswerToDelete.SetRange("Contact No.", Contact."No.");
        ContactProfileAnswerToDelete.SetRange("Profile Questionnaire Code", CortanaProfileQuestionnaireHeader.Code);
        ContactProfileAnswerToDelete.DeleteAll();

        if ImageAnalysisResult.FaceCount() <> 1 then
            exit; // if 0, we have nothing to do, if more than 1 we don't know what face to use

        if PopulateContactGender(Contact, ImageAnalysisResult, CortanaProfileQuestionnaireHeader) or
           PopulateContactAge(Contact, ImageAnalysisResult, CortanaProfileQuestionnaireHeader)
        then
            if ImageAnalyzerExtMgt.IsInformationNotificationEnabled(ImageAnalyzerExtMgt.GetContactQuestionnairePopulatedNotificationId()) then
                ImageAnalyzerExtMgt.SendInformationNotification(ProfileQuestionnairePopulatedTxt, ImageAnalyzerExtMgt.GetContactQuestionnairePopulatedNotificationId());
    end;

    local procedure PopulateContactGender(var Contact: Record Contact; ImageAnalysisResult: Codeunit "Image Analysis Result"; CortanaProfileQuestionnaireHeader: Record "Profile Questionnaire Header"): Boolean
    var
        ProfileQuestionnaireLine: Record "Profile Questionnaire Line";
        Gender: Option " ",Male,Female;
    begin
        EVALUATE(Gender, ImageAnalysisResult.FaceGender(1));

        // search for an answer that matches the gender
        ProfileQuestionnaireLine.SetRange("Profile Questionnaire Code", CortanaProfileQuestionnaireHeader.Code);
        ProfileQuestionnaireLine.SetRange(Type, ProfileQuestionnaireLine.Type::Answer);

        ProfileQuestionnaireLine.SetRange(Description, GetGenderText(Gender));
        if (ProfileQuestionnaireLine.FindFirst()) then begin
            InsertAnswer(Contact, CortanaProfileQuestionnaireHeader, ProfileQuestionnaireLine."Line No.");
            exit(true);
        end;
    end;

    local procedure GetGenderText(GenderOption: Option " ",Male,Female): Text[250]
    begin
        case GenderOption of
            GenderOption::" ":
                exit('');

            GenderOption::Male:
                exit(MaleTok);

            GenderOption::Female:
                exit(FemaleTok);
        end;
    end;

    local procedure PopulateContactAge(var Contact: Record Contact; ImageAnalysisResult: Codeunit "Image Analysis Result"; CortanaProfileQuestionnaireHeader: Record "Profile Questionnaire Header"): Boolean
    var
        ProfileQuestionnaireLine: Record "Profile Questionnaire Line";
        Age: Integer;
    begin
        Age := ImageAnalysisResult.FaceAge(1);

        // search for an answer that matches the age
        ProfileQuestionnaireLine.SetRange("Profile Questionnaire Code", CortanaProfileQuestionnaireHeader.Code);
        ProfileQuestionnaireLine.SetRange(Type, ProfileQuestionnaireLine.Type::Answer);
        ProfileQuestionnaireLine.SetRange("From Value", Age);
        ProfileQuestionnaireLine.SetRange("To Value", Age);

        if (ProfileQuestionnaireLine.FindFirst()) then begin
            InsertAnswer(Contact, CortanaProfileQuestionnaireHeader, ProfileQuestionnaireLine."Line No.");
            exit(true);
        end;
    end;

    local procedure InsertAnswer(Contact: Record Contact; CortanaProfileQuestionnaireHeader: Record "Profile Questionnaire Header"; ProfileQuestionnaireLineNo: Integer)
    var
        ContactProfileAnswer: Record "Contact Profile Answer";
    begin
        ContactProfileAnswer.Init();
        ContactProfileAnswer."Profile Questionnaire Code" := CortanaProfileQuestionnaireHeader.Code;
        ContactProfileAnswer."Profile Questionnaire Priority" := CortanaProfileQuestionnaireHeader.Priority;
        ContactProfileAnswer."Answer Priority" := ContactProfileAnswer."Answer Priority"::Normal;
        ContactProfileAnswer."Contact Company No." := Contact."Company No.";
        ContactProfileAnswer."Last Date Updated" := TODAY();
        ContactProfileAnswer."Line No." := ProfileQuestionnaireLineNo;
        ContactProfileAnswer."Contact No." := Contact."No.";

        ContactProfileAnswer.Insert(true);
    end;

    procedure GetImageAnalyzerQuestionnaireCode(): Code[20]
    begin
        exit(CopyStr(ImageAnalyzerQuestionnaireCodeTxt, 1, 20));
    end;

    procedure GetImageAnalyzerQuestionnaireDescription(): Text[50]
    begin
        exit(CopyStr(ImageAnalyzerContactQuestionnaireDescriptionTxt, 1, 50));
    end;

    procedure GetAgeProfileQuestionDescription(): Text[250]
    begin
        exit(CopyStr(AgeProfileQuestionTxt, 1, 250));
    end;

    procedure GetGenderProfileQuestionDescription(): Text[250]
    begin
        exit(CopyStr(GenderProfileQuestionTxt, 1, 250));
    end;

    local procedure GetAndCreateCortanaQuestionnaireIfNeeded(var ProfileQuestionnaireHeader: Record "Profile Questionnaire Header")
    var
        Age: Integer;
        LineNumber: Integer;
    begin
        ProfileQuestionnaireHeader.Reset();
        ProfileQuestionnaireHeader.SetRange(Code, GetImageAnalyzerQuestionnaireCode());
        IF not ProfileQuestionnaireHeader.FindFirst() then begin
            LineNumber := 10000;
            ProfileQuestionnaireHeader.Code := GetImageAnalyzerQuestionnaireCode();
            ProfileQuestionnaireHeader.Description := GetImageAnalyzerQuestionnaireDescription();
            ProfileQuestionnaireHeader."Contact Type" := ProfileQuestionnaireHeader."Contact Type"::People;
            ProfileQuestionnaireHeader.Priority := ProfileQuestionnaireHeader.Priority::Normal;
            ProfileQuestionnaireHeader.Insert();

            CreateQuestionnaireQuestionLine(LineNumber, GetGenderProfileQuestionDescription());
            CreateQuestionnaireAnswerLine(LineNumber, MaleTok, 0, 0);
            CreateQuestionnaireAnswerLine(LineNumber, FemaleTok, 0, 0);

            CreateQuestionnaireQuestionLine(LineNumber, GetAgeProfileQuestionDescription());
            for Age := 16 to 150 do
                CreateQuestionnaireAnswerLine(LineNumber, Format(Age), Age, Age);
        end;
    end;


    local procedure CreateQuestionnaireQuestionLine(var LineNumber: Integer; QuestionDescription: Text[250])
    var
        ProfileQuestionnaireLine: Record "Profile Questionnaire Line";
    begin
        ProfileQuestionnaireLine.Init();
        ProfileQuestionnaireLine."Line No." := LineNumber;
        ProfileQuestionnaireLine."Profile Questionnaire Code" := GetImageAnalyzerQuestionnaireCode();
        ProfileQuestionnaireLine.Type := ProfileQuestionnaireLine.Type::Question;
        ProfileQuestionnaireLine.Description := QuestionDescription;
        ProfileQuestionnaireLine.Insert();
        LineNumber += 10000;
    end;

    local procedure CreateQuestionnaireAnswerLine(var LineNumber: Integer; AnswerDescription: Text[250]; FromValue: Integer; ToValue: Integer)
    var
        ProfileQuestionnaireLine: Record "Profile Questionnaire Line";
    begin
        ProfileQuestionnaireLine.Init();
        ProfileQuestionnaireLine."Line No." := LineNumber;
        ProfileQuestionnaireLine."Profile Questionnaire Code" := GetImageAnalyzerQuestionnaireCode();
        ProfileQuestionnaireLine.Type := ProfileQuestionnaireLine.Type::Answer;
        ProfileQuestionnaireLine.Description := AnswerDescription;
        ProfileQuestionnaireLine."From Value" := FromValue;
        ProfileQuestionnaireLine."To Value" := ToValue;
        ProfileQuestionnaireLine.Insert();
        LineNumber += 10000;
    end;
}