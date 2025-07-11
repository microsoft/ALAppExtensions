#if not CLEAN25
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Telemetry;

codeunit 10053 "IRS 1099 Trans. Error Handler"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        Telemetry: Codeunit Telemetry;

    trigger OnRun()
    var
        IRSFormsSetup: Record "IRS Forms Setup";
    begin
        IRSFormsSetup.InitSetup();
        Clear(IRSFormsSetup."Data Transfer Task ID");
        IRSFormsSetup."Data Transfer Error Message" := CopyStr(GetLastErrorText(), 1, MaxStrLen(IRSFormsSetup."Data Transfer Error Message"));
        IRSFormsSetup.Modify();
        Telemetry.LogMessage('0000MKE', StrSubstNo(FailedTransferDataTxt, GetLastErrorText()), Verbosity::Warning, DataClassification::SystemMetadata);
    end;

    var
        FailedTransferDataTxt: Label 'Transfer data has failed: %1', Comment = '%1 = error message';
}
#endif