// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using System.Azure.Identity;
using System.Security.AccessControl;

codeunit 5684 "Create Contoso Permissions"
{
    Access = Internal;

    trigger OnRun()
    var
        PlanIDs: Codeunit "Plan Ids";
    begin
        AddPermissionSet(PlanIDs.GetDelegatedAdminPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDelegatedAdminPlanId(), 'D365 BACKUP/RESTORE', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDelegatedAdminPlanId(), 'D365 FULL ACCESS', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDelegatedAdminPlanId(), 'D365 RAPIDSTART', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDelegatedAdminPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDelegatedAdminPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDelegatedAdminPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDelegatedAdminPlanId(), 'TROUBLESHOOT TOOLS', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetHelpDeskPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetHelpDeskPlanId(), 'D365 FULL ACCESS', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetHelpDeskPlanId(), 'D365 RAPIDSTART', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetHelpDeskPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetHelpDeskPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetHelpDeskPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetHelpDeskPlanId(), 'TROUBLESHOOT TOOLS', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetD365AdminPartnerPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetD365AdminPartnerPlanId(), 'D365 FULL ACCESS', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetD365AdminPartnerPlanId(), 'D365 RAPIDSTART', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetD365AdminPartnerPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetD365AdminPartnerPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetD365AdminPartnerPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetD365AdminPartnerPlanId(), 'TROUBLESHOOT TOOLS', SystemApplicationAppIdLbl);
        AddPermissionSet(D365AutomationPlanIdLbl, 'D365 AUTOMATION', BaseApplicationAppIdLbl);
        AddPermissionSet(D365AutomationPlanIdLbl, 'D365 RAPIDSTART', BaseApplicationAppIdLbl);
        AddPermissionSet(D365AutomationPlanIdLbl, 'EXTEN. MGT. - ADMIN', SystemApplicationAppIdLbl);
        AddPermissionSet(D365AutomationPlanIdLbl, 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(D365AutomationPlanIdLbl, 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetGlobalAdminPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetGlobalAdminPlanId(), 'D365 BACKUP/RESTORE', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetGlobalAdminPlanId(), 'D365 READ', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetGlobalAdminPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetGlobalAdminPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetGlobalAdminPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetGlobalAdminPlanId(), 'SECURITY', EmptyAppId);
        AddPermissionSet(PlanIDs.GetGlobalAdminPlanId(), 'TROUBLESHOOT TOOLS', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetPremiumPartnerSandboxPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetPremiumPartnerSandboxPlanId(), 'D365 BUS PREMIUM', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetPremiumPartnerSandboxPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetPremiumPartnerSandboxPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetPremiumPartnerSandboxPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetEssentialISVPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetEssentialISVPlanId(), 'D365 BUS FULL ACCESS', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetEssentialISVPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetEssentialISVPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetEssentialISVPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetTeamMemberPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetTeamMemberPlanId(), 'D365 READ', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetTeamMemberPlanId(), 'D365 TEAM MEMBER', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetTeamMemberPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetTeamMemberPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetTeamMemberPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetPremiumPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetPremiumPlanId(), 'D365 BUS PREMIUM', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetPremiumPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetPremiumPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetPremiumPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetBasicPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetBasicPlanId(), 'D365 BASIC ISV', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetBasicPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetBasicPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetBasicPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetEssentialPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetEssentialPlanId(), 'D365 BUS FULL ACCESS', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetEssentialPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetEssentialPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetEssentialPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetInfrastructurePlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetInfrastructurePlanId(), 'D365 FULL ACCESS', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetInfrastructurePlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetInfrastructurePlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetInfrastructurePlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetAccountantHubPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetAccountantHubPlanId(), 'D365 ACCOUNTANTS', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetAccountantHubPlanId(), 'D365 BASIC', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetAccountantHubPlanId(), 'D365 JOBS, EDIT', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetAccountantHubPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetAccountantHubPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetAccountantHubPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetAccountantHubPlanId(), 'TROUBLESHOOT TOOLS', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDevicePlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDevicePlanId(), 'D365 BUS FULL ACCESS', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDevicePlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDevicePlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDevicePlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetTeamMemberISVPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetTeamMemberISVPlanId(), 'D365 READ', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetTeamMemberISVPlanId(), 'D365 TEAM MEMBER', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetTeamMemberISVPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetTeamMemberISVPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetTeamMemberISVPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetExternalAccountantPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetExternalAccountantPlanId(), 'D365 BUS FULL ACCESS', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetExternalAccountantPlanId(), 'D365 READ', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetExternalAccountantPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetExternalAccountantPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetExternalAccountantPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetPremiumISVPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetPremiumISVPlanId(), 'D365 BUS PREMIUM', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetPremiumISVPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetPremiumISVPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetPremiumISVPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDeviceISVPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDeviceISVPlanId(), 'D365 BUS FULL ACCESS', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDeviceISVPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDeviceISVPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDeviceISVPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetViralSignupPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetViralSignupPlanId(), 'D365 BUS PREMIUM', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetViralSignupPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetViralSignupPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetViralSignupPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetViralSignupPlanId(), 'TROUBLESHOOT TOOLS', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetD365AdminPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetD365AdminPlanId(), 'D365 BACKUP/RESTORE', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetD365AdminPlanId(), 'D365 READ', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetD365AdminPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetD365AdminPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetD365AdminPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetD365AdminPlanId(), 'SECURITY', EmptyAppId);
        AddPermissionSet(PlanIDs.GetD365AdminPlanId(), 'TROUBLESHOOT TOOLS', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetMicrosoft365PlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetEssentialAttachPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetEssentialAttachPlanId(), 'D365 BUS FULL ACCESS', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetEssentialAttachPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetEssentialAttachPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetEssentialAttachPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDelegatedBCAdminPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDelegatedBCAdminPlanId(), 'D365 BACKUP/RESTORE', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDelegatedBCAdminPlanId(), 'D365 FULL ACCESS', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDelegatedBCAdminPlanId(), 'D365 RAPIDSTART', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDelegatedBCAdminPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDelegatedBCAdminPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDelegatedBCAdminPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetDelegatedBCAdminPlanId(), 'TROUBLESHOOT TOOLS', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetBCAdminPlanId(), 'AUTOMATE - EXEC', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetBCAdminPlanId(), 'D365 BACKUP/RESTORE', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetBCAdminPlanId(), 'D365 READ', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetBCAdminPlanId(), 'EXCEL EXPORT ACTION', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetBCAdminPlanId(), 'LOCAL', BaseApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetBCAdminPlanId(), 'LOGIN', SystemApplicationAppIdLbl);
        AddPermissionSet(PlanIDs.GetBCAdminPlanId(), 'SECURITY', EmptyAppId);
        AddPermissionSet(PlanIDs.GetBCAdminPlanId(), 'TROUBLESHOOT TOOLS', SystemApplicationAppIdLbl);
    end;

    local procedure AddPermissionSet(PlanId: Guid; RoleId: Code[20]; AppId: Guid)
    var
        AggregatePermissionSet: Record "Aggregate Permission Set";
        PlanConfiguration: Codeunit "Plan Configuration";
        Scope: Option System,Tenant;
    begin
        if AggregatePermissionSet.Get(Scope::System, AppId, RoleId) then
            PlanConfiguration.AddDefaultPermissionSetToPlan(PlanId, RoleId, AppId, Scope::System);
    end;

    var
        D365AutomationPlanIdLbl: Label '{00000000-0000-0000-0000-000000000010}', Locked = true;
        BaseApplicationAppIdLbl: Label '{437dbf0e-84ff-417a-965d-ed2bb9650972}', Locked = true;
        SystemApplicationAppIdLbl: Label '{63ca2fa4-4f03-4f2b-a480-172fef340d3f}', Locked = true;
        EmptyAppId: Guid;
}
