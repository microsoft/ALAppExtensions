// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.Foundation.Period;
using Microsoft.Inventory.Setup;
using System.Integration;

codeunit 47004 "SL Fiscal Periods"
{
    Access = Internal;

    internal procedure MoveStagingData()
    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLFiscalPeriods: Record "SL Fiscal Periods";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        InitialYear: Integer;
    begin
        InitialYear := SLCompanyAdditionalSettings.GetInitialYear();
        if InitialYear > 0 then
            SLFiscalPeriods.SetFilter(Year1, '>= %1', InitialYear);

        if not SLFiscalPeriods.FindSet() then
            exit;

        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLFiscalPeriods.PeriodID));

        repeat
            CreateFiscalPeriods(SLFiscalPeriods);
        until SLFiscalPeriods.Next() = 0;

    end;

    internal procedure CreateFiscalPeriods(SLFiscalPeriods: Record "SL Fiscal Periods")
    var
        AccountingPeriod: Record "Accounting Period";
        InventorySetup: Record "Inventory Setup";
        StartingDate: Date;
    begin
        Clear(AccountingPeriod);
        StartingDate := SLFiscalPeriods.PeriodDT;

        if not AccountingPeriod.Get(StartingDate) then begin
            case SLFiscalPeriods.PeriodID of
                1:
                    begin
                        AccountingPeriod.Validate("Starting Date", StartingDate);
                        AccountingPeriod.Validate(Name, Format(SLFiscalPeriods.Year1) + '-01');
                        AccountingPeriod."New Fiscal Year" := true;
                        InventorySetup.Get();
                        AccountingPeriod."Average Cost Calc. Type" := InventorySetup."Average Cost Calc. Type";
                        AccountingPeriod."Average Cost Period" := InventorySetup."Average Cost Period";
                    end;
                2:
                    begin
                        AccountingPeriod.Validate("Starting Date", StartingDate);
                        AccountingPeriod.Validate(Name, Format(SLFiscalPeriods.Year1) + '-02');
                    end;
                3:
                    begin
                        AccountingPeriod.Validate("Starting Date", StartingDate);
                        AccountingPeriod.Validate(Name, Format(SLFiscalPeriods.Year1) + '-03');
                    end;
                4:
                    begin
                        AccountingPeriod.Validate("Starting Date", StartingDate);
                        AccountingPeriod.Validate(Name, Format(SLFiscalPeriods.Year1) + '-04');
                    end;
                5:
                    begin
                        AccountingPeriod.Validate("Starting Date", StartingDate);
                        AccountingPeriod.Validate(Name, Format(SLFiscalPeriods.Year1) + '-05');
                    end;
                6:
                    begin
                        AccountingPeriod.Validate("Starting Date", StartingDate);
                        AccountingPeriod.Validate(Name, Format(SLFiscalPeriods.Year1) + '-06');
                    end;
                7:
                    begin
                        AccountingPeriod.Validate("Starting Date", StartingDate);
                        AccountingPeriod.Validate(Name, Format(SLFiscalPeriods.Year1) + '-07');
                    end;
                8:
                    begin
                        AccountingPeriod.Validate("Starting Date", StartingDate);
                        AccountingPeriod.Validate(Name, Format(SLFiscalPeriods.Year1) + '-08');
                    end;
                9:
                    begin
                        AccountingPeriod.Validate("Starting Date", StartingDate);
                        AccountingPeriod.Validate(Name, Format(SLFiscalPeriods.Year1) + '-09');
                    end;
                10:
                    begin
                        AccountingPeriod.Validate("Starting Date", StartingDate);
                        AccountingPeriod.Validate(Name, Format(SLFiscalPeriods.Year1) + '-10');
                    end;
                11:
                    begin
                        AccountingPeriod.Validate("Starting Date", StartingDate);
                        AccountingPeriod.Validate(Name, Format(SLFiscalPeriods.Year1) + '-11');
                    end;
                12:
                    begin
                        AccountingPeriod.Validate("Starting Date", StartingDate);
                        AccountingPeriod.Validate(Name, Format(SLFiscalPeriods.Year1) + '-12');
                    end;
            end;
            AccountingPeriod.Insert();
        end;
    end;
}