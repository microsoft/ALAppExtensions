// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 684 "Date-Time Dialog"
{
    Extensible = false;
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field(Date; DateValue)
            {
                ApplicationArea = All;
                Caption = 'Date';

                trigger OnValidate()
                begin
                    if TimeValue = 0T then
                        TimeValue := 000000T;
                end;
            }
            field(Time; TimeValue)
            {
                ApplicationArea = All;
                Caption = 'Time';
            }
        }
    }

    actions
    {
    }

    var
        DateValue: Date;
        TimeValue: Time;

    procedure SetDateTime(DateTime: DateTime)
    begin
        // Setter method to initialize the Date and Time fields on the page

        DateValue := DT2Date(DateTime);
        TimeValue := DT2Time(DateTime);
    end;

    procedure GetDateTime(): DateTime
    begin
        // Getter method for the entered datatime value

        exit(CreateDateTime(DateValue, TimeValue));
    end;
}

