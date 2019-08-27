// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9056 "Plan Installer"
{
    Subtype = Install;

    trigger OnInstallAppPerDatabase()
    begin
        CreatePlan('00000000-0000-0000-0000-000000000007', 'Administrator', 9022, '7584DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('00000000-0000-0000-0000-000000000008', 'Helpdesk', 9022, '8884DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('62E90394-69F5-4237-9190-012177145E10', 'Internal Administrator', 9022, '9B84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('8BB56CEA-3F11-4647-854A-212E2B05306A', 'Dynamics 365 Business Central, Essential ISV User', 9022, '2E84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('07EB0DC4-7DA7-4E7B-BB42-2D44C5E08B08', 'Microsoft Invoice', 9029, '0D84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('9695F925-27A8-4127-98C7-3CAAC1809758', 'Test Plan - Finance and Operations for Financials', 9022, 'CF84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('39B5C996-467E-4E60-BD62-46066F572726', 'Microsoft Invoicing', 9029, '1384DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('D9A6391B-8970-4976-BD94-5F205007C8D8', 'Finance and Operations, Team Member', 9028, '5784DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('8E9002C0-A1D8-4465-B952-817D2948E6E2', 'Dynamics 365 Business Central, Premium User', 9022, '3884DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('46764787-E039-4AB0-8F00-820FC2D89BF9', 'Test Plan - Fin and Ops, External Accountant', 9027, 'C184DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('2EC8B6CA-AB13-4753-A479-8C2FFE4C323B', 'Dynamics 365 Business Central, ISV User', 9022, '4C84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('920656A2-7DD8-4C83-97B6-A356414DBD36', 'Finance and Operations', 9022, '2484DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('996DEF3D-B36C-4153-8607-A6FD3C01B89F', 'Project Madeira Infrastructure Base Application', 9022, 'A684DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('5D60EA51-0053-458F-80A8-B6F426A1A0C1', 'Dynamics 365 - Accountant Hub', 1151, '6684DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('100E1865-35D4-4463-AAFF-D38EEE3A1116', 'Finance and Operations, Device', 9022, 'AC84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('FD1441B8-116B-4FA7-836E-D7956700E0FA', 'Dynamics 365 Business Central, Team Member ISV', 9028, '5E84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('170991D7-B98E-41C5-83D4-DB2052E1795F', 'Finance and Operations, External Accountant', 9027, '1A84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('4C52D56D-5121-425A-91A5-DD0DE136CA17', 'Dynamics 365 Business Central, Premium ISV User', 9022, '4284DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('A98D0C4A-A52F-4771-A609-E20366102D2A', 'Dynamics 365 Business Central Device - Embedded', 9022, 'B684DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('312BDEEE-8FBD-496E-B529-EB985F305FCF', 'Test - Fin and Ops, Team Members Business Edition', 9028, 'DE84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('3F2AFEED-6FB5-4BF9-998F-F2912133AEAD', 'Finance and Operations for IWs', 9022, '0184DDCA-27B8-E911-BB26-000D3A2B005C');
    end;

    local procedure CreatePlan(PlanGuid: Guid; PlanName: Text[50]; RoleCenterId: Integer; SystemId: Guid)
    var
        Plan: Record Plan;
    begin
        if Plan.Get(PlanGuid) then
            exit;

        Plan.Init();
        Plan."Plan ID" := PlanGuid;
        Plan.Name := PlanName;
        Plan."Role Center ID" := RoleCenterId;
        Plan.SystemId := SystemId;
        Plan.Insert(true);
    end;
}