// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Identity;

/// <summary>
/// Exposes functionality to get plan IDs.
/// </summary>
codeunit 9027 "Plan Ids"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
    end;

    var
        Microsoft365PlanGUIDTxt: Label '{57ff2da0-773e-42df-b2af-ffb7a2317929}', Locked = true;
        TeamMemberPlanGUIDTxt: Label '{d9a6391b-8970-4976-bd94-5f205007c8d8}', Locked = true;
        EssentialPlanGUIDTxt: Label '{920656a2-7dd8-4c83-97b6-a356414dbd36}', Locked = true;
        PremiumPlanGUIDTxt: Label '{8e9002c0-a1d8-4465-b952-817d2948e6e2}', Locked = true;
        ViralSignupPlanGUIDTxt: Label '{3F2AFEED-6FB5-4BF9-998F-F2912133AEAD}', Locked = true;
        ExternalAccountantPlanGUIDTxt: Label '{170991d7-b98e-41c5-83d4-db2052e1795f}', Locked = true;
        TeamMemberISVPlanGUIDTxt: Label '{fd1441b8-116b-4fa7-836e-d7956700e0fa}', Locked = true;
        EssentialISVPlanGUIDTxt: Label '{8bb56cea-3f11-4647-854a-212e2b05306a}', Locked = true;
        PremiumISVPlanGUIDTxt: Label '{4c52d56d-5121-425a-91a5-dd0de136ca17}', Locked = true;
        DeviceISVPlanGUIDTxt: Label '{a98d0c4a-a52f-4771-a609-e20366102d2a}', Locked = true;
        EssentialAttachPlanGUIDTxt: Label '{17ca446c-d7a4-4d29-8dec-8e241592164b}', Locked = true;
        DevicePlanGUIDTxt: Label '{100e1865-35d4-4463-aaff-d38eee3a1116}', Locked = true;
        BasicPlanGUIDTxt: Label '{2ec8b6ca-ab13-4753-a479-8c2ffe4c323b}', Locked = true;
        AccountantHubPlanGuidTxt: Label '{5d60ea51-0053-458f-80a8-b6f426a1a0c1}', Locked = true;
        InfrastructurePlanGuidTxt: Label '{996DEF3D-B36C-4153-8607-A6FD3C01B89F}', Locked = true;
        PremiumPartnerSandboxPlanGuidTxt: Label '{37b1c04b-a429-4139-a15e-067784a80a55}', Locked = true;
        D365AdminGUIDTxt: Label '{44367163-eba1-44c3-98af-f5787879f96a}', Locked = true;
#pragma warning disable AA0240
        DelegatedAdminGUIDTxt: Label '{00000000-0000-0000-0000-000000000007}', Locked = true;
        GlobalAdminGUIDTxt: Label '{62e90394-69f5-4237-9190-012177145e10}', Locked = true;
        HelpDeskPlanGuidTxt: Label '{00000000-0000-0000-0000-000000000008}', Locked = true;
        D365AdminPartnerGUIDTxt: Label '{00000000-0000-0000-0000-000000000009}', Locked = true;
