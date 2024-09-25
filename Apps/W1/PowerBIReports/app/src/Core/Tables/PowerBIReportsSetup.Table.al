namespace Microsoft.PowerBIReports;

using System.DateTime;

table 36951 "PowerBI Reports Setup"
{
    Access = Internal;
    Caption = 'Setup for Power BI Connector';

    fields
    {
        field(1; "Entry No."; Code[10])
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "First Month of Fiscal Calendar"; Integer)
        {
            Caption = 'First Month of Fiscal Calendar';
            DataClassification = CustomerContent;
            InitValue = 7;
            // Used by both Fiscal Calendar and Fiscal Weekly Calendar
        }
        field(3; "First Day Of Week"; Option)
        {
            Caption = 'First Day Of Week';
            OptionMembers = Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday;
            OptionCaption = 'Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday';
            DataClassification = CustomerContent;
            InitValue = 1;
            // Defines the first day of a week and defines when a week starts in a weekly calendar. US calendars typically use 0 (Sunday), whereas European calendars use 1 (Monday).
        }
        field(4; "ISO Country Holidays"; Option)
        {
            Caption = 'Iso Country Holidays';
            OptionMembers = AT,AU,BE,CA,DE,ES,FR,GB,IT,NL,NO,PT,SE,US;
            OptionCaption = 'AT,AU,BE,CA,DE,ES,FR,GB,IT,NL,NO,PT,SE,US';
            DataClassification = CustomerContent;
            // Use only supported ISO countries or "" for no holidays
        }
        field(5; "Weekly Type"; Option)
        {
            Caption = 'Weekly Type';
            OptionMembers = Last,Nearest;
            OptionCaption = 'Last,Nearest';
            InitValue = "Last";
            DataClassification = CustomerContent;

            // Determines the end of the year definition for fiscal weekly calendar (FW). Reference for Last/Nearest definition on Wikipedia.
            // Last: for last weekday of the month at fiscal year end
            // Nearest: for last weekday nearest the end of month

            // For the ISO calendar use:
            // FiscalCalendarFirstMonth = 1 (ISO always starts in January)
            // FirstDayOfWeek = 1 (ISO always starts on Monday)
            // WeeklyType = “Nearest” (ISO uses the nearest week type algorithm)

            // For US with last Saturday of the month at fiscal year end
            // FirstDayOfWeek = 0 (US weeks start on Sunday)
            // WeeklyType = “Last”

            // For US with last Saturday nearest the end of month
            // FirstDayOfWeek = 0 (US weeks start on Sunday)
            // WeeklyType = “Nearest”
        }
        field(6; "Quarter Week Type"; Option)
        {
            Caption = 'Quarter Week Type';
            OptionMembers = Type445,Type454,Type544;
            OptionCaption = '445,454,544';
            InitValue = Type445;
            DataClassification = CustomerContent;
            // Defines the number of weeks per period in each quarter. Quarters which always count 13 weeks in the Fiscal weekly calendar (FW).
        }
        field(7; "Calendar Range"; Option)
        {
            Caption = 'Calendar Range';
            OptionMembers = Calendar,FiscalGregorian,FiscalWeekly;
            OptionCaption = 'Standard,Fiscal Calendar,Weekly';
            InitValue = FiscalGregorian;
            DataClassification = CustomerContent;
            // Defines to which type of calendar the year boundaries are applied during table’s generation. 
            // Using FiscalWeekly the first and last day of the year might not correspond to a first and last day of a month, respectively.
        }
        field(8; "Calendar Gregorian Prefix"; Text[10])
        {
            Caption = 'Calendar Gregorian Prefix';
            InitValue = '';
            DataClassification = CustomerContent;
            // Prefix used in columns of solar Gregorian calendar.
        }
        field(9; "Fiscal Gregorian Prefix"; Text[10])
        {
            Caption = 'Fiscal Gregorian Prefix';
            InitValue = 'F';
            DataClassification = CustomerContent;
            // Prefix used in columns of fiscal Gregorian calendar.  
        }
        field(10; "Fiscal Weekly Prefix"; Text[10])
        {
            Caption = 'Fiscal Weekly Prefix';
            InitValue = "FW";
            DataClassification = CustomerContent;
            // Prefix used in columns of fiscal Weekly calendar.  
        }
        field(12; "Use Custom Fiscal Periods"; Boolean)
        {
            Caption = 'Use Custom Fiscal Periods';
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(13; "Ignore Weekly Fiscal Periods"; Boolean)
        {
            Caption = 'Ignore Weekly Fiscal Periods';
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(15; "Date Table Starting Date"; Date)
        {
            Caption = 'Date Table Starting Date';
            DataClassification = CustomerContent;
        }
        field(16; "Date Table Ending Date"; Date)
        {
            Caption = 'Date Table Ending Date';
            DataClassification = CustomerContent;
        }
        field(17; "Last Dim. Set Entry Date-Time"; DateTime)
        {
            Caption = 'Last Dim. Set Entry Date-Time';
            DataClassification = CustomerContent;
        }
        field(18; "Time Zone"; Text[180])
        {
            Caption = 'Time Zone';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
        }
    }


    procedure GetTimeZoneDisplayName(): Text[250]
    var
        TimeZoneSelection: Codeunit "Time Zone Selection";
    begin
        if "Time Zone" = '' then
            exit('');
        exit(TimeZoneSelection.GetTimeZoneDisplayName("Time Zone"));
    end;
}

