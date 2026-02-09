// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Finance.VAT.Reporting;
using Microsoft.Foundation.Reporting;
using System.Environment.Configuration;
using System.Reflection;

codeunit 10561 "GovTalk Helper Procedures"
{
    Access = Internal;

    var
        GovTalkApplicationAppIdTok: Label '{80672d74-d90a-4eb0-8f90-5b9bcea58dca}', Locked = true;

    procedure TransferRecords(SourceTableId: Integer; TargetTableId: Integer)
    var
        SourceField: Record Field;
        SourceRecRef: RecordRef;
        TargetRecRef: RecordRef;
        TargetFieldRef: FieldRef;
        SourceFieldRef: FieldRef;
        SourceFieldRefNo: Integer;
    begin
        SourceRecRef.Open(SourceTableId, false);
        TargetRecRef.Open(TargetTableId, false);

        if SourceRecRef.IsEmpty() then
            exit;

        if SourceRecRef.FindSet() then
            repeat
                Clear(SourceField);
                SourceField.SetRange(TableNo, SourceTableId);
                SourceField.SetRange(Class, SourceField.Class::Normal);
                SourceField.SetRange(Enabled, true);
                if SourceField.Findset() then
                    repeat
                        SourceFieldRefNo := SourceField."No.";
                        SourceFieldRef := SourceRecRef.Field(SourceFieldRefNo);
                        TargetFieldRef := TargetRecRef.Field(SourceFieldRefNo);
                        TargetFieldRef.VALUE := SourceFieldRef.VALUE;
                    until SourceField.Next() = 0;
                TargetRecRef.Insert();
            until SourceRecRef.Next() = 0;
        SourceRecRef.Close();
        TargetRecRef.Close();
    end;

    procedure UpgradeVATReportHeaderStatus()
    var
        VATReportHeader: Record "VAT Report Header";
    begin
        if VATReportHeader.FindSet() then
            repeat
                if VATReportHeader.Status.AsInteger() = 7 then
                    VATReportHeader.Status := VATReportHeader.Status::"Part. Accepted";
                VATReportHeader.Modify();
            until VATReportHeader.Next() = 0;
    end;

    procedure TransferFields(TableId: Integer; SourceFieldNo: Integer; TargetFieldNo: Integer)
    var
        RecRef: RecordRef;
        TargetFieldRef: FieldRef;
        SourceFieldRef: FieldRef;
    begin
        RecRef.Open(TableId, false);
        SourceFieldRef := RecRef.Field(SourceFieldNo);
        SourceFieldRef.SetFilter('<>%1', '');

        if RecRef.FindSet() then
            repeat
                TargetFieldRef := RecRef.Field(TargetFieldNo);
                TargetFieldRef.VALUE := SourceFieldRef.VALUE;
                RecRef.Modify(false);
            until RecRef.Next() = 0;
    end;

    procedure SetDefaultReportLayouts()
    begin
        SetDefaultReportLayout(Report::"EC Sales List");
    end;

    local procedure SetDefaultReportLayout(ReportID: Integer)
    var
        SelectedReportLayoutList: Record "Report Layout List";
    begin
        SelectedReportLayoutList.SetRange("Report ID", ReportID);
        SelectedReportLayoutList.SetRange(Name, 'GBlocalizationLayout');
        SelectedReportLayoutList.SetRange("Application ID", GovTalkApplicationAppIdTok);
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