// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Finance.GST.Base;

codeunit 19044 "Create IN Tax Acc. Period"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoUtilities: Codeunit "Contoso Utilities";
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
        Year: Integer;
        StaringYear: Integer;
        EndingYear: Integer;
        PeriodStartDate: Date;
        PeriodEndDate: Date;
    begin
        PeriodStartDate := ContosoUtilities.AdjustDate(19010101D);
        PeriodEndDate := ContosoUtilities.AdjustDate(19041201D);
        StaringYear := Date2DMY(PeriodStartDate, 3);
        EndingYear := Date2DMY(PeriodEndDate, 3);

        CreateTaxTypeSetup();

        for Year := StaringYear to EndingYear do begin
            StartDate := DMY2Date(1, 4, Year);
            EndDate := DMY2Date(31, 3, (Year + 1));
            ContosoINTaxSetup.InsertTaxAccountingPeriod('GST', StartDate, EndDate);
            ContosoINTaxSetup.InsertTaxAccountingPeriod('TDS/TCS', StartDate, EndDate);
        end;
        UpdateGSTCreditMemoLockPeriod('GST');
    end;

    local procedure UpdateGSTCreditMemoLockPeriod(TaxTypeCode: Code[20])
    var
        TaxAccountingPeriod: Record "Tax Accounting Period";
        TaxAccountPeriod: Record "Tax Accounting Period";
    begin
        TaxAccountPeriod.SetRange("Tax Type Code", TaxTypeCode);
        if TaxAccountPeriod.FindSet() then
            repeat
                if TaxAccountPeriod.Quarter in ['Q1', 'Q2'] then begin
                    TaxAccountingPeriod.Reset();
                    TaxAccountingPeriod.SetRange("Tax Type Code", TaxTypeCode);
                    TaxAccountingPeriod.SetRange("Financial Year", TaxAccountPeriod."Financial Year");
                    TaxAccountingPeriod.SetRange(Quarter, 'Q2');
                    if TaxAccountingPeriod.FindLast() then begin
                        TaxAccountPeriod."Credit Memo Locking Date" := TaxAccountingPeriod."Ending Date";
                        TaxAccountPeriod.Modify();
                    end;
                end;
                if TaxAccountPeriod.Quarter in ['Q3', 'Q4'] then begin
                    TaxAccountingPeriod.Reset();
                    TaxAccountingPeriod.SetRange("Tax Type Code", TaxTypeCode);
                    TaxAccountingPeriod.SetRange("Financial Year", TaxAccountPeriod."Financial Year");
                    TaxAccountingPeriod.SetRange(Quarter, 'Q4');
                    if TaxAccountingPeriod.FindLast() then begin
                        TaxAccountPeriod."Credit Memo Locking Date" := TaxAccountingPeriod."Ending Date";
                        TaxAccountPeriod.Modify();
                    end;
                end;
            until TaxAccountPeriod.Next() = 0;
    end;


    procedure CreateTaxTypeSetup()
    var
        TCSSetup: Record "TCS Setup";
        TDSSetup: Record "TDS Setup";
        GSTSetup: Record "GST Setup";
    begin
        if TCSSetup.Get() then begin
            TCSSetup."Tax Type" := 'TCS';
            TCSSetup.Modify();
        end else begin
            TCSSetup.Init();
            TCSSetup."Tax Type" := 'TCS';
            TCSSetup.Insert();
        end;

        if TDSSetup.Get() then begin
            TDSSetup."Tax Type" := 'TDS';
            TDSSetup.Modify();
        end else begin
            TDSSetup.Init();
            TDSSetup."Tax Type" := 'TDS';
            TDSSetup.Insert();
        end;

        if GSTSetup.Get() then begin
            GSTSetup."GST Tax Type" := 'GST';
            GSTSetup."Cess Tax Type" := 'GST CESS';
            GSTSetup.Modify();
        end else begin
            GSTSetup.Init();
            GSTSetup."GST Tax Type" := 'GST';
            GSTSetup."Cess Tax Type" := 'GST CESS';
            GSTSetup.Insert();
        end;
    end;

    var
        StartDate: Date;
        EndDate: Date;

}
