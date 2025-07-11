// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

using System.Utilities;

report 11758 "Unreliable Payer Get All CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Get All Unreliable Payers';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = sorting("No.") where(Blocked = filter(<> All));
            RequestFilterFields = "No.", "Vendor Posting Group", "Country/Region Code", "Tax Area Code";

            trigger OnAfterGetRecord()
            begin
                if IsUnreliablePayerCheckPossibleCZL() then
                    if UnreliablePayerMgtCZL.AddVATRegNoToList("VAT Registration No.") then
                        VendCount += 1;
            end;

            trigger OnPostDataItem()
            begin
                if VendCount > 0 then
                    if ConfirmManagement.GetResponseOrDefault(StrSubstNo(UpdatedStatusQst, VendCount), true) then
                        UnreliablePayerMgtCZL.ImportUnrPayerStatus(true);
            end;

            trigger OnPreDataItem()
            begin
                if UpdateOnlyUnreliablePayers then
                    CurrReport.Break();
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(UpdateOnlyUnreliablePayersCZL; UpdateOnlyUnreliablePayers)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Update Only Unreliable Payers';
                        ToolTip = 'Specifies if this batch job has to be only Unreliable Payers actualized.';
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        UnrelPayerServiceSetupCZL.Get();
        UnrelPayerServiceSetupCZL.TestField("Unreliable Payer Web Service");
        UnrelPayerServiceSetupCZL.TestField(Enabled);
        if UpdateOnlyUnreliablePayers then
            UnreliablePayerMgtCZL.ImportUnrPayerList(true);
    end;

    var
        UnrelPayerServiceSetupCZL: Record "Unrel. Payer Service Setup CZL";
        ConfirmManagement: Codeunit "Confirm Management";
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
        VendCount: Integer;
        UpdateOnlyUnreliablePayers: Boolean;
        UpdatedStatusQst: Label 'Really update unreliable status for %1 Vendors?', Comment = '%1 = count';
}
