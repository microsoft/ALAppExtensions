// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1851 "MS - Sales Forecast Parameter"
{
    ReplicateData = false;

    fields
    {
        field(1; "Item No."; Code[20])
        {
        }
        field(2; "Time Series Period Type"; Option)
        {
            OptionMembers = Day,Week,Month,Quarter,Year;
        }
        field(3; "History Start Date"; Date)
        {
        }
        field(4; "Forecast Start Date"; Date)
        {
        }
        field(5; Horizon; Integer)
        {
        }
        field(6; "Last Updated"; DateTime)
        {
        }
    }

    keys
    {
        key(Key1; "Item No.")
        {
        }
    }

    procedure NewRecord(ItemNo: Code[20])
    var
        MSSalesForecastSetup: Record "MS - Sales Forecast Setup";
    begin
        MSSalesForecastSetup.GetSingleInstance();

        Init();
        Validate("Item No.", ItemNo);
        Validate("Time Series Period Type", MSSalesForecastSetup."Period Type");
        Validate("Forecast Start Date", WorkDate());
        Validate(Horizon, MSSalesForecastSetup.Horizon);
        Validate("Last Updated", CreateDateTime(WorkDate(), Time()));
        Insert(true);
    end;
}

