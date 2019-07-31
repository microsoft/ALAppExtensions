// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 139593 "Contact Pic Analyzer Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        NotificationHandled: Boolean;

    [Test]
    [HandlerFunctions('NotificationHandler')]
    procedure TestPopulateAgeAndGender()
    var
        Contact: Record Contact;
        ImageAnalysisResult: Codeunit "Image Analysis Result";
        ContactPictureAnalyze: Codeunit "Contact Picture Analyze";
        JsonManagement: Codeunit "JSON Management";
        Gender: Option " ",Male,Female;
        AnalysisType: Option Tags,Faces,Color;
    begin
        // [Scenario] Check the contact is populated correctly in a success case
        // [Given] A contact and an analysis result with age and gender
        Initialize();
        CreateTestContact(Contact);

        JsonManagement.InitializeObject('{"requestId":"2c15a4c1-9271-4584-a30e-342d7fdf206b"' +
        ',"metadata":{"width":500,"height":600,"format":"Jpeg"},"faces":[ { "age": 37, "gender": "Female",' +
        '"faceRectangle": { "left": 1379, "top": 320, "width": 310, "height": 310 } } ] }');
        ImageAnalysisResult.SetJson(JsonManagement, AnalysisType::Faces);

        // [When] We try to populate the contact
        ContactPictureAnalyze.PopulateContact(Contact, ImageAnalysisResult);

        // [Then] The contact is populated as expected
        Contact.Get(Contact.RecordId());

        Assert.IsTrue(GetContactAge(Contact) = 37, StrSubstNo('Age should have been 37, but was %1', GetContactAge(Contact)));
        Assert.IsTrue(GetContactGender(Contact) = Gender::Female, 'Expected the gender to be female.');
    end;

    [Test]
    procedure TestPopulate2Faces()
    var
        Contact: Record Contact;
        ContactProfileAnswer: Record "Contact Profile Answer";
        ImageAnalysisResult: Codeunit "Image Analysis Result";
        ContactPictureAnalyze: Codeunit "Contact Picture Analyze";
        JsonManagement: Codeunit "JSON Management";
        AnalysisType: Option Tags,Faces,Color;
    begin
        // [Scenario] Check the contact is not populated in a case where 2 faces are on a picture
        // [Given] A contact and an analysis result with age and gender for 2 faces
        Initialize();
        CreateTestContact(Contact);

        JsonManagement.InitializeObject('{"tags":[],"requestId":"2c15a4c1-9271-4584-a30e-342d7fdf206b"' +
        ',"metadata":{"width":500,"height":600,"format":"Jpeg"},"faces":[ { "age": 37, "gender": "Female",' +
        '"faceRectangle": { "left": 1379, "top": 320, "width": 310, "height": 310 } }, { "age": 45, "gender": "Male",' +
        '"faceRectangle": { "left": 1379, "top": 320, "width": 310, "height": 310 } } ] }');
        ImageAnalysisResult.SetJson(JsonManagement, AnalysisType::Faces);

        // [When] We try to populate the contact
        ContactPictureAnalyze.PopulateContact(Contact, ImageAnalysisResult);

        // [Then] The contact is not populated because of the 2 faces
        Contact.Get(Contact.RecordId());
        Assert.IsFalse(GetContactAzureAIAnswers(Contact, ContactProfileAnswer), 'Expected the contact questionnaire answers not to be populated');
    end;

    local procedure Initialize()
    var
        ImageAnalysisSetup: Record "Image Analysis Setup";
        ProfileQuestionnaireLine: Record "Profile Questionnaire Line";
        ProfileQuestionnaireHeader: Record "Profile Questionnaire Header";
        ContactProfileAnswer: Record "Contact Profile Answer";
        ContactPictureAnalyze: Codeunit "Contact Picture Analyze";
    begin
        NotificationHandled := false;
        ImageAnalysisSetup.GetSingleInstance();
        ImageAnalysisSetup."Image-Based Attribute Recognition Enabled" := true;
        ImageAnalysisSetup.Modify();

        ContactProfileAnswer.SetRange("Profile Questionnaire Code", ContactPictureAnalyze.GetImageAnalyzerQuestionnaireCode());
        ContactProfileAnswer.DeleteAll();

        ProfileQuestionnaireLine.SetRange("Profile Questionnaire Code", ContactPictureAnalyze.GetImageAnalyzerQuestionnaireCode());
        ProfileQuestionnaireLine.DeleteAll();

        ProfileQuestionnaireHeader.SetRange("Code", ContactPictureAnalyze.GetImageAnalyzerQuestionnaireCode());
        ProfileQuestionnaireHeader.DeleteAll();
    end;


    local procedure GetContactAge(Contact: Record Contact): Integer
    var
        ProfileQuestionnaireLineAgeQuestion: Record "Profile Questionnaire Line";
        ProfileQuestionnaireLineAnswer: Record "Profile Questionnaire Line";
        ContactProfileAnswer: Record "Contact Profile Answer";
        ContactPictureAnalyze: Codeunit "Contact Picture Analyze";
        Age: Integer;
    begin
        ProfileQuestionnaireLineAgeQuestion.SetRange("Profile Questionnaire Code", ContactPictureAnalyze.GetImageAnalyzerQuestionnaireCode());
        ProfileQuestionnaireLineAgeQuestion.SetRange(Type, ProfileQuestionnaireLineAgeQuestion.Type::Question);
        ProfileQuestionnaireLineAgeQuestion.SetRange(Description, ContactPictureAnalyze.GetAgeProfileQuestionDescription());
        ProfileQuestionnaireLineAgeQuestion.FindFirst();

        if GetContactAzureAIAnswers(Contact, ContactProfileAnswer) then
            repeat
                ProfileQuestionnaireLineAnswer.SetRange("Profile Questionnaire Code", ContactPictureAnalyze.GetImageAnalyzerQuestionnaireCode());
                ProfileQuestionnaireLineAnswer.SetRange(Type, ProfileQuestionnaireLineAnswer.Type::Answer);
                ProfileQuestionnaireLineAnswer.SetRange("Line No.", ContactProfileAnswer."Line No.");
                ProfileQuestionnaireLineAnswer.FindFirst();
                if ProfileQuestionnaireLineAnswer.FindQuestionLine() = ProfileQuestionnaireLineAgeQuestion."Line No." then begin
                    Evaluate(Age, ProfileQuestionnaireLineAnswer.Description);
                    exit(Age);
                end;
            until ContactProfileAnswer.Next() = 0;
        exit(0);
    end;

    local procedure GetContactAzureAIAnswers(Contact: Record Contact; var ContactProfileAnswer: Record "Contact Profile Answer"): Boolean
    var
        ContactPictureAnalyze: Codeunit "Contact Picture Analyze";
    begin
        ContactProfileAnswer.Reset();
        ContactProfileAnswer.SetRange("Profile Questionnaire Code", ContactPictureAnalyze.GetImageAnalyzerQuestionnaireCode());
        ContactProfileAnswer.SetRange("Contact No.", Contact."No.");
        exit(ContactProfileAnswer.FindSet());
    end;

    local procedure GetContactGender(Contact: Record Contact): Option " ",Male,Female
    var
        ProfileQuestionnaireLineGenderQuestion: Record "Profile Questionnaire Line";
        ProfileQuestionnaireLineAnswer: Record "Profile Questionnaire Line";
        ContactProfileAnswer: Record "Contact Profile Answer";
        ContactPictureAnalyze: Codeunit "Contact Picture Analyze";
        Gender: Option " ",Male,Female;
    begin
        ProfileQuestionnaireLineGenderQuestion.SetRange("Profile Questionnaire Code", ContactPictureAnalyze.GetImageAnalyzerQuestionnaireCode());
        ProfileQuestionnaireLineGenderQuestion.SetRange(Type, ProfileQuestionnaireLineGenderQuestion.Type::Question);
        ProfileQuestionnaireLineGenderQuestion.SetRange(Description, ContactPictureAnalyze.GetGenderProfileQuestionDescription());
        ProfileQuestionnaireLineGenderQuestion.FindFirst();

        if GetContactAzureAIAnswers(Contact, ContactProfileAnswer) then
            repeat
                ProfileQuestionnaireLineAnswer.SetRange("Profile Questionnaire Code", ContactPictureAnalyze.GetImageAnalyzerQuestionnaireCode());
                ProfileQuestionnaireLineAnswer.SetRange(Type, ProfileQuestionnaireLineAnswer.Type::Answer);
                ProfileQuestionnaireLineAnswer.SetRange("Line No.", ContactProfileAnswer."Line No.");
                ProfileQuestionnaireLineAnswer.FindFirst();
                if ProfileQuestionnaireLineAnswer.FindQuestionLine() = ProfileQuestionnaireLineGenderQuestion."Line No." then begin
                    Evaluate(Gender, ProfileQuestionnaireLineAnswer.Description);
                    exit(Gender);
                end;
            until ContactProfileAnswer.Next() = 0;
        exit(Gender::" ");
    end;

    local procedure CreateTestContact(var Contact: Record Contact)
    begin
        Contact.Reset();
        Contact.SetFilter(Name, 'Test contact');
        Contact.DeleteAll();

        Contact.Init();
        Contact.Name := 'Test contact';
        Contact.Insert(true);
    end;

    [SendNotificationHandler]
    procedure NotificationHandler(var Notification: Notification): Boolean
    begin
        exit(true);
    end;
}
