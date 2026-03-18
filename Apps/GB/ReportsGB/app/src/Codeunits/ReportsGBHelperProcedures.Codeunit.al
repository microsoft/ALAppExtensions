// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Bank.Reports;
using Microsoft.CashFlow.Reports;
#if not CLEAN28
using Microsoft.FixedAssets.Reports;
#endif
using Microsoft.Foundation.Reporting;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Reports;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.History;
using Microsoft.Sales.Reminder;
using Microsoft.Sales.Reports;
using System.Environment.Configuration;
using System.Reflection;
codeunit 10592 "Reports GB Helper Procedures"
{
    Access = Internal;

    var
        ReportsGBApplicationAppIdTok: Label '{a4417920-02d4-47fc-b6d2-3bcfdfe1e798}', Locked = true;

    procedure SetDefaultReportLayouts()
    begin
        SetDefaultReportLayout(Report::"Sales Document - Test");
        SetDefaultReportLayout(Report::"Purchase Document - Test");
        SetDefaultReportLayout(Report::Reminder);
        SetDefaultReportLayout(Report::"Bank Account - List");
        SetDefaultReportLayout(Report::"Cash Flow Dimensions - Detail");
        SetDefaultReportLayout(Report::"Finance Charge Memo");
#if not CLEAN28
#pragma warning disable AL0432
        SetDefaultReportLayout(Report::"Fixed Asset - Projected Value");
#pragma warning restore AL0432
#endif
        SetDefaultReportLayout(Report::"Purchase - Quote");
        SetDefaultReportLayout(Report::"Purchase - Receipt");
        SetDefaultReportLayout(Report::"Sales - Shipment");
    end;

    local procedure SetDefaultReportLayout(ReportID: Integer)
    var
        SelectedReportLayoutList: Record "Report Layout List";
    begin
        SelectedReportLayoutList.SetRange("Report ID", ReportID);
        SelectedReportLayoutList.SetRange(Name, 'GBlocalizationLayout');
        SelectedReportLayoutList.SetRange("Application ID", ReportsGBApplicationAppIdTok);
        if SelectedReportLayoutList.FindFirst() then
            SetDefaultReportLayoutSelection(SelectedReportLayoutList);
        SelectedReportLayoutList.Reset();
    end;

    local procedure SetDefaultReportLayoutSelection(SelectedReportLayoutList: Record "Report Layout List")
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomDimensions: Dictionary of [Text, Text];
        EmptyGuid: Guid;
        SelectedCompany: Text[30];
    begin
        SelectedCompany := CopyStr(CompanyName, 1, MaxStrLen(SelectedCompany));
        AddLayoutSelection(SelectedReportLayoutList, EmptyGuid, SelectedCompany);
        if ReportLayoutSelection.get(SelectedReportLayoutList."Report ID", SelectedCompany) then begin
            ReportLayoutSelection.Type := GetReportLayoutSelectionCorrespondingEnum(SelectedReportLayoutList);
            ReportLayoutSelection.Modify(true);
        end else begin
            ReportLayoutSelection."Report ID" := SelectedReportLayoutList."Report ID";
            ReportLayoutSelection."Company Name" := SelectedCompany;
            ReportLayoutSelection."Custom Report Layout Code" := '';
            ReportLayoutSelection.Type := GetReportLayoutSelectionCorrespondingEnum(SelectedReportLayoutList);
            ReportLayoutSelection.Insert(true);
        end;

        InitReportLayoutListDimensions(SelectedReportLayoutList, CustomDimensions);
        AddReportLayoutDimensionsAction('SetDefault', CustomDimensions);
    end;

    local procedure AddLayoutSelection(SelectedReportLayoutList: Record "Report Layout List"; UserId: Guid; SelectedCompany: Text[30]): Boolean
    var
        TenantReportLayoutSelection: Record "Tenant Report Layout Selection";
    begin
        TenantReportLayoutSelection.Init();
        TenantReportLayoutSelection."App ID" := SelectedReportLayoutList."Application ID";
        TenantReportLayoutSelection."Company Name" := SelectedCompany;
        TenantReportLayoutSelection."Layout Name" := SelectedReportLayoutList."Name";
        TenantReportLayoutSelection."Report ID" := SelectedReportLayoutList."Report ID";
        TenantReportLayoutSelection."User ID" := UserId;

        if not TenantReportLayoutSelection.Insert(true) then
            TenantReportLayoutSelection.Modify(true);
    end;

    local procedure GetReportLayoutSelectionCorrespondingEnum(SelectedReportLayoutList: Record "Report Layout List"): Integer
    begin
        case SelectedReportLayoutList."Layout Format" of

            SelectedReportLayoutList."Layout Format"::RDLC:
                exit(0);
            SelectedReportLayoutList."Layout Format"::Word:
                exit(1);
            SelectedReportLayoutList."Layout Format"::Excel:
                exit(3);
            SelectedReportLayoutList."Layout Format"::Custom:
                exit(4);
        end
    end;

    local procedure InitReportLayoutListDimensions(ReportLayoutList: Record "Report Layout List"; var CustomDimensions: Dictionary of [Text, Text])
    begin
        CustomDimensions.Set('ReportId', Format(ReportLayoutList."Report ID"));
        CustomDimensions.Set('LayoutName', ReportLayoutList."Name");
    end;

    local procedure AddReportLayoutDimensionsAction(Action: Text; var CustomDimensions: Dictionary of [Text, Text])
    begin
        CustomDimensions.Add('Action', Action);
    end;
}