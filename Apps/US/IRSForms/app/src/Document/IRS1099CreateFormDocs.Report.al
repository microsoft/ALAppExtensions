// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Vendor;
using System.Telemetry;
using System.Utilities;

report 10035 "IRS 1099 Create Form Docs"
{
    Caption = 'IRS 1099 Create Form Documents';
    ProcessingOnly = true;
    ApplicationArea = BasicUS;

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(Period; PeriodNo)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Period';
                        ToolTip = 'Specifies the period to create a form document for';
                        TableRelation = "IRS Reporting Period";

                        trigger OnValidate()
                        begin
                            FormNo := '';
                        end;
                    }
                    field(Vendor; VendorNo)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Vendor No.';
                        ToolTip = 'Specifies the vendor to create a form document for. If this field is empty then forms will be created for all vendors.';
                        TableRelation = Vendor;
                    }
                    field(Form; FormNo)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Form No.';
                        ToolTip = 'Specifies the form to create a form document for. If this field is empty then forms will be created for all forms.';
                        TableRelation = "IRS 1099 Form"."No.";

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            IRS1099Form: Record "IRS 1099 Form";
                            IRS1099FormsPage: Page "IRS 1099 Forms";
                        begin
                            if PeriodNo = '' then
                                Error(PeriodNotSpecifiedErr);
                            IRS1099Form.SetRange("Period No.", PeriodNo);
                            IRS1099FormsPage.SetTableView(IRS1099Form);
                            IRS1099FormsPage.LookupMode(true);
                            if IRS1099FormsPage.RunModal() = Action::LookupOK then begin
                                IRS1099FormsPage.GetRecord(IRS1099Form);
                                FormNo := IRS1099Form."No.";
                            end;
                        end;

                        trigger OnValidate()
                        var
                            IRS1099Form: Record "IRS 1099 Form";
                        begin
                            if PeriodNo = '' then
                                Error(PeriodNotSpecifiedErr);
                            if FormNo <> '' then
                                IRS1099Form.Get(PeriodNo, FormNo);
                        end;
                    }
                    field(ReplaceControl; Replace)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Replace';
                        ToolTip = 'Specifies whether the newly created forms will replace the existing ones. If this option is not selected then only new forms will be created and the existing ones remain the same.';
                    }
                }
            }
        }
    }

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ReplaceFormsQst: Label 'Do you want to replace the existing 1099 forms with the new ones?';
        PeriodNotSpecifiedErr: Label 'Period is not specified.';
        IRSFormsTok: Label 'IRS Forms', Locked = true;

    protected var
        PeriodNo: Code[20];
        VendorNo: Code[20];
        FormNo: Code[20];
        Replace: Boolean;

    trigger OnPreReport()
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if PeriodNo = '' then
            Error(PeriodNotSpecifiedErr);
        if not Replace then
            exit;

        if not ConfirmManagement.GetResponse(ReplaceFormsQst, false) then
            CurrReport.Break();
    end;

    trigger OnPostReport()
    var
        IRS1099CalcParameters: Record "IRS 1099 Calc. Params";
        IRS1099FormDocument: Codeunit "IRS 1099 Form Document";
    begin
        BuildCalcParams(IRS1099CalcParameters);
        IRS1099FormDocument.CreateFormDocs(IRS1099CalcParameters);
        FeatureTelemetry.LogUptake('0000MJN', IRSFormsTok, Enum::"Feature Uptake Status"::Used);
    end;

    procedure InitializeRequest(NewPeriodNo: Code[20]; NewVendorNo: Code[20]; NewFormNo: Code[20]; NewReplace: Boolean)
    begin
        PeriodNo := NewPeriodNo;
        VendorNo := NewVendorNo;
        FormNo := NewFormNo;
        Replace := NewReplace;
    end;

    local procedure BuildCalcParams(var IRS1099CalcParameters: Record "IRS 1099 Calc. Params")
    begin
        IRS1099CalcParameters."Period No." := PeriodNo;
        IRS1099CalcParameters."Vendor No." := VendorNo;
        IRS1099CalcParameters."Form No." := FormNo;
        IRS1099CalcParameters.Replace := Replace;
        OnAfterBuildCalcParams(IRS1099CalcParameters);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBuildCalcParams(var IRS1099CalcParameters: Record "IRS 1099 Calc. Params")
    begin
    end;
}
