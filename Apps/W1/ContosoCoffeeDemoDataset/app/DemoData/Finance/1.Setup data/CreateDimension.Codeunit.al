// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 5463 "Create Dimension"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoDimension: Codeunit "Contoso Dimension";
    begin
        ContosoDimension.InsertDimension(AreaDimension(), AreaLbl);
        ContosoDimension.InsertDimension(BusinessGroupDimension(), BusinessGroupLbl);
        ContosoDimension.InsertDimension(CustomerGroupDimension(), CustomerGroupLbl);
        ContosoDimension.InsertDimension(DepartmentDimension(), DepartmentLbl);
        ContosoDimension.InsertDimension(SalesCampaignDimension(), SalesCampaignLbl);
        UpdateDimensionOnGeneralLedgerSetup()
    end;

    local procedure UpdateDimensionOnGeneralLedgerSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();

        GeneralLedgerSetup.Validate("Global Dimension 1 Code", DepartmentDimension());
        GeneralLedgerSetup.Validate("Global Dimension 2 Code", CustomerGroupDimension());
        GeneralLedgerSetup.Modify(true);
    end;

    procedure AreaDimension(): Code[20]
    begin
        exit(AreaTok);
    end;

    procedure BusinessGroupDimension(): Code[20]
    begin
        exit(BusinessGroupTok);
    end;

    procedure CustomerGroupDimension(): Code[20]
    begin
        exit(CustomerGroupTok);
    end;

    procedure DepartmentDimension(): Code[20]
    begin
        exit(DepartmentTok);
    end;

    procedure SalesCampaignDimension(): Code[20]
    begin
        exit(SalesCampaignTok);
    end;

    var
        AreaTok: Label 'AREA', MaxLength = 20;
        AreaLbl: Label 'Area', MaxLength = 100;
        BusinessGroupTok: Label 'BUSINESSGROUP', MaxLength = 20;
        BusinessGroupLbl: Label 'Business Group', MaxLength = 100;
        CustomerGroupTok: Label 'CUSTOMERGROUP', MaxLength = 20;
        CustomerGroupLbl: Label 'Customer Group', MaxLength = 100;
        DepartmentTok: Label 'DEPARTMENT', MaxLength = 20;
        DepartmentLbl: Label 'Department', MaxLength = 100;
        SalesCampaignTok: Label 'SALESCAMPAIGN', MaxLength = 20;
        SalesCampaignLbl: Label 'Sales campaign', MaxLength = 100;
}
