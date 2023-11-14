// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139752 "Outlook API Helper Tests"
{
    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";
        SendEmailExternalUserErr: Label 'Could not send the email, because the user is delegated or external.';

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSendMailDelegatedAdmin()
    var
        PlanIds: Codeunit "Plan Ids";
        AzureADPlanTestLibrary: Codeunit "Azure AD Plan Test Library";
        AzureADUserTestLibrary: Codeunit "Azure AD User Test Library";
        OutlookAPIClient: Codeunit "Email - Outlook API Client";
        EmailMessage: Codeunit "Email Message";
    begin
        // [SCENARIO] External user (Delegated Admin) are prevented from sending emails
        // [GIVEN] The user is a delegated admin
        BindSubscription(AzureADUserTestLibrary);
        AzureADUserTestLibrary.SetIsUserDelegatedAdmin(true);
        AzureADPlanTestLibrary.AssignUserToPlan(UserSecurityId(), PlanIds.GetDelegatedAdminPlanId());

        // [WHEN] The user attempts to send an email
        asserterror OutlookAPIClient.SendEmail('', GetEmailJson(EmailMessage));

        // [THEN] The email is blocked and an error is shown
        LibraryAssert.ExpectedError(SendEmailExternalUserErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSendMailDelegatedHelpdesk()
    var
        PlanIds: Codeunit "Plan Ids";
        AzureADPlanTestLibrary: Codeunit "Azure AD Plan Test Library";
        AzureADUserTestLibrary: Codeunit "Azure AD User Test Library";
        OutlookAPIClient: Codeunit "Email - Outlook API Client";
        EmailMessage: Codeunit "Email Message";
    begin
        // [SCENARIO] External user (Delegated Helpdesk) is prevented from sending emails
        // [GIVEN] The user is a delegated helpdesk
        BindSubscription(AzureADUserTestLibrary);
        AzureADUserTestLibrary.SetIsUserDelegatedHelpdesk(true);
        AzureADPlanTestLibrary.AssignUserToPlan(UserSecurityId(), PlanIds.GetHelpDeskPlanId());

        // [WHEN] The user attempts to send an email
        asserterror OutlookAPIClient.SendEmail('', GetEmailJson(EmailMessage));

        // [THEN] The email is blocked and an error is shown
        LibraryAssert.ExpectedError(SendEmailExternalUserErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSendMailExternalAccountant()
    var
        AzureADPlanTestLibrary: Codeunit "Azure AD Plan Test Library";
        OutlookAPIClient: Codeunit "Email - Outlook API Client";
        EmailMessage: Codeunit "Email Message";
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
    begin
        // [SCENARIO] External user (External Accountant) is prevented from sending emails
        DeleteAllFromTablePlanAndUserPlan();

        // [GIVEN] The user only has an External Accountant license assigned
        AzureADPlanTestLibrary.AssignUserToPlan(UserSecurityId(), PlanIds.GetExternalAccountantPlanId());
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetExternalAccountantPlanId()), 'User has no assigned external accountant plan.');

        // [WHEN] The user attempts to send an email
        asserterror OutlookAPIClient.SendEmail('', GetEmailJson(EmailMessage));

        // [THEN] The email is blocked and an error is shown
        LibraryAssert.ExpectedError(SendEmailExternalUserErr);
    end;

    local procedure DeleteAllFromTablePlanAndUserPlan()
    var
        AzureADPlanTestLibraries: Codeunit "Azure AD Plan Test Library";
    begin
        AzureADPlanTestLibraries.DeleteAllPlans();
        AzureADPlanTestLibraries.DeleteAllUserPlan();
    end;

    local procedure GetEmailJson(EmailMessage: Codeunit "Email Message"): JsonObject
    var
        LibraryOutlookRestAPI: Codeunit "Library - Outlook Rest API";
        APIHelper: Codeunit "Email - Outlook API Helper";
    begin
        LibraryOutlookRestAPI.CreateEmailMessage(true, EmailMessage);
        exit(APIHelper.EmailMessageToJson(EmailMessage));
    end;
}
