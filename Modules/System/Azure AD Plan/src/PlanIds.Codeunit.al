// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to get plan IDs.
/// </summary>
codeunit 9027 "Plan Ids"
{

    trigger OnRun()
    begin
    end;

    var
        BasicPlanGUIDTxt: Label '{7e8e26a8-91a4-4590-961d-d12b61c16a43}', Locked = true;
        TeamMemberPlanGUIDTxt: Label '{d9a6391b-8970-4976-bd94-5f205007c8d8}', Locked = true;
        EssentialPlanGUIDTxt: Label '{920656a2-7dd8-4c83-97b6-a356414dbd36}', Locked = true;
        PremiumPlanGUIDTxt: Label '{8e9002c0-a1d8-4465-b952-817d2948e6e2}', Locked = true;
        InvoicingPlanGUIDTxt: Label '{39b5c996-467e-4e60-bd62-46066f572726}', Locked = true;
        ViralSignupPlanGUIDTxt: Label '{3F2AFEED-6FB5-4BF9-998F-F2912133AEAD}', Locked = true;
        ExternalAccountantPlanGUIDTxt: Label '{170991d7-b98e-41c5-83d4-db2052e1795f}', Locked = true;
        DelegatedAdminGUIDTxt: Label '{00000000-0000-0000-0000-000000000007}', Locked = true;
        InternalAdminGUIDTxt: Label '{62e90394-69f5-4237-9190-012177145e10}', Locked = true;
        TeamMemberISVPlanGUIDTxt: Label '{fd1441b8-116b-4fa7-836e-d7956700e0fa}', Locked = true;
        EssentialISVPlanGUIDTxt: Label '{8bb56cea-3f11-4647-854a-212e2b05306a}', Locked = true;
        PremiumISVPlanGUIDTxt: Label '{4c52d56d-5121-425a-91a5-dd0de136ca17}', Locked = true;
        DeviceISVPlanGUIDTxt: Label '{a98d0c4a-a52f-4771-a609-e20366102d2a}', Locked = true;
        DevicePlanGUIDTxt: Label '{100e1865-35d4-4463-aaff-d38eee3a1116}', Locked = true;

    /// <summary>
    /// Returns the ID for the Basic plan.
    /// </summary>
    /// <returns>The ID for the Basic plan.</returns>
    procedure GetBasicPlanId(): Guid
    begin
        EXIT(BasicPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Finance and Operations, Team Member plan.
    /// </summary>
    /// <returns>The ID for the Finance and Operations, Team Member plan.</returns>
    procedure GetTeamMemberPlanId(): Guid
    begin
        EXIT(TeamMemberPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Finance and Operations plan.
    /// </summary>
    /// <returns>The ID for the Finance and Operations plan.</returns>
    procedure GetEssentialPlanId(): Guid
    begin
        EXIT(EssentialPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Dynamics 365 Business Central, Premium User plan.
    /// </summary>
    /// <returns>The ID for the Dynamics 365 Business Central, Premium User plan.</returns>
    procedure GetPremiumPlanId(): Guid
    begin
        EXIT(PremiumPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Microsoft Invoicing plan.
    /// </summary>
    /// <returns>The ID for the Microsoft Invoicing plan.</returns>
    procedure GetInvoicingPlanId(): Guid
    begin
        EXIT(InvoicingPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Finance and Operations for IWs plan.
    /// </summary>
    /// <returns>The ID for the Finance and Operations for IWs plan.</returns>
    procedure GetViralSignupPlanId(): Guid
    begin
        EXIT(ViralSignupPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Finance and Operations, External Accountant plan.
    /// </summary>
    /// <returns>The ID for the Finance and Operations, External Accountant plan.</returns>
    procedure GetExternalAccountantPlanId(): Guid
    begin
        EXIT(ExternalAccountantPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Administrator plan.
    /// </summary>
    /// <returns>The ID for the Administrator plan.</returns>
    procedure GetDelegatedAdminPlanId(): Guid
    begin
        EXIT(DelegatedAdminGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Internal Administrator plan.
    /// </summary>
    /// <returns>The ID for the Internal Administrator plan.</returns>
    procedure GetInternalAdminPlanId(): Guid
    begin
        EXIT(InternalAdminGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Dynamics 365 Business Central, Team Member ISV plan.
    /// </summary>
    /// <returns>The ID for the Dynamics 365 Business Central, Team Member ISV plan.</returns>
    procedure GetTeamMemberISVPlanId(): Guid
    begin
        EXIT(TeamMemberISVPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Dynamics 365 Business Central, Essential ISV User plan.
    /// </summary>
    /// <returns>The ID for the Dynamics 365 Business Central, Essential ISV User plan.</returns>
    procedure GetEssentialISVPlanId(): Guid
    begin
        EXIT(EssentialISVPlanGUIDTxt);
    end;

    /// <summary>
    /// Returns the ID for the Dynamics 365 Business Central, Premium ISV User plan.
    /// </summary>
    /// <returns>The ID for the Dynamics 365 Business Central, Premium ISV User plan.</returns>
    procedure GetPremiumISVPlanId(): Guid
    begin
        EXIT(PremiumISVPlanGUIDTxt);
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
    /// Returns the ID for the Finance and Operations, Device plan.
    /// </summary>
    /// <returns>The ID for the Finance and Operations, Device plan.</returns>
    procedure GetDevicePlanId(): Guid
    begin
        exit(DevicePlanGUIDTxt);
    end;
}

