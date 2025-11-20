// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;
using System.Integration;

codeunit 47203 "SL Cloud Migration US"
{
    [EventSubscriber(ObjectType::Codeunit, CodeUnit::"Data Migration Mgt.", 'OnAfterMigrationFinished', '', false, false)]
    local procedure OnAfterMigrationFinishedSubscriber(var DataMigrationStatus: Record "Data Migration Status"; WasAborted: Boolean; StartTime: DateTime; Retry: Boolean)
    var
        SLHelperFunctions: Codeunit "SL Helper Functions";
    begin
        if not (DataMigrationStatus."Migration Type" = SLHelperFunctions.GetMigrationTypeTxt()) then
            exit;

        RunPostMigration();
    end;

    procedure RunPostMigration()
    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLPopulateVendor1099Data: Codeunit "SL Populate Vendor 1099 Data";
    begin
        if (SLCompanyAdditionalSettings.GetMigrateCurrent1099YearEnabled()) or (SLCompanyAdditionalSettings.GetMigrateNext1099YearEnabled()) then begin
            SetupIRSFormsFeatureIfNeeded();
            BindSubscription(SLPopulateVendor1099Data);
            SLPopulateVendor1099Data.Run();
            UnbindSubscription(SLPopulateVendor1099Data);
        end;
    end;

    local procedure SetupIRSFormsFeatureIfNeeded()
    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLIRSFormData: Codeunit "SL IRS Form Data";
        SLVendor1099MappingHelpers: Codeunit "SL Vendor 1099 Mapping Helpers";
        ReportingYear: Integer;
        Open1099Year: Boolean;
    begin
        SLCompanyAdditionalSettings.GetSingleInstance();
        if SLCompanyAdditionalSettings.GetMigrateCurrent1099YearEnabled() then begin
            ReportingYear := SLVendor1099MappingHelpers.GetCurrent1099YearFromSLAPSetup();
            Open1099Year := SLVendor1099MappingHelpers.GetCurrent1099YearOpenStatus();
            if ReportingYear <> 0 then
                if Open1099Year then
                    SLIRSFormData.CreateIRSFormsReportingPeriodIfNeeded(ReportingYear);
        end;
        if SLCompanyAdditionalSettings.GetMigrateNext1099YearEnabled() then begin
            ReportingYear := SLVendor1099MappingHelpers.GetNext1099YearFromSLAPSetup();
            Open1099Year := SLVendor1099MappingHelpers.GetNext1099YearOpenStatus();
            if ReportingYear <> 0 then
                if Open1099Year then
                    SLIRSFormData.CreateIRSFormsReportingPeriodIfNeeded(ReportingYear);
        end;
    end;
}