#pragma warning restore AA0240

    /// <summary>
    /// Returns the ID for the Dynamics 365 Business Central Basic Financials plan.
    /// </summary>
    /// <returns>The ID for the Dynamics 365 Business Central Basic Financials plan.</returns>
    procedure GetBasicPlanId(): Guid
    begin
        exit(BasicPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Dynamics 365 Business Central Team Member plan.
    /// </summary>
    /// <returns>The ID for the Dynamics 365 Business Central Team Member plan.</returns>
    procedure GetTeamMemberPlanId(): Guid
    begin
        exit(TeamMemberPlanGUIDTxt);
    end;

#if not CLEAN22
    /// <summary>
    /// Returns the ID for the Microsoft 365 Collaboration plan.
    /// </summary>
    /// <returns>The ID for the Microsoft 365 Collaboration plan.</returns>
    [Obsolete('Replaced by GetMicrosoft365PlanId()', '22.0')]
    procedure GetM365CollaborationPlanId(): Guid
    begin
        exit(Microsoft365PlanGUIDTxt);
    end;
#endif

    /// <summary>
    /// Returns the ID for the Microsoft 365 plan.
    /// </summary>
    /// <returns>The ID for the Microsoft 365 plan.</returns>
    procedure GetMicrosoft365PlanId(): Guid
    begin
        exit(Microsoft365PlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Dynamics 365 Business Central Essentials plan.
    /// </summary>
    /// <returns>The ID for the Dynamics 365 Business Central Essentials plan.</returns>
    procedure GetEssentialPlanId(): Guid
    begin
        exit(EssentialPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Dynamics 365 Business Central Premium plan.
    /// </summary>
    /// <returns>The ID for the Dynamics 365 Business Central Premium plan.</returns>
    procedure GetPremiumPlanId(): Guid
    begin
        exit(PremiumPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Dynamics 365 Business Central for IWs plan.
    /// </summary>
    /// <returns>The ID for the Dynamics 365 Business Central for IWs plan.</returns>
    procedure GetViralSignupPlanId(): Guid
    begin
        exit(ViralSignupPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Dynamics 365 Business Central External Accountant plan.
    /// </summary>
    /// <returns>The ID for the Dynamics 365 Business Central External Accountant plan.</returns>
    procedure GetExternalAccountantPlanId(): Guid
    begin
        exit(ExternalAccountantPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Delegated Admin agent - Partner plan.
    /// </summary>
    /// <returns>The ID for the Delegated Admin agent - Partner plan.</returns>
    procedure GetDelegatedAdminPlanId(): Guid
    begin
        exit(DelegatedAdminGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Dynamics 365 Admin - Partner plan.
    /// </summary>
    /// <returns>The ID for the Dynamics 365 Admin - Partner plan.</returns>
    procedure GetD365AdminPartnerPlanId(): Guid
    begin
        exit(D365AdminPartnerGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Dynamics 365 Administrator plan.
    /// </summary>
    /// <returns>The ID for the Internal Administrator plan.</returns>
    procedure GetD365AdminPlanId(): Guid
    begin
        exit(D365AdminGUIDTxt);
    end;

#if not CLEAN23
    /// <summary>
    /// Returns the ID for the Internal Administrator plan.
    /// </summary>
    /// <returns>The ID for the Internal Administrator plan.</returns>
    [Obsolete('Replaced by GetGlobalAdminPlanId()', '23.0')]
    procedure GetInternalAdminPlanId(): Guid
    begin
        exit(GlobalAdminGUIDTxt);
    end;
#endif

    /// <summary>
    /// Returns the ID for the Global Administrator plan.
    /// </summary>
    /// <returns>The ID for the Global Administrator plan.</returns>
    procedure GetGlobalAdminPlanId(): Guid
    begin
        exit(GlobalAdminGUIDTxt);
    end;
    /// <summary>
    /// Returns the ID for the D365 Business Central Team Member - Embedded plan.
    /// </summary>
    /// <returns>The ID for the D365 Business Central Team Member - Embedded plan.</returns>
    procedure GetTeamMemberISVPlanId(): Guid
    begin
        exit(TeamMemberISVPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Dynamics 365 Business Central Essential - Embedded plan.
    /// </summary>
    /// <returns>The ID for the Dynamics 365 Business Central Essential - Embedded plan.</returns>
    procedure GetEssentialISVPlanId(): Guid
    begin
        exit(EssentialISVPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Dynamics 365 Business Central Premium - Embedded plan.
    /// </summary>
    /// <returns>The ID for the Dynamics 365 Business Central Premium - Embedded plan.</returns>
    procedure GetPremiumISVPlanId(): Guid
    begin
        exit(PremiumISVPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Dynamics 365 Business Central Essential - Attach plan.
    /// </summary>
    /// <returns>The ID for the Dynamics 365 Business Central Essential - Attach plan.</returns>
    procedure GetEssentialAttachPlanId(): Guid
    begin
        exit(EssentialAttachPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Dynamics 365 Business Central Device - Embedded plan.
    /// </summary>
    /// <returns>The ID for the Dynamics 365 Business Central Device - Embedded plan.</returns>
    procedure GetDeviceISVPlanId(): Guid
    begin
        exit(DeviceISVPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Dynamics 365 Business Central Device plan.
    /// </summary>
    /// <returns>The ID for the Dynamics 365 Business Central Device plan.</returns>
    procedure GetDevicePlanId(): Guid
    begin
        exit(DevicePlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Dynamics 365 Business Central Basic Financials - Embedded plan.
    /// </summary>
    /// <returns>The ID for the Dynamics 365 Business Central Basic Financials - Embedded plan.</returns>
    procedure GetBasicFinancialsISVPlanId(): Guid
    begin
        exit(BasicPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Microsoft Dynamics 365 - Accountant Hub plan.
    /// </summary>
    /// <returns>The ID for the Microsoft Dynamics 365 - Accountant Hub plan.</returns>
    procedure GetAccountantHubPlanId(): Guid
    begin
        exit(AccountantHubPlanGuidTxt);
    end;

    /// <summary>
    /// Returns the ID for the Delegated Helpdesk agent - Partner plan.
    /// </summary>
    /// <returns>The ID for the Delegated Helpdesk agent - Partner plan.</returns>
    procedure GetHelpDeskPlanId(): Guid
    begin
        exit(HelpDeskPlanGuidTxt);
    end;

    /// <summary>
    /// Returns the ID for the D365 Business Central Infrastructure plan.
    /// </summary>
    /// <returns>The ID for the D365 Business Central Infrastructure plan.</returns>
    procedure GetInfrastructurePlanId(): Guid
    begin
        exit(InfrastructurePlanGuidTxt);
    end;

    /// <summary>
    /// Returns the ID for the D365 Business Central Premium Partner Sandbox plan.
    /// </summary>
    /// <returns>The ID for the D365 Business Central Premium Partner Sandbox plan.</returns>
    procedure GetPremiumPartnerSandboxPlanId(): Guid
    begin
        exit(PremiumPartnerSandboxPlanGuidTxt);
    end;
}