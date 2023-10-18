// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Feedback;

using System.Feedback;
using System.TestLibraries.Feedback;
using System.TestLibraries.Utilities;

codeunit 132103 "Customer Exp. Survey Test"
{
    Subtype = Test;

    var
        CustomerExperienceSurvey: Codeunit "Customer Experience Survey";
        CustExpSurveyReqMock: Codeunit "Cust. Exp. Survey Req. Mock";
        CustomerExpSurveyMock: Codeunit "Customer Exp. Survey Mock";
        CustomerExpSurveyLibrary: Codeunit "Customer Exp. Survey Library";
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    [Scope('OnPrem')]
    procedure TestRegisterEventRequest()
    begin
        // [SCENARIO] Register event makes a call to CES Events endpoint with the event name
        Initialize(true);

        // [WHEN] RegisterEvent facade is called
        CustomerExperienceSurvey.RegisterEvent('modernactionbar_event');

        // [THEN] Request URL is the CES Events endpoint
        LibraryAssert.AreEqual(CustExpSurveyReqMock.GetGlobalRequestUri(), 'https://world.tip1.ces.microsoftcloud.com/api/v1/d365bc/Events?userId=48d31887-5fad-4d73-a9f5-3c356e68a038&eventName=modernactionbar_event', 'Request URL is incorrect.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetEligibilityRequest()
    var
        FormsProId: Text;
        FormsPoEligibilityId: Text;
        IsEligible: Boolean;
    begin
        // [SCENARIO] Get eligibility makes a call to CES Eligibilities endpoint with the user ID, survey name and tenant ID
        Initialize(true);

        // [WHEN] GetEligibility facade is called
        CustomerExperienceSurvey.GetEligibility('modernactionbar', FormsProId, FormsPoEligibilityId, IsEligible);

        // [THEN] Request URL is the CES Eligibilities endpoint
        LibraryAssert.AreEqual(CustExpSurveyReqMock.GetGlobalRequestUri(), 'https://world.tip1.ces.microsoftcloud.com/api/v1/d365bc/Eligibilities/modernactionbar?userId=48d31887-5fad-4d73-a9f5-3c356e68a038&tenantId=816800a7-f29f-464c-9d58-c7b250995cba', 'Request URL is incorrect.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetEligibilityResponse()
    var
        FormsProId: Text;
        FormsPoEligibilityId: Text;
        IsEligible: Boolean;
    begin
        // [SCENARIO] Get eligibility returns eligibility for the user
        Initialize(true);

        // [WHEN] GetEligibility facade is called
        CustomerExperienceSurvey.GetEligibility('modernactionbar', FormsProId, FormsPoEligibilityId, IsEligible);

        // [THEN] Response contains correct eligibility
        LibraryAssert.IsTrue(IsEligible, 'User must be eligible for the survey.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRegisterEventAndGetEligibilityRequest()
    var
        FormsProId: Text;
        FormsPoEligibilityId: Text;
        IsEligible: Boolean;
    begin
        // [SCENARIO] Register event and get eligibility makes a call to CES Eligibilities endpoint with the user ID, survey name, event name and tenant ID
        Initialize(true);

        // [WHEN] RegisterEventAndGetEligibility facade is called
        CustomerExperienceSurvey.RegisterEventAndGetEligibility('modernactionbar_event', 'modernactionbar', FormsProId, FormsPoEligibilityId, IsEligible);

        // [THEN] Request URL is the CES Eligibilities endpoint
        LibraryAssert.AreEqual(CustExpSurveyReqMock.GetGlobalRequestUri(), 'https://world.tip1.ces.microsoftcloud.com/api/v1/d365bc/Eligibilities/modernactionbar?userId=48d31887-5fad-4d73-a9f5-3c356e68a038&eventName=modernactionbar_event&tenantId=816800a7-f29f-464c-9d58-c7b250995cba', 'Request URL is incorrect.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRegisterEventAndGetEligibilityResponse()
    var
        FormsProId: Text;
        FormsPoEligibilityId: Text;
        IsEligible: Boolean;
    begin
        // [SCENARIO] Register event and get eligibility returns eligibility, forms pro ID and froms pro eligibility ID for the user
        Initialize(true);

        // [WHEN] RegisterEventAndGetEligibility facade is called
        CustomerExperienceSurvey.RegisterEventAndGetEligibility('modernactionbar_event', 'modernactionbar', FormsProId, FormsPoEligibilityId, IsEligible);

        // [THEN] Response contains correct eligibility, forms pro ID and froms pro eligibility ID for the user
        LibraryAssert.AreEqual(FormsProId, 'v4j5cvGGr0GRqyOTdPVEc3U0pJV0FGSUJGWi4u', 'FormsProId is incorrect.');
        LibraryAssert.AreEqual(FormsPoEligibilityId, 'fbbb693b-9798-488e-bf96-21abb6d20d1d', 'FormsPoEligibilityId is incorrect.');
        LibraryAssert.IsTrue(IsEligible, 'User must be eligible for the survey.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetSurveyRequest()
    var
        CustomerExperienceSurveyRec: Record "Customer Experience Survey";
    begin
        // [SCENARIO] Get survey makes a call to CES Surveys endpoint with the survey name
        Initialize(true);

        // [WHEN] GetSurvey facade is called
        CustomerExperienceSurvey.GetSurvey('modernactionbar', CustomerExperienceSurveyRec);

        // [THEN] Request URL is the CES Surveys endpoint
        LibraryAssert.AreEqual(CustExpSurveyReqMock.GetGlobalRequestUri(), 'https://world.tip1.ces.microsoftcloud.com/api/v1/d365bc/Surveys/modernactionbar', 'Request URL is incorrect.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetSurveyResponse()
    var
        CustomerExperienceSurveyRec: Record "Customer Experience Survey";
    begin
        // [SCENARIO] Get survey returns the survey properties with the given name
        Initialize(true);

        // [WHEN] GetSurvey facade is called
        CustomerExperienceSurvey.GetSurvey('modernactionbar', CustomerExperienceSurveyRec);

        // [THEN] Response contains correct survey properties
        VerifyCustomerExperienceSurveyRec(CustomerExperienceSurveyRec);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRemoveUserIdFromMessage()
    begin
        // [SCENARIO] User ID is removed from telemetry messages
        Initialize(true);

        // [WHEN] Facade is called
        CustomerExperienceSurvey.RegisterEvent('modernactionbar_event');

        // [THEN] User ID is removed from the request URL
        LibraryAssert.AreEqual(CustomerExpSurveyLibrary.RemoveUserIdFromMessage(CustExpSurveyReqMock.GetGlobalRequestUri()), 'https://world.tip1.ces.microsoftcloud.com/api/v1/d365bc/Events?userId=&eventName=modernactionbar_event', 'User ID should be removed from the request URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFailedRequestExitsSilent()
    begin
        // [SCENARIO] Failed requests do not surface to the user
        Initialize(false);

        // [WHEN] Facade is called
        CustomerExperienceSurvey.RegisterEvent('modernactionbar_event');

        // [THEN] Process fails silently and does not interrupt user
    end;

    local procedure Initialize(BindReqMockSubscription: Boolean)
    begin
        ClearBindings();

        BindSubscription(CustomerExpSurveyMock);

        if BindReqMockSubscription then
            BindSubscription(CustExpSurveyReqMock)
        else
            UnbindSubscription(CustExpSurveyReqMock);
    end;

    local procedure ClearBindings()
    begin
        UnbindSubscription(CustExpSurveyReqMock);
        UnbindSubscription(CustomerExpSurveyMock);
    end;

    local procedure VerifyCustomerExperienceSurveyRec(CustomerExperienceSurveyRec: Record "Customer Experience Survey")
    begin
        LibraryAssert.AreEqual(CustomerExperienceSurveyRec.Name, 'modernactionbar', 'Survey name is incorrect.');
        LibraryAssert.AreEqual(CustomerExperienceSurveyRec.Description, 'Modern Action Bar', 'Survey description is incorrect.');
        LibraryAssert.AreEqual(CustomerExperienceSurveyRec."Survey Cooling Time", 90, 'Survey cooling time is incorrect.');
        LibraryAssert.AreEqual(CustomerExperienceSurveyRec."NPS Cooling Time", 90, 'Survey NPS cooling time is incorrect.');
        LibraryAssert.AreEqual(CustomerExperienceSurveyRec."CES Cooling Time", 90, 'Survey CES cooling time is incorrect.');
        LibraryAssert.IsTrue(CustomerExperienceSurveyRec.Enabled, 'Survey should be enabled.');
        LibraryAssert.AreEqual(CustomerExperienceSurveyRec."Trigger Event Name", 'modernactionbar_event', 'Survey trigger event name is incorrect.');
        LibraryAssert.AreEqual(CustomerExperienceSurveyRec."Trigger Type", CustomerExperienceSurveyRec."Trigger Type"::Simple, 'Survey trigger type is incorrect.');
        LibraryAssert.AreEqual(CustomerExperienceSurveyRec."Trigger Period", 0, 'Survey trigger period is incorrect.');
        LibraryAssert.AreEqual(CustomerExperienceSurveyRec."Forms Pro Id", 'v4j5cvGGr0GRqyOTdPVEc3U0pJV0FGSUJGWi4u', 'Survey forms pro ID is incorrect.');
    end;
}