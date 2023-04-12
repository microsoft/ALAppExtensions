// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9087 "Microsoft 365 License Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Aggregate Permission Set" = r,
                  tabledata "Custom Permission Set In Plan" = r,
                  tabledata "Plan Configuration" = rm,
                  tabledata "Company" = r;

    procedure ShowM365ConfigurationNotification()
    var
        M365ConfigurationNotification: Notification;
    begin
        M365ConfigurationNotification.Id := CreateGuid();
        M365ConfigurationNotification.Message(M365ConfigurationNotificationTxt);
        M365ConfigurationNotification.AddAction(AddPermissionsTok, Codeunit::"Microsoft 365 License Impl.", 'AssignD365ReadPermission');
        M365ConfigurationNotification.AddAction(LearnMoreTok, Codeunit::"Microsoft 365 License Impl.", 'OpenM365LicenseDocumentation');
        M365ConfigurationNotification.Scope := NotificationScope::LocalScope;

        M365ConfigurationNotification.Send();
    end;

    procedure AssignMicrosoft365ReadPermission(ShowNotification: Boolean)
    var
        AggregatePermissionSet: Record "Aggregate Permission Set";
        CustomPermissionSetInPlan: Record "Custom Permission Set In Plan";
        PlanConfigurationRec: Record "Plan Configuration";
        PlanConfiguration: Codeunit "Plan Configuration";
        PlanIds: Codeunit "Plan Ids";
    begin
        AggregatePermissionSet.SetRange("Role ID", D365ReadTok);
        AggregatePermissionSet.FindFirst();

        PlanConfigurationRec.SetRange("Plan ID", PlanIds.GetMicrosoft365PlanId());
        PlanConfigurationRec.FindFirst();

        // Transfer Default Permission Set to Custom (and set license Customized)
        TransferDefaultPermissions(PlanConfigurationRec, ShowNotification);

        // Insert 'M365 Read' in Custom Permission Plan
        PlanConfiguration.AddCustomPermissionSetToPlan(PlanIds.GetMicrosoft365PlanId(),
                                                           AggregatePermissionSet."Role ID",
                                                           AggregatePermissionSet."App ID",
                                                           AggregatePermissionSet.Scope,
                                                           CopyStr(CompanyName(), 1, MaxStrLen(CustomPermissionSetInPlan."Company Name")));
    end;

    procedure OpenBCAdminCenter()
    begin
        PlanConfigurationImpl.OpenBCAdminCenter();
    end;

    procedure OpenM365AdminCenter()
    begin
        PlanConfigurationImpl.OpenM365AdminCenter();
    end;

    local procedure TransferDefaultPermissions(var Rec: Record "Plan Configuration"; ShowNotification: Boolean)
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        Rec.Customized := true;
        Rec.Modify();

        TelemetryDimensions.Add('Customized', Format(Rec.Customized));
        TelemetryDimensions.Add('PlanId', Format(Rec."Plan ID", 0, 4));
        FeatureTelemetry.LogUptake('0000GLS', PlanConfigurationFeatureNameTok, Enum::"Feature Uptake Status"::"Set up", TelemetryDimensions);

        Session.LogSecurityAudit(PlanConfigurationFeatureNameTok, SecurityOperationResult::Success,
            StrSubstNo(PlanConfigurationUpdatedLbl, Rec."Plan ID", Rec.Customized), AuditCategory::UserManagement);

        PlanConfigurationImpl.TransferPermissions(Rec."Plan ID");
        if ShowNotification then
            PlanConfigurationImpl.ShowCustomPermissionsEffectNotification(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Plan Configuration Card", OnOpenPageEvent, '', false, false)]
    local procedure ShowM365LicenseNotification(var Rec: Record "Plan Configuration")
    var
        Company: Record "Company";
        PlanIds: Codeunit "Plan Ids";
    begin
        if Rec."Plan ID" = PlanIds.GetMicrosoft365PlanId() then begin
            Company.Get(CompanyName());
            if (not Rec.Customized) and Company."Evaluation Company" then
                ShowM365ConfigurationNotification();
        end;
    end;

    internal procedure AssignD365ReadPermission(Notification: Notification)
    begin
        AssignMicrosoft365ReadPermission(true);
    end;

    internal procedure OpenM365LicenseDocumentation(Notification: Notification)
    begin
        Hyperlink(M365LicenseDocumentationLinkTxt);
    end;

    var
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
        D365ReadTok: Label 'D365 READ', Locked = true;
        M365LicenseDocumentationLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2209653', Locked = true;
        PlanConfigurationFeatureNameTok: Label 'Custom Permissions Assignment Per Plan', Locked = true;
        PlanConfigurationUpdatedLbl: Label 'Plan Configuration was modified for plan %1. Customized: %2.', Locked = true;
        M365ConfigurationNotificationTxt: Label 'Just trying this out? Start by adding ''D365 READ'' permissions to all objects to experience how employees across the organization can read Business Central data in Microsoft Teams using only their Microsoft 365 license.', Comment = 'Do not translate ''D365 READ'', ''Business Central'', ''Microsoft Teams'' and ''Microsoft 365''';
        LearnMoreTok: Label 'Learn more';
        AddPermissionsTok: Label 'Add permissions to all objects';
}